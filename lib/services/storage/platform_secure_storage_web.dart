// Web implementation — uses localStorage so that data persists across tabs
// and page refreshes.  The Descope SDK itself stores sessions in shared
// browser storage (localStorage / IndexedDB), so userData must also be shared;
// otherwise opening a second tab sees null userData and clears the Descope
// session for ALL tabs (ST-4).
//
// All values are AES-GCM-256 encrypted via the browser's WebCrypto API before
// being written to localStorage.  The encryption key is a non-extractable
// CryptoKey stored in IndexedDB — JavaScript cannot read its raw bytes, so a
// localStorage dump cannot be decrypted offline.
//
// Legacy (plaintext) keys prefixed `optmsg_secure_` are transparently migrated
// to the encrypted prefix `optmsg_enc_` on first read.
import 'package:web/web.dart' as web;

import 'platform_secure_storage.dart';
import 'web_crypto_helper.dart';

PlatformSecureStorage createPlatformSecureStorageImpl() => _WebSecureStorage();

class _WebSecureStorage implements PlatformSecureStorage {
  /// Encrypted key prefix (new format).
  static const _encPrefix = 'optmsg_enc_';

  /// Legacy plaintext key prefix (pre-encryption).
  static const _legacyPrefix = 'optmsg_secure_';

  /// Whether encryption is available.  WebCrypto requires a secure context
  /// (HTTPS or localhost).  When unavailable we fall back to plaintext storage
  /// with the legacy prefix and log a warning.
  static final bool _canEncrypt = WebCryptoHelper.isSecureContext;

  @override
  Future<void> write({required String key, required String value}) async {
    if (!_canEncrypt) {
      // Insecure context fallback — store plaintext under the legacy prefix.
      web.window.localStorage.setItem('$_legacyPrefix$key', value);
      return;
    }

    try {
      final cryptoKey = await WebCryptoHelper.getOrCreateKey();
      final encrypted = await WebCryptoHelper.encrypt(value, cryptoKey);
      web.window.localStorage.setItem('$_encPrefix$key', encrypted);

      // Clean up any legacy plaintext entry for this key.
      web.window.localStorage.removeItem('$_legacyPrefix$key');
    } catch (_) {
      // W-5: If encryption fails (e.g. IndexedDB blocked in private browsing),
      // remove the stale encrypted entry FIRST so that read() can reach the
      // plaintext fallback.  Without this, read() finds optmsg_enc_<key>,
      // fails decryption, and returns null — never reaching the legacy prefix.
      web.window.localStorage.removeItem('$_encPrefix$key');
      web.window.localStorage.setItem('$_legacyPrefix$key', value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    // 1. Try encrypted value first.
    final encValue = web.window.localStorage.getItem('$_encPrefix$key');
    if (encValue != null) {
      try {
        final cryptoKey = await WebCryptoHelper.getOrCreateKey();
        return await WebCryptoHelper.decrypt(encValue, cryptoKey);
      } catch (e) {
        // W-6: Do NOT return null here — fall through to the legacy plaintext
        // check below.  Returning null immediately meant that data stored as
        // plaintext fallback (W-5 path) was never recovered after a
        // decryption failure. The encrypted entry is preserved so it can be
        // retried on the next read (e.g. after IndexedDB becomes available).
        // ignore: avoid_print
        print(
          '[WebSecureStorage] Decryption failed for key "$key": $e '
          '— falling through to legacy plaintext check',
        );
      }
    }

    // 2. Check for legacy plaintext value and migrate it.
    final legacyValue = web.window.localStorage.getItem('$_legacyPrefix$key');
    if (legacyValue != null && _canEncrypt) {
      try {
        // Migrate: encrypt and store under new prefix, delete legacy.
        final cryptoKey = await WebCryptoHelper.getOrCreateKey();
        final encrypted = await WebCryptoHelper.encrypt(legacyValue, cryptoKey);
        web.window.localStorage.setItem('$_encPrefix$key', encrypted);
        web.window.localStorage.removeItem('$_legacyPrefix$key');
      } catch (_) {
        // Migration failed — leave legacy value in place for now.
      }
      return legacyValue;
    }

    return legacyValue;
  }

  @override
  Future<void> delete({required String key}) async {
    // Remove both encrypted and legacy entries.
    web.window.localStorage.removeItem('$_encPrefix$key');
    web.window.localStorage.removeItem('$_legacyPrefix$key');
  }

  @override
  Future<void> deleteAll() async {
    final toRemove = <String>[];
    for (var i = 0; i < web.window.localStorage.length; i++) {
      final k = web.window.localStorage.key(i);
      if (k != null &&
          (k.startsWith(_encPrefix) || k.startsWith(_legacyPrefix))) {
        toRemove.add(k);
      }
    }
    for (final k in toRemove) {
      web.window.localStorage.removeItem(k);
    }
  }
}
