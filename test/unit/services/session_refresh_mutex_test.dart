import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

void main() {
  group('SessionRefreshMutex static flags', () {
    setUp(() {
      // Reset static state between tests
      SessionRefreshMutex.isLoggedOut = false;
      SessionRefreshMutex.passkeyFlowInProgress = false;
      SessionRefreshMutex.isRefreshing = false;
    });

    test('isLoggedOut should default to false', () {
      expect(SessionRefreshMutex.isLoggedOut, false);
    });

    test('isLoggedOut should be settable', () {
      SessionRefreshMutex.isLoggedOut = true;
      expect(SessionRefreshMutex.isLoggedOut, true);
    });

    test('passkeyFlowInProgress should default to false', () {
      expect(SessionRefreshMutex.passkeyFlowInProgress, false);
    });

    test('passkeyFlowInProgress should be settable', () {
      SessionRefreshMutex.passkeyFlowInProgress = true;
      expect(SessionRefreshMutex.passkeyFlowInProgress, true);
    });

    test('isRefreshing should default to false', () {
      expect(SessionRefreshMutex.isRefreshing, false);
    });

    test('isRefreshing should be settable', () {
      SessionRefreshMutex.isRefreshing = true;
      expect(SessionRefreshMutex.isRefreshing, true);
    });

    test('guardedRefreshIfNeeded should return immediately when logged out',
        () async {
      SessionRefreshMutex.isLoggedOut = true;
      // Should return without error (skips refresh)
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    });

    test(
        'guardedRefreshIfNeeded should return immediately during passkey flow',
        () async {
      SessionRefreshMutex.passkeyFlowInProgress = true;
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    });
  });
}
