import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import 'package:optmsg/router/route_observer_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'bottom_nav_state.dart';

final bottomNavProvider =
    NotifierProvider<BottomNavNotifier, BottomNavState>(BottomNavNotifier.new);

class BottomNavNotifier extends Notifier<BottomNavState> {
  final SecureStorageService secureStorage = SecureStorageService();

  bool _disposed = false;

  @override
  BottomNavState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    Future.microtask(init);
    return const BottomNavState();
  }

  // ---------------------------
  // INIT
  // ---------------------------
  Future<void> init() async {
    final data = ref.read(authProvider).userData;
    if (_disposed) return;

    if (data != null) {
      state = state.copyWith(userData: data);
    }

    final lastRoute = await getInitialRoute();
    if (_disposed) return;
    state = state.copyWith(lastRoute: lastRoute);
  }

  // ---------------------------
  // TAB INDEX
  // ---------------------------

  /// ✅ Runs only once to apply your `initialIndex`
  void setInitialIndex(int index) {
    if (state.initialized) return;

    state = state.copyWith(
      currentIndex: index,
      initialized: true,
    );
  }

  /// ✅ Called from BottomNavigationBar.onTap
  void setIndex(int index) {
    printLog('Bottom Nav Index:', index);
    state = state.copyWith(currentIndex: index);
  }

  /// Syncs the bottom nav index from the current GoRouter path.
  /// Call this on every build so deep links, browser back/forward,
  /// and side-menu navigation keep the bottom nav in sync.
  void syncFromRoute(String path) {
    final index = _indexForRoute(path);
    if (index != null && index != state.currentIndex) {
      state = state.copyWith(currentIndex: index, initialized: true);
    }
  }

  static int? _indexForRoute(String path) {
    if (path.startsWith(AppRoutes.inbox)) return 0;
    if (path.startsWith(AppRoutes.drafts)) return 1;
    if (path.startsWith(AppRoutes.archive)) return 2;
    if (path.startsWith(AppRoutes.sent)) return 3;
    if (path.startsWith(AppRoutes.trash)) return 4;
    if (path.startsWith(AppRoutes.contacts)) return 5;
    return null;
  }

  // ---------------------------
  // NAV BAR VISIBILITY
  // ---------------------------
  void toggleNavBar() {
    state = state.copyWith(
      showBottomNavBar: !state.showBottomNavBar,
    );
  }

  void hideNavBar() {
    state = state.copyWith(showBottomNavBar: false);
  }

  void showNavBar() {
    state = state.copyWith(showBottomNavBar: true);
  }

  // Socket count listeners are handled centrally by SocketService →
  // countProvider. No duplicate subscriptions needed here (M-05).

  // ---------------------------
  // CLEANUP
  // ---------------------------
  void getLastNavigation() {
    getInitialRoute().then((lastRoute) {
      if (_disposed) return;
      state = state.copyWith(lastRoute: lastRoute);
    });
  }

}
