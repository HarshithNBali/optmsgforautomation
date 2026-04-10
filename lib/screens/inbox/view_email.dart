import 'dart:async';
import 'dart:convert';

import 'package:descope/descope.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/common/utilites/secure_print_helper.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/inbox/native_app_html_view.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';
import 'package:optmsg/services/global_variable_notifier.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/widgets/drawer_item.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import '../../constant/app_config.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/model/view_email_model.dart';
import 'package:optmsg/model/inbox_list_model.dart' as inbo;
import 'package:optmsg/model/sent_list_model.dart' as sent;

import 'package:optmsg/widgets/standard_fab.dart';
import 'package:optmsg/services/count_notifier.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../router/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'custom_file_downloader_manager.dart';

class ViewEmail extends ConsumerStatefulWidget {
  final int emailId;
  final String emailType;
  final TagsListModel? allTagsList;
  final int? itemIndex;
  final bool hideAppBar;

  /// Callback for when an action is performed in reading pane mode (hideAppBar=true).
  /// This is called instead of context.pop() to allow the parent to handle the action.
  final void Function(Map<String, dynamic> actionData)? onAction;

  /// PC-01: Callback to report fetch errors to the parent (reading pane).
  /// Replaces the emailDetailProvider error-watch pattern that caused a
  /// duplicate email/detail API call on every email open.
  final void Function(String error)? onError;

  /// PC-01: Called when fetch error is cleared (successful load or retry).
  final VoidCallback? onErrorCleared;

  const ViewEmail({
    super.key,
    required this.emailId,
    required this.emailType,
    this.allTagsList,
    this.itemIndex,
    this.hideAppBar = false,
    this.onAction,
    this.onError,
    this.onErrorCleared,
  });

  @override
  ConsumerState<ViewEmail> createState() => _ViewEmailState();
}

class _ViewEmailState extends ConsumerState<ViewEmail> {
  bool _isLoading = false;
  bool _isScaling = false;
  final Set<int> _activePointers = {};
  bool _expandedView = false;
  bool _showTagList = false;
  bool _showMenuOptions = false;
  bool _showAllAttachments = false;
  bool _markedAsUnread = false; // Track if email was marked as unread
  bool _movedToArchive = false; // Track if email was moved to archive
  bool _movedToTrash = false; // Track if email was moved to trash
  bool _movedToInbox = false; // Track if email was moved to inbox
  bool _movedToSent = false; // Track if email was moved to sent
  bool _canPopNow = false; // Track if we are allowed to pop
  List<Map<String, dynamic>>? selectTagList;
  final SecureStorageService secureStorageService = SecureStorageService();
  dynamic newNotification;
  Map<String, dynamic>? userData;
  List<inbo.EmailRecipientTags> updatedTags = [];
  List<sent.EmailTag> sentUpdatedTags = [];
  ViewEmailModel? emailData;
  late Email emails;
  Map<dynamic, List<Receivers>> categorizedData = {};
  Map<String, List<Map<String, dynamic>>> dividedByType = {};
  bool showFullEmail = false;
  String htmlContent = '';
  String token = "";
  bool isTagsUpdated = false;
  bool fileDownloading = false;
  bool _isOpeningAttachment = false;
  // final ValueNotifier<double> _heightNotifier = ValueNotifier<double>(100);
  StreamSubscription? _notificationSub;
  Timer? _statusUpdateTimer;
  // L-09: Track last config key to avoid redundant setAppBarConfig calls
  // that trigger parent rebuilds and risk an infinite loop.
  String _lastAppBarConfigKey = '';
  void _pushAppBarConfig() {
    if (!mounted || widget.hideAppBar) return;
    final isMobileView = !kIsWeb || AppBreakpoints.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    final showActions = !isNativeTabletLandscape && isMobileView;

    final emailTitle = CommonService().capitalize(
      widget.emailType == 'newEmailInbox'
          ? 'Inbox'
          : widget.emailType == 'newEmailCommunity'
          ? 'Trash'
          : widget.emailType,
    );

    // L-09: Skip if config hasn't changed — prevents parent rebuild loop
    // when setAppBarConfig triggers setState in ShellLayout.
    // Include overlay state so the config (and onBackPressed) stays in sync.
    final configKey = '$emailTitle|$showActions|${emailData != null}|$_showMenuOptions|$_showTagList';
    if (configKey == _lastAppBarConfigKey) return;
    _lastAppBarConfigKey = configKey;

    final hasOverlay = _showMenuOptions || _showTagList;

    ShellLayout.of(context)?.setAppBarConfig(
      AppBarConfig(
        title: emailTitle,
        onBackPressed: hasOverlay
            ? () {
                setState(() {
                  _showMenuOptions = false;
                  _showTagList = false;
                });
              }
            : null,
        customActions: showActions
            ? [
                IconButton(
                  key: const Key('view_email_optin_button'),
                  tooltip: 'Opt-in sender',
                  icon: SvgPicture.asset(svgOptin),
                  onPressed: emailData != null
                      ? () {
                          CommonService().gotoAddRecipient(
                            emailData!.data.email.senderEmail,
                            context: context,
                            senderDisplayName: _displayNameForEmail(emailData!.data.email.senderEmail),
                          );
                        }
                      : null,
                ),
                IconButton(
                  key: const Key('view_email_delete_button'),
                  tooltip: 'Delete',
                  icon: SvgPicture.asset(svgDelete, height: 20, width: 20),
                  onPressed: () {
                    setState(() {
                      _showMenuOptions = false;
                    });
                    _handleMoveToTrash();
                  },
                ),
                IconButton(
                  key: const Key('view_email_more_button'),
                  tooltip: 'More options',
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    setState(() {
                      _showMenuOptions = !_showMenuOptions;
                    });
                  },
                ),
              ]
            : [],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Always fetch email details if data doesn't match the current ID
    if (emailData?.data.email.id != widget.emailId) {
      getEmailViewDetail();
    }
    _setupListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushAppBarConfig();
    });
  }

  @override
  void didUpdateWidget(ViewEmail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If email ID changed, fetch new details
    if (oldWidget.emailId != widget.emailId) {
      // Clear existing data
      setState(() {
        emailData = null;
        _isLoading = true;
      });

      // Fetch new details
      getEmailViewDetail();
    }
  }

  Widget _buildWebDetailActionBar(bool isNativeTabletLandscape) {
    printLog("_buildWebDetailActionBar", "message");
    if (((!kIsWeb && !isNativeTabletLandscape) ||
        widget.hideAppBar ||
        emailData == null)) {
      return const SizedBox.shrink();
    }
    final bool isTrash = widget.emailType == 'Trash';
    final bool isArchive = widget.emailType == 'Archive';
    final bool isSent = widget.emailType == 'Sent';
    final Map<String, dynamic>? currentUserMap =
        userData?['user'] as Map<String, dynamic>?;
    final int? currentUserId = currentUserMap?['id'] as int?;
    final bool canMoveToInbox =
        (isArchive || isTrash) &&
        currentUserId != null &&
        currentUserId != emails.senderId;
    final bool canMoveToSent =
        (isArchive || isTrash) &&
        currentUserId != null &&
        currentUserId == emails.senderId;
    final liveTagsList = ref.watch(tagsProvider).tagsList;
    final bool hasTags =
        liveTagsList != null && liveTagsList.data.tags.isNotEmpty;

    List<Widget> actionItems = [
      // Back button is now in the app bar, not here
      CommonWebButton(
        onPressed: gotoCompose,
        iconAsset: svgCompose,
        label: 'Compose',
      ),
      const SizedBox(width: 16),
      _buildActionIcon(
        svgReplyBtn,
        () => gotoReply(widget.emailId, "reply"),
        tooltip: 'Reply',
      ),
      _buildActionIcon(
        svgReplyAllBtn,
        () => gotoReply(widget.emailId, "replyAll"),
        tooltip: 'Reply All',
      ),
      _buildActionIcon(
        svgForwardBtn,
        () => gotoReply(widget.emailId, "forward"),
        tooltip: 'Forward',
      ),
      _buildActionIcon(svgPrint, _handlePrintAction, tooltip: 'Print'),
      if (!isSent)
        _buildActionIcon(
          svgDelete,
          _handleMoveToTrash,
          tooltip: widget.emailType == 'Trash'
              ? permanentlyDelete
              : 'Move to Trash',
        ),
      if (!isArchive && !isSent)
        _buildActionIcon(
          svgArchive,
          _handleMoveToArchive,
          tooltip: 'Move to Archive',
        ),
      if (canMoveToInbox)
        _buildActionIcon(
          svgInbox,
          _handleMoveToInbox,
          tooltip: 'Move to Inbox',
        ),
      if (canMoveToSent)
        _buildActionIcon(svgSent, _handleMoveToSent, tooltip: 'Move to Sent'),
      if (!isSent)
        _buildActionIcon(
          svgUnread,
          _handleMarkAsUnread,
          tooltip: 'Mark as Unread',
        ),
      _buildActionIcon(
        svgTags,
        hasTags ? _handleTagAction : null,
        tooltip: 'Tag',
      ),
      _buildActionIcon(
        svgOptin,
        _handleOptInAction,
        tooltip: optIn,
        useDefaultColor: false,
      ),
    ];

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < actionItems.length; i++) {
      spacedChildren.add(actionItems[i]);
      if (i != actionItems.length - 1) {
        spacedChildren.add(const SizedBox(width: 4));
      }
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(width: 1, color: context.colors.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: spacedChildren),
      ),
    );
  }

  Widget _buildActionIcon(
    String asset,
    VoidCallback? onPressed, {
    String? tooltip,
    bool useDefaultColor = true,
  }) {
    final Color activeColor = context.colors.onSurfaceVariant;
    final Color disabledColor = context.colors.outlineVariant;
    final Widget icon = SvgPicture.asset(
      asset,
      height: 20,
      width: 20,
      colorFilter: useDefaultColor
          ? ColorFilter.mode(
              onPressed == null ? disabledColor : activeColor,
              BlendMode.srcIn,
            )
          : null,
    );

    return IconButton(
      key: Key('view_email_action_${asset.split('/').last.split('.').first}'),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 22,
      icon: icon,
    );
  }

  void _handleMoveToTrash() async {
    if (widget.emailType == 'Trash') {
      onCancel(context, 0, 'isTrash', 'actionSheet', 'undo');
    } else {
      setState(() {
        _movedToTrash = true;
      });
      changeEmailStatus(
        context,
        widget.itemIndex ?? 0,
        'isTrash',
        'actionSheet',
        true,
      );
    }
  }

  void _handleMoveToArchive() async {
    setState(() {
      _movedToArchive = true;
    });
    changeEmailStatus(
      context,
      widget.itemIndex ?? 0,
      'isArchive',
      'actionSheet',
      true,
    );
  }

  void _handleMoveToInbox() async {
    setState(() {
      _movedToInbox = true;
    });
    changeEmailStatus(
      context,
      widget.itemIndex ?? 0,
      'isInbox',
      'actionSheet',
      true,
    );
  }

  void _handleMoveToSent() async {
    setState(() {
      _movedToSent = true;
    });
    changeEmailStatus(
      context,
      widget.itemIndex ?? 0,
      'isSent',
      'actionSheet',
      true,
    );
  }

  void _handleMarkAsUnread() async {
    setState(() {
      _markedAsUnread = true;
    });

    // Mark as unread should happen immediately — no undo delay or snackbar.
    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/update-email-status',
        {
          "key": "isRead",
          "emailIds": [widget.emailId],
          "value": false,
        },
      );
      if (resp['success']) {
        // Update unread count via socket
        if (kIsWeb && userData != null && userData!['user'] != null) {
          SocketService().emitEventWithAck(
            'unReadCount',
            {"userId": userData!['user']['id']},
            ackCallback: (data) {
              if (data != null && kIsWeb) {
                ref.read(countProvider.notifier).updateCounts(
                      inbox: data['inboxCount'] ?? 0,
                      draft: data['draftCount'] ?? 0,
                      trash: data['trashCount'] ?? 0,
                      archive: data['archiveCount'] ?? 0,
                    );
              }
            },
          );
        }
        redirection('isRead');
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      // API call may fail silently
    }
  }

  void _handleTagAction() {
    final tagsState = ref.read(tagsProvider);
    if (tagsState.tagsList != null &&
        tagsState.tagsList!.data.tags.isNotEmpty) {
      setState(() {
        _showTagList = !_showTagList;
        _showMenuOptions = false;
      });
    } else {
      CommonService.animatedToast("No Tags Found", 'warning');
    }
  }

  Future<void> _handlePrintAction() async {
    ActionBiometricGuard.markDeparture();
    printLog("_handlePrintAction", "print");
    final sessionToken = Descope.sessionManager.session?.sessionJwt ?? token;
    await openSecurePrint(
      printUrl: '$printUrl${widget.emailId}',
      token: sessionToken,
      context: context,
      subject: emailData?.data.email.subject,
    );
  }

  /// Returns the display name for a given email address by checking sender and
  /// receivers in the currently-loaded email. Returns null if not found or empty.
  String? _displayNameForEmail(String email) {
    if (emailData == null) return null;
    final data = emailData!.data.email;
    if (email == data.senderEmail) {
      final parts = [
        data.sender.firstName?.trim(),
        data.sender.lastName?.trim(),
      ].where((p) => p != null && p.isNotEmpty).join(' ');
      return parts.isEmpty ? null : parts;
    }
    return null;
  }

  void _handleOptInAction() {
    if (emailData == null || emailData!.data.email.senderEmail.isEmpty) {
      CommonService.animatedToast('Email data not loaded', 'error');
      return;
    }
    CommonService().gotoAddRecipient(
      emailData!.data.email.senderEmail,
      context: context,
      senderDisplayName: _displayNameForEmail(emailData!.data.email.senderEmail),
    );
  }

  /// Initialize the socket connection to the server.
  ///
  /// It emits a login event with the descope token, and then requests the unread count.
  /// It also listens for new notifications and updates the unread count.
  Future<void> _setupListeners() async {
    try {
      await getUserData();
      if (userData == null ||
          userData!['user'] == null ||
          userData!['user']['id'] == null) {
        return;
      }

      SocketService().emitEventWithAck(
        'unReadCount',
        {"userId": userData!['user']['id']},
        ackCallback: (data) {
          if (data != null && mounted) {
            setState(() {
              if (!kIsWeb) {
                // AppBadgePlus.updateBadge(data['badgeCount'] ?? 0);
                // We might want to leave this or remove it depending if ShellLayout handles it perfectly on mobile.
                // Plan said ShellLayout handles it. Let's comment/remove to avoid double updates or conflicts.
                // However, ViewEmail might be the only place updating THIS specific Badge if it's foreground?
                // ShellLayout handles it now. So safe to remove or just leave as visual.
                // I will remove the countProvider update.
              }
            });
            // Removed redundancy: ref.read(countProvider.notifier).updateCounts(...)
          }
        },
      );

      SocketService().emitEventWithAck(
        'notificationExists',
        {"userId": userData!['user']['id']},
        ackCallback: (data) {
          if (data != null && mounted) {
            dynamic sanitizedData = data;
            if (kIsWeb &&
                data is! Map &&
                data is! List &&
                data is! String &&
                data is! num &&
                data is! bool) {
              try {
                sanitizedData = jsonDecode(jsonEncode(data));
              } catch (_) {
                // JSON serialization may fail for non-serializable web objects
              }
            }
            setState(() => newNotification = sanitizedData);
          }
        },
      );

      _notificationSub = SocketService().onEvent('notificationExists').listen((
        data,
      ) {
        if (mounted) {
          dynamic sanitizedData = data;
          if (kIsWeb &&
              data is! Map &&
              data is! List &&
              data is! String &&
              data is! num &&
              data is! bool) {
            try {
              sanitizedData = jsonDecode(jsonEncode(data));
            } catch (_) {
              // JSON serialization may fail for non-serializable web objects
            }
          }
          setState(() => newNotification = sanitizedData);
        }
      });
    } catch (_) {
      // Socket listener setup may fail if socket is not connected
    }
  }

  @override
  /// Cleans up resources used by the `_ViewEmailState`.
  ///
  /// Disconnects and disposes the socket connection, and cleans up the socket
  /// instance. Calls `super.dispose()` to release any other resources.
  void dispose() {
    _notificationSub?.cancel();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  bool isDownloading = false;
  String progress = "";
  String status = "Idle";

  Future<void> saveFileToDownloads(String fileUrl, String fileName) async {
    CustomFileDownloaderManger().urlFileSaver(url: fileUrl, fileName: fileName);

    /* try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';

      setState(() => status = "Starting download...");

      final dio = Dio(BaseOptions(
          responseType: ResponseType.bytes, // ✅ force binary
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 2),
        ),);


      final response = await dio.get<List<int>>(
        fileUrl,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percent = (received / total * 100).toStringAsFixed(0);
            setState(() => status = "Downloading... $percent%");
          }
        },
      );
      context.pop();
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Invalid file response");
      }

      final file = File(tempFilePath);
      await file.writeAsBytes(response.data!, flush: true);

      final fileSize = await file.length();
      debugPrint("Downloaded file size: $fileSize bytes");

      if (fileSize == 0) {
        throw Exception("Downloaded file is empty");
      }

      setState(() => status = "Download complete. Choose save location...");

      final result = await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: fileName,
      );

      if (result.status == ShareResultStatus.success) {
        setState(() => status = "File saved successfully.");
        showToast(context, "File saved successfully");
      } else if (result.status == ShareResultStatus.dismissed) {
        setState(() => status = "File downloaded (not saved).");
      }



    } catch (e) {
      debugPrint("Download error: $e");
      setState(() => status = "Download failed");
      showToast(context, "Download failed");
    }*/
  }

  // final Set<int> _activePointers = {}; // Tracks active pointers (fingers)
  // final bool _isWebViewLoading = true;
  @override
  /// Builds the [ViewEmail] widget tree.
  ///
  /// This widget contains the email message body and attachment contacts_riverpod.
  /// It also handles the print, tag, move to archive_riverpod, move to trash, and cancel actions.
  ///
  Widget build(BuildContext context) {
    // Read tags from provider so the list is always current (not stale widget param)
    final liveAllTagsList = ref.watch(tagsProvider).tagsList;
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    // Re-push AppBarConfig after build so actions stay in sync with state.
    // Must defer to avoid "modify provider while building" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushAppBarConfig();
    });
    return PopScope(
      canPop: _canPopNow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (CommonService().getPlatform() != 'ios') {
          await redirection('tag');
        }
      },
      child: Scaffold(
        floatingActionButton:
            widget.hideAppBar ||
                ((kIsWeb && !AppBreakpoints.isMobileLayout(context)) ||
                    isNativeTabletLandscape) ||
                _showTagList ||
                fileDownloading
            ? null
            : StandardFab.button(
                iconAsset: svgReplyIcon,
                onPressed: () {
                  if (!_isLoading) _showActionSheet(context);
                },
              ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        body: SafeArea(
          top: false,
          bottom: false,
          child: DelayedLoadingOverlay(
            isLoading: _isLoading || isDownloading,
            child: Builder(
            builder: (context) {
              if (emailData == null) {
                return _isLoading ? const SizedBox.shrink() : const EmptyState(variant: EmptyStateVariant.emailDetail);
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: _isScaling
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: !kIsWeb
                          ? EdgeInsets.all(Platform.isIOS ? 8.0 : 15)
                          : const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((kIsWeb &&
                                  !widget.hideAppBar &&
                                  !AppBreakpoints.isMobileLayout(context)) ||
                              (isNativeTabletLandscape &&
                                  !widget.hideAppBar)) ...[
                            _buildWebDetailActionBar(isNativeTabletLandscape),
                            const SizedBox(height: 12),
                          ],
                          if (emailData!.data.email.subject
                              .toString()
                              .trim()
                              .isNotEmpty)
                            SelectionArea(
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    CommonService().capitalize(
                                      emailData!.data.email.subject.toString(),
                                    ),
                                    style: AppTypography.viewEmailSubject(context),
                                  ),
                                ),
                              ),
                            ),
                          SelectionArea(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colors.outlineVariant,
                                  width: 2.0,
                                ),
                              ),
                              child: InkWell(
                                key: const Key('view_email_expand_toggle'),
                                onTap: () {
                                  setState(() {
                                    _expandedView = !_expandedView;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 45,
                                              child: Text(
                                                CommonService().capitalize(
                                                  'From:',
                                                ),
                                                style: AppTypography.messageHeaderLabel(context),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.zero,
                                                child: getSenderfullName(
                                                  emailData!
                                                      .data
                                                      .email
                                                      .sender
                                                      .firstName
                                                      .toString(),
                                                  emailData!
                                                      .data
                                                      .email
                                                      .senderEmail,
                                                  _expandedView
                                                      ? "email"
                                                      : "name",
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              key: const Key('view_email_expand_toggle_icon'),
                                              onTap: () {
                                                setState(() {
                                                  _expandedView =
                                                      !_expandedView;
                                                });
                                              },
                                              child: SvgPicture.asset(
                                                _expandedView
                                                    ? svgUpArrow
                                                    : svgDownArrow,
                                                colorFilter: ColorFilter.mode(
                                                  context.colors.onSurfaceVariant,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      for (var key in categorizedData.keys)
                                        if ((key == "to" && !_expandedView) ||
                                            _expandedView)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 45,
                                                      child: Text(
                                                        CommonService()
                                                            .capitalize(
                                                              '$key:',
                                                            ),
                                                        style: AppTypography
                                                            .messageHeaderLabel(context),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 5.0,
                                                            ),
                                                        child: Wrap(
                                                          children: [
                                                            for (var item
                                                                in categorizedData[key]!
                                                                    .asMap()
                                                                    .entries)
                                                              if ((item.value.type ==
                                                                          "to" &&
                                                                      !_expandedView) ||
                                                                  _expandedView)
                                                                Wrap(
                                                                  children: [
                                                                    formatEmailNameText(
                                                                      item.value,
                                                                      categorizedData[key]
                                                                          ?.length,
                                                                      item.key,
                                                                    ),
                                                                    if (_expandedView) ...[
                                                                      const SizedBox(width: 3),
                                                                      formatEmailText(
                                                                        item.value,
                                                                        categorizedData[key]
                                                                            ?.length,
                                                                        item.key,
                                                                      ),
                                                                    ],
                                                                  ],
                                                                ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            CommonService.fullDateTime(
                                              emailData!.data.email.created,
                                            ),
                                            style: AppTypography.timeStamp(context),
                                          ),
                                          if (emailData!
                                              .data
                                              .email
                                              .attachments
                                              .isNotEmpty)
                                            SvgPicture.asset(
                                              svgAttachment,
                                              colorFilter: ColorFilter.mode(
                                                context.colors.onSurfaceVariant,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  if (emailData!
                                      .data
                                      .email
                                      .emailTags
                                      .isNotEmpty)
                                    for (
                                      int index = 0;
                                      index <
                                          emailData!
                                              .data
                                              .email
                                              .emailTags
                                              .length;
                                      index++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 3.0,
                                          bottom: 5.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                context.appColors.tagChipBg,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 1.0,
                                            vertical: 2.0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ensure that each row wraps independently
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                      left: 5.0,
                                                      right: 2.0,
                                                    ),
                                                child: Text(
                                                  emailData!
                                                      .data
                                                      .email
                                                      .emailTags[index]
                                                      .tag,
                                                  style: AppTypography.labelSmall(context).copyWith(
                                                    color: context.appColors.tagChipText,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => addAndDeleteEmailTags(
                                                  emailData!
                                                      .data
                                                      .email
                                                      .emailTags[index]
                                                      .id,
                                                  'delete',
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 4.0),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: context.appColors.tagChipText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          if (emailData!.data.email.attachments.isNotEmpty)
                            _buildHorizontalAttachments(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Listener(
                              onPointerDown: (event) {
                                _activePointers.add(event.pointer);
                                if (_activePointers.length >= 2) {
                                  setState(() => _isScaling = true);
                                }
                              },
                              onPointerUp: (event) {
                                _activePointers.remove(event.pointer);
                                if (_activePointers.length < 2) {
                                  setState(() => _isScaling = false);
                                }
                              },
                              onPointerCancel: (event) {
                                _activePointers.remove(event.pointer);
                                if (_activePointers.length < 2) {
                                  setState(() => _isScaling = false);
                                }
                              },
                              child: NativeAppHtmlView(
                                html: emailData!.data.email.message,
                                onCallback: (email) => openClipboard(email),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showTagList)
                    PointerInterceptor(
                      intercepting: kIsWeb || Platform.isAndroid ? true : false,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showMenuOptions = false;
                            _showTagList = false;
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppStyles.backDrop,
                          ),
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      AppBreakpoints.screenHeight(context) *
                                      0.43, // Set the maximum height here
                                ),

                                // height:
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (liveAllTagsList != null &&
                                          widget
                                              .allTagsList!
                                              .data
                                              .tags
                                              .isNotEmpty)
                                        for (
                                          int index = 0;
                                          index <
                                              widget
                                                  .allTagsList!
                                                  .data
                                                  .tags
                                                  .length;
                                          index++
                                        )
                                          MyDrawerItem(
                                            title: widget
                                                .allTagsList!
                                                .data
                                                .tags[index]
                                                .tag, // You can use item.title here if you have a title in your tag object
                                            svgIcon:
                                                svgTags, // You can use item.svgIcon here if you have an icon in your tag object
                                            showRightIcon:
                                                emailData!.data.email.emailTags
                                                    .any(
                                                      (element) =>
                                                          element.id ==
                                                          widget
                                                              .allTagsList!
                                                              .data
                                                              .tags[index]
                                                              .id,
                                                    )
                                                ? true
                                                : false,

                                            rightIcon: Icon(
                                              Icons.check,
                                              color: context.colors.primary,
                                            ),
                                            // ]
                                            onTap: () {
                                              addAndDeleteEmailTags(
                                                widget
                                                    .allTagsList!
                                                    .data
                                                    .tags[index]
                                                    .id,
                                                'add',
                                              );
                                            },
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_showMenuOptions)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showMenuOptions = false;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppStyles.backDrop,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    MyDrawerItem(
                                      title: 'Print',
                                      svgIcon: svgPrint,
                                      onTap: () async {
                                        setState(() {
                                          _showMenuOptions = !_showMenuOptions;
                                        });
                                        ActionBiometricGuard.markDeparture();
                                        final sessionToken = Descope.sessionManager.session?.sessionJwt ?? token;
                                        await openSecurePrint(
                                          printUrl: '$printUrl${widget.emailId}',
                                          token: sessionToken,
                                          context: context,
                                          subject: emailData?.data.email.subject,
                                        );
                                      },
                                      showRightIcon: false,
                                    ),
                                    MyDrawerItem(
                                      title: 'Tag',
                                      svgIcon: svgTags,
                                      onTap: () {
                                        if (liveAllTagsList != null &&
                                            widget
                                                .allTagsList!
                                                .data
                                                .tags
                                                .isNotEmpty) {
                                          setState(() {
                                            _showTagList = !_showTagList;
                                            _showMenuOptions =
                                                !_showMenuOptions;
                                          });
                                        } else {
                                          CommonService.animatedToast(
                                            "No Tags Found",
                                            'warning',
                                          );
                                        }
                                      },
                                      showRightIcon: false,
                                    ),
                                    if (widget.emailType != 'Archive')
                                      MyDrawerItem(
                                        title: 'Move to Archive',
                                        svgIcon: svgArchive,
                                        onTap: () async {
                                          setState(() {
                                            _showMenuOptions = false;
                                          });
                                          _handleMoveToArchive();
                                        },
                                        showRightIcon: false,
                                      ),
                                    if (widget.emailType != 'Sent')
                                      MyDrawerItem(
                                        title: widget.emailType == 'Trash'
                                            ? permanentlyDelete
                                            : 'Move to Trash',
                                        svgIcon: svgTrash1,
                                        onTap: () async {
                                          setState(() {
                                            _showMenuOptions = false;
                                          });
                                          _handleMoveToTrash();
                                        },
                                        showRightIcon: false,
                                      ),
                                    if ((widget.emailType == 'Archive' ||
                                            widget.emailType == 'Trash') &&
                                        userData?['user']?['id'] !=
                                            emails.senderId)
                                      MyDrawerItem(
                                        title: 'Move to Inbox',
                                        svgIcon: svgInbox,
                                        onTap: () async {
                                          setState(() {
                                            _showMenuOptions = false;
                                          });
                                          _handleMoveToInbox();
                                        },
                                        showRightIcon: false,
                                      ),
                                    if ((widget.emailType == 'Archive' ||
                                            widget.emailType == 'Trash') &&
                                        userData?['user']?['id'] != null &&
                                        userData!['user']['id'] ==
                                            emails.senderId)
                                      MyDrawerItem(
                                        title: 'Move to Sent',
                                        svgIcon: svgSent,
                                        onTap: () async {
                                          setState(() {
                                            _showMenuOptions = false;
                                          });
                                          _handleMoveToSent();
                                        },
                                        showRightIcon: false,
                                      ),
                                    if (widget.emailType != "Sent")
                                      MyDrawerItem(
                                        title: 'Mark as Unread',
                                        svgIcon: svgUnread,
                                        onTap: () async {
                                          await updateEmailStatus('isRead');

                                          // Store the flag and close the menu
                                          setState(() {
                                            _markedAsUnread = true;
                                            _showMenuOptions = false;
                                          });
                                        },
                                        showRightIcon: false,
                                      ),
                                    MyDrawerItem(
                                      svgColor: context.appColors.svgIconAccent,
                                      title: optIn,
                                      svgIcon: svgOptin,
                                      onTap: emailData != null
                                          ? () async {
                                              CommonService().gotoAddRecipient(
                                                emailData!.data.email.senderEmail,
                                                context: context,
                                                senderDisplayName: _displayNameForEmail(emailData!.data.email.senderEmail),
                                              );
                                            }
                                          : null,
                                      showRightIcon: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        ),
      ),
    );
  }

  /// Navigates to the ViewContact page to display the details of the given contact.
  ///
  /// This function takes a [contact] object and navigates to the [ViewContact] page,
  /// passing the contact information along with a 'contacts_riverpod' page type. It uses the
  /// [Navigator] to push a new [MaterialPageRoute] onto the navigation stack, which
  /// results in displaying the contact details.
  Future<void> viewContact(Contacts contact) async {
    await context.push(
      AppRoutes.viewContactriverpodPath(contact.id),
      extra: {'contact': contact, 'page': 'contacts_riverpod'},
    );
  }

  /// Shows a bottom sheet for performing reply, reply all, or forward on an email.
  ///
  /// This function takes a [BuildContext] object and displays a bottom sheet with
  /// options to reply, reply all, or forward the email. It uses the [showModalBottomSheet]
  /// to display the bottom sheet and uses the [Navigator] to pop the sheet when an action
  /// is performed. The sheet is decorated with a rounded border and a semi-transparent
  /// background.
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      backgroundColor: const Color.fromARGB(20, 0, 0, 0),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 25),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppStyles.radiusM)),
            child: Wrap(
              children: <Widget>[
                PointerInterceptor(
                  intercepting: kIsWeb || Platform.isAndroid ? true : false,
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: const Center(
                      child: Text(
                        'Reply All',
                        style: TextStyle(color: AppStyles.primary2Color),
                      ),
                    ),
                    onTap: () {
                      // Perform action when "Choose from Photos" is tapped
                      context.pop();
                      gotoReply(
                        widget.emailId,
                        "replyAll",
                      ); // Close the action sheet
                    },
                  ),
                ),
                const Divider(),
                PointerInterceptor(
                  intercepting: kIsWeb || Platform.isAndroid ? true : false,
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: const Center(
                      child: Text(
                        'Reply',
                        style: TextStyle(color: AppStyles.primary2Color),
                      ),
                    ),
                    onTap: () {
                      context.pop();
                      gotoReply(widget.emailId, "reply");
                    },
                  ),
                ),
                const Divider(),
                PointerInterceptor(
                  intercepting: kIsWeb || Platform.isAndroid ? true : false,
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: const Center(
                      child: Text(
                        'Forward',
                        style: TextStyle(color: AppStyles.primary2Color),
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    onTap: () {
                      // Perform action when "Take a Photo" is tapped
                      context.pop();
                      gotoReply(
                        widget.emailId,
                        "forward",
                      ); // Close the action sheet
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: PointerInterceptor(
                    intercepting: kIsWeb || Platform.isAndroid ? true : false,
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppStyles.primary2Color),
                        ),
                      ),
                      onTap: () {
                        // Perform action when "Cancel" is tapped
                        context.pop(); // Close the action sheet
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Downloads a file from the given [url] and saves it to the downloads directory.
  ///
  /// On web, it uses the [CheckOutImp] class to download the file.
  ///
  /// On mobile, it uses the [path_provider] package to get the downloads directory
  /// and the [http] package to download the file.
  ///
  /// The [showDialog] is used to show a loading indicator while the file is being
  /// downloaded.
  ///
  /// When the download is complete, the loading indicator is dismissed with
  /// [Navigator.of(context, rootNavigator: true).pop()].
  ///
  Future<void> _downloadFile(
    BuildContext context,
    Attachments attachment,
  ) async {
    if (isDownloading) return; // Prevent multiple simultaneous downloads
    isDownloading = true;
    final url = s3BaseUrl + attachment.path.toString();
    String path = attachment.path.toString();
    const String attachmentUrl =
        'email/attachment-url'; // Use const to ensure immutability
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: LoaderIndicator(),
          );
        },
      );
      Map<String, dynamic> attachData = await ApiService().post(attachmentUrl, {
        "file": path,
      });
      if (attachData['success'] == true) {
        if (kIsWeb) {
          // CheckOutImp().webWindowOpenPrint(
          //   attachData['data']['signedUrl'],
          //   'new tab',
          // );
          CheckOutImp().downloadWebFileWithPicker(
            attachData['data']['signedUrl'],
            suggestedName: url.split('/').last,
          );
        } else {
          await saveFileToDownloads(
            attachData['data']['signedUrl'],
            url.split('/').last,
          );
        }
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    } finally {
      isDownloading = false; // Reset the flag
      context.pop();
    }
  }

  /// File extensions that browsers can render inline (images, PDFs, plain text).
  /// Used on web to decide whether to show "Open" or only "Download".
  static const _webPreviewableExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
    'pdf', 'txt', 'csv',
  };

  /// Returns `true` when the browser can natively preview this attachment type.
  bool _isWebPreviewable(Attachments attachment) {
    final ext = (attachment.type ?? '').toLowerCase();
    if (_webPreviewableExtensions.contains(ext)) return true;
    final path = (attachment.path ?? '').toLowerCase();
    return _webPreviewableExtensions.any((e) => path.endsWith('.$e'));
  }

  Future<void> _openAttachmentInNativeApp(
    Attachments attachment,
    int type,
  ) async {
    if (_isOpeningAttachment) return;
    ActionBiometricGuard.markDeparture();

    _isOpeningAttachment = true;

    // iOS: use showDialog (safe — iOS MethodChannel opens native QuickLook
    // which doesn't trigger activity destruction).
    // Android & Web: use isDownloading / DelayedLoadingOverlay (a widget, not
    // a Navigator route — avoids the Navigator lock crash during Android
    // activity transitions).
    final bool useDialog = !kIsWeb && Platform.isIOS;
    if (useDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: LoaderIndicator());
        },
      );
    } else {
      setState(() => isDownloading = true);
    }

    try {
      // Determine file type from attachment metadata — available immediately,
      // before the signed-URL API call.  We need this early so we can
      // pre-open a browser tab while still inside the user gesture on Safari.
      // Safari's popup blocker rejects window.open() called after any await.
      final String preCheckPath = (attachment.path ?? '').toLowerCase();
      final bool willBeImage =
          preCheckPath.endsWith('.jpg') ||
          preCheckPath.endsWith('.jpeg') ||
          preCheckPath.endsWith('.png') ||
          preCheckPath.endsWith('.gif') ||
          preCheckPath.endsWith('.bmp') ||
          preCheckPath.endsWith('.webp') ||
          (attachment.type != null &&
              ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
                  .contains(attachment.type!.toLowerCase()));
      final bool willBePdf =
          preCheckPath.endsWith('.pdf') ||
          (attachment.type != null &&
              attachment.type!.toLowerCase() == 'pdf');
      // Pre-open a blank tab synchronously within the user gesture so Safari
      // allows it.  The open methods below (openHtmlInNewTab, openBlobInNewTab,
      // webWindowOpenPrint) will navigate this tab instead of opening a new one.
      if (kIsWeb) {
        CheckOutImp().preOpenTab();
      }

      // Get signed URL from API
      const String attachmentUrlApi = 'email/attachment-url';
      final String path = attachment.path ?? '';
      String signedUrl = s3BaseUrl + path;

      final Map<String, dynamic> resp = await ApiService().post(
        attachmentUrlApi,
        {"file": path},
      );

      debugPrint('ATTACHMENT: API response success=${resp['success']}');
      if (resp['success'] == true && resp['data'] != null) {
        signedUrl = resp['data']['signedUrl'] ?? signedUrl;
        debugPrint('ATTACHMENT: using signedUrl from API');
      } else {
        debugPrint('ATTACHMENT: API failed, falling back to unsigned URL');
      }
      debugPrint('ATTACHMENT: signedUrl=$signedUrl');

      if (kIsWeb) {
        if (willBeImage) {
          await CheckOutImp().openImageBlobInNewTab(signedUrl);
        } else if (willBePdf) {
          await CheckOutImp().openBlobInNewTab(
            signedUrl,
            mimeType: 'application/pdf',
          );
        } else {
          CheckOutImp().webWindowOpenPrint(signedUrl);
        }
      } else {
        // Build the local filename, ensuring it always has an extension.
        String fileName = CommonService().getFileName(attachment.path ?? '');
        if (!fileName.contains('.') && (attachment.type?.isNotEmpty ?? false)) {
          fileName = '$fileName.${attachment.type}';
        }
        final localPath = await _downloadFileToTemp(signedUrl, fileName);

        // Dismiss the iOS download dialog BEFORE launching the native viewer.
        if (useDialog && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (localPath != null) {
          if (Platform.isIOS) {
            bool? result;
            try {
              const MethodChannel channel = MethodChannel(
                'com.optmsg.mail/file_opener',
              );
              result = await channel.invokeMethod<bool>('openFile', {
                'filePath': localPath,
              });
            } on MissingPluginException {
              debugPrint('ATTACHMENT: MethodChannel not registered — native handler missing');
              if (mounted) {
                CommonService.animatedToast(
                  'File preview unavailable',
                  'error',
                );
              }
            } on PlatformException catch (e) {
              debugPrint('ATTACHMENT: PlatformException code=${e.code} msg=${e.message}');
              if (mounted) {
                CommonService.animatedToast(
                  cannotOpenFileType,
                  'error',
                );
              }
            } catch (e) {
              debugPrint('ATTACHMENT: unexpected error=${e.runtimeType}: $e');
              if (mounted) {
                CommonService.animatedToast(
                  cannotOpenFileType,
                  'error',
                );
              }
            }
            if (result == true) {
              try {
                await File(localPath).delete();
              } catch (_) {}
            } else if (result == false) {
              final pathToDelete = localPath;
              Future.delayed(const Duration(seconds: 30), () async {
                try {
                  await File(pathToDelete).delete();
                } catch (_) {}
              });
            }
          } else if (Platform.isAndroid) {
            final fileSize = await File(localPath).length();
            debugPrint('ATTACHMENT: file downloaded to $localPath ($fileSize bytes)');

            ActionBiometricGuard.markDeparture();
            debugPrint('ATTACHMENT: launching OpenFilex.open');

            final result = await OpenFilex.open(localPath);
            debugPrint('ATTACHMENT: OpenFilex result type=${result.type}, message=${result.message}');
            if (result.type != ResultType.done && mounted) {
              CommonService.animatedToast(cannotOpenFileType, 'error');
              try { await File(localPath).delete(); } catch (_) {}
            } else {
              final pathToDelete = localPath;
              Future.delayed(const Duration(seconds: 30), () async {
                try {
                  await File(pathToDelete).delete();
                } catch (_) {}
              });
            }
          }
        } else {
          if (mounted) {
            CommonService.animatedToast('Failed to download file', 'error');
          }
        }
      }
    } catch (e) {
      if (kIsWeb) CheckOutImp().closeAndClearPendingTab();
      if (useDialog && mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (mounted) {
        CommonService.animatedToast(catchError, 'error');
      }
    } finally {
      _isOpeningAttachment = false;
      if (mounted && !useDialog) {
        setState(() => isDownloading = false);
      }
    }
  }

  /// Downloads file to local temporary directory for opening
  // Future<String?> _downloadFileToTemp(String url, String fileName) async {
  //   try {
  //     // Get temporary directory
  //     final Directory tempDir = await getTemporaryDirectory();
  //     final String filePath = '${tempDir.path}/$fileName';

  //     // Check if file already exists
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       return filePath;
  //     }

  //     // Download file with progress
  //     Dio dio = Dio();
  //     await dio.download(
  //       url,
  //       filePath,
  //       onReceiveProgress: (received, total) {
  //         if (total != -1 && mounted) {
  //           final progress = (received / total * 100).toStringAsFixed(0);
  //           if (kDebugMode) {
  //             debugPrint('Download progress: $progress%');
  //           }
  //         }
  //       },
  //     );

  //     return filePath;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('Download error: $e');
  //     }
  //     return null;
  //   }
  // }

  Future<String?> _downloadFileToTemp(String url, String fileName) async {
    try {
      // iOS: use Application Support — stable, never purged while the app is
      // running, and accessible by UIDocumentInteractionController.
      // getTemporaryDirectory() can be cleared mid-session on iOS under memory
      // pressure, causing QuickLook to fail silently with FILE_NOT_FOUND.
      //
      // Android: use internal cache (getTemporaryDirectory). External cache
      // (/storage/emulated/0/...) triggers MANAGE_EXTERNAL_STORAGE permission
      // in open_filex, which the app doesn't have. Internal cache
      // (/data/user/0/.../cache/) is covered by <cache-path> in open_filex's
      // FileProvider and creates a proper content:// URI for receiving apps.
      final Directory dir;
      if (Platform.isIOS) {
        dir = await getApplicationSupportDirectory();
      } else {
        dir = await getTemporaryDirectory();
      }

      final String filePath = '${dir.path}/$fileName';
      debugPrint('ATTACHMENT: downloading to $filePath');

      // Always delete any leftover file before downloading. Reusing a cached
      // file risks serving a stale or partial file from a previous crashed session.
      final file = File(filePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      Dio dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 5),
        followRedirects: true,
        maxRedirects: 5,
      ));
      debugPrint('ATTACHMENT: starting Dio download');
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && (received % (1024 * 1024) < 65536 || received == total)) {
            debugPrint('ATTACHMENT: progress ${(received / total * 100).toStringAsFixed(0)}% ($received/$total)');
          }
        },
      );
      debugPrint('ATTACHMENT: download status=${response.statusCode}');

      if (await file.exists()) {
        final size = await file.length();
        debugPrint('ATTACHMENT: file exists, size=$size bytes');
        return filePath;
      }

      debugPrint('ATTACHMENT: file does not exist after download');
      return null;
    } catch (e) {
      debugPrint('ATTACHMENT: download error=$e');
      return null;
    }
  }

  /// Download all attachments sequentially.
  // Future<void> _downloadAllAttachments() async {
  //   if (emailData == null || emailData!.data.email.attachments.isEmpty) return;
  //   for (final attachment in emailData!.data.email.attachments) {
  //     if (!mounted) break;
  //     await _downloadFile(context, attachment);
  //   }
  // }

  /// Download all attachments as a zip file.

  Future<void> _downloadAllAttachments() async {
    if (emailData == null || emailData!.data.email.attachments.isEmpty) return;

    if (isDownloading) return; // Prevent multiple simultaneous downloads
    isDownloading = true;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: LoaderIndicator(),
          );
        },
      );

      // Prepare file keys from attachments
      List<String> fileKeys = emailData!.data.email.attachments
          .map((attachment) => attachment.path ?? '')
          .where((path) => path.isNotEmpty)
          .toList();

      if (fileKeys.isEmpty) {
        context.pop();
        CommonService.animatedToast(
          'No valid attachments to download',
          'error',
        );
        return;
      }

      // Call the zip API
      const String attachmentZipUrl = 'email/attachments-zip-url';
      Map<String, dynamic> zipData = await ApiService().post(attachmentZipUrl, {
        "emailId": widget.emailId,
        "fileKeys": fileKeys,
        "zipName": "attachments.zip",
      });

      if (zipData['success'] == true && zipData['data'] != null) {
        String signedUrl = zipData['data']['signedUrl'];

        if (kIsWeb) {
          // Open in external browser for web
          // CheckOutImp().webWindowOpenPrint(
          //   signedUrl,
          //   'new tab',
          // );
          CheckOutImp().downloadWebFileWithPicker(
            signedUrl,
            suggestedName: attachmentsZip,
          );
        } else {
          // For mobile, download the zip file
          await saveFileToDownloads(signedUrl, attachmentsZip);
        }
      } else {
        CommonService.animatedToast(
          zipData['message'] ?? 'Failed to create zip',
          'error',
        );
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    } finally {
      isDownloading = false;
      if (mounted) {
        context.pop();
      }
    }
  }

  /// Preview all attachments sequentially (opens each in the platform handler).

  /// Returns an icon widget for the attachment based on file type/extension.
  /// Falls back to the existing generic doc icon with an extension overlay.
  Widget _buildAttachmentIcon(Attachments attachment) {
    String ext = (attachment.type ?? '').toLowerCase();
    if (ext.isEmpty) {
      final path = (attachment.path ?? '').toLowerCase();
      final dot = path.lastIndexOf('.');
      if (dot != -1 && dot + 1 < path.length) {
        ext = path.substring(dot + 1);
      }
    }

    // Slightly larger icon for >= 1 MB
    final int fileBytes = (attachment.size is int) ? attachment.size as int : 0;
    final bool isLarge = fileBytes >= 1024 * 1024; // >= 1 MB
    final double iconW = isLarge ? 28 : 24;
    final double iconH = isLarge ? 32 : 28;

    String? asset;
    switch (ext) {
      case 'pdf':
        asset = svgpdf;
        break;
      case 'txt':
        asset = 'assets/svg/txt_logo.svg';
        break;
      case 'doc':
      case 'docx':
        asset = 'assets/svg/Word_Logo.svg';
        break;
      case 'xls':
      case 'xlsx':
        asset = 'assets/svg/Excel_Logo.svg';
        break;
      case 'ppt':
      case 'pptx':
        asset = 'assets/svg/Powerpoint_Logo.svg';
        break;
      case 'jpg':
      case 'jpeg':
        asset = 'assets/svg/jpeg_logo.svg';
        break;
      case 'png':
        asset = 'assets/svg/png_logo.svg';
        break;
      case 'gif':
      case 'bmp':
      case 'webp':
        asset = svgimage;
        break;
      default:
        asset = null;
    }

    if (asset != null) {
      return SvgPicture.asset(asset, width: iconW, height: iconH);
    }

    // Fallback: generic doc with extension overlay
    return Stack(
      children: [
        SvgPicture.asset(svgdoc, width: iconW, height: iconH),
        Positioned(
          top: 16,
          left: 0,
          right: 1.5,
          child: Center(
            child: Text(
              (ext.isNotEmpty ? ext : (attachment.type ?? '')).toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                color: context.colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a [Widget] for displaying the sender's full name. The [Widget] shows
  /// the sender's name and email address. The email address is displayed in a
  /// [Text] widget and is clickable. When the email address is clicked, the
  /// [openClipboard] function is called with the sender's email address as the

  Widget getSenderfullName(
    String firstName,
    String senderEmail,
    String nameType,
  ) {
    String name = firstName.isEmpty
        ? senderEmail.toString().split('@').first
        : firstName;
    return nameType == "name"
        ? Text(
            CommonService().capitalize(name),
            style: AppTypography.messageHeaderValue(context),
          )
        : Wrap(
            children: [
              Text(
                CommonService().capitalize(name),
                style: AppTypography.messageHeaderValue(context),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTapUp: (details) {
                  openClipboard(
                    senderEmail,
                    tapPosition: details.globalPosition,
                  );
                },
                child: Text(
                  CommonService().capitalize("($senderEmail)"),
                  style: AppTypography.messageHeaderMeta(context).copyWith(color: context.appColors.linkBlue),
                ),
              ),
            ],
          );
  }

  Widget formatEmailText(Receivers item, int? length, int key) {
    final emailStyle = AppTypography.messageHeaderMeta(context).copyWith(color: context.appColors.linkBlue);
    return Wrap(
      children: [
        item.forwardEmail != null
            ? Wrap(
                children: [
                  GestureDetector(
                    onTapUp: (details) {
                      openClipboard(
                        item.receiverEmail,
                        tapPosition: details.globalPosition,
                      );
                    },
                    child: Text(
                      "(${item.receiverEmail})",
                      style: emailStyle,
                    ),
                  ),
                  Text(
                    ' forwarded via ',
                    style: AppTypography.messageHeaderMeta(context),
                  ),
                  GestureDetector(
                    onTapUp: (details) {
                      openClipboard(
                        item.forwardEmail ?? '',
                        tapPosition: details.globalPosition,
                      );
                    },
                    child: Text(
                      "(${item.forwardEmail})",
                      style: emailStyle,
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTapUp: (details) {
                  openClipboard(
                    item.receiverEmail,
                    tapPosition: details.globalPosition,
                  );
                },
                child: Text(
                  "(${item.receiverEmail})",
                  style: emailStyle,
                ),
              ),
        if (length != null && length > key)
          Text(', ', style: AppTypography.messageHeaderValue(context)),
      ],
    );
  }

  /// Returns a widget that displays the name of a receiver in an email.
  ///
  /// If the receiver's first name is not empty, it is capitalized and used as the
  /// name. Otherwise, the first part of the receiver's email address is used.
  ///
  /// The name is always followed by a comma unless it is the last receiver in
  /// the contacts_riverpod and the expanded view is not enabled.

  Widget formatEmailNameText(Receivers item, int? length, int key) {
    String receiverName = item.receiver.firstName?.isNotEmpty == true
        ? CommonService().capitalize(item.receiver.firstName!)
        : CommonService().capitalize(
            item.receiverEmail.toString().split('@').first,
          );
    return Wrap(
      children: [
        Text(
          receiverName,
          style: AppTypography.messageHeaderValue(context),
        ),
        if (length! - 1 > key && !_expandedView)
          Text(', ', style: AppTypography.messageHeaderValue(context)),
      ],
    );
  }

  /// Navigates to the reply screen for a given email id and type.
  Future<void> gotoReply(int id, String type) async {
    int pageId = DateTime.now().microsecondsSinceEpoch;
    final DateTime now = DateTime.now();
    final Duration offset = now.timeZoneOffset;

    final int offsetInMinutes = offset.inMinutes;
    final result = await context.push(
      AppRoutes.compose,
      extra: {
        'type': type,
        'url':
            '${defaultBaseUrl}email/compose?emailId=${widget.emailId}&type=$type&pageId=$pageId&timeZone=$offsetInMinutes',
        'token': Descope.sessionManager.session?.sessionJwt ?? token,
        'emailId': id,
        'pageId': pageId,
        'sourcePage': _getSourcePagePath(),
      },
    );

    printLog(
      "gotoReplyUrl",
      '${defaultBaseUrl}email/compose?emailId=${widget.emailId}&type=$type&pageId=$pageId&timeZone=$offsetInMinutes',
    );

    // If email was sent, pop back with the result so the list can refresh

    if (result == 'emailSent' && mounted) {
      setState(() => _canPopNow = true);
      context.pop();
    }
  }

  /// Returns the route path for the source page based on emailType
  String _getSourcePagePath() {
    switch (widget.emailType.toLowerCase()) {
      case 'sent':
        return AppRoutes.sent;
      case 'archive':
        return AppRoutes.archive;
      case 'trash':
        return AppRoutes.trash;
      case 'drafts':
      case 'draft':
        return AppRoutes.drafts;
      default:
        return AppRoutes.inbox;
    }
  }

  Future<void> gotoCompose() async {
    int pageId = DateTime.now().microsecondsSinceEpoch;
    final DateTime now = DateTime.now();
    final Duration offset = now.timeZoneOffset;

    final int offsetInMinutes = offset.inMinutes;
    final result = await context.push(
      AppRoutes.compose,
      extra: {
        'url':
            '${defaultBaseUrl}email/compose?pageId=$pageId&timeZone=$offsetInMinutes',
        'token': Descope.sessionManager.session?.sessionJwt ?? token,
        'pageId': pageId,
        'type': 'compose',
        'sourcePage': _getSourcePagePath(),
      },
    );

    // If email was sent, pop back with the result so the list can refresh
    if (result == 'emailSent' && mounted) {
      // context.pop('emailSent');
      setState(() => _canPopNow = true);
      context.pop();
    }
  }

  /// Gets the email detail with given emailId and updates the UI accordingly.
  ///
  /// If the email is a new email, a dialog will be shown to ask the user if they want to add the sender to their contacts.
  /// If the email is not a new email, the UI will be updated with the fetched email data.
  ///
  /// If there is an error during the API call, an error toast will be shown.
  ///
  /// If the API call is successful and the response is valid, the UI will be updated with the fetched email data.
  Future<void> getEmailViewDetail() async {
    setState(() {
      _isLoading = true;
    });
    printLog("[ViewEmail] Fetching details for ID", widget.emailId);
    printLog("[ViewEmail] Email type", widget.emailType);
    try {
      // PH-06: Check LRU cache before hitting the network.
      Map<String, dynamic> resp;
      final cached = AppCache().getEmailDetail(widget.emailId);
      if (cached != null) {
        resp = cached;
        printLog("[ViewEmail] Cache hit for ID", widget.emailId);
      } else {
        resp = await ApiService().post('email/detail', {
          "emailId": widget.emailId,
        });
        // Cache successful responses
        if (resp['success'] == true) {
          AppCache().putEmailDetail(widget.emailId, resp);
        }
      }
      printLog("[ViewEmail] API response success", resp['success']);

      final parsedEmailData = ViewEmailModel.fromJson(resp);
      if (!mounted) return;
      if (parsedEmailData.success) {
        widget.onErrorCleared?.call(); // PC-01: clear any prior error
        setState(() {
          emailData = parsedEmailData;
          // Now you can safely access emailData
          emails = emailData!.data.email;
          categorizedData = {};
          final receivers = emailData!.data.email.receivers;
          for (var item in receivers) {
            String? type = item.type;
            if (!categorizedData.containsKey(type)) {
              categorizedData[type] = [];
            }
            categorizedData[type]!.add(item);
          }

          // Fallback: if emailTags is empty, derive from receiver's
          // emailRecipientTags (archive/trash detail API may not populate
          // the top-level emailTags field).
          _syncEmailTagsFromRecipients();

          _isLoading = false;
        });
        if (widget.emailType == 'newEmailInbox' ||
            widget.emailType == 'newEmailCommunity') {
          if (widget.emailType == 'newEmailCommunity') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddEmailModal(
                  title: addEmail,
                  type: "longPress",
                  subtitleFirst: emails.senderEmail,
                  subtitle: addEmailcontact,
                  contact: null,
                  saveFlag: () async {
                    // Update logic here if needed after saving
                  },
                );
              },
            );
          }
        }
      } else {
        if (!mounted) return;
        final errorMsg = emailData?.message ?? 'Failed to load email';
        setState(() {
          _isLoading = false;
        });
        widget.onError?.call(errorMsg); // PC-01: report to reading pane
        CommonService.animatedToast(errorMsg, 'error');
      }
    } catch (error) {
      debugPrint('Error fetching email details: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      widget.onError?.call('Failed to load email'); // PC-01: report to reading pane
      // RC-3: If logout is already in progress (session expired, biometric
      // timeout, etc.), suppress this generic toast. SessionExpiryManager has
      // already shown "Session expired. Please log in again." and navigation
      // to /login is underway — a second toast here produces the double-toast
      // symptom reported by users.
      if (SessionRefreshMutex.isLoggedOut) return;
      if (error is! NoInternetException) {
        CommonService.animatedToast('Error loading details', 'error');
      }
    }
    if (kIsWeb && userData != null && userData!['user']?['id'] != null) {
      SocketService().emitEventWithAck(
        'unReadCount',
        {"userId": userData!['user']['id']},
        ackCallback: (data) {
          if (data != null) {
            ref
                .read(countProvider.notifier)
                .updateCounts(
                  inbox: data['inboxCount'] ?? 0,
                  draft: data['draftCount'] ?? 0,
                  trash: data['trashCount'] ?? 0,
                  archive: data['archiveCount'] ?? 0,
                );
          }
        },
      );
    }
  }

  /// If [emailData.data.email.emailTags] is empty, populates it from the first
  /// receiver's [emailRecipientTags]. The archive/trash/sent detail API may not
  /// return the top-level emailTags field.
  void _syncEmailTagsFromRecipients() {
    if (emailData == null) return;
    final email = emailData!.data.email;
    if (email.emailTags.isNotEmpty) return;
    for (final r in email.receivers) {
      if (r.emailRecipientTags != null && r.emailRecipientTags!.isNotEmpty) {
        email.emailTags.addAll(
          r.emailRecipientTags!.map(
            (ert) => EmailTags(
              id: ert.tag.id,
              userId: ert.tag.userId,
              tag: ert.tag.tag,
              isSuspended: ert.tag.isSuspended,
              isDeleted: ert.tag.isDeleted,
              created: ert.tag.created,
              updated: ert.tag.updated,
            ),
          ),
        );
        break; // use first receiver with tags
      }
    }
  }

  /// Adds or deletes a tag for the specified email based on its current existence.
  ///
  /// This function checks if the tag with the given `tagId` already exists for
  /// the email. If it exists, the function will remove it; otherwise, it will
  /// add the tag. The operation type ('add' or 'delete') is determined by the
  /// current existence of the tag.
  Future<void> addAndDeleteEmailTags(int tagId, String type) async {
    bool tagExist = emailData!.data.email.emailTags.any(
      (element) => element.id == tagId,
    );
    type = tagExist ? 'delete' : 'add';
    debugPrint(
      '[ViewEmail] addAndDeleteEmailTags - tagId: $tagId, type: $type',
    );
    try {
      Map<String, dynamic> resp = await ApiService().post('email/emails-tags', {
        "emailIds": [widget.emailId], //isRead/isSpam/isDeleted/isArchive
        "tagsId": [tagId],
        "type": type,
      });
      if (resp['success']) {
        // PH-06: Invalidate cached detail since tags changed.
        AppCache().invalidateEmailDetail(widget.emailId);
        if (!mounted) return;
        setState(() {
          debugPrint(
            '[ViewEmail] Full API response email data: ${resp['data']['email']}',
          );
          debugPrint(
            '[ViewEmail] emailRecipientTags: ${resp['data']['email']['emailRecipientTags']}',
          );
          debugPrint(
            '[ViewEmail] emailTags: ${resp['data']['email']['emailTags']}',
          );
          var tagsJson =
              resp['data']['email']['emailRecipientTags'] as List<dynamic>;
          debugPrint('[ViewEmail] API response tagsJson: $tagsJson');
          debugPrint('[ViewEmail] widget.emailType: ${widget.emailType}');
          if (widget.emailType == 'Inbox') {
            updatedTags = tagsJson
                .map(
                  (tagJson) => inbo.EmailRecipientTags.fromJson(
                    tagJson as Map<String, dynamic>,
                  ),
                )
                .toList();
            debugPrint('[ViewEmail] Updated updatedTags: $updatedTags');
          } else {
            sentUpdatedTags = tagsJson
                .map(
                  (tagJson) =>
                      sent.EmailTag.fromJson(tagJson as Map<String, dynamic>),
                )
                .toList();
            debugPrint('[ViewEmail] Updated sentUpdatedTags: $sentUpdatedTags');
          }
          isTagsUpdated = true;
          debugPrint('[ViewEmail] isTagsUpdated set to: $isTagsUpdated');

          // PM-03: Always derive emailTags from the reliable
          // emailRecipientTags response (the top-level emailTags field
          // is empty/incomplete for archive/trash/sent emails).
          final recipientTagsJson =
              resp['data']['email']['emailRecipientTags'] as List<dynamic>?;
          if (recipientTagsJson != null && recipientTagsJson.isNotEmpty) {
            emailData!.data.email.emailTags
              ..clear()
              ..addAll(
                recipientTagsJson.map((rt) {
                  final tagJson =
                      (rt as Map<String, dynamic>)['tag'] as Map<String, dynamic>;
                  return EmailTags(
                    id: tagJson['id'],
                    userId: tagJson['userId'],
                    tag: tagJson['tag'],
                    isSuspended: tagJson['isSuspended'] ?? false,
                    isDeleted: tagJson['isDeleted'] ?? false,
                    created: tagJson['created'] ?? '',
                    updated: tagJson['updated'] ?? '',
                  );
                }),
              );
          } else if (type == 'delete') {
            // Fallback for delete if emailRecipientTags not in response
            emailData!.data.email.emailTags.removeWhere(
              (element) => element.id == tagId,
            );
          }
        });

        // Notify reading pane parent so the message list updates its tag chips.
        if (widget.hideAppBar && widget.onAction != null) {
          widget.onAction!({
            'type': 'tagsUpdated',
            'emailId': widget.emailId,
            'tagType': type,
            'tagId': tagId,
            'updatedTags': widget.emailType == 'Inbox'
                ? updatedTags
                : sentUpdatedTags,
          });
        }
      } else {
        context.pop();
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (error) {
      debugPrint('[ViewEmail] addAndDeleteEmailTags error: $error');
      context.pop();
    }
  }

  /// Reads the user data from secure storage and updates the state.
  ///
  /// This method is typically called when the widget is first created or when the
  /// user data needs to be refreshed.
  ///
  /// The [userData] variable is updated with the new data and the widget is
  /// rebuilt with the new data.
  ///
  /// The user token is also updated.
  Future<void> getUserData() async {
    userData = (await secureStorageService.readObjectData(
      'userData',
    ))!; // Await the Future
    setState(() {
      token = userData!['token'];
    });
  }

  /// Update the status of an email based on the provided type.
  Future<void> updateEmailStatus(String type) async {
    bool value = false;
    String key = type;
    if (type == "isArchive") {
      value = !emails.isArchive;
    } else if (type == "isTrash") {
      if (widget.emailType == 'Trash') {
        key = 'isDeleted';
        value = true;
      } else {
        value = !emails.isTrash;
      }
    } else if (type == "isDeleted") {
      value = true;
    } else if (type == "isRead") {
      value = false;
    } else if (type == 'isInbox') {
      if (widget.emailType == 'Trash') {
        value = false;
        key = 'isTrash';
      } else if (widget.emailType == 'Archive') {
        value = false;
        key = 'isArchive';
      }
    } else if (type == 'isSent') {
      if (widget.emailType == 'Trash') {
        value = false;
        key = 'isTrash';
      } else if (widget.emailType == 'Archive') {
        value = false;
        key = 'isArchive';
      }
    }

    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/update-email-status',
        {
          "key": key, //isRead/isSpam/isDeleted/isArchive
          "emailIds": [widget.emailId],
          "value": value,
        },
      );
      if (resp['success']) {
        redirection(type);
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      // Status update API call may fail
    }

    if (kIsWeb) {
      SocketService().emitEventWithAck(
        'unReadCount',
        {"userId": userData!['user']['id']},
        ackCallback: (data) {
          if (data != null) {
            if (kIsWeb) {
              ref
                  .read(countProvider.notifier)
                  .updateCounts(
                    inbox: data['inboxCount'] ?? 0,
                    draft: data['draftCount'] ?? 0,
                    trash: data['trashCount'] ?? 0,
                    archive: data['archiveCount'] ?? 0,
                  );
            }
          }
        },
      );
    }
  }

  /// Redirects the user to the respective screen after performing an action.
  Future<void> redirection(String type) async {
    // Determine if we should return with undo action
    bool shouldUndo =
        _movedToArchive || _movedToTrash || _movedToInbox || _movedToSent;
    String actionType = type;

    if (_movedToArchive) {
      actionType = 'isArchive';
    } else if (_movedToTrash) {
      actionType = 'isTrash';
    } else if (_movedToInbox) {
      actionType = 'isInbox';
    } else if (_movedToSent) {
      actionType = 'isSent';
    }

    final tagToReturn = widget.emailType == 'Inbox'
        ? updatedTags
        : sentUpdatedTags;

    debugPrint('=== [ViewEmail] redirection CALLED ===');
    debugPrint('[ViewEmail] type: $type, actionType: $actionType');
    debugPrint('[ViewEmail] widget.emailType: ${widget.emailType}');
    debugPrint('[ViewEmail] isTagsUpdated: $isTagsUpdated');
    debugPrint('[ViewEmail] updatedTags: $updatedTags');
    debugPrint('[ViewEmail] sentUpdatedTags: $sentUpdatedTags');
    debugPrint('[ViewEmail] tagToReturn: $tagToReturn');
    debugPrint('[ViewEmail] tagToReturn type: ${tagToReturn.runtimeType}');

    final actionData = {
      'type': actionType,
      'undo': shouldUndo, // True if moved to archive/trash
      'value': type == "isArchive"
          ? !emails.isArchive
          : type == "isTrash"
          ? !emails.isTrash
          : type == "isDeleted"
          ? true
          : false,
      'tag': tagToReturn,
      'isTagsUpdated': isTagsUpdated,
      'markedAsUnread': _markedAsUnread, // Include the flag
      'emailId': widget.emailId,
    };

    // In reading pane mode (hideAppBar=true), use the callback instead of context.pop()
    // This allows the parent (reading pane) to handle the action and update the list
    if (widget.hideAppBar && widget.onAction != null) {
      widget.onAction!(actionData);
      return;
    }

    if (mounted) {
      setState(() {
        _canPopNow = true;
      });
      context.pop(actionData);
    }
  }

  /// Shows a bottom sheet with clipboard options when an email is long pressed.
  /// For mobile app: shows bottom action sheet
  /// For web: shows dialog (for large screens, positions near tap position)
  void openClipboard(String email, {Offset? tapPosition}) async {
    // Check if mobile app (not web)
    const isMobileApp = !kIsWeb;

    if (isMobileApp) {
      // Show bottom action sheet for mobile app
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        backgroundColor: const Color.fromARGB(20, 0, 0, 0),
        builder: (BuildContext buildContext) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 25),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
              ),
              child: Wrap(
                children: <Widget>[
                  PointerInterceptor(
                    intercepting: kIsWeb || Platform.isAndroid ? true : false,
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Center(
                        child: Text('Copy', style: AppTypography.actionSheetCancel(context)),
                      ),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: email));
                        Navigator.of(buildContext).pop();
                        CommonService.animatedToast(
                          'Successfully copied',
                          'success',
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  PointerInterceptor(
                    intercepting: kIsWeb || Platform.isAndroid ? true : false,
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Center(
                        child: Text(
                          'Compose',
                          style: AppTypography.actionSheetCancel(context),
                        ),
                      ),
                      onTap: () async {
                        Navigator.of(buildContext).pop();
                        int pageId = DateTime.now().microsecondsSinceEpoch;
                        final DateTime now = DateTime.now();
                        final Duration offset = now.timeZoneOffset;
                        final int offsetInMinutes = offset.inMinutes;
                        final result = await context.push(
                          AppRoutes.compose,
                          extra: {
                            'url':
                                '${defaultBaseUrl}email/compose?pageId=$pageId&toEmail=$email&timeZone=$offsetInMinutes',
                            'token': Descope.sessionManager.session?.sessionJwt ?? token,
                            'type': 'contact',
                            'email': email,
                            'pageId': pageId,
                            'sourcePage': _getSourcePagePath(),
                          },
                        );

                        // If email was sent, pop back with the result so the list can refresh
                        if (result == 'emailSent' && mounted) {
                          context.pop('emailSent');
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  PointerInterceptor(
                    intercepting: kIsWeb || Platform.isAndroid ? true : false,
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Center(
                        child: Text(
                          optIn,
                          style: AppTypography.actionSheetCancel(context),
                        ),
                      ),
                      onTap: () {
                        CommonService().gotoAddRecipient(
                          email,
                          context: buildContext,
                          senderDisplayName: _displayNameForEmail(email),
                        );
                        Navigator.of(buildContext).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: PointerInterceptor(
                      intercepting: kIsWeb || Platform.isAndroid ? true : false,
                      child: ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        title: Center(
                          child: Text(
                            'Cancel',
                            style: AppTypography.actionSheetCancel(context),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(buildContext).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    } else {}

    // Web: Show dialog (existing behavior)
    final isLargeScreen = kIsWeb && !AppBreakpoints.isMobileLayout(context);
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.3),
      builder: (dialogContext) {
        Widget buildOption(
          Widget leading,
          String label,
          Future<void> Function() onTap,
        ) {
          return InkWell(
            onTap: () async {
              await onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge(context).copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final dialogContent = Material(
          color: Colors.transparent,
          child: Container(
            width: 260,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildOption(
                  Icon(
                    Icons.copy_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  'Copy',
                  () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    dialogContext.pop();
                    CommonService.animatedToast(
                      'Successfully copied',
                      'success',
                    );
                  },
                ),
                const Divider(),
                buildOption(
                  Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  'Compose',
                  () async {
                    dialogContext.pop();
                    int pageId = DateTime.now().microsecondsSinceEpoch;
                    final DateTime now = DateTime.now();
                    final Duration offset = now.timeZoneOffset;
                    final int offsetInMinutes = offset.inMinutes;

                    final result = await context.push(
                      AppRoutes.compose,
                      extra: {
                        'url':
                            '${defaultBaseUrl}email/compose?pageId=$pageId&toEmail=$email&timeZone=$offsetInMinutes',
                            'token': Descope.sessionManager.session?.sessionJwt ?? token,
                        'type': 'contact',
                        'email': email,
                        'pageId': pageId,
                        'sourcePage': _getSourcePagePath(),
                      },
                    );

                    // If email was sent, pop back with the result so the list can refresh
                    if (result == 'emailSent' && mounted) {
                      context.pop('emailSent');
                    }
                  },
                ),
                const Divider(),
                buildOption(
                  SvgPicture.asset(
                    svgOptin,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      context.appColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                  optIn,
                  () async {
                    dialogContext.pop();
                    CommonService().gotoAddRecipient(
                      email,
                      context: context,
                      senderDisplayName: _displayNameForEmail(email),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        // For large screens with tap position, show dialog near cursor
        if (isLargeScreen && tapPosition != null) {
          // Calculate position ensuring dialog stays within screen bounds
          const dialogWidth = 260.0;
          const dialogHeight = 180.0; // Approximate height

          double left = tapPosition.dx;
          double top = tapPosition.dy;

          // Adjust if dialog would go off screen
          if (left + dialogWidth > screenSize.width) {
            left = screenSize.width - dialogWidth - 16;
          }
          if (top + dialogHeight > screenSize.height) {
            top = screenSize.height - dialogHeight - 16;
          }

          return Stack(
            children: [Positioned(left: left, top: top, child: dialogContent)],
          );
        }

        // For mobile or when no tap position, center the dialog
        return Center(child: dialogContent);
      },
    );
  }

  /// Show a modal sheet with three options for opt-in:
  /// 1. Create a new contact with the given email
  /// 2. Add the given email to an existing contact
  /// 3. Cancel the operation.
  void optInMenu(String email, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: const Color.fromARGB(20, 0, 0, 0),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 25),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppStyles.radiusM)),
            child: Wrap(
              children: <Widget>[
                PointerInterceptor(
                  intercepting: kIsWeb || Platform.isAndroid ? true : false,
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: Center(
                      child: Text(
                        'Create New',
                        style: AppTypography.actionSheetCancel(context),
                      ),
                    ),
                    onTap: () {
                      context.pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddEmailModal(
                            title: addEmail,
                            subtitleFirst: email,
                            subtitle: addEmailcontact,
                            contact: null,
                            senderDisplayName: _displayNameForEmail(email),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                PointerInterceptor(
                  intercepting: kIsWeb || Platform.isAndroid ? true : false,
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: Center(
                      child: Text(
                        'Add to Existing',
                        style: AppTypography.actionSheetCancel(context),
                      ),
                    ),
                    onTap: () {
                      context.pop();
                      context.push(
                        AppRoutes.addExistingContact,
                        extra: {'prevEmail': email, 'type': 'optin'},
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: PointerInterceptor(
                    intercepting: kIsWeb || Platform.isAndroid ? true : false,
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Center(
                        child: Text(
                          'Cancel',
                          style: AppTypography.actionSheetCancel(context),
                        ),
                      ),
                      onTap: () {
                        context.pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays a custom popup modal to inform the user that the email already exists
  /// in their contacts. The modal includes a title, subtitle, and two buttons:
  /// "Cancel" and "Ok". Both buttons close the modal when pressed.

  void commRecConfirmModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopupModal(
          onPressedButton1: () {
            context.pop();
          },
          onPressedButton2: () {
            context.pop();
          },
          textButton1: 'Cancel',
          textButton2: 'Ok',
          icon: null,
          title: communityRecommendation,
          subtitle: 'This Email Already Exist in your Contacts',
        );
      },
    );
  }

  /// Shows a modal sheet with a delete and cancel button. The modal sheet
  /// is used when the user wants to delete an email. The user can either
  /// delete the email permanently or cancel the deletion.
  void onCancel(
    BuildContext context,
    int index,
    String status,
    String action,
    String? page,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: const Color.fromARGB(20, 0, 0, 0),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 25),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppStyles.radiusM)),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  tileColor: Theme.of(context).colorScheme.surface,
                  title: Center(
                    child: Text(
                      "Permanently Delete",
                      style: AppTypography.actionSheetDelete(context),
                    ),
                  ),
                  onTap: () {
                    context.pop();
                    if (page == 'undo') {
                      context.pop({
                        'undo': true,
                        'type': 'isTrash',
                        'emailId': widget.emailId,
                      });
                    } else {
                      changeEmailStatus(context, index, status, action, true);
                    }
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: Center(
                      child: Text("Cancel", style: AppTypography.actionSheetCancel(context)),
                    ),
                    onTap: () {
                      context.pop();
                      changeEmailStatus(context, index, status, action, false);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Changes the status of an email based on the provided parameters.
  ///
  /// This function handles the logic for changing the email status, such as
  /// marking it as trash or archiving it. It optionally shows a popup for
  /// confirmation. If the status is "isTrash" and the email type is "Trash",
  /// a cancel action is triggered unless `popup` is provided. An undo action
  /// is available to revert the status within a short time frame.
  void changeEmailStatus(
    BuildContext context,
    int index,
    String status,
    String action, [
    bool? popup,
  ]) async {
    bool deletePop = false;
    ref.read(globalVariableProvider.notifier).updateGlobalEmailNavigation('1');
    if (status == "isTrash" && widget.emailType == "Trash" && popup == null) {
      deletePop = false;
      onCancel(context, index, status, action, '');
    } else {
      deletePop = true;
    }

    if (deletePop && (popup == null || popup == true)) {
      bool undoStatus = false;
      if (!mounted) return;
      // Define the undo action
      void undoAction() {
        if (!mounted) return;
        setState(() {
          undoStatus = true;
        });
        ref.read(globalVariableProvider.notifier).clearGlobalEmailNavigation();
      }

      // Show the toast and handle undo action
      if (mounted) {
        CommonService.animatedToast(
          CommonService().undoStatus(
            status.replaceAll('is', ''),
            (widget.emailType == "Trash" && status == 'isTrash') ? true : false,
          ),
          undo,
          undoAction,
        );
      }
      setState(() {
        _showMenuOptions = false;
      });

      // Delay for 3 seconds before updating the email status
      _statusUpdateTimer?.cancel();
      _statusUpdateTimer = Timer(const Duration(seconds: 3), () {
        if (!undoStatus && mounted) {
          updateEmailStatus(status);
          setState(() {
            _showMenuOptions = false;
          });
        }
      });
    }
  }

  /// Builds horizontal attachment display with +X files functionality - Added By Shubham on 10_01_2025
  /// Modified to fix single attachment positioning and remove horizontal scrolling - Added By Assistant on 13_01_2025
  Widget _buildHorizontalAttachments() {
    final attachments = emailData!.data.email.attachments;
    // const maxInitialDisplay = 3; // Show 3 files initially
    final maxInitialDisplay = AppBreakpoints.isMobileLayout(context)
        ? 2
        : 3; // 2 on mobile, 3 otherwise
    final shouldShowExpandButton =
        attachments.length > maxInitialDisplay && !_showAllAttachments;
    final filesToShow = _showAllAttachments
        ? attachments
        : attachments.take(maxInitialDisplay).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap file cards instead of horizontal scrolling
        if (attachments.length == 1)
          // Single attachment: align to start (left)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildHorizontalAttachmentCard(filesToShow.first),
          )
        else
          // Multiple attachments: use wrap layout
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // File cards
              ...filesToShow.map(
                (attachment) => _buildHorizontalAttachmentCard(attachment),
              ),
              // +X files button
              if (shouldShowExpandButton)
                _buildExpandFilesButton(attachments.length - maxInitialDisplay),
              // Show Less button when all attachments are displayed
              if (_showAllAttachments && attachments.length > maxInitialDisplay)
                _buildShowLessButton(),
            ],
          ),
        // Download All and Preview All buttons
        if (attachments.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    await _downloadAllAttachments();
                  },
                  child: Text(
                    'Download All',
                    style: TextStyle(
                      color: context.appColors.linkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                //   child: Text('•', style: TextStyle(color: Colors.grey)),
                // ),
                // InkWell(
                //   onTap: () async {
                //     await _previewAllAttachments();
                //   },
                //   child: const Text(
                //     'Preview All',
                //     style: TextStyle(
                //       color: AppStyles.primaryColor,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds individual horizontal attachment card - Added By Shubham on 10_01_2025
  /// Modified to make entire card clickable for preview - Added By Assistant on 13_01_2025
  Widget _buildHorizontalAttachmentCard(Attachments attachment) {
    printLog('Attachment', 'Attachment=$attachment');
    printLog('Attachment', 'Attachment=${attachment.path}');
    printLog('Attachment1', 'Attachment=${attachment.size}');
    printLog('Attachment', attachment.toJson().toString());
    return Container(
      width: 220, // Compact width for attachment cards
      margin: const EdgeInsets.only(right: 12.0, top: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        color: context.colors.outlineVariant,
      ),
      child: PointerInterceptor(
        intercepting: kIsWeb || Platform.isAndroid ? true : false,
        child: InkWell(
          onTap: () {
            if (kIsWeb && !_isWebPreviewable(attachment)) {
              CommonService.animatedToast(
                'Open not available for this file type. Download to open.',
                'info',
              );
              return;
            }
            _openAttachmentInNativeApp(attachment, 0);
          },
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10.0,
            ),
            child: Row(
              children: [
                // File icon on the left
                _buildAttachmentIcon(attachment),
                const SizedBox(width: 8),
                // File name and size in the middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // File name
                      Text(
                        CommonService()
                            .getFileName(attachment.path ?? "")
                            .toString(),
                        style: AppTypography.attachmentMeta(context).copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      // File size
                      Text(
                        CommonService().formatFileSize(attachment.size ?? 0),
                        style: AppTypography.attachmentSize(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Download button on the right — 44px tap target for touch
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _downloadFile(context, attachment),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      svgDownload,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandFilesButton(int remainingCount) {
    return Container(
      margin: const EdgeInsets.only(right: 12.0, top: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _showAllAttachments = true;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$remainingCount more',
              style: AppTypography.titleSmall(context).copyWith(
                color: context.appColors.linkBlue,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              svgDownArrow,
              width: 10,
              height: 10,
              colorFilter: ColorFilter.mode(
                context.appColors.linkBlue,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Show Less button - Added By Assistant on 13_01_2025
  Widget _buildShowLessButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12.0, top: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _showAllAttachments = false;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Show Less',
              style: AppTypography.titleSmall(context).copyWith(
                color: context.appColors.linkBlue,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              svgDownArrow,
              width: 10,
              height: 10,
              colorFilter: ColorFilter.mode(
                context.appColors.linkBlue,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
