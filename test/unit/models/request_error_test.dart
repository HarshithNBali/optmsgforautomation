import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/base_response/request_error.dart';

void main() {
  group('RequestResponse', () {
    test('should hold data without error', () {
      final response = RequestResponse<String>(data: 'hello');

      expect(response.data, 'hello');
      expect(response.error, isNull);
    });

    test('should hold error without data', () {
      final error = RequestError.singleMessage('fail');
      final response = RequestResponse<String>(error: error);

      expect(response.data, isNull);
      expect(response.error, isNotNull);
      expect(response.error!.error, 'fail');
    });

    test('should allow both null', () {
      final response = RequestResponse<int>();

      expect(response.data, isNull);
      expect(response.error, isNull);
    });
  });

  group('RequestError', () {
    test('should parse String message from data', () {
      final error = RequestError(
        statusCode: 400,
        data: {'message': 'Invalid email'},
      );

      expect(error.error, 'Invalid email');
      expect(error.errors, isNull);
      expect(error.statusCode, 400);
    });

    test('should parse errors array from data', () {
      final error = RequestError(data: {
        'errors': [
          {'field': 'email', 'message': 'Required'},
          {'field': 'name', 'message': 'Too short'},
        ],
      });

      expect(error.error, isNull);
      expect(error.errors, hasLength(2));
      expect(error.errors![0].field, 'email');
      expect(error.errors![0].message, 'Required');
      expect(error.errors![1].field, 'name');
    });

    test('should parse detail field from data', () {
      final error = RequestError(data: {
        'detail': 'Not found',
      });

      expect(error.error, 'Not found');
    });

    test('should parse error field from data', () {
      final error = RequestError(data: {
        'error': 'Server error',
      });

      expect(error.error, 'Server error');
    });

    test('should parse match_format field from data', () {
      final error = RequestError(data: {
        'match_format': ['Invalid format'],
      });

      expect(error.error, 'Invalid format');
    });

    test('should parse List message as field errors', () {
      final error = RequestError(data: {
        'message': [
          {'field': 'password', 'message': 'Too weak'},
        ],
      });

      expect(error.errors, hasLength(1));
      expect(error.errors![0].field, 'password');
    });

    test('should handle null data without throwing', () {
      final error = RequestError(statusCode: 500);

      expect(error.error, isNull);
      expect(error.errors, isNull);
    });

    test('singleMessage factory should set error string', () {
      final error = RequestError.singleMessage('Custom error');

      expect(error.error, 'Custom error');
      expect(error.statusCode, isNull);
    });

    test('noUser factory should set "No User" message', () {
      final error = RequestError.noUser();

      expect(error.error, 'No User');
    });

    test('noToken factory should set "Empty Token" message', () {
      final error = RequestError.noToken();

      expect(error.error, 'Empty Token');
    });

    test('should prioritize String message over other fields', () {
      // When message is a String, it should be captured immediately
      final error = RequestError(data: {
        'message': 'Direct message',
        'errors': [
          {'field': 'x', 'message': 'y'}
        ],
      });

      // String message should win because the check is first
      expect(error.error, 'Direct message');
    });
  });

  group('FieldErrorModel', () {
    test('should parse from JSON', () {
      final model = FieldErrorModel.fromJson({
        'field': 'email',
        'message': 'Invalid email address',
      });

      expect(model.field, 'email');
      expect(model.message, 'Invalid email address');
    });

    test('should handle null fields', () {
      final model = FieldErrorModel.fromJson({});

      expect(model.field, isNull);
      expect(model.message, isNull);
    });
  });
}
