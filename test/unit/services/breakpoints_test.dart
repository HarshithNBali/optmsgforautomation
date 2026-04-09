// Implements: TC-DISC-BP-001..015
// Source: lib/common/responsive/breakpoints.dart
// Coverage target: 85%+ (UI layer)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';

void main() {
  group('AppBreakpoints', () {
    // -----------------------------------------------------------------------
    // Constants
    // -----------------------------------------------------------------------
    group('constants', () {
      test('should have correct breakpoint values', () {
        // TC-DISC-BP-001
        expect(AppBreakpoints.mobile, 600.0);
        expect(AppBreakpoints.tablet, 600.0);
        expect(AppBreakpoints.desktop, 1024.0);
        expect(AppBreakpoints.largeDesktop, 1440.0);
        expect(AppBreakpoints.readingPane, 600.0);
        expect(AppBreakpoints.minHeightForReadingPane, 500.0);
      });

      test('should have correct UI layout constants', () {
        expect(AppBreakpoints.authFormWidthNarrow, 450.0);
        expect(AppBreakpoints.authFormWidthMedium, 500.0);
        expect(AppBreakpoints.authFormWidthWide, 533.0);
        expect(AppBreakpoints.formWidthDesktop, 600.0);
        expect(AppBreakpoints.formWidthTablet, 500.0);
        expect(AppBreakpoints.splitPaneMinWidth, 280.0);
        expect(AppBreakpoints.splitPaneMaxWidth, 600.0);
        expect(AppBreakpoints.overlayMenuWidth, 200.0);
        expect(AppBreakpoints.popupMaxWidth, 500.0);
        expect(AppBreakpoints.actionSheetMaxWidth, 400.0);
        expect(AppBreakpoints.webLoginFormWidth, 420.0);
        expect(AppBreakpoints.creditCardWidth, 323.0);
        expect(AppBreakpoints.creditCardHeight, 181.0);
      });
    });

    // -----------------------------------------------------------------------
    // Width-based predicates (pure functions — no BuildContext needed)
    // -----------------------------------------------------------------------
    group('isMobile (width)', () {
      test('should return true for width < 600', () {
        // TC-DISC-BP-002
        expect(AppBreakpoints.isMobile(599), isTrue);
        expect(AppBreakpoints.isMobile(300), isTrue);
        expect(AppBreakpoints.isMobile(0), isTrue);
      });

      test('should return false for width >= 600', () {
        expect(AppBreakpoints.isMobile(600), isFalse);
        expect(AppBreakpoints.isMobile(1024), isFalse);
      });
    });

    group('isTablet (width)', () {
      test('should return true for width 600-1023', () {
        // TC-DISC-BP-003
        expect(AppBreakpoints.isTablet(600), isTrue);
        expect(AppBreakpoints.isTablet(800), isTrue);
        expect(AppBreakpoints.isTablet(1023), isTrue);
      });

      test('should return false for width < 600 or >= 1024', () {
        expect(AppBreakpoints.isTablet(599), isFalse);
        expect(AppBreakpoints.isTablet(1024), isFalse);
        expect(AppBreakpoints.isTablet(1440), isFalse);
      });
    });

    group('isDesktop (width)', () {
      test('should return true for width >= 1024', () {
        // TC-DISC-BP-004
        expect(AppBreakpoints.isDesktop(1024), isTrue);
        expect(AppBreakpoints.isDesktop(1440), isTrue);
        expect(AppBreakpoints.isDesktop(1920), isTrue);
      });

      test('should return false for width < 1024', () {
        expect(AppBreakpoints.isDesktop(1023), isFalse);
        expect(AppBreakpoints.isDesktop(600), isFalse);
      });
    });

    group('isLargeDesktop (width)', () {
      test('should return true for width >= 1440', () {
        // TC-DISC-BP-005
        expect(AppBreakpoints.isLargeDesktop(1440), isTrue);
        expect(AppBreakpoints.isLargeDesktop(1920), isTrue);
      });

      test('should return false for width < 1440', () {
        expect(AppBreakpoints.isLargeDesktop(1439), isFalse);
        expect(AppBreakpoints.isLargeDesktop(1024), isFalse);
      });
    });

    group('canShowReadingPane (width)', () {
      test('should return true for width >= 600', () {
        // TC-DISC-BP-006
        expect(AppBreakpoints.canShowReadingPane(600), isTrue);
        expect(AppBreakpoints.canShowReadingPane(1024), isTrue);
      });

      test('should return false for width < 600', () {
        expect(AppBreakpoints.canShowReadingPane(599), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // getDeviceType (pure function)
    // -----------------------------------------------------------------------
    group('getDeviceType', () {
      test('should return mobile for width < 600', () {
        // TC-DISC-BP-007
        expect(AppBreakpoints.getDeviceType(0), DeviceType.mobile);
        expect(AppBreakpoints.getDeviceType(599), DeviceType.mobile);
      });

      test('should return tablet for width 600-1023', () {
        expect(AppBreakpoints.getDeviceType(600), DeviceType.tablet);
        expect(AppBreakpoints.getDeviceType(1023), DeviceType.tablet);
      });

      test('should return desktop for width >= 1024', () {
        expect(AppBreakpoints.getDeviceType(1024), DeviceType.desktop);
        expect(AppBreakpoints.getDeviceType(1920), DeviceType.desktop);
      });
    });

    // -----------------------------------------------------------------------
    // Boundary tests
    // -----------------------------------------------------------------------
    group('boundary values', () {
      test('width 599.9 is mobile', () {
        expect(AppBreakpoints.isMobile(599.9), isTrue);
        expect(AppBreakpoints.isTablet(599.9), isFalse);
      });

      test('width 600.0 is tablet', () {
        expect(AppBreakpoints.isMobile(600.0), isFalse);
        expect(AppBreakpoints.isTablet(600.0), isTrue);
        expect(AppBreakpoints.isDesktop(600.0), isFalse);
      });

      test('width 1023.9 is tablet', () {
        expect(AppBreakpoints.isTablet(1023.9), isTrue);
        expect(AppBreakpoints.isDesktop(1023.9), isFalse);
      });

      test('width 1024.0 is desktop', () {
        expect(AppBreakpoints.isTablet(1024.0), isFalse);
        expect(AppBreakpoints.isDesktop(1024.0), isTrue);
        expect(AppBreakpoints.isLargeDesktop(1024.0), isFalse);
      });

      test('width 1440.0 is large desktop', () {
        expect(AppBreakpoints.isDesktop(1440.0), isTrue);
        expect(AppBreakpoints.isLargeDesktop(1440.0), isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // isPhysicalTablet (static getter, cache-based)
    // -----------------------------------------------------------------------
    group('isPhysicalTablet', () {
      test('should return false when not initialized (web context)', () {
        // TC-DISC-BP-008
        // In test environment, kIsWeb behavior — returns false
        expect(AppBreakpoints.isPhysicalTablet, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Flex ratios
    // -----------------------------------------------------------------------
    group('flex ratios', () {
      test('should have correct flex values for split layout', () {
        expect(AppBreakpoints.emailListFlex, 1);
        expect(AppBreakpoints.readingPaneFlex, 2);
      });
    });
  });

  // -------------------------------------------------------------------------
  // DeviceType enum
  // -------------------------------------------------------------------------
  group('DeviceType', () {
    test('should have three values', () {
      expect(DeviceType.values, hasLength(3));
      expect(DeviceType.values, contains(DeviceType.mobile));
      expect(DeviceType.values, contains(DeviceType.tablet));
      expect(DeviceType.values, contains(DeviceType.desktop));
    });
  });
}
