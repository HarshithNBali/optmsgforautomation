import 'package:descope/descope.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/email/inbox_riverpod/layouts/inbox_desktop_layout.dart';
import 'package:optmsg/screens/email/inbox_riverpod/layouts/inbox_mobile_layout.dart';
import 'package:optmsg/screens/email/inbox_riverpod/layouts/inbox_tablet_layout.dart';
import 'package:optmsg/widgets/upgrade_plan_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/widgets/standard_fab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/app_config.dart';
import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../services/common_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/tags_provider.dart';
import '../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../widgets/add_email_modal.dart';
import '../../../widgets/pop_up_modal_tag_list.dart';
import '../../../services/bottom_nav_provider.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'inbox_notifier.dart';
import 'inbox_state.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';

class InboxResponsive extends ConsumerStatefulWidget {
  final String type;
  final VoidCallback? onLongPress;
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;
  final int? selectedEmailId;
  final int? tagId;
  final String? tagName;

  const InboxResponsive({
    super.key,
    required this.type,
    this.onLongPress,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
    this.selectedEmailId,
    this.tagId,
    this.tagName,
  });

  @override
  ConsumerState<InboxResponsive> createState() => InboxResponsiveState();
}

GlobalKey<InboxResponsiveState> inboxResponsiveKey = GlobalKey();

class InboxResponsiveState extends ConsumerState<InboxResponsive>
    with WidgetsBindingObserver {
  final TextEditingController searchController = TextEditingController();
  final _focusNode = FocusNode();
  TagsState? tagState;
  bool _hasInitializedOverlays = false;
  bool _wasNavigatedAway = false;
  DeviceType? _lastDeviceType;
  double? _lastScreenWidth;
  bool isDialogShow = false;
  String addPasskey = 'add-passkey';
  final SecureStorageService secureStorageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tagState = ref.read(tagsProvider);
    // Always clear overlay states when page initializes (M-02: moved out of build()).
    _scheduleOverlayInit();
    // Push AppBar config once on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pushAppBarConfig();
    });
    // Re-push AppBar config when selection mode changes (long-press, select-all, etc.)
    ref.listenManual(
      inboxProvider.select((s) => (s.longPressFlag, s.selectedEmailIds.length)),
      (_, _) {
        if (mounted) _pushAppBarConfig();
      },
    );
    // Re-push AppBar config when filter/overlay state changes so the mobile
    // filter icon updates and onBackPressed stays in sync with overlay state.
    ref.listenManual(
      inboxProvider.select((s) => (
        s.emailType,
        s.tagFilter,
        s.showFilter,
        s.showTagList,
        s.showMenuOptions,
        s.showMoveOverlay,
      )),
      (_, _) {
        if (mounted) _pushAppBarConfig();
      },
    );

    // Always bootstrap/reload - same as draft and archive pages
    // Note: bootstrap() already handles tag loading via _maybeLoadTags()
    // Don't preserve reading pane on init - start with empty reading pane like archive
    // Resize case is handled separately in didChangeDependencies
    Future.microtask(() async {
      try {
        await ref
            .read(inboxProvider.notifier)
            .bootstrap(
              preserveReadingPane: false,
              emailIdToRestore: widget.selectedEmailId,
              initialTagId: widget.tagId,
              initialEmailType: widget.tagId != null ? 'all' : null,
            );
        // Bootstrap complete — userData is now loaded. Safe to check upgrade popup.
        if (kIsWeb && widget.type == 'inbox') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _checkAndShowUpgradePopup();
          });
        }
      } catch (e) {
        // Bootstrap failed
      }
    });

    // Initialize device type tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastDeviceType = AppBreakpoints.deviceType(context);
        _lastScreenWidth = AppBreakpoints.screenWidth(context);
      }
    });

    //CommonService().getLastActivity(context);

    // Check if the passkey page set the upgrade-popup trigger flag before
    // navigating here.  Checked once in initState, not on every rebuild.
    if (kIsWeb && widget.type == 'inbox') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        final shouldTrigger =
            prefs.getBool('triggerUpgradePopupOnInbox') ?? false;
        if (shouldTrigger) {
          await prefs.setBool('triggerUpgradePopupOnInbox', false);
          if (mounted) _checkAndShowUpgradePopup();
        }
      });
    }
    // C-01 fix: ref.listen must not be called inside build().
    // Register all listeners once here in initState() using ref.listenManual.
    ref.listenManual(bottomNavProvider.select((s) => s.currentIndex), (
      previous,
      next,
    ) {
      if (previous != null && previous != 0 && next == 0) {
        // User returned to the inbox tab from another tab.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _wasNavigatedAway = false;
            ref.read(inboxProvider.notifier).clearOverlayStates();
            ref.read(inboxProvider.notifier).bootstrap();
            _scheduleOverlayInit();
          }
        });
      }
    });

    // Guard (kIsWeb) is inside the listener callback, not around the registration.
    ref.listenManual(
      inboxProvider.select(
        (s) => s.selectedEmailIds.isNotEmpty && !s.showCheckboxes,
      ),
      (_, shouldActivate) {
        if (kIsWeb && shouldActivate == true) {
          ref.read(inboxProvider.notifier).setShowCheckboxes(true);
        }
      },
    );

    // M-10: Show AddEmailModal in UI when notifier sets pendingOptInEmail.
    ref.listenManual(
      inboxProvider.select((s) => s.pendingOptInEmail),
      (previous, next) {
        if (next == null || !mounted) return;
        final s = ref.read(inboxProvider);
        final emails = s.pendingOptInEmails;
        final emailIndex = emails.indexOf(next);
        showDialog<String>(
          context: context,
          builder: (ctx) => AddEmailModal(
            title: addEmail,
            type: emails.length > 1 ? 'Multiple' : 'longPress',
            subtitleFirst: next,
            subtitle: addEmailcontact,
            contact: null,
            saveFlag: () async {},
            currentIndex: emailIndex >= 0 ? emailIndex : 0,
            totalEmails: emails.length,
            senderDisplayName: s.pendingOptInSenderName,
          ),
        ).then((result) {
          if (mounted) {
            ref.read(inboxProvider.notifier).handleOptInDialogResult(result);
          }
        });
      },
    );

    // M-10: Show PopUpModalTagList in UI when notifier sets showTagDialog.
    ref.listenManual(
      inboxProvider.select((s) => s.showTagDialog),
      (previous, next) {
        if (next != true || !mounted) return;
        final s = ref.read(inboxProvider);
        final n = ref.read(inboxProvider.notifier);
        final tagState = ref.read(tagsProvider);
        showDialog(
          context: context,
          builder: (ctx) => PopUpModalTagList(
            loading: false,
            title: 'Tags',
            title2: 'Create',
            getTagsApi: n.getAllTags,
            showList: n.showList,
            initialSelectedTagIds: s.selectedTagIds,
            itemList: tagState.tagsList?.data.tags ?? [],
            emailId: s.tagDialogEmailId,
            itemIndex: s.tagDialogItemIndex,
            onTagDeleted: (tagId) async {},
            onPressedButton2: () async {
              await n.handleTagDialogSave();
            },
            textButton1: 'Cancel',
            textButton2: 'Add',
            callback: (value) {
              ref.read(inboxProvider.notifier).updateSelectedTagIds(value);
            },
          ),
        ).then((_) {
          if (mounted) {
            ref.read(inboxProvider.notifier).dismissTagDialog();
          }
        });
      },
    );
  }


  Future<void> _checkAndShowUpgradePopup() async {
    try {
      if (!mounted) return;

      // Check if passkey page is currently open via SharedPreferences flag
      // This is needed because context.push() doesn't change the URL on web
      SharedPreferences prefsCheck = await SharedPreferences.getInstance();
      bool isPasskeyPageOpen = prefsCheck.getBool('isPasskeyPageOpen') ?? false;
      if (isPasskeyPageOpen) {
        return;
      }

      // CRITICAL: Check if inbox is the current visible route (not covered by another page)
      // This prevents popup from showing when passkey or other pages are pushed on top
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) {
        // Another page (like passkey) is on top, don't show popup
        return;
      }

      // Use GoRouter to get the actual current top-level route
      // This correctly detects when passkey or other pages are pushed on top
      if (!mounted) return;
      final router = GoRouter.of(context);
      final currentFullPath =
          router.routerDelegate.currentConfiguration.fullPath;

      // If we're not on the inbox route (e.g., passkey is showing), don't show popup
      if (!currentFullPath.startsWith(AppRoutes.inbox) ||
          currentFullPath.contains('passkey') ||
          currentFullPath.contains(addPasskey)) {
        return;
      }

      final userData = ref.read(inboxProvider).userData;
      if (userData == null || userData['user'] == null) {
        return;
      }

      final isFreeUser = userData['user']['isFreeUser'];
      final subscriptionEndDate = userData['user']['subscriptionEndDate'];

      // Show popup for free/reader users:
      // 1. isFreeUser == true (new reader accounts)
      // 2. isFreeUser == null but subscriptionEndDate exists (old reader accounts without the flag)
      // Don't show for isFreeUser == false (paid users) or if no subscription end date
      if (isFreeUser == false ||
          (isFreeUser != true && subscriptionEndDate == null)) {
        // Not a free user - either explicitly paid or unknown without reader plan
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      bool popupShown = false;
      if (kIsWeb) {
        final String? value = await secureStorageService.readData(
          "upgradePopupShownAfterLogin",
        );
        popupShown = value == "true";
      } else {
        popupShown = prefsCheck.getBool('upgradePopupShownAfterLogin') ?? false;
      }

      printLog("popupShown", popupShown);
      if (popupShown) {
        return;
      }
      isDialogShow = true;
      if (!mounted) return;

      // Double-check we're still on inbox route before showing dialog
      final recheckPath = GoRouter.of(
        context,
      ).routerDelegate.currentConfiguration.fullPath;
      if (!recheckPath.startsWith(AppRoutes.inbox) ||
          recheckPath.contains('passkey') ||
          recheckPath.contains(addPasskey)) {
        return;
      }

      String userEmail = userData['user']['userName'] ?? 'your email';
      if (userEmail.isNotEmpty && !userEmail.contains('@')) {
        userEmail = '$userEmail@optmsg.com';
      }

      if (mounted) {
        // Final check: ensure we're still on inbox before showing dialog
        final finalPath = GoRouter.of(
          context,
        ).routerDelegate.currentConfiguration.fullPath;
        final isOnInbox =
            finalPath.startsWith(AppRoutes.inbox) &&
            !finalPath.contains('passkey') &&
            !finalPath.contains(addPasskey);
        if (isOnInbox) {
          // M-04: Mark popup as shown only after we confirm we will show it.
          await prefs.setBool('upgradePopupShownAfterLogin', true);
          if (kIsWeb) {
            await secureStorageService.writeData(
              'upgradePopupShownAfterLogin',
              "true",
            );
          }
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 24,
                ),
                child: upgradePlanPopup(
                  context: dialogContext,
                  userEmail: userEmail,
                  subscriptionEndDate: subscriptionEndDate,
                  onUpgrade: () {
                    Navigator.of(dialogContext).pop();
                    // M-02: pushReplacement keeps a single stack entry;
                    // push().then(go()) was unreliable in go_router v17.
                    context.pushReplacement(AppRoutes.changeSubscription);
                    isDialogShow = false;
                  },
                  onClose: () {
                    isDialogShow = false;
                    Navigator.of(dialogContext).pop();
                  },
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      printLog("Upgrade Popup Error", e.toString());
    }
  }

  /// M-02: Schedules a post-frame callback that clears overlay states and marks
  /// overlays as initialised.  Call this instead of mutating
  /// [_hasInitializedOverlays] directly so that the side-effect never
  /// originates inside [build].
  void _scheduleOverlayInit() {
    _hasInitializedOverlays = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitializedOverlays) {
        ref.read(inboxProvider.notifier).clearOverlayStates();
        setState(() {
          _hasInitializedOverlays = true;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // C-02 fix: route-state mutations must not happen inside build().
    // didChangeDependencies() is called by the framework when ModalRoute (an
    // InheritedWidget) changes, e.g. when another route is pushed/popped.
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _wasNavigatedAway) {
      _wasNavigatedAway = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(inboxProvider.notifier).clearOverlayStates();
          _pushAppBarConfig(); // Restore search/filter in AppBar after return
          if (kIsWeb && widget.type == 'inbox') {
            _checkAndShowUpgradePopup();
          }
        }
      });
    } else if (route != null && !route.isCurrent && !_wasNavigatedAway) {
      _wasNavigatedAway = true;
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (!kIsWeb) {
        // await ref.read(inboxProvider.notifier).filterContactsToJson();
        final inboxState = ref.read(inboxProvider);
        await CommonService().updateBadge(inboxState.badgeCount);
      }
    }
  }

  @override
  void didUpdateWidget(InboxResponsive oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selectedEmailId changed (e.g. via URL navigation), update the selection in notifier
    // without doing a full bootstrap/reload of the entire list.
    // Use addPostFrameCallback to avoid modifying provider state during the build phase.
    if (widget.selectedEmailId != oldWidget.selectedEmailId &&
        widget.selectedEmailId != null) {
      final emailId = widget.selectedEmailId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(inboxProvider.notifier)
              .setSelectedEmailIdForReadingPane(emailId);
        }
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Detect screen size changes and handle layout updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Don't reload if a dialog is open (route.isCurrent is false when dialog is shown)
        final route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) {
          return; // Skip metrics handling when a dialog is open
        }

        final currentDeviceType = AppBreakpoints.deviceType(context);
        final currentScreenWidth = AppBreakpoints.screenWidth(context);

        final deviceTypeChanged =
            _lastDeviceType != null && _lastDeviceType != currentDeviceType;

        // Handle device type changes (mobile <-> tablet <-> desktop)
        if (deviceTypeChanged) {
          final previousDeviceType = _lastDeviceType;
          _lastDeviceType = currentDeviceType;
          _lastScreenWidth = currentScreenWidth;

          // Preserve reading pane selection when changing device types
          final currentSelection = ref
              .read(inboxProvider)
              .selectedEmailIdForReadingPane;
          final currentIndex = ref.read(inboxProvider).selectedEmailIndex;

          // Clear overlays but DON'T call bootstrap() which clears reading pane selection
          ref.read(inboxProvider.notifier).clearOverlayStates();

          // When going from mobile to tablet/desktop, restore reading pane selection
          // The selection should already be preserved in state
          if (previousDeviceType == DeviceType.mobile &&
              (currentDeviceType == DeviceType.tablet ||
                  currentDeviceType == DeviceType.desktop)) {
            // Restore selection if we have one stored
            if (currentSelection != null) {
              ref
                  .read(inboxProvider.notifier)
                  .setSelectedEmailIdForReadingPane(
                    currentSelection,
                    currentIndex,
                  );
            }
          }

          // Reset initialization flag to ensure overlays are hidden
          _scheduleOverlayInit();
        } else {
          // For window resize within same device type, just trigger a rebuild
          // without clearing the email list or reading pane selection
          final screenSizeChanged =
              _lastScreenWidth != null &&
              (_lastScreenWidth! - currentScreenWidth).abs() > 50;

          if (screenSizeChanged) {
            _lastScreenWidth = currentScreenWidth;

            // Just clear overlay states and trigger rebuild, keep emails and selection
            _scheduleOverlayInit();
          } else {
            // Update tracking even if no action needed
            _lastDeviceType = currentDeviceType;
            _lastScreenWidth = currentScreenWidth;
          }
        }
      }
    });
  }

  // PERF-01: Use ref.read for the getter so callbacks outside build() don't
  // incorrectly call ref.watch. The build() method registers the rebuild
  // subscription explicitly via ref.watch at the top.
  InboxState get s => ref.read(inboxProvider);
  InboxNotifier get n => ref.read(inboxProvider.notifier);

  void _onSearchChanged(String value) {
    n.onSearchChanged(value);
  }

  void _onLongPress(int? id, String? email) {
    n.onLongPress(id, email);
    if (widget.onLongPress != null) widget.onLongPress!();
  }

  /// B-05: Build a lookup map once per rebuild instead of O(n) indexWhere
  /// per selected email. The map is rebuilt only when items identity changes.
  Map<int, bool>? _readStatusCache;
  Object? _lastItemsIdentity;

  Map<int, bool> _getReadStatusMap() {
    final items = s.items;
    if (!identical(items, _lastItemsIdentity)) {
      _readStatusCache = {for (final e in items) e.emailId: e.isRead};
      _lastItemsIdentity = items;
    }
    return _readStatusCache!;
  }

  String _computeMarkActionTitle() {
    final readMap = _getReadStatusMap();
    final selectedIds = s.selectedEmailIds;

    if (selectedIds.isEmpty && s.selectedEmailIdForReadingPane != null) {
      final isRead = readMap[s.selectedEmailIdForReadingPane];
      if (isRead != null) return isRead ? markUnread : markRead;
      return markUnread;
    }
    if (selectedIds.isEmpty) return markUnread;

    final statuses = <bool>[];
    for (final id in selectedIds) {
      final isRead = readMap[id];
      if (isRead != null) statuses.add(isRead);
    }
    if (statuses.isEmpty) return 'Mark';

    if (selectedIds.length == 1) {
      return statuses.first ? markUnread : markRead;
    }
    final allRead = statuses.every((s) => s);
    final allUnread = statuses.every((s) => !s);
    if (allRead) return markUnread;
    if (allUnread) return markRead;
    return markUnread;
  }

  String _getSelectionState() {
    final readMap = _getReadStatusMap();
    final ids = s.selectedEmailIds;
    if (ids.isEmpty) return 'none';

    final statuses = <bool>[];
    for (final id in ids) {
      final isRead = readMap[id];
      if (isRead != null) statuses.add(isRead);
    }
    if (statuses.isEmpty) return 'none';

    if (ids.length == 1) {
      return statuses.first ? 'singleRead' : 'singleUnread';
    }
    final allRead = statuses.every((s) => s);
    final allUnread = statuses.every((s) => !s);
    if (allRead) return 'allRead';
    if (allUnread) return 'allUnread';
    return 'mixed';
  }

  String _getMarkActionIcon() {
    final readMap = _getReadStatusMap();
    final selectedIds = s.selectedEmailIds;

    if (selectedIds.isEmpty && s.selectedEmailIdForReadingPane != null) {
      final isRead = readMap[s.selectedEmailIdForReadingPane];
      if (isRead != null) return isRead ? svgUnread : svgRead;
      return svgUnread;
    }

    final selectionState = _getSelectionState();
    if (selectionState == 'singleRead' || selectionState == 'allRead') {
      return svgUnread;
    }
    return svgRead;
  }

  /// Push the correct AppBarConfig for the current state.
  void _pushAppBarConfig() {
    if (!mounted) return;
    final isInSelectionMode = !s.longPressFlag || s.selectedEmailIds.isNotEmpty;
    // Only show selection-mode AppBar on small screens.
    // Medium/large screens handle multi-select in the list header & action bar.
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (!isInSelectionMode || !isMobile) {
      // Normal mode — title comes from route via ShellLayout.didUpdateWidget
      ShellLayout.of(context)?.setAppBarConfig(
            AppBarConfig(
              showSearch: true,
              onSearch: _onSearchChanged,
              filterWidget: _buildFilterWidget(),
            ),
          );
    } else {
      // Selection mode — mobile only
      ShellLayout.of(context)?.setAppBarConfig(
            AppBarConfig(
              title: '',
              isSelectionMode: true,
              selectionLeading: _buildSelectionLeadingWidget(),
              selectionActions: _buildSelectionActionsWidgets(),
            ),
          );
    }
  }

  Widget? _buildFilterWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.emailType == 'inbox' && !s.tagFilter)
          IconButton(
            icon: SvgPicture.asset(svgFilter),
            onPressed: () {
              n.toggleFilter();
            },
          ),
        if (s.emailType == 'unread')
          IconButton(
            icon: SvgPicture.asset(
              svgUnread,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              n.clearUnreadFilter(s.searchKey);
            },
            tooltip: 'Clear Unread Filter',
          ),
        if (s.tagFilter)
          IconButton(
            icon: SvgPicture.asset(
              svgTags,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              n.clearTagFilterAndRefresh(s.searchKey);
            },
            tooltip: 'Clear Tag Filter',
          ),
      ],
    );
  }

  Widget _buildSelectionLeadingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: () {
            _onLongPress(null, null);
          },
          icon: SvgPicture.asset(
            svgLeftArrow,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        IconButton(
          icon: s.allEmailIdsFlag
              ? const Icon(Icons.check_box)
              : s.selectedEmailIds.isNotEmpty
                  ? const Icon(Icons.indeterminate_check_box)
                  : const Icon(Icons.check_box_outline_blank),
          onPressed: _handleSelectAllEmails,
        ),
        Text(
          s.allEmailIdsFlag
              ? 'All Selected (${s.selectedCount})'
              : s.selectedEmailIds.isNotEmpty
                  ? '${s.selectedCount} selected'
                  : selectAll,
          style: AppTypography.labelMedium(context).copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActionsWidgets() {
    return [
      IconButton(
        icon: SvgPicture.asset(
          svgOptin,
          height: 24,
          width: 24,
        ),
        onPressed: () {
          if (s.selectedEmails.isNotEmpty) {
            List<String> uniqueEmails = s.selectedEmails.toSet().toList();
            ref.read(inboxProvider.notifier).startAddEmailFlow(uniqueEmails);
          }
        },
      ),
      IconButton(
        onPressed: () {
          n.handleDelete();
        },
        icon: SvgPicture.asset(
          svgDelete,
          height: 24,
          width: 24,
        ),
      ),
      IconButton(
        onPressed: () {
          n.handleArchive();
        },
        icon: SvgPicture.asset(
          svgArchive,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
      IconButton(
        onPressed: () {
          n.toggleMenuOptions();
        },
        icon: SvgPicture.asset(
          svgMoreHori,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // PERF-01: Explicit watch registers rebuild subscription. The `s` getter
    // uses ref.read so it is safe in both build helpers and event callbacks.
    ref.watch(inboxProvider);

    // AppBar config pushed in initState + on selection mode changes only.
    // NOT on every build — prevents stale callbacks after navigation.

    final tagsListModel = tagState!.tagsList;
    final tagsList = tagsListModel?.data.tags ?? [];
    // Only show reading pane selection in action bar when reading pane is active
    // This ensures action ribbon doesn't show when returning from full-screen detail view
    final bool hasReadingPaneSelection =
        s.readingPaneEnabledWeb && s.selectedEmailIdForReadingPane != null;
    final bool hasListSelection = s.selectedEmailIds.isNotEmpty;
    final bool hasAnySelection = hasReadingPaneSelection || hasListSelection;
    final String currentMenuLabel = CommonService().capitalize(
      s.emailType ?? 'Inbox',
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Only exit the app on Android native; web and iOS do not support
        // programmatic app exit and will no-op or throw.
        if (!didPop && !kIsWeb) {
          SystemNavigator.pop();
        }
      },
      child: Stack(
        children: [
          _buildBody(
            tagsList,
            tagsListModel,
            currentMenuLabel,
            hasAnySelection,
            hasReadingPaneSelection,
          ),
          StandardFab(
            iconAsset: svgComposeIcon,
            onPressed: _gotoCompose,
            heroTag: 'InboxResponsive',
            visible: s.longPressFlag && AppBreakpoints.isMobileLayout(context),
          ),
        ],
      ),
    );
  }


  void resetReadingPane() {
    n.clearReadingPaneSelection();
  }

  Widget _buildBody(
    List tagsList,
    TagsListModel? tagsListModel,
    String currentMenuLabel,
    bool hasAnySelection,
    bool hasReadingPaneSelection,
  ) {
    // Show delayed spinner during initial load (no items yet).
    // DelayedLoadingOverlay handles the 600ms delay internally.
    // Matches archive's pattern: only check isLoading, not inboxList == null.
    // isLoading defaults to true and is only set false after API completes.
    if (s.items.isEmpty && s.isLoading) {
      return const DelayedLoadingOverlay(
        isLoading: true,
        child: SizedBox.shrink(),
      );
    }

    // Hide overlays until state has been cleared (prevents flash of old state)
    final hideOverlays = !_hasInitializedOverlays;

    // Use device type detection that works for both web and native apps
    // This ensures tablets show tablet layout, not mobile layout
    final deviceType = AppBreakpoints.deviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return InboxMobileLayout(
          tagsList: tagsList,
          tagsListModel: tagsListModel,
          searchController: searchController,
          hideOverlays: hideOverlays,
          onBack: () {
            // PM-02: Only clear search UI state on return — don't re-fetch.
            // Mutations (archive, trash, tags) are handled by the result map
            // from ViewEmail; read-only views don't need a refresh.
            searchController.clear();
            n.setSearchKey('');
          },
        );
      case DeviceType.tablet:
        return MediaQuery.of(context).orientation == Orientation.landscape
            ? InboxDesktopLayout(
                state: s,
                notifier: n,
                tagsList: tagsList,
                tagsListModel: tagsListModel,
                currentMenuLabel: currentMenuLabel,
                hasAnySelection: hasAnySelection,
                hasReadingPaneSelection: hasReadingPaneSelection,
                onCompose: _gotoCompose,
                onReply: _gotoReply,
                getMarkActionIcon: _getMarkActionIcon,
                computeMarkActionTitle: _computeMarkActionTitle,
                getSelectionState: _getSelectionState,
                onMarkAsRead: _handleMarkAsReadAction,
                onMarkAsUnread: _handleMarkAsUnreadAction,
              )
            : InboxTabletLayout(
                state: s,
                notifier: n,
                tagsList: tagsList,
                tagsListModel: tagsListModel,
                currentMenuLabel: currentMenuLabel,
                hasAnySelection: hasAnySelection,
                hasReadingPaneSelection: hasReadingPaneSelection,
                onCompose: _gotoCompose,
                onReply: _gotoReply,
                getMarkActionIcon: _getMarkActionIcon,
                computeMarkActionTitle: _computeMarkActionTitle,
                getSelectionState: _getSelectionState,
                onMarkAsRead: _handleMarkAsReadAction,
                onMarkAsUnread: _handleMarkAsUnreadAction,
              );
      case DeviceType.desktop:
        return InboxDesktopLayout(
          state: s,
          notifier: n,
          tagsList: tagsList,
          tagsListModel: tagsListModel,
          currentMenuLabel: currentMenuLabel,
          hasAnySelection: hasAnySelection,
          hasReadingPaneSelection: hasReadingPaneSelection,
          onCompose: _gotoCompose,
          onReply: _gotoReply,
          getMarkActionIcon: _getMarkActionIcon,
          computeMarkActionTitle: _computeMarkActionTitle,
          getSelectionState: _getSelectionState,
          onMarkAsRead: _handleMarkAsReadAction,
          onMarkAsUnread: _handleMarkAsUnreadAction,
        );
    }
  }


  void _handleSelectAllEmails() {
    if (s.allEmailIdsFlag) {
      n.clearSelection();
    } else {
      n.selectAllFromList();
    }
  }

  Future<void> _gotoCompose() async {
    final userData = s.userData;
    if (userData == null) return;

    if (userData['user']['isFreeUser'] == true) {
      CommonService.animatedToast(freeUserWarning, 'warning', null, true);
      return;
    }

    final pageId = DateTime.now().microsecondsSinceEpoch;
    final now = DateTime.now();
    final offset = now.timeZoneOffset.inMinutes;
    final sessionJwt = Descope.sessionManager.session?.sessionJwt ?? s.token;
    final composeUrl =
        '${defaultBaseUrl}email/compose?pageId=$pageId&timeZone=$offset';

    // On desktop with reading pane + native compose: open in reading pane
    final isDesktop = !AppBreakpoints.isMobileLayout(context);
    if (useNativeCompose && isDesktop && s.readingPaneEnabledWeb) {
      n.openComposeInReadingPane({'mode': 'compose'});
      return;
    }

    final result = await context.push(
      AppRoutes.compose,
      extra: {
        'url': composeUrl,
        'token': sessionJwt,
        'pageId': pageId,
        'type': 'compose',
        'sourcePage': AppRoutes.inbox,
      },
    );

    // Refresh inbox if email was sent
    if (result == 'emailSent') {
      await n.refresh();
    }
  }

  void _gotoReply(int id, String type) {
    // On desktop with reading pane + native compose: open in reading pane
    final isDesktop = !AppBreakpoints.isMobileLayout(context);
    if (useNativeCompose && isDesktop && s.readingPaneEnabledWeb) {
      n.openComposeInReadingPane({'mode': type, 'emailId': id});
      return;
    }

    final pageId = DateTime.now().microsecondsSinceEpoch;
    final now = DateTime.now();
    final offset = now.timeZoneOffset.inMinutes;

    context.push(
      AppRoutes.compose,
      extra: {
        'type': type,
        'url':
            '${defaultBaseUrl}email/compose?emailId=$id&type=$type&pageId=$pageId&timeZone=$offset',
        'token': Descope.sessionManager.session?.sessionJwt ?? s.token,
        'emailId': id,
        'pageId': pageId,
        'sourcePage': AppRoutes.inbox,
      },
    );
  }

  Future<void> _handleMarkAsReadAction() async {
    if (s.selectedEmailIds.isNotEmpty) {
      await n.markSelectedAsRead();
      _onLongPress(null, null);
    }
  }

  Future<void> _handleMarkAsUnreadAction() async {
    if (s.selectedEmailIds.isNotEmpty) {
      await n.updateEmailStatus('isRead', s.selectedEmailIds, 0);

      // Close reading pane if the viewed email is among those being marked as unread
      if (s.currentlyViewedEmailId != null &&
          s.selectedEmailIds.contains(s.currentlyViewedEmailId)) {
        n.setCurrentlyViewedEmailId(null, null, null);
      }

      _onLongPress(null, null);
    }
  }
}
