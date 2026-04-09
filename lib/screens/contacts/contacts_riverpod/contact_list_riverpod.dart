import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/layouts/mobile_read_pane.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/layouts/tablet_read_pane.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/layouts/web_read_pane.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../model/contact_list_model.dart';
import '../../../widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/widgets/standard_fab.dart';

class ContactListriverpod extends ConsumerStatefulWidget {
  final String? prevEmail;
  final String? type;
  final List<String>? multipleEmails;
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  const ContactListriverpod({
    super.key,
    this.prevEmail,
    this.type,
    this.multipleEmails,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
  });

  @override
  ConsumerState<ContactListriverpod> createState() =>
      _ContactListriverpodState();
}

class _ContactListriverpodState extends ConsumerState<ContactListriverpod>
    with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear selection when widget initializes
      ref.read(contactListProvider.notifier).clearSelection();
      ref.read(contactListProvider.notifier).init();
      _lastOrientation = MediaQuery.of(context).orientation;

      // Push AppBar config once on mount
      if (mounted) {
        _pushAppBarConfig();
      }
    });
    // Re-push AppBar config when multi-select or filter state changes
    ref.listenManual(
      contactListProvider.select((s) => (s.longPressFlag, s.selectedContactIds.length, s.contactTypeFilter)),
      (_, _) {
        if (mounted) _pushAppBarConfig();
      },
    );
  }

  void _pushAppBarConfig() {
    if (!mounted) return;
    final state = ref.read(contactListProvider);
    final notifier = ref.read(contactListProvider.notifier);
    final isMobile = AppBreakpoints.isMobileLayout(context);

    final isInSelectionMode = state.hasMultiSelection;

    if (isInSelectionMode && isMobile) {
      // Selection mode AppBar (mobile only — desktop/tablet handle it in content area)
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: '',
          isSelectionMode: true,
          selectionLeading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5),
              IconButton(
                onPressed: () => notifier.clearMultiSelection(),
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
                icon: state.allContactsFlag
                    ? const Icon(Icons.check_box)
                    : state.selectedContactIds.isNotEmpty
                        ? const Icon(Icons.indeterminate_check_box)
                        : const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  if (state.allContactsFlag) {
                    notifier.clearMultiSelection();
                  } else {
                    notifier.selectAllContacts();
                  }
                },
              ),
              Text(
                state.allContactsFlag
                    ? 'All Selected (${state.selectedCount})'
                    : state.selectedContactIds.isNotEmpty
                        ? '${state.selectedCount} selected'
                        : selectAll,
                style: AppTypography.button(context),
              ),
            ],
          ),
          selectionActions: [
            IconButton(
              icon: SvgPicture.asset(
                svgDelete,
                height: 20,
                width: 20,
              ),
              onPressed: state.isInProcess
                  ? null
                  : () => notifier.handleDeleteSelectedContacts(),
              tooltip: 'Delete',
            ),
          ],
        ),
      );
    } else {
      // Normal AppBar — show +Add in app bar only on tablet/desktop
      // (mobile uses a FAB instead to reduce app bar congestion)
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          showSearch: true,
          searchOpenByDefault: true,
          onSearch: _onSearch,
          showAddButton: !isMobile,
          onAdd: _onAddContact,
          filterWidget: _buildFilterWidget(),
        ),
      );
    }
  }

  Widget? _buildFilterWidget() {
    final state = ref.read(contactListProvider);
    final notifier = ref.read(contactListProvider.notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.contactTypeFilter == 'all')
          IconButton(
            icon: SvgPicture.asset(svgFilter),
            onPressed: () => notifier.toggleFilter(),
          ),
        if (state.contactTypeFilter == 'person')
          IconButton(
            icon: SvgPicture.asset(
              svgContactTypeUser,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => notifier.clearContactTypeFilter(),
            tooltip: 'Clear People Filter',
          ),
        if (state.contactTypeFilter == 'company')
          IconButton(
            icon: SvgPicture.asset(
              svgContactTypeOffice,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => notifier.clearContactTypeFilter(),
            tooltip: 'Clear Companies Filter',
          ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Schedule a rebuild after orientation change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentOrientation = MediaQuery.of(context).orientation;
        if (_lastOrientation != currentOrientation) {
          _lastOrientation = currentOrientation;
          // Clear selection when switching from landscape to portrait on tablet
          // to prevent stale state in the reading pane
          setState(() {});
        }
      }
    });
  }

  void _onSearch(String value) {
    final notifier = ref.read(contactListProvider.notifier);
    notifier.clearSelectionContact();
    // M-07: debounce to avoid filtering on every keystroke
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      notifier.searchFilterContact(value);
    });
  }

  void _clearSearch() {
    searchController.clear();
    ref.read(contactListProvider.notifier).searchFilterContact('');
  }

  Future<void> _onAddContact() async {
    final notifier = ref.read(contactListProvider.notifier);
    final value = await context.push(AppRoutes.addContactriverpod);
    FocusScope.of(context).unfocus();
    notifier.refreshContacts();
    if (value != null &&
        value is Map<String, dynamic> &&
        value['type'] == 'add') {
      final Contacts newContact = value['contact'] as Contacts;
      notifier.addContact(newContact);
      if (mounted) {
        GoRouter.of(context).push(
          AppRoutes.viewContactriverpodPath(newContact.id),
          extra: {
            'contact': newContact,
            'page': 'addContact',
            'onContactUpdated':
                (Map<String, dynamic> updateResult) async {
                  if (updateResult['type'] == 'edit') {
                    notifier.updateContact(updateResult['contact']);
                  } else if (updateResult['type'] == 'delete') {
                    notifier.deleteContactRecord(
                      updateResult['contact'].id,
                    );
                  }
                },
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactListProvider);
    final notifier = ref.read(contactListProvider.notifier);

    // Check if native tablet/iPad in landscape mode
    final deviceType = AppBreakpoints.deviceType(context);

    final bool isNativeTabletLandscape =
        !kIsWeb &&
        MediaQuery.of(context).orientation == Orientation.landscape &&
        deviceType == DeviceType.tablet;
    final bool isReadingPane =
        ((kIsWeb || isNativeTabletLandscape) &&
        state.readingPaneEnabled == true);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: state.isLoading && state.filteredContacts.isEmpty
        ? const DelayedLoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          )
        : ResponsiveLayoutBuilder(
            mobile: (ctx, deviceType, width) {
              final double availableWidth = isReadingPane
                  ? (MediaQuery.of(context).size.width / 3) * 0.7
                  : MediaQuery.of(context).size.width * 0.7;
              return Stack(
                children: [
                  mobileReadPane(
                    state,
                    notifier,
                    context,
                    widget,
                    availableWidth,
                    _clearSearch,
                  ),
                  StandardFab(
                    iconAsset: svgAddIcon,
                    onPressed: _onAddContact,
                    heroTag: 'contactsAddFab',
                    visible: !state.hasMultiSelection,
                  ),
                ],
              );
            },
            tablet: (ctx, deviceType, width) {
              return isNativeTabletLandscape
                  ? webReadPane(state, notifier, context, widget)
                  : tabletReadPane(state, notifier, context, widget);
            },
            desktop: (ctx, deviceType, width) {
              // Always use webReadPane for web desktop or native tablet/iPad landscape to show Add button and reading pane
              if (kIsWeb || isNativeTabletLandscape) {
                return webReadPane(state, notifier, context, widget);
              }
              final double availableWidth =
                  MediaQuery.of(context).size.width * 0.7;
              return mobileReadPane(
                state,
                notifier,
                context,
                widget,
                availableWidth,
                _clearSearch,
              );
            },
          ),
      ),
    );
  }
}
