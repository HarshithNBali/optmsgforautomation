/// Platform-conditional secure storage.
///
/// On mobile (iOS/Android) this delegates to [FlutterSecureStorage] which uses
/// Keychain and EncryptedSharedPreferences respectively.
///
/// On web this uses [localStorage] with AES-GCM-256 encryption via the
/// browser's WebCrypto API.  Values are encrypted before writing and decrypted
/// on read; the non-extractable encryption key is stored in IndexedDB.
/// localStorage is used (rather than sessionStorage) so that data is shared
/// across tabs — required for Descope SDK cross-tab session compatibility.
library;

import 'platform_secure_storage_stub.dart'
    if (dart.library.js_interop) 'platform_secure_storage_web.dart';

/// Factory that returns the platform-appropriate implementation.
///
/// Usage:
/// ```dart
/// final storage = createPlatformSecureStorage();
/// await storage.write(key: 'k', value: 'v');
/// ```
PlatformSecureStorage createPlatformSecureStorage() =>
    createPlatformSecureStorageImpl();

/// Minimal interface mirroring the subset of [FlutterSecureStorage] that
/// [SecureStorageService] actually uses.
abstract class PlatformSecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}
