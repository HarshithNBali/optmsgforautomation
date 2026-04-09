// Implements: TC-DISC-NAV-001..015
// Source: lib/services/bottom_nav_provider.dart
// Coverage target: 90%+ (standard)
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/services/bottom_nav_provider.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late RiverpodTestSetup setup;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        return null;
      },
    );

    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
  });

  tearDown(() {
    container.dispose();
  });

  group('BottomNavNotifier', () {
    // -----------------------------------------------------------------------
    // Initial State
    // -----------------------------------------------------------------------
    test('should have correct initial state', () async {
      // TC-DISC-NAV-001
      container = ProviderContainer(overrides: setup.serviceOverrides);
      final state = container.read(bottomNavProvider);

      expect(state.currentIndex, 0);
      expect(state.showBottomNavBar, isTrue);
      expect(state.initialized, isFalse);
      expect(state.loading, isFalse);
      expect(state.lastRoute, isNull);
    });

    // -----------------------------------------------------------------------
    // setInitialIndex
    // -----------------------------------------------------------------------
    group('setInitialIndex', () {
      test('should set initial index and mark initialized', () {
        // TC-DISC-NAV-002
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).setInitialIndex(3);

        final state = container.read(bottomNavProvider);
        expect(state.currentIndex, 3);
        expect(state.initialized, isTrue);
      });

      test('should not change index when already initialized', () {
        // TC-DISC-NAV-003
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        final notifier = container.read(bottomNavProvider.notifier);
        notifier.setInitialIndex(3);
        notifier.setInitialIndex(5); // should be ignored

        expect(container.read(bottomNavProvider).currentIndex, 3);
      });
    });

    // -----------------------------------------------------------------------
    // setIndex
    // -----------------------------------------------------------------------
    test('setIndex should update currentIndex', () {
      // TC-DISC-NAV-004
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(bottomNavProvider);

      container.read(bottomNavProvider.notifier).setIndex(2);

      expect(container.read(bottomNavProvider).currentIndex, 2);
    });

    // -----------------------------------------------------------------------
    // syncFromRoute
    // -----------------------------------------------------------------------
    group('syncFromRoute', () {
      test('should set index 0 for inbox routes', () {
        // TC-DISC-NAV-005
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/inbox');
        expect(container.read(bottomNavProvider).currentIndex, 0);

        container.read(bottomNavProvider.notifier).syncFromRoute('/inbox/email?id=1');
        expect(container.read(bottomNavProvider).currentIndex, 0);
      });

      test('should set index 1 for drafts routes', () {
        // TC-DISC-NAV-006
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/drafts');
        expect(container.read(bottomNavProvider).currentIndex, 1);
      });

      test('should set index 2 for archive routes', () {
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/archive');
        expect(container.read(bottomNavProvider).currentIndex, 2);
      });

      test('should set index 3 for sent routes', () {
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/sent');
        expect(container.read(bottomNavProvider).currentIndex, 3);
      });

      test('should set index 4 for trash routes', () {
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/trash');
        expect(container.read(bottomNavProvider).currentIndex, 4);
      });

      test('should set index 5 for contacts routes', () {
        // TC-DISC-NAV-007
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/contacts');
        expect(container.read(bottomNavProvider).currentIndex, 5);
      });

      test('should not change index for unknown routes', () {
        // TC-DISC-NAV-008
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).setIndex(2);
        container.read(bottomNavProvider.notifier).syncFromRoute('/settings');

        expect(container.read(bottomNavProvider).currentIndex, 2);
      });

      test('should not update if index already matches', () {
        // TC-DISC-NAV-009
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        final notifier = container.read(bottomNavProvider.notifier);
        notifier.setIndex(0);
        notifier.syncFromRoute('/inbox'); // same index, should be no-op

        expect(container.read(bottomNavProvider).currentIndex, 0);
      });

      test('should mark initialized on sync', () {
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).syncFromRoute('/drafts');

        expect(container.read(bottomNavProvider).initialized, isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // Nav bar visibility
    // -----------------------------------------------------------------------
    group('nav bar visibility', () {
      test('toggleNavBar should toggle showBottomNavBar', () {
        // TC-DISC-NAV-010
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).toggleNavBar();
        expect(container.read(bottomNavProvider).showBottomNavBar, isFalse);

        container.read(bottomNavProvider.notifier).toggleNavBar();
        expect(container.read(bottomNavProvider).showBottomNavBar, isTrue);
      });

      test('hideNavBar should set showBottomNavBar to false', () {
        // TC-DISC-NAV-011
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        container.read(bottomNavProvider.notifier).hideNavBar();
        expect(container.read(bottomNavProvider).showBottomNavBar, isFalse);
      });

      test('showNavBar should set showBottomNavBar to true', () {
        // TC-DISC-NAV-012
        container = ProviderContainer(overrides: setup.serviceOverrides);
        container.read(bottomNavProvider);

        final notifier = container.read(bottomNavProvider.notifier);
        notifier.hideNavBar();
        notifier.showNavBar();
        expect(container.read(bottomNavProvider).showBottomNavBar, isTrue);
      });
    });
  });
}
