import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_notifier.dart';
import 'package:optmsg/screens/staticPages/static_pages_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
  });

  // ===== AccountNotifier =====
  group('AccountNotifier', () {
    late ProviderContainer container;
    late AccountNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(accountProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('build should return default AccountState', () {
      final state = container.read(accountProvider);
      expect(state.userData, isNull);
      expect(state.subscriptionDate, '');
      expect(state.isLoading, false);
    });

    test('loadUser should populate from authProvider userData', () async {
      final userData = {
        'user': {
          'subscriptionEndDate': 1735689600,
        },
      };
      final authContainer = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(userData)),
        ],
      );
      addTearDown(authContainer.dispose);
      await Future.delayed(Duration.zero);

      final acctNotifier = authContainer.read(accountProvider.notifier);
      await acctNotifier.loadUser();

      final state = authContainer.read(accountProvider);
      expect(state.userData, isNotNull);
      expect(state.isLoading, false);
    });

    test('formatTimestamp should format unix seconds timestamp', () {
      // 1705276800 seconds = Jan 15, 2024
      final result = notifier.formatTimestamp(1705276800);
      expect(result, contains('Jan'));
      expect(result, contains('2024'));
    });
  });

  // ===== StaticPagesNotifier =====
  group('StaticPagesNotifier', () {
    late ProviderContainer container;
    late StaticPagesNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(staticPagesProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('build should return default StaticPagesState', () {
      final state = container.read(staticPagesProvider);
      expect(state.isLoading, false);
      expect(state.htmlData, '');
      expect(state.faq, isEmpty);
      expect(state.didDataLoad, false);
      expect(state.fetchAttempted, false);
    });

    test('StaticPagesState copyWith should work', () {
      final state = StaticPagesState();
      final modified = state.copyWith(
        isLoading: true,
        htmlData: '<p>test</p>',
        didDataLoad: true,
      );
      expect(modified.isLoading, true);
      expect(modified.htmlData, '<p>test</p>');
      expect(modified.didDataLoad, true);
      expect(modified.faq, isEmpty);
    });

    test('toggleFaqExpansion should toggle expanded state', () {
      notifier.state = notifier.state.copyWith(
        faq: [
          {'question': 'Q1?', 'answer': 'A1', 'isExpanded': false},
          {'question': 'Q2?', 'answer': 'A2', 'isExpanded': false},
        ],
      );

      notifier.toggleFaqExpansion(0);
      expect(container.read(staticPagesProvider).faq[0]['isExpanded'], true);
      expect(container.read(staticPagesProvider).faq[1]['isExpanded'], false);

      notifier.toggleFaqExpansion(0);
      expect(container.read(staticPagesProvider).faq[0]['isExpanded'], false);
    });

    test('toggleFaqExpansion should handle missing isExpanded key', () {
      notifier.state = notifier.state.copyWith(
        faq: [
          {'question': 'Q1?', 'answer': 'A1'},
        ],
      );

      notifier.toggleFaqExpansion(0);
      expect(container.read(staticPagesProvider).faq[0]['isExpanded'], true);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _fakeUserData;
  _FakeAuthNotifier(this._fakeUserData);

  @override
  AuthState build() {
    if (_fakeUserData != null) return AuthState.authenticated(_fakeUserData);
    return AuthState.unauthenticated();
  }
}
