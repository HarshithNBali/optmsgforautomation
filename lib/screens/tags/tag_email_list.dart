import 'dart:async';

import 'package:optmsg/constant/common_constant.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:optmsg/widgets/pop_up_modal_tag_list.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/model/inbox_list_model.dart';

import 'package:descope/descope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/widgets/standard_fab.dart';
import '../../router/app_routes.dart';

class TagEmailList extends ConsumerStatefulWidget {
  final dynamic data;
  final dynamic tagsList;
  const TagEmailList({super.key, this.data, this.tagsList});
  @override
  ConsumerState<TagEmailList> createState() => _TagEmailListState();
}

class _TagEmailListState extends ConsumerState<TagEmailList> {
  bool _isLoading = false;
  Timer? _loaderTimer;
  Timer? _refreshTimer;
  int currentPage = 1;
  InboxListModel? inboxList;
  List<Emails> _items = [];
  bool _longPressFlag = true;
  List<int> selectedEmailIds = [];
  List<String> selectedEmails = [];
  bool _allEmailIdsFlag = false;
  int? _currentlyViewedEmailId;
  int _lastClickedIndex = -1;

  bool get _isInSelectionMode => !_longPressFlag || selectedEmailIds.isNotEmpty;
  int get _selectedCount => selectedEmailIds.length;

  // ── Origin Awareness (sent vs received) ──

  int? get _userId =>
      ref.read(inboxProvider).userData?['user']?['id'] as int?;

  bool _isSentByMe(Emails item) =>
      _userId != null && item.email.senderId == _userId;

  /// Returns 'allSent', 'allReceived', 'mixed', or 'none' — same semantics
  /// as `ArchiveNotifier.getSelectionOrigin()`.
  String _getSelectionOrigin() {
    if (selectedEmailIds.isEmpty) return 'none';
    bool hasSent = false;
    bool hasReceived = false;
    for (final id in selectedEmailIds) {
      final item = _items.cast<Emails?>().firstWhere(
            (e) => e?.emailId == id,
            orElse: () => null,
          );
      if (item != null) {
        if (_isSentByMe(item)) {
          hasSent = true;
        } else {
          hasReceived = true;
        }
      }
      if (hasSent && hasReceived) return 'mixed';
    }
    if (hasSent) return 'allSent';
    if (hasReceived) return 'allReceived';
    return 'none';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushAppBarConfig();
    });
    getAllEmails("");
  }

  // ── AppBar Config ──

  void _pushAppBarConfig() {
    if (!mounted) return;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (_isInSelectionMode && isMobile) {
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: '',
          isSelectionMode: true,
          selectionLeading: _buildSelectionLeading(),
          selectionActions: _buildSelectionActions(),
        ),
      );
    } else {
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: widget.data['tagName'] ?? '',
        ),
      );
    }
  }

  Widget _buildSelectionLeading() {
    final appBarFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: _clearSelection,
          icon: SvgPicture.asset(
            svgLeftArrow,
            colorFilter: ColorFilter.mode(appBarFg, BlendMode.srcIn),
          ),
        ),
        IconButton(
          icon: _allEmailIdsFlag
              ? const Icon(Icons.check_box)
              : selectedEmailIds.isNotEmpty
                  ? const Icon(Icons.indeterminate_check_box)
                  : const Icon(Icons.check_box_outline_blank),
          onPressed: _handleSelectAll,
        ),
        Text(
          _allEmailIdsFlag
              ? 'All Selected ($_selectedCount)'
              : selectedEmailIds.isNotEmpty
                  ? '$_selectedCount selected'
                  : selectAll,
          style: AppTypography.labelMedium(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActions() {
    if (selectedEmailIds.isEmpty) return [];
    final origin = _getSelectionOrigin();
    final appBarFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    Widget icon(String asset, VoidCallback onTap, {bool tint = false}) {
      return IconButton(
        onPressed: onTap,
        icon: SvgPicture.asset(
          asset,
          height: 24,
          width: 24,
          colorFilter: tint
              ? ColorFilter.mode(appBarFg, BlendMode.srcIn)
              : null,
        ),
      );
    }

    return [
      // Opt-In — hide for sent or mixed selection (not applicable to sent messages)
      if (origin != 'allSent' && origin != 'mixed')
        icon(svgOptin, _handleOptIn),
      // Delete — always available
      icon(svgDelete, () => _bulkUpdateStatus('isTrash')),
      // Archive — always available
      icon(svgArchive, () => _bulkUpdateStatus('isArchive'), tint: true),
      // More — always available
      icon(svgMoreHori, () {
        setState(() => _showMoreMenu = !_showMoreMenu);
      }, tint: true),
    ];
  }

  // ── Selection Management ──

  void _handleSelectAll() {
    if (_allEmailIdsFlag) {
      _clearSelection();
    } else {
      setState(() {
        selectedEmailIds = _items.map<int>((item) => item.emailId).toList();
        selectedEmails = _items.map((item) => item.email.senderEmail).toList();
        _allEmailIdsFlag = true;
        _longPressFlag = false;
      });
      _pushAppBarConfig();
    }
  }

  void _clearSelection() {
    setState(() {
      _longPressFlag = true;
      _allEmailIdsFlag = false;
      selectedEmailIds = [];
      selectedEmails = [];
      _lastClickedIndex = -1;
    });
    _pushAppBarConfig();
  }

  void _selectRange(int fromIndex, int toIndex) {
    if (_items.isEmpty) return;
    final start = fromIndex.clamp(0, _items.length - 1);
    final end = toIndex.clamp(0, _items.length - 1);
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;

    final ids = {...selectedEmailIds};
    final emails = {...selectedEmails};
    for (int i = lo; i <= hi; i++) {
      ids.add(_items[i].emailId);
      emails.add(_items[i].email.senderEmail);
    }

    setState(() {
      selectedEmailIds = ids.toList();
      selectedEmails = emails.toList();
      _allEmailIdsFlag = ids.length == _items.length;
      _longPressFlag = false;
      _lastClickedIndex = end;
    });
    _pushAppBarConfig();
  }

  void _toggleByIndex(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final ids = [...selectedEmailIds];
    final emails = [...selectedEmails];

    if (ids.contains(item.emailId)) {
      ids.remove(item.emailId);
      emails.remove(item.email.senderEmail);
    } else {
      ids.add(item.emailId);
      emails.add(item.email.senderEmail);
    }

    setState(() {
      selectedEmailIds = ids;
      selectedEmails = emails;
      _allEmailIdsFlag = ids.length == _items.length && _items.isNotEmpty;
      _longPressFlag = ids.isEmpty;
      _lastClickedIndex = index;
    });
    _pushAppBarConfig();
  }

  // ── Bulk Actions ──

  Future<void> _bulkUpdateStatus(String type) async {
    final ids = List<int>.from(selectedEmailIds);
    _clearSelection();

    // Partition by origin — sent messages require the dual-API move pattern
    final sentIds = <int>[];
    final receivedIds = <int>[];
    for (final id in ids) {
      final item = _items.cast<Emails?>().firstWhere(
            (e) => e?.emailId == id,
            orElse: () => null,
          );
      if (item != null && _isSentByMe(item)) {
        sentIds.add(id);
      } else {
        receivedIds.add(id);
      }
    }

    try {
      // Received messages: single API call
      if (receivedIds.isNotEmpty) {
        await ApiService().post(
          'email/update-email-status',
          {"key": type, "emailIds": receivedIds, "value": true},
        );
      }
      // Sent messages: dual-API pattern (remove isSent → set target → keep isRead)
      // Same pattern as archive_list_notifier.updateInboxEmailStatus for sentPath
      if (sentIds.isNotEmpty) {
        final resp = await ApiService().post(
          'email/update-email-status',
          {"key": "isSent", "emailIds": sentIds, "value": false},
        );
        if (resp['success'] == true) {
          await ApiService().post(
            'email/update-email-status',
            {"key": type, "emailIds": sentIds, "value": true},
          );
          // Sent emails should stay read when moved
          await ApiService().post(
            'email/update-email-status',
            {"key": "isRead", "emailIds": sentIds, "value": true},
          );
        }
      }
      if (!mounted) return;
      setState(() { currentPage = 1; });
      await getAllEmails("");
    } catch (_) {}
  }

  void _handleOptIn() {
    final senderEmails = <String>{};
    for (final id in selectedEmailIds) {
      final item = _items.cast<Emails?>().firstWhere(
        (e) => e?.emailId == id,
        orElse: () => null,
      );
      if (item != null) {
        senderEmails.add(item.email.senderEmail);
      }
    }
    if (senderEmails.isEmpty) return;
    for (final email in senderEmails) {
      CommonService().gotoAddRecipient(email);
    }
  }

  // ── More Menu Overlay ──

  bool _showMoreMenu = false;

  void _closeMoreMenu() {
    if (_showMoreMenu) {
      setState(() => _showMoreMenu = false);
    }
  }

  void _handleBulkTag() {
    final tagList = widget.data['tagsList']?.data?.tags;
    if (tagList != null && tagList.isNotEmpty) {
      List<int> selectedTagIdsForPopup = [];
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return PopUpModalTagList(
            title: 'Tags',
            loading: false,
            onPressedButton2: () async {
              selectedTagIdsForPopup.removeWhere((item) => item == 0);
              try {
                final resp = await ApiService().post(
                  'email/emails-tags',
                  {
                    "emailIds": selectedEmailIds,
                    "tagsId": selectedTagIdsForPopup,
                    "type": "add",
                  },
                );
                if (!mounted) return;
                if (resp['success']) {
                  CommonService.animatedToast(resp['message'], 'success');
                  _clearSelection();
                  setState(() { currentPage = 1; });
                  getAllEmails("");
                } else {
                  CommonService.animatedToast(resp['message'], 'error');
                }
              } catch (_) {}
            },
            textButton1: 'Cancel',
            textButton2: 'Add',
            itemList: tagList,
            callback: (value) {
              selectedTagIdsForPopup = List<int>.from(value);
            },
          );
        },
      );
    } else {
      CommonService.animatedToast('No tags found', 'warning');
    }
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final tagsList = widget.data['tagsList']?.data?.tags ?? [];

    return Scaffold(
      body: DelayedLoadingOverlay(
        isLoading: _isLoading,
        child: Stack(
          children: [
            CustomDismissible(
              emailType: 'all',
              items: _items,
              userData: ref.read(inboxProvider).userData,
              tagsList: tagsList,
              longPress: !_longPressFlag,
              allEmailIdsFlag: _allEmailIdsFlag,
              selectedEmailIds: selectedEmailIds,
              selectedEmails: selectedEmails,
              setSelectedEmailIds: (ids, emails) {
                setState(() {
                  selectedEmailIds = ids;
                  selectedEmails = emails;
                  _allEmailIdsFlag = ids.length == _items.length && _items.isNotEmpty;
                  _longPressFlag = ids.isEmpty;
                });
                _pushAppBarConfig();
              },
              onLongPress: (id, email) {
                setState(() {
                  _longPressFlag = false;
                  selectedEmailIds = [id];
                  selectedEmails = [email];
                });
                _pushAppBarConfig();
              },
              onRefresh: () async {
                setState(() { currentPage = 1; });
                await getAllEmails("");
              },
              onEndReached: () {
                if (inboxList?.data?.nextPage == true) {
                  getAllEmails("");
                }
              },
              shouldShowStartPane: true,
              viewDetail: (id, selectedTag, index) {
                // Track last clicked index for Shift+Click anchor
                _lastClickedIndex = index;
                if (_items[index].isRead == false) {
                  _updateEmailStatus("isRead", [_items[index].emailId]);
                }
                _gotoViewDetail(id);
              },
              rightActions: const ['More', 'Archive', 'Trash'],
              updateEmailStatus: (type, ids, _) async {
                await _updateEmailStatus(type, ids);
              },
              addEmailTags: (emailIds, tagId, _, _) async {
                await _addEmailTagsById(emailIds, tagId);
              },
              onArchiveEmail: (id, _) => _bulkUpdateStatusSingle('isArchive', id),
              onDeleteEmail: (id, _) => _bulkUpdateStatusSingle('isTrash', id),
              onOptInEmail: (email, _) {
                CommonService().gotoAddRecipient(email);
              },
              selectedEmailId: _currentlyViewedEmailId,
              onShiftClick: (index) {
                final from = _lastClickedIndex >= 0
                    ? _lastClickedIndex
                    : (_currentlyViewedEmailId != null
                        ? _items.indexWhere((e) => e.emailId == _currentlyViewedEmailId)
                        : index);
                _selectRange(from < 0 ? index : from, index);
              },
              onCtrlClick: (index) {
                if (selectedEmailIds.isEmpty && _currentlyViewedEmailId != null) {
                  final viewedIdx = _items.indexWhere((e) => e.emailId == _currentlyViewedEmailId);
                  if (viewedIdx >= 0) _toggleByIndex(viewedIdx);
                }
                _toggleByIndex(index);
              },
            ),
            // More menu overlay (matches inbox pattern)
            if (_showMoreMenu)
              _buildMoreMenuOverlay(),
            StandardFab(
              iconAsset: svgComposeIcon,
              onPressed: _gotoCompose,
              heroTag: 'tagEmailCompose',
              visible: AppBreakpoints.isMobileLayout(context) && !_isInSelectionMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuOverlay() {
    final origin = _getSelectionOrigin();
    return InkWell(
      onTap: _closeMoreMenu,
      child: Container(
        color: Colors.black54,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _moreMenuItem(svgTags, 'Tag', () {
                    _closeMoreMenu();
                    _handleBulkTag();
                  }),
                  _moreMenuItem(svgArchive, moveToArchive, () {
                    _closeMoreMenu();
                    _bulkUpdateStatus('isArchive');
                  }),
                  _moreMenuItem(svgDelete, moveToTrash, () {
                    _closeMoreMenu();
                    _bulkUpdateStatus('isTrash');
                  }),
                  // Mark Read/Unread — hide for sent or mixed (sent messages have no unread concept)
                  if (origin != 'allSent' && origin != 'mixed') ...[
                    _moreMenuItem(svgRead, markRead, () {
                      _closeMoreMenu();
                      _bulkUpdateStatus('isRead');
                    }),
                    _moreMenuItem(svgUnread, markUnread, () {
                      _closeMoreMenu();
                      _bulkUpdateStatus('isUnread');
                    }),
                  ],
                  // Opt-In — hide for sent or mixed (not applicable to sent messages)
                  if (origin != 'allSent' && origin != 'mixed')
                    _moreMenuItem(svgOptin, optIn, () {
                      _closeMoreMenu();
                      _handleOptIn();
                    }),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _moreMenuItem(String icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                context.colors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.labelMedium(context).copyWith(
              color: context.colors.onSurfaceVariant,
            )),
          ],
        ),
      ),
    );
  }

  // ── Navigation ──

  void _gotoViewDetail(int id) {
    setState(() {
      _currentlyViewedEmailId = id;
    });
    context.push(
      AppRoutes.viewEmailPath(id.toString()),
      extra: {
        'emailId': id,
        'emailType': "Inbox",
        'allTagsList': widget.tagsList,
      },
    );
  }

  Future<void> _gotoCompose() async {
    final inboxState = ref.read(inboxProvider);
    final userData = inboxState.userData;
    if (userData == null) return;

    if (userData['user']['isFreeUser'] == true) {
      CommonService.animatedToast(freeUserWarning, 'warning', null, true);
      return;
    }

    final pageId = DateTime.now().microsecondsSinceEpoch;
    final offset = DateTime.now().timeZoneOffset.inMinutes;
    final sessionJwt =
        Descope.sessionManager.session?.sessionJwt ?? inboxState.token;
    final composeUrl =
        '${defaultBaseUrl}email/compose?pageId=$pageId&timeZone=$offset';

    await context.push(
      AppRoutes.compose,
      extra: {
        'url': composeUrl,
        'token': sessionJwt,
        'pageId': pageId,
        'type': 'compose',
        'sourcePage': AppRoutes.tags,
      },
    );
  }

  // ── API ──

  Future<void> getAllEmails(String searchKey) async {
    _loaderTimer?.cancel();
    _loaderTimer = Timer(
      const Duration(milliseconds: duration),
      () {
        if (mounted) setState(() => _isLoading = true);
      },
    );
    final reqData = {
      "type": "all",
      "page": currentPage,
      "limit": itemCount,
      "search": searchKey,
      "tagsId": [widget.data['tagId']],
    };
    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/listv2',
        reqData,
      );
      inboxList = InboxListModel.fromJson(resp);
      _loaderTimer?.cancel();
      if (!mounted) return;
      if (inboxList!.success) {
        setState(() {
          if (currentPage > 1) {
            _items.addAll(inboxList!.data!.emails);
          } else {
            _items = inboxList!.data!.emails;
          }
          currentPage++;
          _isLoading = false;
        });
      } else {
        final msg = inboxList!.message.toLowerCase();
        if (!msg.contains('invalid token') && !msg.contains('unauthorized')) {
          CommonService.animatedToast(inboxList!.message, 'error');
        }
        setState(() { _isLoading = false; });
      }
    } catch (error) {
      _loaderTimer?.cancel();
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _updateEmailStatus(String type, List ids) async {
    try {
      await ApiService().post(
        'email/update-email-status',
        {"key": type, "emailIds": ids, "value": true},
      );
    } catch (_) {}
  }

  void _bulkUpdateStatusSingle(String type, int id) {
    final item = _items.cast<Emails?>().firstWhere(
          (e) => e?.emailId == id,
          orElse: () => null,
        );
    final isSent = item != null && _isSentByMe(item);

    Future<void> doMove() async {
      if (isSent) {
        // Dual-API pattern for sent messages
        final resp = await ApiService().post(
          'email/update-email-status',
          {"key": "isSent", "emailIds": [id], "value": false},
        );
        if (resp['success'] == true) {
          await ApiService().post(
            'email/update-email-status',
            {"key": type, "emailIds": [id], "value": true},
          );
          await ApiService().post(
            'email/update-email-status',
            {"key": "isRead", "emailIds": [id], "value": true},
          );
        }
      } else {
        await _updateEmailStatus(type, [id]);
      }
    }

    doMove().then((_) {
      if (mounted) {
        setState(() { currentPage = 1; });
        getAllEmails("");
      }
    });
  }

  Future<void> _addEmailTagsById(List<int> emailIds, int tagId) async {
    try {
      await ApiService().post(
        'email/emails-tags',
        {"emailIds": emailIds, "tagsId": [tagId], "type": "add"},
      );
      if (!mounted) return;
      setState(() { currentPage = 1; });
      getAllEmails("");
    } catch (_) {}
  }
}
