// Web-only helper that provides AES-GCM-256 encryption backed by the browser's
// WebCrypto API.  The encryption key is a non-extractable CryptoKey stored in
// IndexedDB — JavaScript cannot read its raw bytes, so an attacker who dumps
// localStorage still cannot decrypt values offline.
//
// This file is only imported from `platform_secure_storage_web.dart` which is
// guarded behind a `dart.library.js_interop` conditional import.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// AES-GCM-256 encrypt / decrypt helper using the browser WebCrypto API.
///
/// The encryption key is a **non-extractable** [web.CryptoKey] persisted in
/// IndexedDB so that it survives page reloads and is shared across tabs.
class WebCryptoHelper {
  WebCryptoHelper._();

  // ── IndexedDB constants ──────────────────────────────────────────────
  static const _dbName = 'optmsg_keystore';
  static const _storeName = 'keys';
  static const _keyId = 'aes-gcm-master';
  static const _dbVersion = 1;

  // ── AES-GCM constants ───────────────────────────────────────────────
  static const _ivLength = 12; // 96-bit IV recommended for AES-GCM

  // ── In-memory cache ─────────────────────────────────────────────────
  static web.CryptoKey? _cachedKey;

  /// Serialises concurrent [getOrCreateKey] calls so only one key-generation
  /// or IDB-load is in flight at a time.  Without this, two concurrent callers
  /// can both miss [_cachedKey], both generate *different* keys, and the second
  /// write overwrites the first — making data encrypted with the first key
  /// permanently unreadable.
  static Completer<web.CryptoKey>? _keyCompleter;

  // ── Public API ──────────────────────────────────────────────────────

  /// Returns `true` when the page is served over HTTPS (or localhost).
  /// WebCrypto's `subtle` is only available in a secure context.
  static bool get isSecureContext => web.window.isSecureContext;

  /// Retrieve the existing AES-GCM-256 key from IndexedDB, or generate a
  /// new one and persist it.  The key is cached in memory for the lifetime
  /// of the page so that subsequent calls are synchronous.
  static Future<web.CryptoKey> getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    // If another call is already loading / generating the key, wait for it.
    if (_keyCompleter != null) return _keyCompleter!.future;

    _keyCompleter = Completer<web.CryptoKey>();
    try {
      // Try loading from IndexedDB first.
      final existing = await _loadKeyFromIdb();
      if (existing != null) {
        _cachedKey = existing;
        _keyCompleter!.complete(existing);
        return existing;
      }

      // Generate a brand-new non-extractable key.
      final algorithm = _aesKeyGenParams();
      final keyUsages = <JSString>['encrypt'.toJS, 'decrypt'.toJS].toJS;

      final result = await web.window.crypto.subtle
          .generateKey(algorithm, false /* extractable */, keyUsages)
          .toDart;
      final key = result! as web.CryptoKey;

      // Persist to IndexedDB so other tabs (and future page loads) can use it.
      await _saveKeyToIdb(key);
      _cachedKey = key;
      _keyCompleter!.complete(key);
      return key;
    } catch (e) {
      _keyCompleter!.completeError(e);
      rethrow;
    } finally {
      _keyCompleter = null;
    }
  }

  /// Encrypt [plaintext] with AES-GCM-256 using [key].
  ///
  /// Returns a base-64 string whose binary layout is:
  /// ```
  /// [12 bytes IV][N bytes ciphertext + 16 bytes auth-tag]
  /// ```
  static Future<String> encrypt(String plaintext, web.CryptoKey key) async {
    final iv = Uint8List(_ivLength);
    web.window.crypto.getRandomValues(iv.toJS);

    final data = utf8.encode(plaintext);
    final algorithm = _aesGcmParams(iv);

    final encrypted = await web.window.crypto.subtle
        .encrypt(algorithm, key, data.buffer.toJS)
        .toDart;
    final cipherBytes = (encrypted! as JSArrayBuffer).toDart.asUint8List();

    // Prepend IV so we can recover it during decryption.
    final combined = Uint8List(_ivLength + cipherBytes.length);
    combined.setAll(0, iv);
    combined.setAll(_ivLength, cipherBytes);

    return base64Encode(combined);
  }

  /// Decrypt a base-64 string previously produced by [encrypt].
  ///
  /// Throws on tampered / corrupted data (AES-GCM authentication failure).
  static Future<String> decrypt(String encoded, web.CryptoKey key) async {
    final combined = base64Decode(encoded);
    if (combined.length <= _ivLength) {
      throw const FormatException('Encrypted payload too short');
    }

    final iv = Uint8List.sublistView(combined, 0, _ivLength);
    final ciphertext = Uint8List.sublistView(combined, _ivLength);
    final algorithm = _aesGcmParams(iv);

    // W-4: Use ciphertext.toJS (Uint8Array) NOT ciphertext.buffer.toJS
    // (ArrayBuffer). A Uint8List.sublistView carries a byteOffset into its
    // parent buffer; .buffer.toJS ignores that offset and passes the full
    // parent [(IV bytes)(ciphertext)], causing AES-GCM decryption to fail
    // every time.  .toJS produces a JS Uint8Array that carries the correct
    // byteOffset/byteLength so WebCrypto reads only the ciphertext.
    final decrypted = await web.window.crypto.subtle
        .decrypt(algorithm, key, ciphertext.toJS)
        .toDart;
    final plainBytes = (decrypted! as JSArrayBuffer).toDart.asUint8List();

    return utf8.decode(plainBytes);
  }

  // ── Private helpers ─────────────────────────────────────────────────

  /// Construct the `{name: 'AES-GCM', length: 256}` algorithm identifier
  /// expected by `generateKey`.
  static JSObject _aesKeyGenParams() {
    return {'name': 'AES-GCM', 'length': 256}.jsify() as JSObject;
  }

  /// Construct the `{name: 'AES-GCM', iv: Uint8Array}` algorithm identifier
  /// expected by `encrypt` / `decrypt`.
  static JSObject _aesGcmParams(Uint8List iv) {
    return {'name': 'AES-GCM', 'iv': iv.toJS}.jsify() as JSObject;
  }

  // ── IndexedDB persistence ───────────────────────────────────────────

  static Future<web.CryptoKey?> _loadKeyFromIdb() async {
    final db = await _openDb();
    try {
      final tx = db.transaction(_storeName.toJS, 'readonly');
      final store = tx.objectStore(_storeName);
      final request = store.get(_keyId.toJS);

      final result = await _idbRequestToFuture<JSAny?>(request);
      if (result == null || result.isUndefinedOrNull) return null;
      return result as web.CryptoKey;
    } finally {
      db.close();
    }
  }

  static Future<void> _saveKeyToIdb(web.CryptoKey key) async {
    final db = await _openDb();
    try {
      final tx = db.transaction(_storeName.toJS, 'readwrite');
      final store = tx.objectStore(_storeName);
      store.put(key, _keyId.toJS);

      // Wait for the transaction to complete.
      await _idbTransactionComplete(tx);
    } finally {
      db.close();
    }
  }

  /// Open (or create) the IndexedDB database that holds the encryption key.
  static Future<web.IDBDatabase> _openDb() {
    final completer = Completer<web.IDBDatabase>();
    final request = web.window.indexedDB.open(_dbName, _dbVersion);

    request.onupgradeneeded = (web.Event event) {
      final db = (event.target as web.IDBRequest).result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(_storeName)) {
        db.createObjectStore(_storeName);
      }
    }.toJS;

    request.onsuccess = (web.Event event) {
      completer.complete(
        (event.target as web.IDBRequest).result as web.IDBDatabase,
      );
    }.toJS;

    request.onerror = (web.Event event) {
      completer.completeError(
        StateError('Failed to open IndexedDB "$_dbName"'),
      );
    }.toJS;

    return completer.future;
  }

  /// Convert an [web.IDBRequest] into a Dart [Future].
  static Future<T> _idbRequestToFuture<T>(web.IDBRequest request) {
    final completer = Completer<T>();

    request.onsuccess = (web.Event _) {
      // ignore: invalid_runtime_check_with_js_interop_types
      completer.complete(request.result as T);
    }.toJS;

    request.onerror = (web.Event _) {
      completer.completeError(
        StateError('IndexedDB request failed: ${request.error?.message}'),
      );
    }.toJS;

    return completer.future;
  }

  /// Wait for an [web.IDBTransaction] to fire its `complete` event.
  static Future<void> _idbTransactionComplete(web.IDBTransaction tx) {
    final completer = Completer<void>();

    tx.oncomplete = (web.Event _) {
      completer.complete();
    }.toJS;

    tx.onerror = (web.Event _) {
      completer.completeError(
        StateError('IndexedDB transaction failed: ${tx.error?.message}'),
      );
    }.toJS;

    tx.onabort = (web.Event _) {
      completer.completeError(StateError('IndexedDB transaction aborted'));
    }.toJS;

    return completer.future;
  }
}
