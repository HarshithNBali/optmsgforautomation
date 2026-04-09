// Implements: TC-DISC-COUNT-001..010
// Source: lib/services/count_notifier.dart
// Coverage target: 90%+ (standard)
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/count_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    // Mock the AppBadgePlus method channel so _updateBadge() doesn't crash
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        if (methodCall.method == 'updateBadge') return null;
        return null;
      },
    );
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CountNotifier', () {
    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------
    test('should have default state with all zeros', () {
      // TC-DISC-COUNT-001
      final state = container.read(countProvider);

      expect(state.inboxCount, 0);
      expect(state.draftCount, 0);
      expect(state.archiveCount, 0);
      expect(state.trashCount, 0);
      expect(state.isUpdateDialogVisible, isFalse);
      expect(state.isUpdatePopUpDismiss, isFalse);
      expect(state.newNotification, 'no');
    });

    // -----------------------------------------------------------------------
    // updateCounts
    // -----------------------------------------------------------------------
    group('updateCounts', () {
      test('should update all four counts', () {
        // TC-DISC-COUNT-002
        container.read(countProvider.notifier).updateCounts(
              inbox: 5,
              draft: 3,
              archive: 10,
              trash: 2,
            );

        final state = container.read(countProvider);
        expect(state.inboxCount, 5);
        expect(state.draftCount, 3);
        expect(state.archiveCount, 10);
        expect(state.trashCount, 2);
      });

      test('should handle zero counts', () {
        // TC-DISC-COUNT-003
        container.read(countProvider.notifier).updateCounts(
              inbox: 0,
              draft: 0,
              archive: 0,
              trash: 0,
            );

        final state = container.read(countProvider);
        expect(state.inboxCount, 0);
        expect(state.draftCount, 0);
        expect(state.archiveCount, 0);
        expect(state.trashCount, 0);
      });

      test('should overwrite previous counts', () {
        container.read(countProvider.notifier).updateCounts(
              inbox: 5,
              draft: 3,
              archive: 10,
              trash: 2,
            );

        container.read(countProvider.notifier).updateCounts(
              inbox: 1,
              draft: 0,
              archive: 0,
              trash: 0,
            );

        final state = container.read(countProvider);
        expect(state.inboxCount, 1);
        expect(state.draftCount, 0);
      });
    });

    // -----------------------------------------------------------------------
    // updateUpdateDialogState
    // -----------------------------------------------------------------------
    test('updateUpdateDialogState should set isUpdateDialogVisible to true',
        () {
      // TC-DISC-COUNT-004
      container.read(countProvider.notifier).updateUpdateDialogState();

      expect(
          container.read(countProvider).isUpdateDialogVisible, isTrue);
    });

    // -----------------------------------------------------------------------
    // updatePopUpDismissState
    // -----------------------------------------------------------------------
    test('updatePopUpDismissState should set isUpdatePopUpDismiss to true', () {
      // TC-DISC-COUNT-005
      container.read(countProvider.notifier).updatePopUpDismissState();

      expect(
          container.read(countProvider).isUpdatePopUpDismiss, isTrue);
    });

    // -----------------------------------------------------------------------
    // updateNotificationStatus
    // -----------------------------------------------------------------------
    group('updateNotificationStatus', () {
      test('should update newNotification field', () {
        // TC-DISC-COUNT-006
        container
            .read(countProvider.notifier)
            .updateNotificationStatus('yes');

        expect(container.read(countProvider).newNotification, 'yes');
      });

      test('should accept "no" status', () {
        // TC-DISC-COUNT-007
        container
            .read(countProvider.notifier)
            .updateNotificationStatus('yes');
        container
            .read(countProvider.notifier)
            .updateNotificationStatus('no');

        expect(container.read(countProvider).newNotification, 'no');
      });
    });

    // -----------------------------------------------------------------------
    // updateUnreadNotificationCount
    // -----------------------------------------------------------------------
    test('updateUnreadNotificationCount should not throw', () {
      // TC-DISC-COUNT-008
      // The count is stored internally (not in Freezed state) for badge computation.
      // We can only verify it doesn't throw since _unreadNotificationCount is private.
      expect(
        () => container
            .read(countProvider.notifier)
            .updateUnreadNotificationCount(5),
        returnsNormally,
      );
    });

    // -----------------------------------------------------------------------
    // CountState copyWith
    // -----------------------------------------------------------------------
    group('CountState', () {
      test('should support copyWith for all fields', () {
        // TC-DISC-COUNT-009
        const state = CountState();
        final updated = state.copyWith(
          inboxCount: 10,
          draftCount: 5,
          archiveCount: 3,
          trashCount: 1,
          isUpdateDialogVisible: true,
          isUpdatePopUpDismiss: true,
          newNotification: 'yes',
        );

        expect(updated.inboxCount, 10);
        expect(updated.draftCount, 5);
        expect(updated.archiveCount, 3);
        expect(updated.trashCount, 1);
        expect(updated.isUpdateDialogVisible, isTrue);
        expect(updated.isUpdatePopUpDismiss, isTrue);
        expect(updated.newNotification, 'yes');
      });

      test('should preserve unchanged fields on copyWith', () {
        // TC-DISC-COUNT-010
        const state = CountState(inboxCount: 5, draftCount: 3);
        final updated = state.copyWith(trashCount: 1);

        expect(updated.inboxCount, 5);
        expect(updated.draftCount, 3);
        expect(updated.trashCount, 1);
      });
    });
  });
}
