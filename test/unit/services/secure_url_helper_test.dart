import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/utilites/secure_url_helper.dart';

void main() {
  group('stripTokenFromUri', () {
    test('should remove token and tokentype params', () {
      final uri = Uri.parse(
          'https://example.com/page?token=secret&tokentype=descope&other=keep');
      final stripped = stripTokenFromUri(uri);

      expect(stripped.queryParameters.containsKey('token'), false);
      expect(stripped.queryParameters.containsKey('tokentype'), false);
      expect(stripped.queryParameters['other'], 'keep');
    });

    test('should return same URI when no token param exists', () {
      final uri = Uri.parse('https://example.com/page?foo=bar');
      final stripped = stripTokenFromUri(uri);

      expect(stripped.toString(), uri.toString());
    });

    test('should strip all params when only token params exist', () {
      final uri = Uri.parse(
          'https://example.com/page?token=secret&tokentype=jwt');
      final stripped = stripTokenFromUri(uri);
      expect(stripped.queryParameters.containsKey('token'), false);
      expect(stripped.queryParameters.containsKey('tokentype'), false);
      expect(stripped.toString(), 'https://example.com/page');
    });

    test('should handle URI with no query params', () {
      final uri = Uri.parse('https://example.com/page');
      final stripped = stripTokenFromUri(uri);

      expect(stripped.toString(), 'https://example.com/page');
    });
  });

  group('stripTokenFromUrl', () {
    test('should return clean URL string', () {
      final result = stripTokenFromUrl(
          'https://example.com/page?token=secret&other=keep');

      expect(result, contains('other=keep'));
      expect(result, isNot(contains('token=secret')));
    });

    test('should handle URL without token', () {
      final result = stripTokenFromUrl('https://example.com/path');
      expect(result, 'https://example.com/path');
    });
  });
}
