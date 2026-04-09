// Default (mobile) implementation — delegates to FlutterSecureStorage.
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'platform_secure_storage.dart';

PlatformSecureStorage createPlatformSecureStorageImpl() =>
    _MobileSecureStorage();

class _MobileSecureStorage implements PlatformSecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// ST-5: Maximum retry attempts for iOS Keychain `-25308` errors.
  static const _maxAttempts = 3;

  @override
  Future<void> write({required String key, required String value}) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        await _storage.write(key: key, value: value);
        return;
      } on PlatformException catch (e) {
        if (e.code == '-25308' && attempt < _maxAttempts - 1) {
          // iOS Keychain locked (cold start before first unlock).
          // Retry with increasing backoff: 200ms, 400ms.
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
          continue;
        }
        rethrow;
      }
    }
  }

  @override
  Future<String?> read({required String key}) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        return await _storage.read(key: key);
      } on PlatformException catch (e) {
        if (e.code == '-25308' && attempt < _maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
          continue;
        }
        rethrow;
      }
    }
    return null;
  }

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
