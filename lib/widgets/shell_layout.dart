// ═══════════════════════════════════════════════════════════════════════════
// ShellLayout — full-width AppBar with sidebar/drawer/bottom nav
//
// ARCHITECTURE:
// - go() routes: config derived from route in didUpdateWidget (synchronous)
// - push() routes: screen calls setAppBarConfig() in initState
// - Email view: /inbox/email?id=xxx (NOT /email) — screen overrides title
// - Help sub-pages: /help/faq, /help/:slug — matched by startsWith('/help/')
// - Default (unmatched): empty title, no search, notification bell only
//
// AppBar Config Reference — all screens by breakpoint
// ═══════════════════════════════════════════════════════════════════════════
//
// SYMBOL LEGEND:
//   ☰        hamburger / drawer toggle (leading)
//   ←        back arrow (leading)
//   [🔍]     search toggle — opens search bar below AppBar
//   [🔔]     notification bell icon
//   [filter]  filter icon (svgFilter) — opens unread/tags/contact-type overlay
//   [+Add]   add button (TextButton.icon on tablet/desktop)
//   FAB      floating action button (bottom-right)
//
// SMALL (Mobile, <600px):
// ────────────────────────────────────────────────────────────────────────
// TOP-LEVEL (go routes):
// /inbox                          ☰drawer  Inbox          [🔍] [🔔] [filter]  (FAB: Compose)
// /drafts                         ☰drawer  Drafts         [🔍] [🔔]           (FAB: Compose)
// /archive|/sent|/trash           ☰drawer  Archive/..     [🔍] [🔔] [filter]  (FAB: Compose)
// /contacts                       ☰drawer  Contacts       [🔍*][🔔] [filter]  (FAB: +Add)
// /tags                           ☰drawer  Tags           [+Add] [🔔]
// /settings                       ☰drawer  Settings       [🔔]
// /help                           ☰drawer  Help Center    [🔔]
//   * /contacts search opens by default (searchOpenByDefault)
//
// SUB-ROUTES (go routes):
// /settings/profile               ←back    Profile        [🔔]
//   (edit mode: title changes to "Edit Profile" via setAppBarConfig)
// /settings/account               ←back    Account        [🔔]
// /settings/account/subscription  ←back    Subscription   [🔔] hideUpgrade
//   (mobile title: "Billing Details")
// /settings/../change_payment     ←back    Payment Meth.  [🔔] hideUpgrade
// /help/faq                       ←back    (page key)     [🔔]
// /help/:slug                     ←back    (resolved title) [🔔]
//
// PUSH ROUTES (screen setAppBarConfig):
// /notifications                  ←back    Notifications  (none)
// /inbox/email?id=xxx             ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /archive/email?id=xxx           ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /sent/email?id=xxx              ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /drafts/email?id=xxx            ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /trash/email?id=xxx             ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /spam/email?id=xxx              ←back    (email type)   [opt-in] [🗑] [⋯]  (FAB: Reply)
// /compose                        ←back    New Message    [📎] [send]
// /contacts/view-contact          ←back    (name)         [✏] [🗑]
// /contacts/edit-contact          ←back    Edit Contact   (none)
// /contacts/add-contact           ←back    New Contact    (none)
// /tags?id=xxx                    ←back    (tag name)     (see selection mode)  (FAB: Compose)
// /subscription/change            ←back    Change Subscription Plan  (none) hideUpgrade
//
// SELECTION MODE (mobile only — triggered by long-press):
// ────────────────────────────────────────────────────────────────────────
// Leading: [←back] [☑ selectAll] "N selected"
// Actions vary by screen:
//   inbox:          [opt-in] [🗑 delete] [📦 archive] [⋯ more]
//   archive:        [opt-in] [🗑 delete] [📦 archive (sent only)] [⋯ more]
//   drafts:         [🗑 delete]
//   contacts:       [🗑 delete]
//   tags list:      [🗑 delete]
//   tag emails:     [opt-in] [🗑 delete] [📦 archive] [⋯ more]
//   notifications:  [🗑 delete] [📧 mark read/unread]
//
// Bottom nav: [Inbox] [Trash] [Contacts]
// Search: slides below AppBar when 🔍 tapped (auto-open on /contacts)
//
// MEDIUM/LARGE (Tablet/Desktop, ≥600px):
// ────────────────────────────────────────────────────────────────────────
// With search: /inbox../contacts  ☰toggle+logo  [══search══]  [🔔]
// Without:    /tags../help/etc    ☰toggle+logo  Title         [🔔]
// Sub/push:   back arrow in title ☰toggle+logo  ←back Title   [🔔]
// Sidebar: 72px collapsed, 200-240px expanded
// Filter/Add/Custom/Selection actions: in content area, not AppBar
// ═══════════════════════════════════════════════════════════════════════════

import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/img_path.dart';
import '../constant/string_constant.dart';
import '../constant/styles.dart';
import '../constant/app_typography.dart';
import '../model/notification_list_model.dart';
import '../repositories/notification/notification_api.dart';
import '../router/app_routes.dart';
import '../services/app_bar_config_state.dart';
import '../services/common_service.dart';
import '../services/storage_service.dart';
import '../services/count_notifier.dart';
import '../common/responsive/responsive.dart';
import '../constant/app_config.dart';
import '../screens/auth/auth_riverpod/auth_notifier.dart';
import 'app_navigation_bar.dart';
import 'drawer.dart';
import 'search_bar.dart';
import 'side_menu.dart';

class ShellLayout extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const ShellLayout({super.key, required this.child, required this.state});

  static _ShellLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ShellLayoutState>();
  }

  @override
  ConsumerState<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends ConsumerState<ShellLayout> {
  // ═══════════════════════════════════════════════════════════════════════
  // AppBar config — LOCAL STATE, not a provider
  // ═══════════════════════════════════════════════════════════════════════

  /// Tracks whether a push overlay was present on the last frame.
  /// Used to detect pop events (canPop transitions true→false) and restore
  /// the route-derived config when a push page is dismissed.
  bool _lastCanPop = false;

  /// The current AppBar configuration. Set synchronously by:
  /// - `didUpdateWidget` for go() routes (title/search derived from route)
  /// - `setAppBarConfig()` for push() routes (called by screens in initState)
  /// - `setAppBarConfig()` for dynamic changes (selection mode, edit mode)
  AppBarConfig _appBarConfig = const AppBarConfig();

  /// Called by screens to update the AppBar config. This is the ONLY way
  /// push-route screens communicate their title/actions to the shell.
  /// For go() routes, didUpdateWidget handles title/showSearch automatically.
  /// Screens call this to add extras (search callback, filter, actions, etc.).
  ///
  /// Preserves route-derived title if the screen doesn't set one explicitly.
  /// Does NOT merge other fields — full replacement to prevent stale bleed.
  /// True when a screen has explicitly set a title via setAppBarConfig.
  /// Prevents the route-title sync from overriding screen-owned titles
  /// (e.g. "Edit Profile" set by the profile screen in edit mode).
  /// Reset when the route actually changes in didUpdateWidget.
  bool _screenOverrideTitle = false;

  void setAppBarConfig(AppBarConfig config) {
    if (!mounted) return;
    final routeTitle = _appBarConfig.title;
    final routeShowSearch = _appBarConfig.showSearch;
    _screenOverrideTitle = config.title.isNotEmpty;
    // Auto-open mobile search when the screen requests it
    final shouldAutoOpenSearch =
        config.searchOpenByDefault && !_mobileSearchOpen;
    setState(() {
      _appBarConfig = config.title.isNotEmpty
          ? config // Screen set an explicit title (push routes) — use as-is
          : config.copyWith(
              title: routeTitle,
              showSearch: config.showSearch || routeShowSearch,
            );
      if (shouldAutoOpenSearch) {
        _mobileSearchOpen = true;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Sidebar state
  // ═══════════════════════════════════════════════════════════════════════

  static bool _desktopExpanded = true;
  static bool _tabletExpanded = false;
  static bool _prefsLoaded = false;

  bool get isSideMenuExpanded => _desktopExpanded;
  bool get isSideMenuCollapsed => !_desktopExpanded;

  // ═══════════════════════════════════════════════════════════════════════
  // Search state — owned by shell, not by screens
  // ═══════════════════════════════════════════════════════════════════════

  final GlobalKey<ScaffoldState> _mobileScaffoldKey =
      GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _mobileSearchOpen = false;

  void openDrawer() => _mobileScaffoldKey.currentState?.openDrawer();

  final SecureStorageService secureStorageService = SecureStorageService();
  Map<String, dynamic>? userData;

  // ═══════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    // Set initial config from the initial route
    _appBarConfig = _configForRoute(
      widget.state.matchedLocation,
      uri: widget.state.uri,
    );
    _loadSidebarState();
    getUserData();
    ref.listenManual(authProvider.select((s) => s.isAuthenticated), (
      previous,
      next,
    ) {
      if (next == true) getUserData();
    });
  }

  @override
  void didUpdateWidget(covariant ShellLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When go() navigation changes the shell route, update config synchronously.
    // This is the KEY insight: go() routes update widget.state.matchedLocation
    // immediately, so we can derive config from the route with zero lag.
    // Push routes DON'T change matchedLocation — screens handle those via
    // setAppBarConfig() in their initState.
    if (widget.state.matchedLocation != oldWidget.state.matchedLocation ||
        widget.state.uri != oldWidget.state.uri) {
      _screenOverrideTitle = false; // Route changed — clear screen override
      setState(() {
        // Use full URI to distinguish /tags (list) from /tags?id=5 (tag emails)
        _appBarConfig = _configForRoute(
          widget.state.matchedLocation,
          uri: widget.state.uri,
        );
        _mobileSearchOpen = false;
      });
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Route → Config mapping (for go() routes only)
  // ═══════════════════════════════════════════════════════════════════════

  /// Derive AppBarConfig from a route path. Used ONLY for go() routes
  /// where widget.state.matchedLocation updates synchronously.
  /// Push routes (notifications, email view, compose) call setAppBarConfig()
  /// from their screen code instead.
  static AppBarConfig _configForRoute(String route, {Uri? uri}) {
    const searchRoutes = [
      '/inbox',
      '/drafts',
      '/archive',
      '/sent',
      '/trash',
      '/contacts',
    ];
    // Only show search bar for top-level list routes, not for detail/sub-pages.
    final hasSearch = searchRoutes.any(
      (r) => route == r || route.startsWith('$r?'),
    );

    // /tags?id=xxx is a specific tag email list — leave title empty so the
    // screen can set the actual tag name. /tags without id= is the tag list.
    final isTagEmailList =
        route.startsWith('/tags') &&
        uri != null &&
        uri.queryParameters.containsKey('id');

    final title = switch (route) {
      final r when r.startsWith('/inbox') => 'Inbox',
      final r when r.startsWith('/drafts') => 'Drafts',
      final r when r.startsWith('/archive') => 'Archive',
      final r when r.startsWith('/sent') => 'Sent',
      final r when r.startsWith('/trash') => 'Trash',
      final r when r.startsWith('/tags') => isTagEmailList ? '' : 'Tags',
      final r when r.startsWith('/contacts') => 'Contacts',
      final r when r.contains('/subscription/change_payment') =>
        'Payment Method',
      final r when r.contains('/subscription') => 'Subscription',
      final r when r.startsWith('/settings/profile') => 'Profile',
      final r when r.startsWith('/settings/account') => 'Account',
      final r when r.startsWith('/settings') => 'Settings',
      final r when r == '/help' => 'Help Center',
      final r when r.startsWith('/help/') => 'Help Center',
      final r when r.startsWith('/notifications') => 'Notifications',
      _ => '',
    };

    return AppBarConfig(title: title, showSearch: hasSearch);
  }

  /// Top-level routes show hamburger; sub-routes show back arrow.
  static bool _isTopLevelRoute(String location) {
    const topLevel = [
      '/inbox',
      '/drafts',
      '/archive',
      '/sent',
      '/trash',
      '/contacts',
      '/help',
      '/settings',
      '/tags',
    ];
    for (final root in topLevel) {
      if (location == root || location.startsWith('$root?')) return true;
    }
    return false;
  }

  /// Navigate back: for nested go() routes, go to the parent path explicitly
  /// instead of relying on context.pop() which may not work reliably for
  /// nested routes under a ShellRoute.
  ///
  /// When [_appBarConfig.onBackPressed] is set (screen has an overlay open),
  /// the callback runs first to close the overlay. The screen then re-pushes
  /// a config without the callback, so the next press navigates normally.
  void _navigateBack(BuildContext context) {
    if (_appBarConfig.onBackPressed != null) {
      _appBarConfig.onBackPressed!();
      return;
    }
    final route = widget.state.matchedLocation;
    // For nested go() sub-routes, derive parent path
    if (!_isTopLevelRoute(route)) {
      // Special case for contacts sub-routes to ensure we go back to the list
      if (route.startsWith('/contacts/')) {
        context.go(AppRoutes.contacts);
        return;
      }
      final lastSlash = route.lastIndexOf('/');
      if (lastSlash > 0) {
        final parent = route.substring(0, lastSlash);
        context.go(parent);
        return;
      }
    }
    // For push routes or top-level, use pop
    context.pop();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Sidebar, user data, notifications, compose
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _loadSidebarState() async {
    if (_prefsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('sidebarExpanded') &&
        !prefs.containsKey('sidebarExpandedDesktop')) {
      final legacy = prefs.getBool('sidebarExpanded') ?? true;
      await prefs.setBool('sidebarExpandedDesktop', legacy);
      await prefs.remove('sidebarExpanded');
    }
    final newDesktop = prefs.getBool('sidebarExpandedDesktop') ?? true;
    final newTablet = prefs.getBool('sidebarExpandedTablet') ?? false;
    final changed =
        newDesktop != _desktopExpanded || newTablet != _tabletExpanded;
    _desktopExpanded = newDesktop;
    _tabletExpanded = newTablet;
    _prefsLoaded = true;
    if (mounted && changed) setState(() {});
  }

  void toggleSideMenuExpanded() async {
    final isTablet = AppBreakpoints.isTabletLayout(context);
    setState(() {
      if (isTablet) {
        _tabletExpanded = !_tabletExpanded;
      } else {
        _desktopExpanded = !_desktopExpanded;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    final key = isTablet ? 'sidebarExpandedTablet' : 'sidebarExpandedDesktop';
    await prefs.setBool(key, isTablet ? _tabletExpanded : _desktopExpanded);
  }

  void getUserData() {
    userData = ref.read(authProvider).userData;
    if (mounted) setState(() {});
  }

  Future<void> _refreshNotificationBadgeCount() async {
    try {
      final response = await NotificationApi().getNotification({
        "page": 1,
        "limit": 100,
      });
      if (!mounted || response.data == null) return;
      final model = NotificationListModel.fromJson(response.data!);
      if (model.success == true) {
        final count = model.data.notifications
            .where((e) => e.isRead == false)
            .length;
        if (mounted)
          ref.read(countProvider.notifier).updateUnreadNotificationCount(count);
      }
    } catch (_) {}
  }

  void _handleCompose() async {
    if (userData == null || userData!['user'] == null) getUserData();
    if (userData != null && userData!['user'] != null) {
      if (userData!['user']['isFreeUser'] == true) {
        CommonService.animatedToast(freeUserWarning, 'warning', null, true);
        return;
      }
      final token =
          Descope.sessionManager.session?.sessionJwt ?? userData!['token'];
      int pageId = DateTime.now().microsecondsSinceEpoch;
      final int offsetInMinutes = DateTime.now().timeZoneOffset.inMinutes;
      if (!mounted) return;
      context.push(
        AppRoutes.compose,
        extra: {
          'url':
              '${defaultBaseUrl}email/compose?pageId=$pageId&timeZone=$offsetInMinutes',
          'token': token,
          'pageId': pageId,
          'type': 'compose',
          'sourcePage': widget.state.matchedLocation,
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AppBar construction
  // ═══════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildShellAppBar(
    BuildContext context, {
    required bool showSidebar,
    required bool isMobile,
  }) {
    final config = _appBarConfig;
    final shellRoute = widget.state.matchedLocation;
    final isTopLevel = _isTopLevelRoute(shellRoute);
    final goCanPop = GoRouter.of(context).canPop();
    // GoRouter.canPop() is true when a page is pushed (email detail, compose,
    // notifications, etc.). It takes precedence over isTopLevel because push
    // routes don't change shellRoute — /inbox/email?id=xxx still shows
    // shellRoute=/inbox which is top-level, but the user needs a back arrow.
    final canPop = goCanPop || !isTopLevel;
    final fgColor =
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    // ── Leading ─────────────────────────────────────────────────────────
    Widget? leading;
    double? leadingWidth;

    if (config.isSelectionMode) {
      leading = config.selectionLeading;
    } else if (showSidebar) {
      final isTabletLayout = AppBreakpoints.isTabletLayout(context);
      final isCollapsed = isTabletLayout ? !_tabletExpanded : !_desktopExpanded;
      final sidebarWidth = SideMenu.getResponsiveWidth(
        context,
        isCollapsed: isCollapsed,
      );
      leadingWidth = sidebarWidth;
      leading = SizedBox(
        width: sidebarWidth,
        child: isCollapsed
            ? Center(
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: toggleSideMenuExpanded,
                ),
              )
            : Row(
                children: [
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: toggleSideMenuExpanded,
                  ),
                  const SizedBox(width: AppStyles.space4),
                  Expanded(
                    child: SvgPicture.asset(
                      svgWebLogo,
                      height: 24,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space8),
                ],
              ),
      );
    } else if (canPop) {
      // Show back button directly in leading slot only for mobile layout
      leading = Padding(
        padding: const EdgeInsets.only(left: AppStyles.space4),
        child: IconButton(
          icon: SvgPicture.asset(
            svgArrowBack,
            colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
          ),
          onPressed: () => _navigateBack(context),
        ),
      );
    } else {
      leading = Padding(
        padding: const EdgeInsets.only(left: AppStyles.space4),
        child: IconButton(icon: const Icon(Icons.menu), onPressed: openDrawer),
      );
    }

    // ── Title ────────────────────────────────────────────────────────────
    Widget title;
    if (config.isSelectionMode) {
      title = const SizedBox.shrink();
    } else if (!isMobile && config.showSearch) {
      title = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: CustomSearchBar(
          isLightBackground: false,
          onSearch: config.onSearch,
          controller: _searchController,
          focusNode: _searchFocusNode,
        ),
      );
    } else if (!isMobile && (!isTopLevel || goCanPop)) {
      // For desktop, if we can pop, show a back button before the title in the row.
      title = Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              svgArrowBack,
              colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
            ),
            onPressed: () => _navigateBack(context),
          ),
          Text(config.title),
        ],
      );
    } else {
      title = Text(config.title);
    }

    // ── Actions ──────────────────────────────────────────────────────────
    List<Widget> actions;
    if (config.isSelectionMode) {
      actions = config.selectionActions;
    } else if (config.customActions != null) {
      actions = config.customActions!;
    } else {
      actions = [
        if (config.showAddButton && isMobile)
          TextButton.icon(
            onPressed: config.onAdd,
            icon: Icon(Icons.add, color: fgColor),
            label: Text(
              'Add',
              style: TextStyle(color: fgColor, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.space8),
              minimumSize: const Size(0, 48),
            ),
          ),
        if (config.showSearch && isMobile)
          IconButton(
            icon: SvgPicture.asset(
              _mobileSearchOpen ? svgClose : svgSearch,
              colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
            ),
            onPressed: () {
              setState(() => _mobileSearchOpen = !_mobileSearchOpen);
              if (!_mobileSearchOpen) {
                _searchController.clear();
                config.onSearch?.call('');
              }
            },
          ),
        _buildNotificationIcon(),
        if (config.filterWidget != null && isMobile) config.filterWidget!,
      ];
    }

    // Free trial banner
    if (!config.isSelectionMode && !config.hideUpgradeBanner) {
      final isFreeUser = userData?['user']?['isFreeUser'] == true;
      if (isFreeUser && actions.isNotEmpty) {
        actions.insert(
          actions.length - 1,
          _buildUpgradeBanner(context, isMobile),
        );
      }
    }

    // Mobile search bar below AppBar
    PreferredSizeWidget? bottom;
    if (isMobile && config.showSearch && _mobileSearchOpen) {
      bottom = PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppStyles.space8,
            right: AppStyles.space8,
            bottom: AppStyles.space8,
          ),
          child: CustomSearchBar(
            isLightBackground: false,
            onSearch: config.onSearch,
            controller: _searchController,
            focusNode: _searchFocusNode,
          ),
        ),
      );
    }

    final appBarGradient = context.appColors.appBarGradient;

    return AppBar(
      toolbarHeight: 48,
      leading: leading,
      title: title,
      titleSpacing: showSidebar ? 16 : AppStyles.space4,
      actions: actions,
      bottom: bottom,
      leadingWidth: config.isSelectionMode && isMobile
          ? MediaQuery.of(context).size.width * 0.65
          : leadingWidth,
      flexibleSpace: appBarGradient != null
          ? DecoratedBox(
              decoration: BoxDecoration(gradient: appBarGradient),
              child: const SizedBox.expand(),
            )
          : null,
    );
  }

  Widget _buildNotificationIcon() {
    final hasNew =
        ref.watch(countProvider.select((s) => s.newNotification)) != 'no';
    final fgColor =
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;
    return IconButton(
      icon: SvgPicture.asset(
        hasNew ? svgNotification : svgNoNotifications,
        colorFilter: hasNew ? null : ColorFilter.mode(fgColor, BlendMode.srcIn),
      ),
      onPressed: () => context.push(AppRoutes.notifications),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, bool isMobile) {
    return TextButton(
      onPressed: () => context.push(AppRoutes.changeSubscription),
      style: TextButton.styleFrom(
        foregroundColor: context.colors.onPrimary,
        backgroundColor: AppStyles.clickableTextColor,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 4 : 6,
        ),
        minimumSize: Size(isMobile ? 50 : 70, isMobile ? 34 : 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isMobile ? AppStyles.radiusXS : AppStyles.radiusS,
          ),
        ),
      ),
      child: Text(
        'Upgrade',
        style: AppTypography.caption(
          context,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (CommonService.isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonService.showConnectivityBanner();
      });
    }

    ref.listen(countProvider.select((s) => s.newNotification), (prev, next) {
      if (next != 'no' && prev != next) _refreshNotificationBadgeCount();
    });

    // ── Route → title sync ────────────────────────────────────────────
    // Keep the AppBar title in sync with the current route. Covers:
    // 1. Push-page pops (canPop true→false, matchedLocation unchanged)
    // 2. Nested go() route navigations within settings/help
    // Only sync when no screen has overridden the config via setAppBarConfig
    // (custom actions or selection mode indicate a screen-owned config).
    final currentCanPop = GoRouter.of(context).canPop();
    final expectedConfig = _configForRoute(
      widget.state.matchedLocation,
      uri: widget.state.uri,
    );
    final titleStale =
        _appBarConfig.title != expectedConfig.title &&
        !_appBarConfig.isSelectionMode &&
        _appBarConfig.customActions == null &&
        !_screenOverrideTitle;
    final pushPopped = _lastCanPop && !currentCanPop;

    if (titleStale || pushPopped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _screenOverrideTitle = false;
            _appBarConfig = _configForRoute(
              widget.state.matchedLocation,
              uri: widget.state.uri,
            );
            _mobileSearchOpen = false;
            _searchController.clear();
          });
        }
      });
    }
    _lastCanPop = currentCanPop;

    final bool isMobile = AppBreakpoints.isMobileLayout(context);
    final bool showSidebar =
        (kIsWeb &&
            (AppBreakpoints.isDesktopLayout(context) ||
                AppBreakpoints.isTabletLayout(context))) ||
        (!kIsWeb && !isMobile);

    final appBar = _buildShellAppBar(
      context,
      showSidebar: showSidebar,
      isMobile: isMobile,
    );
    final routeKey = ValueKey(widget.state.matchedLocation);

    if (!showSidebar) {
      final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      return Scaffold(
        key: _mobileScaffoldKey,
        appBar: appBar,
        drawer: const MyDrawer(),
        bottomNavigationBar: isKeyboardVisible
            ? null
            : const AppNavigationBar(),
        body: KeyedSubtree(key: routeKey, child: widget.child),
      );
    }

    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isExpanded = isTablet ? _tabletExpanded : _desktopExpanded;
    final isCollapsed = !isExpanded;

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          if (ref.watch(authProvider.select((s) => s.isAuthenticated)))
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: SideMenu.getResponsiveWidth(
                context,
                isCollapsed: isCollapsed,
              ),
              child: SideMenu(
                onItemSelected: (route) {
                  // If a push route (e.g. notifications) is on top, reset the
                  // AppBar config before navigating. Don't pop() — go() replaces
                  // the entire stack, and popping first causes a visual flash.
                  if (GoRouter.of(context).canPop()) {
                    setState(() {
                      _appBarConfig = _configForRoute(route);
                      _mobileSearchOpen = false;
                    });
                    _searchController.clear();
                  }
                  context.go(route);
                },
                selectedItem: GoRouter.of(context).canPop()
                    ? '' // Push route on top — deselect all menu items
                    : widget.state.matchedLocation,
                onCompose: _handleCompose,
                isCollapsed: isCollapsed,
                onToggleCollapse: toggleSideMenuExpanded,
              ),
            ),
          Expanded(
            child: KeyedSubtree(key: routeKey, child: widget.child),
          ),
        ],
      ),
    );
  }
}
