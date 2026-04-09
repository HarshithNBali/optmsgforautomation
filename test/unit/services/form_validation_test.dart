import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/form_validation.dart';

void main() {
  late FormValidationService validator;

  setUp(() {
    validator = FormValidationService();
  });

  group('validateName', () {
    test('should return error for null', () {
      expect(validator.validateName(null), isNotNull);
    });

    test('should return error for empty string', () {
      expect(validator.validateName(''), isNotNull);
    });

    test('should return error for whitespace only', () {
      expect(validator.validateName('   '), isNotNull);
    });

    test('should return null for valid name', () {
      expect(validator.validateName('John'), isNull);
    });
  });

  group('validateUserNameWeb', () {
    test('should return error for null', () {
      expect(validator.validateUserNameWeb(null), 'Please enter username');
    });

    test('should return error for empty string', () {
      expect(validator.validateUserNameWeb(''), 'Please enter username');
    });

    test('should return error for whitespace only', () {
      expect(validator.validateUserNameWeb('   '), 'Please enter username');
    });

    test('should return null for valid username', () {
      expect(validator.validateUserNameWeb('testuser'), isNull);
    });
  });

  group('validateFirstName', () {
    test('should return error for null', () {
      expect(validator.validateFirstName(null), 'Please enter first name');
    });

    test('should return null for valid name', () {
      expect(validator.validateFirstName('Jane'), isNull);
    });
  });

  group('validateLastName', () {
    test('should return error for null', () {
      expect(validator.validateLastName(null), 'Please enter last name');
    });

    test('should return null for valid name', () {
      expect(validator.validateLastName('Doe'), isNull);
    });
  });

  group('validateDob', () {
    test('should return error for null', () {
      expect(validator.validateDob(null), 'Please enter your Date of Birth');
    });

    test('should return error for empty string', () {
      expect(validator.validateDob(''), 'Please enter your Date of Birth');
    });

    test('should accept MMMM dd, yyyy format', () {
      expect(validator.validateDob('September 13, 2004'), isNull);
    });

    test('should accept MM/DD/YYYY format', () {
      expect(validator.validateDob('09/13/2004'), isNull);
    });

    test('should reject future dates', () {
      expect(validator.validateDob('01/01/2099'),
          'Date of Birth cannot be greater than today');
    });

    test('should reject invalid month', () {
      expect(validator.validateDob('13/01/2000'), 'Invalid month');
    });

    test('should reject invalid day for month', () {
      expect(validator.validateDob('02/30/2000'),
          'Invalid day for the given month');
    });

    test('should reject malformed date', () {
      expect(validator.validateDob('not-a-date'), isNotNull);
    });

    test('should reject wrong format', () {
      expect(validator.validateDob('2000-01-01'), isNotNull);
    });
  });

  group('validateEmail', () {
    test('should return error for null', () {
      expect(
          validator.validateEmail(null), 'Please enter an email address');
    });

    test('should return error for empty string', () {
      expect(validator.validateEmail(''), 'Please enter an email address');
    });

    test('should return error for invalid email', () {
      expect(validator.validateEmail('notanemail'),
          'Please enter a valid email address');
    });

    test('should return error for email without domain', () {
      expect(validator.validateEmail('test@'),
          'Please enter a valid email address');
    });

    test('should return null for valid email', () {
      expect(validator.validateEmail('test@example.com'), isNull);
    });

    test('should accept email with subdomain', () {
      expect(validator.validateEmail('user@mail.example.com'), isNull);
    });

    test('should accept email with plus sign', () {
      expect(validator.validateEmail('user+tag@example.com'), isNull);
    });
  });

  group('isValidEmail', () {
    test('should return true for standard email', () {
      expect(validator.isValidEmail('user@example.com'), true);
    });

    test('should return false for missing @', () {
      expect(validator.isValidEmail('userexample.com'), false);
    });

    test('should return false for missing TLD', () {
      expect(validator.isValidEmail('user@example'), false);
    });

    test('should return true for email with dots in local part', () {
      expect(validator.isValidEmail('first.last@example.com'), true);
    });
  });

  group('validatePhoneNumber', () {
    test('should return error for null', () {
      expect(validator.validatePhoneNumber(null),
          'Please enter a mobile phone number');
    });

    test('should return error for empty string', () {
      expect(validator.validatePhoneNumber(''),
          'Please enter a mobile phone number');
    });

    test('should return error for non-numeric', () {
      expect(validator.validatePhoneNumber('abcdefghij'),
          'Phone number should only contain numbers');
    });

    test('should return error for less than 10 digits', () {
      expect(validator.validatePhoneNumber('12345'),
          'Phone number should be 10 digits');
    });

    test('should return error for more than 10 digits', () {
      expect(validator.validatePhoneNumber('12345678901'),
          'Phone number should be 10 digits');
    });

    test('should return null for valid 10-digit number', () {
      expect(validator.validatePhoneNumber('5551234567'), isNull);
    });
  });

  group('validateTagName', () {
    test('should return error for null', () {
      expect(validator.validateTagName(null), 'Please enter a Tag name');
    });

    test('should return error for empty string', () {
      expect(validator.validateTagName(''), 'Please enter a Tag name');
    });

    test('should return error for name over 20 characters', () {
      expect(
        validator.validateTagName('abcdefghijklmnopqrstuvwxyz'),
        contains('20 characters'),
      );
    });

    test('should return null for valid tag name', () {
      expect(validator.validateTagName('Important'), isNull);
    });

    test('should accept exactly 20 characters', () {
      expect(validator.validateTagName('a' * 20), isNull);
    });
  });

  group('confirmEmail', () {
    test('should return error for null', () {
      expect(validator.confirmEmail(null, 'test@example.com'),
          'Confirm email is required');
    });

    test('should return error for empty', () {
      expect(validator.confirmEmail('', 'test@example.com'),
          'Confirm email is required');
    });

    test('should return error for mismatch', () {
      expect(
        validator.confirmEmail('other@example.com', 'test@example.com'),
        'Confirm email must be same as new email.',
      );
    });

    test('should return null when emails match', () {
      expect(
          validator.confirmEmail('test@example.com', 'test@example.com'),
          isNull);
    });
  });

  group('validateCompanyName', () {
    test('should return error for null', () {
      expect(validator.validateCompanyName(null),
          'Please enter a Company name');
    });

    test('should return null for valid company name', () {
      expect(validator.validateCompanyName('Acme Corp'), isNull);
    });
  });
}
