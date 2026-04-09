import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/auth/auth_state.dart';

void main() {
  group('AuthState', () {
    group('factory constructors', () {
      test('initial() should be uninitialized and unauthenticated', () {
        final state = AuthState.initial();

        expect(state.status, AuthStatus.unauthenticated);
        expect(state.isInitialized, false);
        expect(state.isAuthenticated, false);
        expect(state.isLoading, false);
        expect(state.hasError, false);
        expect(state.errorMessage, isNull);
        expect(state.userData, isNull);
      });

      test('unauthenticated() should be initialized but not authenticated', () {
        final state = AuthState.unauthenticated();

        expect(state.status, AuthStatus.unauthenticated);
        expect(state.isInitialized, true);
        expect(state.isAuthenticated, false);
        expect(state.isUnauthenticated, true);
      });

      test('authenticating() should show loading', () {
        final state = AuthState.authenticating();

        expect(state.status, AuthStatus.authenticating);
        expect(state.isInitialized, true);
        expect(state.isLoading, true);
        expect(state.isAuthenticating, true);
        expect(state.isAuthenticated, false);
      });

      test('authenticated() should store userData', () {
        final userData = {'id': 1, 'name': 'Test'};
        final state = AuthState.authenticated(userData);

        expect(state.status, AuthStatus.authenticated);
        expect(state.isInitialized, true);
        expect(state.isAuthenticated, true);
        expect(state.userData, userData);
        expect(state.isLoading, false);
      });

      test('error() should store error message and type', () {
        final state = AuthState.error(
          'Network failure',
          type: AuthErrorType.network,
        );

        expect(state.status, AuthStatus.error);
        expect(state.hasError, true);
        expect(state.errorMessage, 'Network failure');
        expect(state.errorType, AuthErrorType.network);
        expect(state.isInitialized, true);
      });

      test('error() with isInitialized=false for init-time errors', () {
        final state = AuthState.error(
          'Descope init failed',
          isInitialized: false,
        );

        expect(state.hasError, true);
        expect(state.isInitialized, false);
      });

      test('error() defaults to generic error type', () {
        final state = AuthState.error('Unknown');

        expect(state.errorType, AuthErrorType.generic);
      });
    });

    group('computed properties', () {
      test('isAuthenticated returns true only for authenticated status', () {
        expect(AuthState.authenticated({}).isAuthenticated, true);
        expect(AuthState.unauthenticated().isAuthenticated, false);
        expect(AuthState.authenticating().isAuthenticated, false);
        expect(AuthState.error('x').isAuthenticated, false);
      });

      test('isAuthenticating returns true only for authenticating status', () {
        expect(AuthState.authenticating().isAuthenticating, true);
        expect(AuthState.authenticated({}).isAuthenticating, false);
      });

      test('isUnauthenticated returns true only for unauthenticated status', () {
        expect(AuthState.unauthenticated().isUnauthenticated, true);
        expect(AuthState.authenticated({}).isUnauthenticated, false);
      });

      test('hasError returns true only for error status', () {
        expect(AuthState.error('x').hasError, true);
        expect(AuthState.authenticated({}).hasError, false);
      });

      test('isLoading is alias for authenticating', () {
        expect(AuthState.authenticating().isLoading, true);
        expect(AuthState.unauthenticated().isLoading, false);
      });

      test('hasVerifyUser when verifyUser is non-null', () {
        const state = AuthState(
          status: AuthStatus.unauthenticated,
          verifyUser: {'id': 1},
        );
        expect(state.hasVerifyUser, true);

        expect(AuthState.initial().hasVerifyUser, false);
      });

      test('isDescopeEnabled when isDescopeLogin is true', () {
        const state = AuthState(
          status: AuthStatus.unauthenticated,
          isDescopeLogin: true,
        );
        expect(state.isDescopeEnabled, true);

        const state2 = AuthState(
          status: AuthStatus.unauthenticated,
          isDescopeLogin: false,
        );
        expect(state2.isDescopeEnabled, false);

        expect(AuthState.initial().isDescopeEnabled, false);
      });

      test('isAwaitingOtp for awaitingOtp status', () {
        const state = AuthState(status: AuthStatus.awaitingOtp);
        expect(state.isAwaitingOtp, true);
        expect(AuthState.initial().isAwaitingOtp, false);
      });
    });

    group('copyWith', () {
      test('should create modified copy', () {
        final original = AuthState.initial();
        final modified = original.copyWith(isInitialized: true);

        expect(original.isInitialized, false);
        expect(modified.isInitialized, true);
        expect(modified.status, original.status);
      });

      test('should allow changing status', () {
        final state = AuthState.unauthenticated()
            .copyWith(status: AuthStatus.authenticated);

        expect(state.isAuthenticated, true);
        expect(state.isInitialized, true);
      });
    });
  });

  group('AuthStatus', () {
    test('should have all expected values', () {
      expect(AuthStatus.values, hasLength(5));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.authenticating));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.awaitingOtp));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });

  group('AuthErrorType', () {
    test('should have all expected values', () {
      expect(AuthErrorType.values, hasLength(6));
      expect(AuthErrorType.values, contains(AuthErrorType.generic));
      expect(AuthErrorType.values, contains(AuthErrorType.network));
      expect(AuthErrorType.values, contains(AuthErrorType.invalidCredentials));
      expect(AuthErrorType.values, contains(AuthErrorType.subscriptionInvalid));
      expect(AuthErrorType.values, contains(AuthErrorType.sessionExpired));
      expect(AuthErrorType.values, contains(AuthErrorType.descopeError));
    });
  });
}
