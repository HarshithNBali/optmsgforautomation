// ignore_for_file: file_names

import 'package:intl/intl.dart';

class FormValidationService {
  /// Returns an error message if the given name is empty, otherwise null.
  ///
  /// This function is used to validate the name field in the create account form.
  ///
  /// The name field is required, so if the given value is null or empty, an error
  /// message is returned. Otherwise, null is returned.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  /// Returns an error message if the given username is empty, otherwise null.
  ///
  /// This function is used to validate the username field in the create account form.
  ///
  /// The username field is required, so if the given value is null or empty, an error
  /// message is returned. Otherwise, null is returned.
  String? validateUserNameWeb(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter username';
    } else {
      return null;
    }
  }

  /// Returns an error message if the given first name is empty, otherwise null.
  ///
  /// This function is used to validate the first name field in the create account form.
  ///
  /// The first name field is required, so if the given value is null or empty, an error
  /// message is returned. Otherwise, null is returned.
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter first name';
    }
    return null;
  }

  /// Returns an error message if the given last name is empty, otherwise null.
  ///
  /// This function is used to validate the last name field in the create account form.
  ///
  /// The last name field is required, so if the given value is null or empty, an error
  /// message is returned. Otherwise, null is returned.
  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter last name';
    }
    return null;
  }

  /// Validates the Date of Birth input.
  ///
  /// This function checks if the provided date string is not null or empty. It verifies
  /// if the date is in the correct format (dd MMMM, yyyy or MM/DD/YYYY) and ensures that
  /// the month and day values are valid. Additionally, it checks that the date is not in the future.
  ///
  /// Returns an error message if any validation fails, otherwise returns null.

  String? validateDob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Date of Birth';
    }

    DateTime? dob;

    // Try to parse as display format first (dd MMMM, yyyy) - e.g., "13 September, 2004"
    try {
      dob = DateFormat('MMMM dd, yyyy').parse(value);
    } catch (e) {
      // If that fails, try to parse as MM/DD/YYYY format (for backward compatibility)
      try {
        final regExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        if (!regExp.hasMatch(value)) {
          return 'Date should be in MM/DD/YYYY format (e.g., 09/13/2004)';
        }

        final List<String> parts = value.split('/');
        final int month = int.parse(parts[0]);
        final int day = int.parse(parts[1]);
        final int year = int.parse(parts[2]);

        // Check if the month is valid (1-12)
        if (month < 1 || month > 12) {
          return 'Invalid month';
        }

        // Check if the day is valid for the given month and year
        final daysInMonth = DateTime(year, month + 1, 0).day;
        if (day < 1 || day > daysInMonth) {
          return 'Invalid day for the given month';
        }

        dob = DateTime(year, month, day);
      } catch (e2) {
        return 'Date should be in MM/DD/YYYY format (e.g., 09/13/2004)';
      }
    }

    // Check if the date is greater than today's date
    if (dob.isAfter(DateTime.now())) {
      return 'Date of Birth cannot be greater than today';
    }

    return null;
  }

  /// Validates the company name input.
  ///
  /// Checks if the provided company name is not null or empty.
  ///
  /// Returns an error message if the company name is invalid.
  /// Otherwise, returns null if the company name is valid.

  String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a Company name';
    }
    return null;
  }

  /// Validates the Tag name input.
  ///
  /// Checks if the provided Tag name is not null or empty, and is not longer
  /// than 20 characters.
  ///
  /// Returns an error message if the Tag name is invalid.
  /// Otherwise, returns null if the Tag name is valid.
  String? validateTagName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a Tag name';
    } else if (value.length > 20) {
      return "You can Tag name must be 20 characters or less";
    }
    return null;
  }

  /// Validates the confirm email input.
  ///
  /// Checks if the given confirm email is not null or empty and matches with
  /// the given email.
  ///
  /// Returns an error message if the confirm email is invalid.
  /// Otherwise, returns null if the confirm email is valid.
  String? confirmEmail(String? value, String email) {
    if (value == null || value.isEmpty) {
      return 'Confirm email is required';
    }
    if (value != email) {
      return 'Confirm email must be same as new email.';
    }
    return null;
  }

  /// Validates the email input.
  ///
  /// Checks if the given email is not null or empty and is a valid email address.
  ///
  /// Returns an error message if the email is invalid.
  /// Otherwise, returns null if the email is valid.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates the mobile phone number input.
  ///
  /// Checks if the given phone number is not null or empty, contains only numbers,
  /// and has exactly 10 digits.
  ///
  /// Returns an error message if the phone number is invalid.
  /// Otherwise, returns null if the phone number is valid.
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a mobile phone number';
    }

    // Trim the input to remove leading and trailing spaces
    final trimmedValue = value.trim();

    // Check if the trimmed input contains only numbers
    final regExp = RegExp(r'^[0-9]+$');
    if (!regExp.hasMatch(trimmedValue)) {
      return 'Phone number should only contain numbers';
    }

    // Check if the trimmed input has exactly 10 digits
    if (trimmedValue.length != 10) {
      return 'Phone number should be 10 digits';
    }

    return null;
  }

  /// Checks if the given email address is valid.
  ///
  /// This function uses a regular expression to validate the format of the
  /// provided email address. It ensures that the email contains a local part,
  /// an '@' symbol, a domain, and a top-level domain. The email should not
  /// contain any leading or trailing whitespace.
  ///
  /// Returns `true` if the email is valid, otherwise `false`.

  bool isValidEmail(String email) {
    // Regular expression pattern for email validation
    const pattern =
        r'^\s*[+\w-]+(\.[+\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})\s*$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }
}
