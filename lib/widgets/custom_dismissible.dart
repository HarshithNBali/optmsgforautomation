import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/global_variable_notifier.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/widgets/draft_email_list.dart';
import 'package:optmsg/widgets/email_list.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/widgets/sent_email_list.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/widgets/pop_up_modal_tag_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import '../common/utilites/logger.dart';

class CustomDismissible extends ConsumerStatefulWidget {
  final List<dynamic> _items;
  final Future<void> Function(List<int>, int, int, String) addEmailTags;
  final String emailType;
  final Future<void> Function(String, List<int>, int) updateEmailStatus;
  final List<dynamic> tagsList;
  final Future<void> Function() onRefresh;
  final VoidCallback onEndReached;
  final List<String> rightActions;
  final bool shouldShowStartPane;
  final Map<String, dynamic>? userData;
  final Function viewDetail;
  final Function? onLongPress;
  final bool? longPress;
  final bool? allEmailIdsFlag;
  final List<int>? selectedEmailIds;
  final List<String>? selectedEmails;
  final Function? setSelectedEmailIds;
  final ScrollController? lstScrollController;
  final int? selectedIndex;
  final Function(int emailId, int index)? onArchiveEmail;
  final Function(int emailId, int index)? onDeleteEmail;
  final Function(String email, int index)? onOptInEmail;
  final Function(int emailId, int index)? onMoveToInboxEmail;
  final int? selectedEmailId;
  final Function(int index)? onShiftClick;
  final Function(int index)? onCtrlClick;
  const CustomDismissible(
      {super.key,
      required items,
      required this.addEmailTags,
      required this.emailType,
      required this.updateEmailStatus,
      required this.tagsList,
      required this.onRefresh,
      required this.onEndReached,
      required this.rightActions,
      required this.shouldShowStartPane,
      this.userData,
      required this.viewDetail,
      this.onLongPress,
      this.longPress,
      this.allEmailIdsFlag,
      this.selectedEmailIds,
      this.selectedEmails,
      this.setSelectedEmailIds,
      this.lstScrollController,
      this.selectedIndex,
      this.onArchiveEmail,
      this.onDeleteEmail,
      this.onOptInEmail,
      this.onMoveToInboxEmail,
      this.selectedEmailId,
      this.onShiftClick,
      this.onCtrlClick})
      : _items = items;

  @override
  ConsumerState<CustomDismissible> createState() => _CustomDismissibleState();
}

class _CustomDismissibleState extends ConsumerState<CustomDismissible> {
  final SecureStorageService secureStorageService = SecureStorageService();
  List<int> selectedEmailIds = [];
  List<String> selectedEmails = [];
  late int totalEmailCount = 0;
  bool allFlag = false;
  List<int> selectedTagIds = [];

  late final ScrollController _scrollController;
  bool _ownController = false;

  // Track modifier keys for Shift/Ctrl+Click multi-select (web only)
  bool _isShiftPressed = false;
  bool _isCtrlOrCmdPressed = false;

  // Drag-to-select state
  bool _isDragSelecting = false;
  int _dragAnchorIndex = -1;
  int _lastDragIndex = -1;
  DateTime? _dragEdgeStart;
  Set<int> _preExistingSelectionIds = {};
  List<String> _preExistingSelectionEmails = [];
  final GlobalKey _listKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};

  bool _handleKeyEvent(KeyEvent event) {
    _updateModifierState();
    return false; // Don't consume the event
  }

  void _updateModifierState() {
    if (!kIsWeb) return;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    _isShiftPressed = keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);
    _isCtrlOrCmdPressed = keys.contains(LogicalKeyboardKey.controlLeft) ||
        keys.contains(LogicalKeyboardKey.controlRight) ||
        keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight);
  }

  /// Auto-scroll the list when the drag finger is near the top or bottom edge.
  /// Speed ramps up gently the longer the finger stays in the edge zone.
  void _handleDragAutoScroll(double globalY) {
    final listRo = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (listRo == null || !listRo.hasSize) return;

    final localY = listRo.globalToLocal(Offset(0, globalY)).dy;
    final listHeight = listRo.size.height;
    const edgeZone = 60.0;
    const baseSpeed = 3.0;
    const maxSpeed = 14.0;
    const rampDuration = Duration(seconds: 2); // Time to reach max speed

    double? direction;
    if (localY < edgeZone) {
      direction = -1; // scroll up
    } else if (localY > listHeight - edgeZone) {
      direction = 1; // scroll down
    }

    if (direction == null) {
      _dragEdgeStart = null;
      return;
    }

    // Start timing when finger first enters edge zone
    _dragEdgeStart ??= DateTime.now();
    final elapsed = DateTime.now().difference(_dragEdgeStart!);
    final progress = (elapsed.inMilliseconds / rampDuration.inMilliseconds)
        .clamp(0.0, 1.0);
    // Ease-in curve for gentle start, faster finish
    final speed = baseSpeed + (maxSpeed - baseSpeed) * (progress * progress);

    final newOffset = (_scrollController.offset + direction * speed)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(newOffset);
  }

  bool get _isInSelectionMode =>
      widget.longPress == true || selectedEmailIds.isNotEmpty;

  /// Whether this list uses the inbox-style item model (EmailList widget).
  /// Tag-filtered ('all') emails share the same data model as inbox.
  bool get _isInboxLikeType =>
      widget.emailType == 'inbox' || widget.emailType == 'all';

  /// Returns the list index at the given global Y position, or -1 if none.
  int _indexAtPosition(double globalY) {
    for (final entry in _itemKeys.entries) {
      final key = entry.value;
      final ro = key.currentContext?.findRenderObject() as RenderBox?;
      if (ro == null || !ro.hasSize || !ro.attached) continue;
      final topLeft = ro.localToGlobal(Offset.zero);
      if (globalY >= topLeft.dy && globalY < topLeft.dy + ro.size.height) {
        return entry.key;
      }
    }
    return -1;
  }

  /// Select all items from [_dragAnchorIndex] to [currentIndex] (inclusive),
  /// merged with any selection that existed before this drag started.
  void _updateDragSelection(int currentIndex) {
    if (_dragAnchorIndex < 0 || currentIndex < 0) return;
    final lo = _dragAnchorIndex < currentIndex ? _dragAnchorIndex : currentIndex;
    final hi = _dragAnchorIndex < currentIndex ? currentIndex : _dragAnchorIndex;

    // Start with the pre-existing selection snapshot
    final ids = Set<int>.from(_preExistingSelectionIds);
    final emails = Set<String>.from(_preExistingSelectionEmails);

    for (int i = lo; i <= hi; i++) {
      if (i >= widget._items.length) break;
      final item = widget._items[i];
      if (_isInboxLikeType) {
        ids.add(item.emailId);
        emails.add(item.email.senderEmail);
      } else if (widget.emailType == 'draft') {
        ids.add(item.id);
        emails.add('');
      } else {
        // archive/sent/trash
        if (item.receivers != null && item.receivers!.isNotEmpty) {
          ids.add(item.receivers![0].emailId!);
          emails.add(item.senderEmail ?? '');
        }
      }
    }

    setState(() {
      selectedEmailIds = ids.toList();
      selectedEmails = emails.toList();
    });
    widget.setSelectedEmailIds?.call(selectedEmailIds, selectedEmails);
  }

  @override
  void initState() {
    super.initState();
    // Initialize local state from widget props
    if (widget.selectedEmailIds != null) {
      selectedEmailIds = List.from(widget.selectedEmailIds!);
    }
    if (widget.selectedEmails != null) {
      selectedEmails = List.from(widget.selectedEmails!);
    }
    // Use provided scroll controller or create our own
    if (widget.lstScrollController != null) {
      _scrollController = widget.lstScrollController!;
    } else {
      _scrollController = ScrollController();
      _ownController = true;
    }
    _scrollController.addListener(_onScroll);
    if (kIsWeb) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }
  }

  /// This function is used to navigate to the view inbox screen.
  void gotoViewDetail(int id, dynamic selectedTag, int index) {
    context.push(
      AppRoutes.viewEmailPath(id.toString(), CommonService().capitalize(widget.emailType)),
      extra: {
        'emailType': CommonService().capitalize(widget.emailType),
        // Don't pass tagsList here as it's a List, not TagsListModel
        // ViewEmail will fetch tags from tagsProvider if needed
        'itemIndex': index,
      },
    ).then((result) {
      if (result != null && result is Map) {
        // Delegate all post-navigation state changes back to the parent
        // notifier via onRefresh rather than directly mutating widget._items.
        if (result['type'] == 'isArchive' ||
            result['type'] == 'isTrash' ||
            result['type'] == 'isDeleted') {
          widget.onRefresh();
        } else {
          // For read-status and tag changes, a refresh syncs state correctly.
          widget.onRefresh();
        }
      }
    });
  }

  /// This function is used to get the background color of the item.
  Color getBgColor(String type) {
    if (type == 'Sent') {
      return context.appColors.statusWarnBg;
    } else if (type == 'Trash') {
      return context.appColors.statusErrorBg;
    } else if (type == 'Archive') {
      return context.appColors.statusInfoBg;
    } else if (type == 'More' || type == 'Inbox') {
      return context.appColors.statusSuccessBg;
    }
    return Colors.transparent;
  }

  /// This function is used to get the text color of the item.
  Color getTextColor(String type) {
    if (type == 'Sent') {
      return context.appColors.statusWarnText;
    } else if (type == 'Trash') {
      return context.appColors.statusErrorText;
    } else if (type == 'Archive') {
      return context.appColors.statusInfoText;
    } else if (type == 'More' || type == 'Inbox') {
      return context.appColors.statusSuccessText;
    }
    return Colors.transparent;
  }

  /// This function is used to get the icon of the item.
  SvgPicture getIcon(String type) {
    if (type == 'Inbox' || type == 'inbox') {
      return SvgPicture.asset(svgInbox,
          height: 24,
          width: 24,
          colorFilter:
              const ColorFilter.mode(AppStyles.textSuccess, BlendMode.srcIn));
    } else if (type == 'Sent') {
      return SvgPicture.asset(svgSent,
          height: 24,
          width: 24,
          colorFilter:
              const ColorFilter.mode(AppStyles.textWarn, BlendMode.srcIn));
    } else if (type == 'Trash') {
      return SvgPicture.asset(svgTrash1,
          height: 24,
          width: 24,
          colorFilter:
              const ColorFilter.mode(AppStyles.textError, BlendMode.srcIn));
    } else if (type == 'Archive') {
      return SvgPicture.asset(svgArchive,
          height: 24,
          width: 24,
          colorFilter:
              const ColorFilter.mode(AppStyles.textInfo, BlendMode.srcIn));
    } else if (type == optIn) {
      return SvgPicture.asset(svgOptin,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
              context.appColors.accent, BlendMode.srcIn));
    } else if (type == 'More') {
      return SvgPicture.asset(svgMoreVerti,
          height: 24,
          width: 24,
          colorFilter:
              const ColorFilter.mode(AppStyles.textSuccess, BlendMode.srcIn));
    }
    return SvgPicture.asset(svgInbox, height: 24, width: 24);
  }

  /// This function is used to get the slide view of the item.
  Column getSlideView(String type, dynamic item) {
    // Determine the actual type for icon and text based on sender
    String actualType = type;
    if (type == 'Sent' &&
        widget.userData?['user'] != null) {
      final senderId = _isInboxLikeType ? item.email.senderId : item.senderId;
      actualType =
          widget.userData?['user']?['id'] == senderId ? 'Sent' : 'Inbox';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getIcon(actualType),
        const SizedBox(
          height: 8,
        ),
        Text(
          actualType,
          style: AppTypography.titleSmall(context),
        )
      ],
    );
  }

  /// This function is used to change the email status.
  ///
  /// It takes the following parameters:
  /// [context] - The context of the widget.
  /// [index] - The index of the item in the list.
  /// [status] - The status to change to.
  /// [action] - The action to take.
  /// [popup] - Whether to show a popup after changing the status.
  ///
  /// It changes the email status and removes the item from the list if the status is not 'Read'.
  /// It also shows an undo toast with the option to undo the action.
  bool isWaiting = false;
  String statusGet = "";
  dynamic itemGet;
  int indexGet = 0;
  int isLo = 0;
  void changeEmailStatus(
      BuildContext context, int index, String status, String action,
      [bool? popup]) async {
    bool deletePop =
        false; // Dismiss any existing toast before showing a new one
    isLo += 1;
    ref.read(globalVariableProvider.notifier).updateGlobalEmailNavigation('1');

    // Calculate emailId correctly based on emailType
    dynamic item = widget._items[index];
    int? emailId;

    if (_isInboxLikeType) {
      emailId = item.emailId;
    } else if (widget.emailType == 'draft') {
      emailId = item.id;
    } else {
      // For other types, try to get from receivers or fallback to id
      if (item.receivers != null && item.receivers!.isNotEmpty) {
        emailId = item.receivers![0].emailId!;
      } else {
        emailId = item.id;
      }
    }

    // Delegate to callbacks if available and return early
    if (emailId != null) {
      if ((status == 'Archive') && widget.onArchiveEmail != null) {
        widget.onArchiveEmail!(emailId, index);
        if (isLo > 0) isLo -= 1;
        return;
      } else if ((status == 'Trash' || status == 'Deleted') &&
          widget.onDeleteEmail != null) {
        // For trash folder, we might want to show confirmation handled by parent
        // or if it's "Permanently Delete"
        widget.onDeleteEmail!(emailId, index);
        if (isLo > 0) isLo -= 1;
        return;
      } else if (status == 'Inbox' && widget.onMoveToInboxEmail != null) {
        widget.onMoveToInboxEmail!(emailId, index);
        if (isLo > 0) isLo -= 1;
        return;
      }
    }

    // Fallback legacy logic for trash folder without callback (if any)
    if ((status == "Trash" || status == "Deleted") &&
        widget.emailType == "trash" &&
        popup == null) {
      deletePop = false;
      onCancel(context, index, status, action);
    } else {
      deletePop = true;
    }
    isWaiting = true;
    if (deletePop && (popup == null || popup == true)) {
      dynamic item = widget._items[index];
      bool undoStatus = false;

      if (!mounted) return;

      setState(() {
        // Optimistic removal is intentionally omitted to avoid direct mutation
        // of the parent widget's list. The parent notifier will update items via
        // updateEmailStatus callback, triggering a proper rebuild.
      });
      itemGet = item;
      indexGet = index;

      // if (mounted) {
      //   CommonService.animatedToast(
      //       CommonService().undoStatus(status.replaceAll('is', ''), (widget.emailType == "trash" && status == 'Trash') ? true : false),
      //       undo,
      //       undoAction,
      //       widget.longPress == true ? false : true);
      // }
      statusGet = status;
      // Future.delayed(const Duration(seconds: 3), () {
      if (!undoStatus && mounted) {
        // Bug 29: 'Sent' action must map to 'isSent', not 'isArchive'
        widget.updateEmailStatus(
          status == 'Sent' ? 'isSent' : 'is$status',
          <int>[
            _isInboxLikeType
                ? item.emailId
                : (widget.emailType == 'draft'
                    ? item.id
                    : (item.receivers != null && item.receivers!.isNotEmpty
                        ? item.receivers![0].emailId!
                        : item.id ?? 0))
          ],
          index,
        );
        isWaiting = false;
      }
      if (isLo > 0) {
        isLo -= 1;
      }
      // });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onEndReached();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    _scrollController.removeListener(_onScroll);
    if (_ownController) _scrollController.dispose();
    if (isWaiting == true && itemGet != null) {
      final emailId = _isInboxLikeType
          ? itemGet.emailId
          : (widget.emailType == 'draft'
              ? itemGet.id
              : (itemGet.receivers?.isNotEmpty == true
                  ? itemGet.receivers![0].emailId
                  : null));

      if (emailId != null) {
        // Bug 29: 'Sent' action must map to 'isSent', not 'isArchive'
        widget.updateEmailStatus(
          statusGet == 'Sent' ? 'isSent' : 'is$statusGet',
          [emailId],
          indexGet,
        );
      }
      isWaiting = false;
    }
    super.dispose();
  }

  /// This function is used to get the status of the item.
  String giveStatus(String status, dynamic item) {
    String updateStatus = status;
    if (status == 'Sent' &&
        widget.userData?['user'] != null) {
      // InboxListModel.Emails stores senderId at item.email.senderId;
      // SentListModel.Emails stores it at item.senderId.
      final senderId = _isInboxLikeType ? item.email.senderId : item.senderId;
      updateStatus =
          widget.userData?['user']?['id'] == senderId ? 'Sent' : 'Inbox';
    }
    return updateStatus;
  }

  /// Displays a Cupertino action sheet prompting the user to either
  /// permanently delete or cancel the action for a given email item.
  ///
  /// The action sheet provides two options:
  /// - "Permanently Delete": Deletes the email and updates its status.
  /// - "Cancel": Dismisses the action sheet without changing the email status.
  ///
  /// Parameters:
  /// - [context]: The build context in which the modal popup is displayed.
  /// - [index]: The index of the email item in the list.
  /// - [status]: The current status of the email item.
  /// - [action]: The action to be taken for the email item.

  void onCancel(BuildContext context, int index, String status, String action) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Permanently Delete",
              style: AppTypography.actionSheetDelete(context),
            ),
            onPressed: () {
              context.pop();
              changeEmailStatus(context, index, status, action, true);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            context.pop();
            changeEmailStatus(context, index, status, action, false);
          },
          child: Text(
            "Cancel",
            style: AppTypography.actionSheetCancel(context),
          ),
        ),
      ),
    );
  }

  @override

  /// This is the overridden method of [StatefulWidget].
  ///
  /// This function is called when the widget is rebuilt.
  ///
  /// It returns a [Scaffold] widget with a [FlatList] as its body.
  ///
  /// The [FlatList] displays the list of emails. Each item in the list is
  /// represented by a [Slidable] widget, which provides a swipe gesture to
  /// reveal the actions that can be taken on the email.
  ///
  /// The actions that can be taken on the email depend on the value of
  /// [widget.rightActions]. If [widget.rightActions] is not empty, the actions
  /// are displayed as [CustomSlidableAction] widgets. The background color and
  /// foreground color of the actions are determined by the value of
  /// [widget.rightActions].
  ///
  /// The function also sets the state of the widget with the values of
  /// [widget.selectedEmailIds] and [widget.selectedEmails].
  ///
  /// Parameters:
  /// - [context]: The build context in which the widget is built.
  @override
  void didUpdateWidget(covariant CustomDismissible oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't overwrite local selection state while a drag gesture is active —
    // the drag handler owns the selection until pointer-up.
    if (_isDragSelecting) return;
    if (widget.selectedEmailIds != oldWidget.selectedEmailIds ||
        widget.selectedEmails != oldWidget.selectedEmails) {
      setState(() {
        selectedEmailIds = widget.selectedEmailIds ?? [];
        selectedEmails = widget.selectedEmails ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildContext = context;

    return Scaffold(
      // Bug 18: Explicit background prevents dark/blue flash during list
      // rebuilds when deleting messages in trash.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SlidableAutoCloseBehavior(
        child: widget._items.isEmpty
            ? const Center(
                child: EmptyState(variant: EmptyStateVariant.inbox),
              )
            : RefreshIndicator(
                color: const Color(0XFF1C5AD6),
                onRefresh: isLo != 0 ? () async {} : widget.onRefresh,
                notificationPredicate: (_) => !_isInSelectionMode,
                child: Listener(
          // Drag-to-select: Listener doesn't compete with scroll/tap gestures.
          // When in multi-select mode, a vertical drag selects items.
          onPointerDown: (event) {
            // Handle Shift+Click at the Listener level — browser may
            // prevent InkWell.onTap from firing when Shift is held.
            if (kIsWeb && !AppBreakpoints.isMobileLayout(context)) {
              _updateModifierState();
              if (_isShiftPressed && widget.onShiftClick != null) {
                final idx = _indexAtPosition(event.position.dy);
                if (idx >= 0) {
                  widget.onShiftClick!(idx);
                  _dragAnchorIndex = -1; // Prevent drag from starting
                  return;
                }
              }
            }

            if (!_isInSelectionMode) return;
            final idx = _indexAtPosition(event.position.dy);
            if (idx >= 0) {
              _dragAnchorIndex = idx;
              _lastDragIndex = -1;
              _dragEdgeStart = null;
              _isDragSelecting = false;
              // Snapshot current selection so drag merges with it
              _preExistingSelectionIds = Set.from(selectedEmailIds);
              _preExistingSelectionEmails = List.from(selectedEmails);
            }
          },
          onPointerMove: (event) {
            if (!_isInSelectionMode || _dragAnchorIndex < 0) return;
            final idx = _indexAtPosition(event.position.dy);
            if (idx >= 0 && idx != _dragAnchorIndex) {
              if (!_isDragSelecting) {
                _isDragSelecting = true;
              }
              if (idx != _lastDragIndex) {
                _lastDragIndex = idx;
                _updateDragSelection(idx);
              }
            }
            // Auto-scroll near edges with gradual velocity increase
            if (_isDragSelecting) {
              _handleDragAutoScroll(event.position.dy);
            }
          },
          onPointerUp: (_) {
            _isDragSelecting = false;
            _dragAnchorIndex = -1;
            _lastDragIndex = -1;
            _dragEdgeStart = null;
            _preExistingSelectionIds = {};
            _preExistingSelectionEmails = [];
            // Don't sync from parent here — widget props may be stale.
            // The next didUpdateWidget (now unguarded since _isDragSelecting
            // is false) will sync when the notifier rebuild arrives.
          },
          // Bug 17: KeyedSubtree keeps _listKey for drag-to-select
          // findRenderObject(); PageStorageKey preserves scroll position
          // across widget rebuilds.
          child: KeyedSubtree(
          key: _listKey,
          child: ListView.builder(
          key: PageStorageKey<String>('dismissible_${widget.emailType}'),
          // Clamp scroll physics in multi-select mode to prevent
          // overscroll / bounce that pulls the list away from the edge.
          physics: _isInSelectionMode
              ? const ClampingScrollPhysics()
              : null,
          controller: _scrollController,
          itemCount: widget._items.length,
          itemBuilder: (context, index) {
            final item = widget._items[index];
            // Track item keys for drag-to-select hit testing
            _itemKeys.putIfAbsent(index, () => GlobalKey());
            return KeyedSubtree(
            key: _itemKeys[index],
            child: Slidable(
              closeOnScroll: true,
              key: ValueKey(item.id),
              startActionPane: widget.shouldShowStartPane
                  ? ActionPane(
                      dragDismissible: true,
                      motion: const DrawerMotion(),
                      children: [
                        CustomSlidableAction(
                            key: Key('slidable_action_optin_$index'),
                            autoClose: true,
                            onPressed: (context) {
                              // Perform archive action
                              CommonService().gotoAddRecipient(
                                  _isInboxLikeType
                                      ? item.email.senderEmail
                                      : item.senderEmail);
                            },
                            backgroundColor: context.appColors.accentBg,
                            foregroundColor: context.appColors.accent,
                            child: getSlideView(optIn, item))
                      ],
                    )
                  : null,
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  if (widget.rightActions[0] != '')
                    CustomSlidableAction(
                        key: Key('slidable_action_right0_$index'),
                        autoClose: true,
                        flex: 3,
                        padding: const EdgeInsets.all(0),
                        onPressed: (context) {
                          moreOptions(determineOptions(item), index);
                        },
                        backgroundColor: getBgColor('More'),
                        foregroundColor: getTextColor('More'),
                        child: getSlideView(widget.rightActions[0], item)),
                  if (widget.rightActions[1] != '')
                    CustomSlidableAction(
                        key: Key('slidable_action_right1_$index'),
                        autoClose: true,
                        flex: 4,
                        padding: const EdgeInsets.all(0),
                        onPressed: (context) => changeEmailStatus(
                            context,
                            index,
                            giveStatus(widget.rightActions[1], item),
                            ''),
                        backgroundColor: getBgColor(giveStatus(widget.rightActions[1], item)),
                        foregroundColor: getTextColor(giveStatus(widget.rightActions[1], item)),
                        child: getSlideView(
                            widget.rightActions[1].toString(), item)),
                  if (widget.rightActions[2] != '')
                    CustomSlidableAction(
                        key: Key('slidable_action_right2_$index'),
                        autoClose: true,
                        flex: 3,
                        padding: const EdgeInsets.all(0),
                        onPressed: (context) => changeEmailStatus(
                            context, index, widget.rightActions[2], ''),
                        backgroundColor: getBgColor(widget.rightActions[2]),
                        foregroundColor: getTextColor(widget.rightActions[2]),
                        child: getSlideView(
                            widget.rightActions[2].toString(), item)),
                ],
              ),
              child: Column(
                children: [
                  if (_isInboxLikeType)
                    EmailList(
                        userId: item.id,
                        addEmailTags: widget.addEmailTags,
                        index: index,
                        emailType: widget.emailType,
                        radioButton: widget.longPress,
                        radioOnTap: () {
                          addAndRemoveKey(item.emailId, item.email.senderEmail);
                        },
                        checkRadio: selectedEmailIds.contains(item.emailId),
                        title: 'title',
                        svgIcon: svgIcon,
                        item: item,
                        testId: 'inbox_list_item_$index',
                        selectedEmailId: widget.selectedEmailId,
                        onTap: () {
                          final bool isMobile =
                              AppBreakpoints.isMobileLayout(buildContext);

                          // Check tracked modifier keys for multi-select on desktop/web
                          if (!isMobile && kIsWeb) {
                            // Re-read keyboard state at tap time for freshness
                            _updateModifierState();

                            if (_isShiftPressed && widget.onShiftClick != null) {
                              widget.onShiftClick!(index);
                              return;
                            }
                            if (_isCtrlOrCmdPressed && widget.onCtrlClick != null) {
                              widget.onCtrlClick!(index);
                              return;
                            }
                          }

                          // For mobile app only: when in selection mode, clicking email selects it instead of navigating
                          final bool isInSelectionMode =
                              widget.longPress == true ||
                                  selectedEmailIds.isNotEmpty;

                          if (isMobile && isInSelectionMode) {
                            // Select the email instead of navigating to preview
                            addAndRemoveKey(
                                item.emailId, item.email.senderEmail);
                          } else {
                            // Normal behavior: navigate to preview
                            widget.viewDetail(
                                item.emailId, item.emailRecipientTags, index);
                          }
                        },
                        onLongPress: () async {
                          if (widget.onLongPress != null) {
                            widget.onLongPress!(
                                item.emailId, item.email.senderEmail);
                          }
                        },
                        onArchive: widget.onArchiveEmail != null
                            ? () {
                                widget.onArchiveEmail!(item.emailId, index);
                              }
                            : null,
                        onDelete: widget.onDeleteEmail != null
                            ? () {
                                widget.onDeleteEmail!(item.emailId, index);
                              }
                            : null,
                        onOptIn: widget.onOptInEmail != null
                            ? () {
                                widget.onOptInEmail!(
                                    item.email.senderEmail, index);
                              }
                            : null,
                        hasAnySelection: selectedEmailIds.isNotEmpty),
                  if (widget.emailType == 'archive' ||
                      widget.emailType == 'sent' ||
                      widget.emailType == 'trash')
                    (item.receivers != null && item.receivers!.isNotEmpty)
                        ? SentEmailList(
                            userId: widget.userData?['user']?['id'],
                            addEmailTags: widget.addEmailTags,
                            index: index,
                            emailType: widget.emailType,
                            radioButton: widget.longPress,
                            selectedIndex: widget.selectedIndex,
                            radioOnTap: () {
                              addAndRemoveKey(item.receivers![0].emailId!,
                                  item.senderEmail);
                            },
                            checkRadio: selectedEmailIds
                                .contains(item.receivers![0].emailId),
                            title: 'title',
                            svgIcon: svgIcon,
                            item: item,
                            testId: '${widget.emailType}_list_item_$index',
                            selectedEmailId: widget.selectedEmailId,
                            onTap: () {
                              final bool isMobile =
                                  AppBreakpoints.isMobileLayout(buildContext);

                              // Check modifier keys for multi-select on desktop/web
                              if (!isMobile && kIsWeb) {
                                _updateModifierState();

                                if (_isShiftPressed && widget.onShiftClick != null) {
                                  widget.onShiftClick!(index);
                                  return;
                                }
                                if (_isCtrlOrCmdPressed && widget.onCtrlClick != null) {
                                  widget.onCtrlClick!(index);
                                  return;
                                }
                              }

                              final bool isInSelectionMode =
                                  widget.longPress == true ||
                                      selectedEmailIds.isNotEmpty;

                              if (isMobile && isInSelectionMode) {
                                // Select the email instead of navigating to preview
                                addAndRemoveKey(item.receivers![0].emailId!,
                                    item.senderEmail);
                              } else {
                                // Normal behavior: navigate to preview
                                widget.viewDetail(
                                    widget._items[index].receivers![0].emailId!,
                                    [],
                                    index);
                              }
                            },
                            onLongPress: () async {
                              if (widget.onLongPress != null) {
                                widget.onLongPress!(item.id, item.senderEmail);
                              }
                            },
                            onArchive: widget.emailType == 'archive'
                                ? null
                                : (widget.onArchiveEmail != null
                                    ? () {
                                        widget.onArchiveEmail!(
                                            item.receivers![0].emailId!, index);
                                      }
                                    : null),
                            onMoveToInbox: (widget.emailType == 'archive' ||
                                    widget.emailType == 'trash')
                                ? (widget.onMoveToInboxEmail != null
                                    ? () {
                                        widget.onMoveToInboxEmail!(
                                            item.receivers![0].emailId!, index);
                                      }
                                    : null)
                                : null,
                            onDelete: widget.onDeleteEmail != null
                                ? () {
                                    widget.onDeleteEmail!(
                                        item.receivers![0].emailId!, index);
                                  }
                                : null,
                            onOptIn: widget.onOptInEmail != null
                                ? () {
                                    // For sent emails, use recipient email; for others, use sender email
                                    final emailToOptIn = widget.emailType ==
                                            'sent'
                                        ? (item.receivers!.isNotEmpty
                                            ? item.receivers![0].receiverEmail
                                            : item.senderEmail)
                                        : item.senderEmail;
                                    widget.onOptInEmail!(emailToOptIn, index);
                                  }
                                : null,
                            hasAnySelection: selectedEmailIds.isNotEmpty)
                        : const SizedBox.shrink(),
                  if (widget.emailType == 'draft')
                    DraftEmailList(
                      index: index,
                      emailType: "draft",
                      radioButton: widget.longPress,
                      radioOnTap: () {
                        addAndRemoveKey(item.id, '');
                      },
                      checkRadio: selectedEmailIds.contains(item.id),
                      title: 'title',
                      svgIcon: svgIcon,
                      item: item,
                      testId: 'draft_list_item_$index',
                      selectedEmailId: widget.selectedEmailId,
                      onTap: () {
                        final bool isMobile =
                            AppBreakpoints.isMobileLayout(buildContext);

                        // Check modifier keys for multi-select on desktop/web
                        if (!isMobile && kIsWeb) {
                          _updateModifierState();

                          if (_isShiftPressed && widget.onShiftClick != null) {
                            widget.onShiftClick!(index);
                            return;
                          }
                          if (_isCtrlOrCmdPressed && widget.onCtrlClick != null) {
                            widget.onCtrlClick!(index);
                            return;
                          }
                        }

                        final bool isInSelectionMode =
                            widget.longPress == true ||
                                selectedEmailIds.isNotEmpty;

                        if (isMobile && isInSelectionMode) {
                          // Select the email instead of navigating to preview
                          addAndRemoveKey(item.id, '');
                        } else {
                          // Normal behavior: navigate to preview
                          widget.viewDetail(item.id);
                        }
                      },
                      onLongPress: () {
                        if (widget.onLongPress != null) {
                          widget.onLongPress!(item.id, '');
                        }
                      },
                      onArchive: widget.onArchiveEmail != null
                          ? () {
                              widget.onArchiveEmail!(item.id, index);
                            }
                          : null,
                      onDelete: widget.onDeleteEmail != null
                          ? () {
                              printLog("onDeleteEmail", item.id);
                              final emailId = item.id;
                              widget.onDeleteEmail?.call(emailId, index);
                            }
                          : null,
                      onOptIn: widget.onOptInEmail != null
                          ? () {
                              widget.onOptInEmail!('', index);
                            }
                          : null,
                      hasAnySelection: selectedEmailIds.isNotEmpty,
                    ),
                ],
              ),
            ),
            );
          },
        ),
        ), // KeyedSubtree
        ),
        ),
      ),
    );
  }

  /// Adds or removes an email ID from the list of selected email IDs and updates the UI.
  void addAndRemoveKey(int id, String email) {
    List<int> arr = List.from(selectedEmailIds);
    List<String> optEmails = List.from(selectedEmails);
    if (arr.contains(id)) {
      arr.remove(id);
      optEmails.remove(email);
    } else {
      arr.add(id);
      optEmails.add(email);
    }
    setState(() {
      selectedEmailIds = arr;
      selectedEmails = optEmails;
    });
    widget.setSelectedEmailIds!(selectedEmailIds, selectedEmails);
  }

  /// Displays a Cupertino action sheet with options to move an email to different folders.
  Future<void> moreOptions(List<String> displayOptions, int itemIndex) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: List.generate(displayOptions.length, (index) {
          return CupertinoActionSheetAction(
            child: Text(
              displayOptions[index],
              style: AppTypography.actionSheetCancel(context),
            ),
            onPressed: () async {
              context.pop();
              switch (displayOptions[index]) {
                case moveToInbox:
                  changeEmailStatus(context, itemIndex, 'Inbox', 'actionSheet');
                  break;
                case moveToTrash || 'Delete':
                  changeEmailStatus(
                      context,
                      itemIndex,
                      widget.emailType == 'trash' ? 'Deleted' : 'Trash',
                      'actionSheet');
                  break;
                case 'Permanently Delete':
                  // Show confirmation popup for permanent deletion in trash
                  changeEmailStatus(
                      context, itemIndex, 'Deleted', 'actionSheet');
                  break;
                case moveToArchive:
                  changeEmailStatus(
                      context, itemIndex, 'Archive', 'actionSheet');
                  break;
                case moveToSent:
                  changeEmailStatus(
                      context, itemIndex, 'Inbox', 'actionSheet', true);
                  break;
                case markUnread:
                  changeEmailStatus(context, itemIndex, 'Read', 'actionSheet');
                case markRead:
                  await markAsReadWithUndo(itemIndex);
                  break;
                case 'Tag':
                  showList(
                      context,
                      _isInboxLikeType
                          ? widget._items[itemIndex].emailId
                          : widget._items[itemIndex].id,
                      itemIndex);
                  break;
                case optIn:
                  CommonService().gotoAddRecipient(_isInboxLikeType
                      ? widget._items[itemIndex].email.senderEmail
                      : widget._items[itemIndex].senderEmail);

                  break;
              }
            },
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            context.pop();
          },
          child: Text(
            cancel,
            style: AppTypography.actionSheetCancel(context),
          ),
        ),
      ),
    );
  }

  /// Given an item, determine the list of options to be displayed in the
  /// bottom sheet.
  ///
  /// The options are based on the email type.
  ///
  /// If the email type is 'inbox', the options are 'Move to Archive', 'Move to
  /// Trash', 'Mark as Unread' if the item is read, 'Tag', and 'Opt-In'.
  ///
  /// If the email type is 'trash', the options are 'Move to Archive',
  /// 'Permanently Delete', 'Move to Sent' or 'Move to Inbox', 'Mark as Unread'
  /// if the item is read, 'Tag', and 'Opt-In'.
  ///
  /// If the email type is 'archive', the options are 'Move to Trash', 'Move to
  /// Sent' or 'Move to Inbox', 'Mark as Unread' if the item is read, 'Tag', and
  /// 'Opt-In'.
  ///
  /// If the email type is 'sent', the options are 'Move to Trash', 'Move to
  /// Archive', 'Tag', and 'Opt-In'.
  ///
  /// If the email type is 'draft', the options are 'Move to Archive'.
  ///
  /// Returns a list of strings representing the options to be displayed in the
  /// bottom sheet.
  List<String> determineOptions(dynamic item) {
    List<String> options = [];

    if (widget.emailType == 'inbox') {
      options.add(moveToArchive);
      options.add(moveToTrash);
      if (item.isRead) {
        options.add(markUnread);
      } else {
        options.add(markRead);
      }
      options.add('Tag');
      options.add(optIn);
    } else if (widget.emailType == 'all') {
      // Tag-filtered view — sender-aware action filtering
      final isSentByMe = widget.userData?['user'] != null &&
          widget.userData?['user']?['id'] == item.email.senderId;
      options.add(moveToArchive);
      options.add(moveToTrash);
      // Sent messages have no unread concept
      if (!isSentByMe) {
        if (item.isRead) {
          options.add(markUnread);
        } else {
          options.add(markRead);
        }
      }
      options.add('Tag');
      // Opt-In not applicable to sent messages
      if (!isSentByMe) options.add(optIn);
    } else if (widget.emailType == 'trash') {
      if (item.isDraft == true) {
        // Trashed draft — limited actions
        options.add(moveToInbox); // Handled as "Restore to Drafts" by notifier
        options.add('Permanently Delete');
      } else {
        options.add(moveToArchive);
        options.add('Permanently Delete');
        final isSentByMe = widget.userData?['user'] != null &&
                widget.userData?['user']?['id'] == item.senderId;
        options.add(isSentByMe ? moveToSent : moveToInbox);
        // Sent-origin emails have no unread concept
        if (!isSentByMe) {
          if (item.receivers != null &&
              item.receivers!.isNotEmpty &&
              item.receivers![0].isRead == true) {
            options.add(markUnread);
          } else {
            options.add(markRead);
          }
        }
        options.add('Tag');
        options.add(optIn);
      }
    } else if (widget.emailType == 'archive') {
      options.add(moveToTrash);
      final isSentByMe = widget.userData?['user'] != null &&
              widget.userData?['user']?['id'] == item.senderId;
      options.add(isSentByMe ? moveToSent : moveToInbox);
      // Sent-origin emails have no unread concept
      if (!isSentByMe) {
        if (item.receivers != null &&
            item.receivers!.isNotEmpty &&
            item.receivers![0].isRead == true) {
          options.add(markUnread);
        } else {
          options.add(markRead);
        }
      }
      options.add('Tag');
      options.add(optIn);
    } else if (widget.emailType == 'sent') {
      options.add(moveToTrash);
      options.add(moveToArchive);
      options.add('Tag');
      options.add(optIn);
    } else if (widget.emailType == 'draft') {
      options.add(moveToArchive);
    }

    return options;
  }

  /// Displays a modal with a list of tags and allows the user to select one or more tags.
  void showList(BuildContext context, int emailId, int itemIndex) {
    if (widget.tagsList.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopUpModalTagList(
            loading: false,
            title: 'Tags',
            onPressedButton2: () {
              if (selectedTagIds.isNotEmpty) {
                widget.addEmailTags(selectedTagIds, emailId, itemIndex, 'add');
              } else {
                CommonService.animatedToast(
                    "Please select at least one tag", 'warning', null, true);
              }
            },
            textButton1: 'Cancel',
            textButton2: 'Add',
            itemList: widget.tagsList,
            callback: (value) {
              if (mounted) {
                setState(() {
                  selectedTagIds = value;
                });
              }
            },
          );
        },
      );
    } else {
      CommonService.animatedToast("No tags found", 'warning', null, true);
    }
  }
}

extension _MarkReadApi on _CustomDismissibleState {
  /// Show undo toast, and after 3s (if not undone) call API to mark as read
  Future<void> markAsReadWithUndo(int itemIndex) async {
    final int emailId = _isInboxLikeType
        ? widget._items[itemIndex].emailId
        : (widget.emailType == 'draft'
            ? widget._items[itemIndex].id
            : widget._items[itemIndex].receivers[0].emailId);

    // if (mounted) {
    //   CommonService.animatedToast(CommonService().undoStatus('Unread'), undo, undoAction, true);
    // }

    // await Future.delayed(const Duration(seconds: 3));

    try {
      Map<String, dynamic> resp = await ApiService().post(
        updateEmailStatusApi,
        {
          "key": 'isRead',
          "emailIds": [emailId],
          "value": true
        },
      );
      if (resp['success']) {
        // Delegate the read-status update back to the parent via onRefresh
        // instead of directly mutating the shared widget list.
        if (mounted) {
          widget.onRefresh();
        }
      } else {
        CommonService.animatedToast(resp['message'], 'error', null, true);
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error', null, true);
    }
  }
}
