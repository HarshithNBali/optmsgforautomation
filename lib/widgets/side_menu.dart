import 'dart:async';

import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/services/count_notifier.dart';
import 'package:optmsg/widgets/web_menu_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/widgets/side_menu_tags_section.dart';

class SideMenu extends ConsumerStatefulWidget {
  final Function(String) onItemSelected;
  final String selectedItem;
  final VoidCallback? onCompose;
  final bool isCollapsed; // Collapse state controlled by parent
  final VoidCallback? onToggleCollapse; // Callback to toggle collapse

  const SideMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedItem,
    this.onCompose,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  /// Get responsive sidebar width based on screen size
  static double getResponsiveWidth(BuildContext context,
      {bool isCollapsed = false}) {
    if (isCollapsed) return 64.0;

    final screenWidth = MediaQuery.of(context).size.width;

    // Large desktop (>= 1440px): 220px fixed width
    if (screenWidth >= AppBreakpoints.largeDesktop) {
      return 220.0;
    }
    // Desktop (>= 1024px): 210px fixed width
    if (screenWidth >= AppBreakpoints.desktop) {
      return 210.0;
    }
    // Tablet (>= 600px): 200px fixed width
    if (screenWidth >= AppBreakpoints.tablet) {
      return 200.0;
    }
    // Mobile: 75% of screen (for drawer)
    return screenWidth * 0.75;
  }

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  String token = "";
  Map<String, dynamic>? userData;
  final SecureStorageService secureStorageService = SecureStorageService();
  Timer? _initTimer;

  @override
  void initState() {
    _setupListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final countState = ref.watch(countProvider);
    final isCollapsed = widget.isCollapsed;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header removed — hamburger + logo now live in ShellLayout's AppBar.
          // Menu items with smooth transition
          Expanded(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ListView(
                  key: ValueKey<bool>(isCollapsed),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 0.0,
                  ),
                  children: _buildMenuItems(countState),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(CountState countState) {
    final bool isCollapsed = widget.isCollapsed;
    return [
      WebMenuItems(
        title: inbox,
        labelText:
            countState.inboxCount > 0 ? countState.inboxCount.toString() : null,
        svgIcon: svgInbox,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.inbox);
        },
        isSelected: widget.selectedItem == AppRoutes.inbox,
      ),
      WebMenuItems(
        title: draft,
        svgIcon: svgDraft,
        draft: true,
        labelText:
            countState.draftCount > 0 ? countState.draftCount.toString() : null,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.drafts);
        },
        isSelected: widget.selectedItem == AppRoutes.drafts,
      ),
      WebMenuItems(
        title: archive,
        svgIcon: svgArchive,
        labelText: countState.archiveCount > 0
            ? countState.archiveCount.toString()
            : null,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.archive);
        },
        isSelected: widget.selectedItem == AppRoutes.archive,
      ),
      WebMenuItems(
        title: sent,
        svgIcon: svgSent,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.sent);
        },
        isSelected: widget.selectedItem == AppRoutes.sent,
      ),
      WebMenuItems(
        title: trash,
        svgIcon: svgTrash1,
        labelText:
            countState.trashCount > 0 ? countState.trashCount.toString() : null,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.trash);
        },
        isSelected: widget.selectedItem == AppRoutes.trash,
      ),
      WebMenuItems(
        title: contacts,
        svgIcon: svgRoundUser,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.contacts);
        },
        isSelected: widget.selectedItem == AppRoutes.contacts,
      ),
      WebMenuItems(
        title: helpCenter,
        svgIcon: svgHelp,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.helpCenter);
        },
        isSelected: widget.selectedItem == AppRoutes.helpCenter,
      ),
      WebMenuItems(
        title: settings,
        svgIcon: svgSettings,
        isCollapsed: isCollapsed,
        onTap: () {
          widget.onItemSelected(AppRoutes.settings);
        },
        isSelected: widget.selectedItem == AppRoutes.settings,
      ),
      const SizedBox(height: 8),
      Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
        indent: isCollapsed ? 16 : 20,
        endIndent: isCollapsed ? 16 : 20,
      ),
      const SizedBox(height: 4),
      SideMenuTagsSection(
        isCollapsed: isCollapsed,
        selectedItem: widget.selectedItem,
        onItemSelected: widget.onItemSelected,
        onToggleCollapse: widget.onToggleCollapse,
      ),
    ];
  }

  /// This function is used to initialize the socket connection and get the user data.
  Future<void> _setupListeners() async {
    try {
      getUserData();
      if (!mounted) return;
      if (userData?['user'] == null) return;
      _initTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        // Just trigger the events, response will be handled by SocketService -> countProvider
        SocketService().emitEventWithAck(
          'unReadCount',
          {"userId": userData!['user']['id']},
        );

        SocketService().emitEventWithAck(
          'notificationExists',
          {"userId": userData!['user']['id']},
        );
      });
    } catch (e) {
      // Initialization error
    }
  }

  void getUserData() {
    final data = ref.read(authProvider).userData;
    if (data != null && mounted) {
      setState(() {
        userData = data;
        token = data['token'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }
}
