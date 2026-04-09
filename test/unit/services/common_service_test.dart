import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/common_service.dart';

void main() {
  late CommonService service;

  setUp(() {
    service = CommonService();
  });

  group('capitalize', () {
    test('should capitalize first letter', () {
      expect(service.capitalize('hello'), 'Hello');
    });

    test('should return empty string for empty input', () {
      expect(service.capitalize(''), '');
    });

    test('should handle single character', () {
      expect(service.capitalize('a'), 'A');
    });

    test('should not change already capitalized', () {
      expect(service.capitalize('Hello'), 'Hello');
    });
  });

  group('formatDateString', () {
    test('should return empty for null', () {
      expect(CommonService.formatDateString(null), '');
    });

    test('should return empty for empty string', () {
      expect(CommonService.formatDateString(''), '');
    });

    test('should return time for today dates', () {
      final now = DateTime.now().toUtc();
      final result = CommonService.formatDateString(now.toIso8601String());
      // Should contain AM or PM for today
      expect(result.contains('AM') || result.contains('PM'), true);
    });

    test('should return Yesterday for yesterday dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toUtc();
      final result = CommonService.formatDateString(yesterday.toIso8601String());
      expect(result, 'Yesterday');
    });

    test('should return day name for recent dates (2-6 days ago)', () {
      final threeDaysAgo =
          DateTime.now().subtract(const Duration(days: 3)).toUtc();
      final result =
          CommonService.formatDateString(threeDaysAgo.toIso8601String());
      // Should be a day name like Monday, Tuesday, etc.
      final dayNames = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
        'Sunday'
      ];
      expect(dayNames.contains(result), true);
    });

    test('should return formatted date for old dates', () {
      final result =
          CommonService.formatDateString('2023-01-15T10:30:00.000Z');
      expect(result, contains('2023'));
    });

    test('should handle full type format', () {
      final result = CommonService.formatDateString(
        '2023-01-15T10:30:00.000Z',
        type: 'full',
      );
      expect(result, contains('2023'));
      expect(result, contains('at'));
    });

    test('should handle onlyDate type format', () {
      final result = CommonService.formatDateString(
        '2023-01-15T10:30:00.000Z',
        type: 'onlyDate',
      );
      expect(result, contains('2023'));
      expect(result, isNot(contains('at')));
    });
  });

  group('fullDateTime', () {
    test('should return empty for null', () {
      expect(CommonService.fullDateTime(null), '');
    });

    test('should return empty for empty string', () {
      expect(CommonService.fullDateTime(''), '');
    });

    test('should format valid date string', () {
      final result = CommonService.fullDateTime('2023-06-15T14:30:00.000Z');
      expect(result, contains('2023'));
      expect(result, contains('at'));
    });
  });

  group('formatDateTime', () {
    test('should return Today for today dates', () {
      final now = DateTime.now().toUtc();
      final result = service.formatDateTime(now.toIso8601String());
      expect(result, startsWith('Today'));
    });

    test('should return formatted date for past dates', () {
      final result = service.formatDateTime('2023-01-15T10:30:00.000Z');
      expect(result, contains('2023'));
    });
  });

  group('getFileName', () {
    test('should extract filename from path', () {
      expect(service.getFileName('/path/to/document.pdf'), 'document.pdf');
    });

    test('should return empty for empty path', () {
      expect(service.getFileName(''), '');
    });

    test('should handle filename without path', () {
      expect(service.getFileName('file.txt'), 'file.txt');
    });
  });

  group('getPlatform', () {
    test('should return a valid platform string', () {
      final platform = service.getPlatform();
      expect(['web', 'android', 'ios'], contains(platform));
    });
  });

  group('formatTimestamp', () {
    test('should format millisecond timestamp', () {
      // 2024-01-15 in ms
      final result = service.formatTimestamp(1705276800000);
      expect(result, contains('Jan'));
      expect(result, contains('2024'));
    });
  });

  group('formatUnixTimestamp', () {
    test('should format unix seconds timestamp', () {
      // 2024-04-29 in seconds
      final result = service.formatUnixTimestamp(1745923852, 'dd MMM yyyy');
      expect(result, contains('2025'));
    });
  });

  group('formatFileSize', () {
    test('should format bytes as KB', () {
      expect(service.formatFileSize(1024), '1.0 KB');
    });

    test('should format large files as MB', () {
      expect(service.formatFileSize(1048576), '1.0 MB');
    });

    test('should format fractional KB', () {
      expect(service.formatFileSize(512), '0.5 KB');
    });
  });

  group('composeFormatFileSize', () {
    test('should format as KB for small files', () {
      expect(service.composeFormatFileSize(512), '0.50 KB');
    });

    test('should format as MB for large files', () {
      expect(service.composeFormatFileSize(1048576), '1.00 MB');
    });
  });

  group('isValidEmail', () {
    test('should return true for valid email', () {
      expect(CommonService.isValidEmail('user@example.com'), true);
    });

    test('should return false for invalid email', () {
      expect(CommonService.isValidEmail('notanemail'), false);
    });

    test('should handle whitespace', () {
      expect(CommonService.isValidEmail('  user@example.com  '), true);
    });
  });

  group('truncateWithEllipsis', () {
    test('should not truncate short text', () {
      expect(service.truncateWithEllipsis(10, 'Hello'), 'Hello  ');
    });

    test('should truncate long text with ellipsis', () {
      final result = service.truncateWithEllipsis(5, 'Hello World');
      expect(result, 'Hello...  ');
    });

    test('should not truncate at exact length', () {
      expect(service.truncateWithEllipsis(5, 'Hello'), 'Hello  ');
    });
  });

  group('undoStatus', () {
    test('should return Moving to status for non-deleted', () {
      expect(service.undoStatus('Trash'), 'Moving to Trash');
    });

    test('should return Permanently Delete for deleted', () {
      expect(service.undoStatus('Trash', true), 'Permanently Delete');
    });

    test('should return Moving to for null isDeleted', () {
      expect(service.undoStatus('Archive'), 'Moving to Archive');
    });

    test('should return Moving to for false isDeleted', () {
      expect(service.undoStatus('Inbox', false), 'Moving to Inbox');
    });
  });

  group('formatPhoneNumber', () {
    test('should format 10-digit number', () {
      final result = service.formatPhoneNumber('+1', '5551234567');
      expect(result, '(+1) 555-123-4567');
    });

    test('should handle short numbers', () {
      final result = service.formatPhoneNumber('+1', '555');
      expect(result, '(+1) 555');
    });

    test('should strip non-digit characters', () {
      final result = service.formatPhoneNumber('+44', '(555) 123-4567');
      expect(result, '(+44) 555-123-4567');
    });
  });

  group('getCopyrightNotice', () {
    test('should contain current year', () {
      final notice = service.getCopyrightNotice();
      expect(notice, contains(DateTime.now().year.toString()));
    });
  });
}
