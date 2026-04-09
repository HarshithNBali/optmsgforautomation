import 'dart:async';
import 'dart:convert';
import 'package:descope/descope.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/repositories/email/archive_api.dart';
import 'package:optmsg/repositories/email/inbox_api.dart';
import 'package:optmsg/repositories/tags/tag_api.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:optmsg/model/sent_list_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/common/utilites/secure_print_helper.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import '../../../constant/app_config.dart';
import '../../../constant/string_constant.dart';
import '../../../main.dart';
import '../../../model/tags_list_model.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/count_notifier.dart';
import '../../../services/global_variable_notifier.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/tags_provider.dart';
import '../../../widgets/add_email_modal.dart';
import '../../../widgets/pop_up_modal.dart';
import '../../../widgets/pop_up_modal_tag_list.dart';
import 'archive_state.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../auth/auth_riverpod/auth_notifier.dart';
import '../../settings/setting_riverpod/settings_notifier.dart';

const String _failedToMoveEmail = 'Failed to move email';

final archiveProvider = NotifierProvider<ArchiveNotifier, ArchiveState>(
  ArchiveNotifier.new,
);

class ArchiveNotifier extends Notifier<ArchiveState> {
  bool _disposed = false;
  // DI: read from providers on demand rather than late fields,
  // so fake notifiers in tests don't crash on uninitialized fields.
  ArchiveApi get _archiveApi => ref.read(archiveApiProvider);
  ApiService get _apiService => ref.read(apiServiceProvider);
  InboxApi get _inboxApi => ref.read(inboxApiProvider);
  TagApi get _tagApi => ref.read(tagApiProvider);

  @override
  ArchiveState build() {
    // C-05: Recreate controllers on each build() so they're fresh after invalidation
    focusNode = FocusNode();
    searchController = TextEditingController();
    _disposed = false;
    // Reset mutable session fields so a rebuild after logout/re-login starts clean
    userData = null;
    userId = null;
    token = '';

    ref.onDispose(() {
      _disposed = true;
      debounce?.cancel();
      undoTimer?.cancel();
      trashMessageSub?.cancel();
      notificationSub?.cancel();
      tagsSub?.cancel();
      searchController.dispose();
      focusNode.dispose();
    });

    // Sync: when global tag list changes (e.g., tag deleted via socket or
    // another client), purge any per-email tags that no longer exist.
    ref.listen<TagsState>(tagsProvider, (previous, next) {
      if (next.tagsList == null) return;
      final validTagIds = next.tagsList!.data.tags.map((t) => t.id).toSet();
      final currentItems = state.items;
      bool anyChanged = false;

      final updated = currentItems.map((email) {
        final tags = email.emailTag;
        if (tags == null || tags.isEmpty) return email;
        final filtered =
            tags.where((t) => validTagIds.contains(t.tagId)).toList();
        if (filtered.length != tags.length) {
          anyChanged = true;
          return email.copyWith(emailTag: filtered);
        }
        return email;
      }).toList();

      if (anyChanged) {
        state = state.copyWith(items: updated);
      }
    });

    Future.microtask(init);
    return const ArchiveState(isLoading: true);
  }

  // services — injected via providers for testability
  SecureStorageService get secureStorageService => ref.read(storageServiceProvider);

  // controllers/timers
  late FocusNode focusNode;
  late TextEditingController searchController;
  Timer? debounce;
  Timer? undoTimer;

  // sockets
  StreamSubscription? trashMessageSub;
  StreamSubscription? notificationSub;
  StreamSubscription? tagsSub;

  // user/session
  Map<String, dynamic>? userData;
  int? userId;
  String token = "";

  // constants
  final String archivePath = AppRoutes.archive;
  final String sentPath = AppRoutes.sent;
  final String trashPath = AppRoutes.trash;

  // undo helpers

  // ---------------------------
  // INIT
  // ---------------------------
  Future<void> init() async {
    await _getUserData();
    await _setupListeners();
  }

  Future<void> _getUserData() async {
    // Try storage first; fall back to in-memory AuthState if a background
    // clearAllData() wiped storage before this read (race between logout
    // cleanup and a fast re-login).
    final data = ref.read(authProvider).userData;

    // Read reading pane from settings provider (updated synchronously by
    // toggleReadingPane) to avoid racing with the async storage write.
    // Fall back to storage on cold boot when settings hasn't loaded yet.
    final sState = ref.read(settingsProvider);
    final bool readingPaneEnabled;
    if (sState.hasUserData) {
      readingPaneEnabled = sState.readingPaneEnabled;
    } else {
      final readingPaneValue = await secureStorageService.readData(
        'readingPaneEnabled',
      );
      readingPaneEnabled = readingPaneValue == null
          ? true
          : readingPaneValue == 'true';
    }

    if (data != null) {
      userData = data;
      userId = data['user']?['id'];
      token = data['token'] ?? '';
      if (_disposed) return;
      state = state.copyWith(
        // Enable reading pane for web and native tablets (tablets will show it in landscape)
        readingPaneEnabled:
            readingPaneEnabled && (kIsWeb || AppBreakpoints.isPhysicalTablet),
      );
    }
  }

  Future<void> resolveInitialRouteAndLoad(
    String? parentRoute, {
    int? emailIdToRestore,
  }) async {
    final globalState = ref.read(globalVariableProvider);
    final tagProvider = ref.read(tagsProvider);
    if (!globalState.pathList.contains(trashApi)) {
      // Re-read reading pane setting: prefer settings provider (avoids storage race)
      final sState2 = ref.read(settingsProvider);
      final bool readingPaneEnabled;
      if (sState2.hasUserData) {
        readingPaneEnabled = sState2.readingPaneEnabled;
      } else {
        final readingPaneValue = await secureStorageService.readData(
          'readingPaneEnabled',
        );
        readingPaneEnabled = readingPaneValue == null
            ? true
            : readingPaneValue == 'true';
      }
      if (_disposed) return;

      String? currentPath;

      currentPath = parentRoute;
      String? emailType;
      if (currentPath == archivePath) {
        emailType = "archive";
      } else if (currentPath == sentPath) {
        emailType = "sent";
      } else if (currentPath == trashPath) {
        emailType = "trash";
      } else {
        emailType = "archive";
      }

      state = state.copyWith(
        currentPage: 1,
        previousPage: 0,
        currentPath: currentPath,
        emailType: emailType,
        longPressFlag: true,
        selectedEmailIdForReadingPane: emailIdToRestore, // Restore if provided
        selectedEmailSender: null,
        selectedEmailIndex: null,
        selectedEmailTags: null,
        showReadingPaneMenuOptions: false,
        // Reset checkbox state when navigating between folders
        showCheckboxes: false,
        selectedEmailIds: [],
        selectedEmails: [],
        allEmailIdsFlag: false,
        // Clear items to prevent flickering when switching folders
        items: [],
        inboxList: null, // Clear model to prevent stale checks in UI
        // Mark as loading immediately so the empty-state widget never flashes
        // while the async chain (_manageComposeFlag → getAllEmails) runs.
        isLoading: true,
        // Re-sync reading pane state from storage (web and native tablets)
        readingPaneEnabled:
            readingPaneEnabled && (kIsWeb || AppBreakpoints.isPhysicalTablet),
      );

      await _manageComposeFlag();
      await getAllEmails("");

      if (tagProvider.tagsList == null ||
          tagProvider.tagsList!.data.tags.isEmpty) {
        await getAllTags();
      }
    }
  }

  void tagsOnclick() {
    final tagProvider = ref.read(tagsProvider);

    if (tagProvider.tagsList != null &&
        tagProvider.tagsList!.data.tags.isNotEmpty) {
      state = state.copyWith(showFilter: false, showTagList: true);
    } else {
      CommonService.animatedToast("No Tags Found", 'warning', null, true);
    }
  }

  void setShowCheckboxes(bool show) {
    state = state.copyWith(showCheckboxes: show);
  }

  void setEmailListPaneWidth(double width) {
    state = state.copyWith(emailListPaneWidth: width);
  }

  void updateReadingPaneSettings(bool enabled) {
    if (!enabled) {
      // Clear selection when turning reading pane OFF
      state = state.copyWith(
        readingPaneEnabled: false,
        selectedEmailIdForReadingPane: null,
        selectedEmailSender: null,
        selectedEmailIndex: null,
        selectedEmailTags: null,
      );
    } else {
      state = state.copyWith(readingPaneEnabled: true);
    }
  }

  Future<void> _manageComposeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('inCompose', false);
  }

  // ---------------------------
  // SOCKETS
  // ---------------------------
  Future<void> _setupListeners() async {
    if (userId == null) return;

    // unread count
    SocketService().emitEventWithAck(
      'unReadCount',
      {"userId": userId},
      ackCallback: (data) {
        if (data != null) {
          _updateBadgeFromSocket(data);
        }
      },
    );

    // notificationExists initial
    SocketService().emitEventWithAck(
      'notificationExists',
      {"userId": userId},
      ackCallback: (data) {
        if (data != null) {
          final hasNotification = data != 'no' && data != false;
          state = state.copyWith(newNotification: hasNotification);
          // Sync with centralized countProvider
          ref
              .read(countProvider.notifier)
              .updateNotificationStatus(data.toString());
        }
      },
    );

    // trashMessage listener
    trashMessageSub = SocketService().onEvent('trashMessage').listen((
      newMessage,
    ) async {
      if (state.currentPath == trashPath) {
        String? communityEmail = state.communityEmail;
        int selectedIndex = state.selectedIndex;

        if (newMessage['communityStatus'] == true) {
          communityEmail = newMessage['id'].toString();
          selectedIndex = 0;
        }

        final newData = jsonEncode(newMessage);
        final newEmail = Emails.fromJson(jsonDecode(newData));

        final updatedItems = [newEmail, ...state.items];
        state = state.copyWith(
          items: updatedItems,
          communityEmail: communityEmail,
          selectedIndex: selectedIndex,
        );
      }
    });

    // notificationExists stream
    notificationSub = SocketService().onEvent('notificationExists').listen((
      data,
    ) {
      final hasNotification = data != null && data != 'no' && data != false;
      state = state.copyWith(newNotification: hasNotification);
      // Sync with centralized countProvider
      ref
          .read(countProvider.notifier)
          .updateNotificationStatus(data.toString());
    });

    // tags contacts_riverpod socket
    tagsSub = SocketService().onEvent('tagList').listen((data) {
      if (data != null) {
        try {
          if (data is List) {
            final wrappedData = {
              'success': true,
              'data': {'tags': data},
              'message': 'Tags received from socket',
            };
            final tagsListModel = TagsListModel.fromJson(wrappedData);
            ref.read(tagsProvider.notifier).setTagsList(tagsListModel);
          }
        } catch (e) {
          debugPrint('Archive: Failed to parse tags socket data: $e');
        }
      }
    });

    if (state.currentPath == trashPath) {
      final communityEmail =
          await secureStorageService.readData(
            'newEmailCommunityNotification',
          ) ??
          '';
      state = state.copyWith(communityEmail: communityEmail);
    }
  }

  void setupNotificationListener() {
    notificationSub?.cancel();
    notificationSub = SocketService().onEvent('notificationExists').listen((
      data,
    ) {
      final hasNotification = data != null && data != 'no' && data != false;
      state = state.copyWith(newNotification: hasNotification);
      // Sync with centralized countProvider
      ref
          .read(countProvider.notifier)
          .updateNotificationStatus(data.toString());
    });
  }

  void updateNotificationFlag(bool flag) {
    state = state.copyWith(newNotification: flag);
    // Sync with centralized countProvider
    ref
        .read(countProvider.notifier)
        .updateNotificationStatus(flag ? 'yes' : 'no');
  }

  /// H-01: Only update native badge count. countProvider is updated centrally
  /// by SocketService._updateCountNotifier() — no duplicate needed.
  /// Bug 17: Removed unconditional refresh() — it caused scroll position loss
  /// when returning from message detail. All callers already update local
  /// state directly; pull-to-refresh handles manual reload.
  void _updateBadgeFromSocket(dynamic data) async {
    if (!kIsWeb && await AppBadgePlus.isSupported()) {
      AppBadgePlus.updateBadge(data['badgeCount'] ?? 0).catchError((_) {});
    }
  }

  // ---------------------------
  // REFRESH
  // ---------------------------
  Future<void> refresh() async {
    // Prevent multiple concurrent refreshes
    if (state.isFetching) return;

    // Reset pagination for refresh, show search bar on pull-down
    state = state.copyWith(isSearch: false, currentPage: 1, previousPage: 0);
    await getAllEmails(state.searchKey, isRefresh: true);
  }

  Future<void> getAllEmails(
    String searchTerm, {
    bool isRefresh = false,
    bool silent = false,
  }) async {
    final currentpath = state.currentPath;

    if (state.isFetching) return;

    state = state.copyWith(isFetching: true);

    // Only show loader if not silent and it's the first page and not a refresh
    if (state.currentPage == 1 && !isRefresh) {
      state = state.copyWith(isLoading: true);
    }

    try {
      Map<String, dynamic> reqData;

      if (currentpath == trashPath) {
        reqData = {
          "type": "trash",
          "page": state.currentPage,
          "limit": itemCount,
          "search": searchTerm,
        };
        if (state.emailType == 'unread') {
          reqData["isUnread"] = true;
        }
        if (state.emailType == 'community') {
          reqData["isCommunityStatus"] = true;
        }
      } else if (currentpath == archivePath) {
        reqData = {
          "type": "archive",
          "page": state.currentPage,
          "limit": itemCount,
          "search": searchTerm,
        };
        if (state.emailType == 'unread') {
          reqData["isUnread"] = true;
        }
      } else {
        // sent
        reqData = {
          "isTrash": false,
          "isArchive": false,
          "page": state.currentPage,
          "limit": itemCount,
          "search": searchTerm,
        };
      }

      if (state.tagIdFilter.isNotEmpty) {
        reqData["tagsId"] = state.tagIdFilter;
      }

      final resp = currentpath == sentPath
          ? await _archiveApi.getSentMails(reqData)
          : await _archiveApi.getTrash(reqData);
      if (_disposed) return;
      if (resp.data!['success'] != true) {
        CommonService.animatedToast(
          resp.data!['message'] ?? catchError,
          'error',
          null,
          true,
        );
        state = state.copyWith(isLoading: false, isFetching: false);
        return;
      }
      final inboxList = SentListModel.fromJson(resp.data!);
      if (!inboxList.success) {
        CommonService.animatedToast(inboxList.message, 'error', null, true);
        state = state.copyWith(isLoading: false, isFetching: false);
        return;
      }

      final List<Emails> newEmails = inboxList.data.emails;
      final bool hasNext = inboxList.data.nextPage == true;

      List<Emails> updatedItems;
      if (state.currentPage > 1 && state.currentPage != state.previousPage) {
        updatedItems = [...state.items, ...newEmails];
      } else {
        updatedItems = newEmails;
      }

      int selectedIndex = state.selectedIndex;
      String communityEmail = state.communityEmail;

      if (communityEmail.isNotEmpty && currentpath == trashPath) {
        await secureStorageService.deleteData('newEmailCommunityNotification');
        final parsedId = int.tryParse(communityEmail);
        if (parsedId != null) {
          selectedIndex = updatedItems.indexWhere(
            (item) => item.id == parsedId,
          );
        } else {
          selectedIndex = 0;
        }
      }

      state = state.copyWith(
        items: updatedItems,
        inboxList: inboxList,
        totalEmailCount: updatedItems.length,
        previousPage: state.currentPage,
        currentPage: hasNext ? state.currentPage + 1 : state.currentPage,
        isLoading: false,
        isFetching: false,
        allEmailIdsFlag: false,
        selectedEmailIds: [],
        selectedEmails: [],
        selectedIndex: selectedIndex,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, isFetching: false);
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  // ---------------------------
  // STATUS UPDATES
  // ---------------------------
  /// Silent version of updateInboxEmailStatus for iOS with filters applied
  /// Makes API call without loader and silently updates UI
  Future<void> updateInboxEmailStatusSilent(
    String type,
    List<int> ids,
    int index,
  ) async {
    final currentpath = state.currentPath;

    try {
      if (currentpath == trashPath) {
        // First, remove from trash
        final statusKey = type == "isTrash"
            ? "isDeleted"
            : (type == "isInbox" || type == "isSent")
            ? "isTrash"
            : type;
        final statusValue = (type == "isInbox" || type == "isSent")
            ? false
            : (type == 'isRead' ? true : true);

        final value = await _archiveApi.updateEmailStatus({
          "key": statusKey,
          "emailIds": ids,
          "value": statusValue,
        });

        if (value.data != null && value.data!['success']) {
          // If moving to Inbox or Sent, make second API call to set the target flag
          if (type == 'isInbox' || type == 'isSent') {
            await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
          }

          if (type == "isRead") {
            // Mark as read (value: true was sent in API call)
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, true);
            }
            state = state.copyWith(items: items);
          }
        }
      } else if (currentpath == archivePath) {
        // First, remove from archive
        final resp = await _apiService.post(updateEmailStatusApi, {
          "key": (type == 'isInbox' || type == 'isSent' || type == 'isTrash')
              ? 'isArchive'
              : type,
          "emailIds": ids,
          "value":
              (type == "isArchive" ||
                  type == 'isInbox' ||
                  type == 'isSent' ||
                  type == 'isTrash')
              ? false
              : (type == "isRead" ? true : true),
        });
        if (resp['success']) {
          // If moving to Inbox, Sent, or Trash, make second API call to set the target flag
          if (type == 'isInbox' || type == 'isSent' || type == 'isTrash') {
            await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
          }

          if (type == "isRead") {
            // Mark as read (value: true was sent in API call)
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, true);
            }
            state = state.copyWith(items: items);
          } else {
            // For other types, update read status to true (email was read)
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, true);
            }
            state = state.copyWith(items: items);
          }
        }
      } else if (currentpath == sentPath) {
        // For Sent, handle move to Inbox/Archive properly
        if (type == 'isInbox' || type == 'isArchive') {
          // First, remove from sent
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": "isSent",
            "emailIds": ids,
            "value": false,
          });
          if (resp['success']) {
            // Second, set the target flag
            await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });

            // Sent emails should stay read when moved to another folder
            await _apiService.post(updateEmailStatusApi, {
              "key": "isRead",
              "emailIds": ids,
              "value": true,
            });

            // Remove items from the list
            final items = [...state.items];
            items.removeWhere((item) {
              final emailId =
                  (item.receivers != null && item.receivers!.isNotEmpty)
                  ? item.receivers![0].emailId
                  : item.id;
              return ids.contains(emailId);
            });
            state = state.copyWith(items: items);

            // Update unread counts via socket
            if (userData != null && userData!['user'] != null) {
              SocketService().emitEventWithAck(
                'unReadCount',
                {'userId': userData!['user']['id']},
                ackCallback: (data) {
                  if (data != null) {
                    _updateBadgeFromSocket(data);
                  }
                },
              );
            }
          }
        } else {
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": type,
            "emailIds": ids,
            "value": type == "isSent" ? false : true,
          });
          if (resp['success']) {
            // Update read status if type is isRead
            if (type == "isRead") {
              // Mark as read (value: true was sent in API call)
              final items = [...state.items];
              for (final emailId in ids) {
                final idx = items.indexWhere((item) => item.id == emailId);
                _setItemReceiverIsRead(items, idx, true);
              }
              state = state.copyWith(items: items);
            } else if (type == "isTrash") {
              // Remove items from the list when moving to trash
              final items = [...state.items];
              items.removeWhere((item) {
                final emailId =
                    (item.receivers != null && item.receivers!.isNotEmpty)
                    ? item.receivers![0].emailId
                    : item.id;
                return ids.contains(emailId);
              });
              state = state.copyWith(items: items);

              // Sent emails should stay read when moved to trash
              await _apiService.post(updateEmailStatusApi, {
                "key": "isRead",
                "emailIds": ids,
                "value": true,
              });

              // Update unread counts via socket
              if (userData != null && userData!['user'] != null) {
                SocketService().emitEventWithAck(
                  'unReadCount',
                  {'userId': userData!['user']['id']},
                  ackCallback: (data) {
                    if (data != null) {
                      _updateBadgeFromSocket(data);
                    }
                  },
                );
              }
            }
          } else {
            // Silently handle error without toast for silent mode
          }
        }
      }
    } catch (error) {
      // Silently handle error without toast for silent mode
    } finally {
      // Clear selected emails after silent update
      if (!_disposed) {
        state = state.copyWith(selectedEmailIds: []);
      }
    }
  }

  Future<void> updateInboxEmailStatus(
    String type,
    List<int> ids,
    int index,
  ) async {
    final currentpath = state.currentPath;

    try {
      if (currentpath == trashPath) {
        // First, remove from trash
        final statusKey = type == "isTrash"
            ? "isDeleted"
            : (type == "isInbox" || type == "isSent")
            ? "isTrash"
            : type;
        final statusValue =
            (type == "isInbox" || type == "isSent" || type == 'isRead')
            ? false
            : true;

        final value = await _archiveApi.updateEmailStatus({
          "key": statusKey,
          "emailIds": ids,
          "value": statusValue,
        });

        if (value.data != null) {
          if (value.data!['success']) {
            // If moving to Inbox or Sent, make second API call to set the target flag
            if (type == 'isInbox' || type == 'isSent') {
              final targetResp = await _apiService.post(updateEmailStatusApi, {
                "key": type,
                "emailIds": ids,
                "value": true,
              });
              if (targetResp['success'] != true) {
                CommonService.animatedToast(
                  targetResp['message'] ?? _failedToMoveEmail,
                  'error',
                  null,
                  true,
                );
              }
            }

            if (type == "isRead") {
              final items = [...state.items];
              for (final emailId in ids) {
                final idx = items.indexWhere((item) => item.id == emailId);
                _setItemReceiverIsRead(items, idx, false);
              }
              state = state.copyWith(items: items);
            }
          } else {
            CommonService.animatedToast(
              value.data!['message'],
              'error',
              null,
              true,
            );
          }
        }
      } else if (currentpath == archivePath) {
        // First, remove from archive
        final statusKey =
            (type == 'isInbox' || type == 'isSent' || type == 'isTrash')
            ? 'isArchive'
            : type;
        final statusValue =
            (type == "isArchive" ||
                type == 'isInbox' ||
                type == 'isSent' ||
                type == 'isTrash' ||
                type == "isRead")
            ? false
            : true;

        final resp = await _apiService.post(updateEmailStatusApi, {
          "key": statusKey,
          "emailIds": ids,
          "value": statusValue,
        });
        if (resp['success']) {
          // If moving to Inbox, Sent, or Trash, make second API call to set the target flag
          if (type == 'isInbox' || type == 'isSent' || type == 'isTrash') {
            final targetResp = await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
            if (targetResp['success'] != true) {
              CommonService.animatedToast(
                targetResp['message'] ?? _failedToMoveEmail,
                'error',
                null,
                true,
              );
            }
          }

          if (type == "isRead") {
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, false);
            }
            state = state.copyWith(items: items);
          }
        } else {
          CommonService.animatedToast(resp['message'], 'error', null, true);
        }
      } else if (currentpath == sentPath) {
        // For Sent, handle move to Inbox/Archive properly
        if (type == 'isInbox' || type == 'isArchive') {
          // First, remove from sent
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": "isSent",
            "emailIds": ids,
            "value": false,
          });
          if (resp['success']) {
            // Second, set the target flag
            final targetResp = await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
            if (targetResp['success'] != true) {
              CommonService.animatedToast(
                targetResp['message'] ?? _failedToMoveEmail,
                'error',
                null,
                true,
              );
            }
            // Update unread count after moving from Sent to Archive/Inbox
            if (userData != null && userData!['user'] != null) {
              SocketService().emitEventWithAck(
                'unReadCount',
                {'userId': userData!['user']['id']},
                ackCallback: (data) {
                  if (data != null) {
                    _updateBadgeFromSocket(data);
                  }
                },
              );
            }
          } else {
            CommonService.animatedToast(resp['message'], 'error', null, true);
          }
        } else {
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": type,
            "emailIds": ids,
            "value": type == "isSent" ? false : true,
          });
          if (resp['success']) {
            // Update unread count after successful status change
            if (userData != null && userData!['user'] != null) {
              SocketService().emitEventWithAck(
                'unReadCount',
                {'userId': userData!['user']['id']},
                ackCallback: (data) {
                  if (data != null) {
                    _updateBadgeFromSocket(data);
                  }
                },
              );
            }
          } else {
            CommonService.animatedToast(resp['message'], 'error', null, true);
          }
        }
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    } finally {
      // H-04: Guard against writing state after the notifier is disposed.
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          isInProcess: false,
          isFetching: false,
        );
      }
    }
  }

  Future<void> updateEmailStatus(
    String type,
    List<int> ids,
    Function() onSuccess,
  ) async {
    final currentpath = state.currentPath;
    state = state.copyWith(isInProcess: true);

    try {
      if (currentpath == trashPath) {
        // First, remove from trash
        final statusKey = type == "isTrash"
            ? "isDeleted"
            : (type == "isInbox" || type == "isSent")
            ? "isTrash"
            : type;
        final statusValue =
            (type == "isInbox" || type == "isSent" || type == 'isRead')
            ? false
            : true;

        final value = await _archiveApi.updateEmailStatus({
          "key": statusKey,
          "emailIds": ids,
          "value": statusValue,
        });

        if (value.data != null && value.data!['success']) {
          // Second, set the target flag
          if (type == 'isInbox' || type == 'isSent') {
            final targetResp = await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
            if (targetResp['success'] != true) {
              CommonService.animatedToast(
                targetResp['message'] ?? _failedToMoveEmail,
                'error',
                null,
                true,
              );
            }
          }

          if (type == "isRead") {
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, true);
            }
            state = state.copyWith(items: items);
          }
          CommonService.animatedToast(
            value.data!['message'],
            'success',
            null,
            true,
          );

          onSuccess();
        } else if (value.data != null) {
          CommonService.animatedToast(
            value.data!['message'],
            'error',
            null,
            true,
          );
        }
      } else if (currentpath == archivePath) {
        // First, remove from archive
        final statusKey =
            (type == "isTrash" || type == "isInbox" || type == "isSent")
            ? "isArchive"
            : type;
        final statusValue =
            (type == "isInbox" ||
                type == "isSent" ||
                type == "isTrash" ||
                type == 'isRead')
            ? false
            : true;

        final value = await _archiveApi.updateEmailStatus({
          "key": statusKey,
          "emailIds": ids,
          "value": statusValue,
        });

        if (value.data != null && value.data!['success']) {
          // Second, set the target flag
          if (type == 'isInbox' || type == 'isSent' || type == 'isTrash') {
            final targetResp = await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
            if (targetResp['success'] != true) {
              CommonService.animatedToast(
                targetResp['message'] ?? _failedToMoveEmail,
                'error',
                null,
                true,
              );
            }
          }

          if (type == "isRead") {
            final items = [...state.items];
            for (final emailId in ids) {
              final idx = items.indexWhere((item) => item.id == emailId);
              _setItemReceiverIsRead(items, idx, true);
            }
            state = state.copyWith(items: items);
          }
          CommonService.animatedToast(
            value.data!['message'],
            'success',
            null,
            true,
          );

          onSuccess();
        } else if (value.data != null) {
          CommonService.animatedToast(
            value.data!['message'],
            'error',
            null,
            true,
          );
        }
      } else if (currentpath == sentPath) {
        // For Sent, handle move to Inbox/Archive properly
        if (type == 'isInbox' || type == 'isArchive') {
          // First, remove from sent
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": "isSent",
            "emailIds": ids,
            "value": false,
          });
          if (resp['success']) {
            // Second, set the target flag
            final targetResp = await _apiService.post(updateEmailStatusApi, {
              "key": type,
              "emailIds": ids,
              "value": true,
            });
            if (targetResp['success'] != true) {
              CommonService.animatedToast(
                targetResp['message'] ?? _failedToMoveEmail,
                'error',
                null,
                true,
              );
            }

            // Sent emails should stay read when moved to another folder
            await _apiService.post(updateEmailStatusApi, {
              "key": "isRead",
              "emailIds": ids,
              "value": true,
            });

            if (type == "isRead") {
              final items = [...state.items];
              for (final emailId in ids) {
                final idx = items.indexWhere((item) => item.id == emailId);
                _setItemReceiverIsRead(items, idx, true);
              }
              state = state.copyWith(items: items);
            }
            CommonService.animatedToast(resp['message'], 'success', null, true);

            onSuccess();
          } else {
            CommonService.animatedToast(resp['message'], 'error', null, true);
          }
        } else {
          final resp = await _apiService.post(updateEmailStatusApi, {
            "key": type,
            "emailIds": ids,
            "value": type == "isSent" ? false : true,
          });
          if (resp['success']) {
            // Sent emails should stay read when moved to trash
            if (type == "isTrash") {
              await _apiService.post(updateEmailStatusApi, {
                "key": "isRead",
                "emailIds": ids,
                "value": true,
              });
            }
            CommonService.animatedToast(resp['message'], 'success', null, true);
            onSuccess();
          } else {
            CommonService.animatedToast(resp['message'], 'error', null, true);
          }
        }
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    } finally {
      // H-04: Guard against writing state after the notifier is disposed.
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          isInProcess: false,
          isFetching: false,
        );
      }
    }
  }

  Future<void> updateSentEmailStatus(String type, List<int> ids) async {
    final currentpath = state.currentPath;
    try {
      final resp = await _apiService.post(updateEmailStatusApi, {
        "key": type,
        "emailIds": ids,
        "value": type == "isTrash"
            ? false
            : type == "isArchive"
            ? false
            : true,
      });
      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
      }
      if (type == "isDeleted" && currentpath == trashPath) {
        final ctx = NavigationService.navigatorKey.currentContext;
        if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
      }
    } catch (error) {
      if (type == "isDeleted" && currentpath == trashPath) {
        final ctx = NavigationService.navigatorKey.currentContext;
        if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
      }
    } finally {
      // setupNotificationListener() removed to prevent loops
    }
  }

  // ---------------------------
  // TAGS
  // ---------------------------
  Future<void> getAllTags() async {
    try {
      final resp = await _tagApi.getTagsList({"search": ""});
      final parsedTagsList = TagsListModel.fromJson(resp.data ?? {});
      if (parsedTagsList.success) {
        ref.read(tagsProvider.notifier).setTagsList(parsedTagsList);
      } else {
        CommonService.animatedToast(
          parsedTagsList.message,
          'error',
          null,
          true,
        );
      }
    } catch (error) {
      // Network errors: global snackbar handles notification
    }
  }

  Future<void> addEmailTags(
    List<int> tagIds,
    int emailId,
    int index,
    String type,
  ) async {
    if (_disposed) return;
    try {
      final response = await _inboxApi.getEmailTags({
        "emailIds": emailId == 0 ? state.selectedEmailIds : [emailId],
        "tagsId": tagIds,
        "type": type,
      });
      final resp = response.data!;
      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
        return;
      }

      if (emailId != 0) {
        final items = [...state.items];
        List<EmailTag> updatedTags;
        if (type == 'delete') {
          updatedTags = (items[index].emailTag ?? [])
              .where((element) => !tagIds.contains(element.tagId))
              .toList();
        } else {
          // Try to get tags from API response
          updatedTags = [];
          try {
            final email = resp['data']?['email'];
            if (email != null) {
              final tagsJson =
                  (email['emailTags'] != null &&
                      (email['emailTags'] as List).isNotEmpty)
                  ? email['emailTags']
                  : email['emailRecipientTags'] ?? [];

              updatedTags = (tagsJson as List<dynamic>)
                  .map(
                    (tagJson) =>
                        EmailTag.fromJson(tagJson as Map<String, dynamic>),
                  )
                  .toList();
            }
          } catch (_) {
            // If API response parsing fails, use fallback
          }

          // Fallback: build tags locally if API response didn't work
          if (updatedTags.isEmpty && tagIds.isNotEmpty) {
            final tagProvider = ref.read(tagsProvider);
            final tagsList = tagProvider.tagsList?.data.tags ?? [];
            final tagsToAdd = tagsList
                .where((tag) => tagIds.contains(tag.id))
                .toList();

            final existingTagIds =
                items[index].emailTag?.map((t) => t.tagId).toList() ?? [];

            final newTags = <EmailTag>[];
            for (final tag in tagsToAdd) {
              if (!existingTagIds.contains(tag.id)) {
                final emailTag = EmailTag.fromJson({
                  'id': 0,
                  'tagId': tag.id,
                  'emailId': emailId,
                  'tag': {'id': tag.id, 'tag': tag.tag},
                });
                newTags.add(emailTag);
              }
            }

            updatedTags = [...(items[index].emailTag ?? []), ...newTags];
          }
        }

        if (updatedTags.isNotEmpty || type == 'delete') {
          items[index] = items[index].copyWith(emailTag: updatedTags);
        }

        state = state.copyWith(
          items: items,
          readingPaneRefreshKey:
              (state.selectedEmailIdForReadingPane == emailId)
              ? state.readingPaneRefreshKey + 1
              : state.readingPaneRefreshKey,
        );
      }
    } catch (error) {
      // Network errors: global snackbar handles notification
    }
  }

  List<int> getExistingTagIdsForEmail(int emailId, int index) {
    final items = state.items;
    final emailIndex = items.indexWhere(
      (item) => item.receivers?.any((r) => r.emailId == emailId) ?? false,
    );

    if (emailIndex == -1) return [];

    final email = items[emailIndex];

    if (email.emailTag != null && email.emailTag!.isNotEmpty) {
      return email.emailTag!.map((t) => t.tagId).toList();
    }

    if (email.receivers != null &&
        email.receivers!.isNotEmpty &&
        email.receivers![index].emailRecipientTags != null) {
      final recipientTags = email.receivers![index].emailRecipientTags!;
      final ids = recipientTags
          .map((tagItem) {
            if (tagItem is Map<String, dynamic>) {
              return tagItem['tagId'] ?? (tagItem['tag']?['id'] ?? 0);
            } else {
              try {
                return tagItem.tagId ?? tagItem.tag?.id ?? 0;
              } catch (_) {
                return 0;
              }
            }
          })
          .where((id) => id != 0)
          .cast<int>()
          .toList();
      return ids;
    }

    return [];
  }

  void showList(int emailId, int itemIndex) {
    final tagProvider = ref.read(tagsProvider);
    List<int> tagsToUse = state.selectedTagIds;

    emailId = state.selectedEmailIds.isNotEmpty
        ? state.selectedEmailIds.last
        : emailId;
    if (emailId != 0) {
      tagsToUse = getExistingTagIdsForEmail(emailId, 0);
      state = state.copyWith(selectedTagIds: tagsToUse);
    }
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (ctx) {
        return PopUpModalTagList(
          loading: false,
          title: 'Tags',
          title2: 'Create',
          getTagsApi: getAllTags,
          showList: showList,
          initialSelectedTagIds: tagsToUse,
          itemList: tagProvider.tagsList?.data.tags ?? [],
          emailId: emailId,
          itemIndex: itemIndex,
          onTagDeleted: (tagId) async {
            if (emailId != 0) {
              await addEmailTags([tagId], emailId, itemIndex, 'delete');
            } else if (state.selectedEmailIds.isNotEmpty) {
              await addEmailTags([tagId], 0, 0, 'delete');
            }
          },
          onPressedButton2: () async {
            if (state.selectedTagIds.isEmpty &&
                state.selectedEmailIds.isEmpty &&
                emailId == 0) {
              CommonService.animatedToast(
                "Please select Email & Tag",
                'warning',
                null,
                true,
              );
              return;
            }
            if (state.selectedEmailIds.isEmpty && emailId == 0) {
              CommonService.animatedToast(
                "Please select Email",
                'warning',
                null,
                true,
              );
              return;
            }
            if (state.selectedTagIds.isEmpty) {
              CommonService.animatedToast(
                "Please select Tag",
                'warning',
                null,
                true,
              );
              return;
            }
            await addEmailTags(state.selectedTagIds, emailId, itemIndex, 'add');

            if (emailId != 0 &&
                state.selectedEmailIdForReadingPane == emailId) {
              // Reading pane email — addEmailTags already updated the list
              // surgically and bumped readingPaneRefreshKey. Just update
              // the available tags model for the tag overlay.
              final tagProvider = ref.read(tagsProvider);
              state = state.copyWith(selectedEmailTags: tagProvider.tagsList);
            } else {
              // Batch or non-reading-pane — full refresh needed.
              state = state.copyWith(currentPage: 1, previousPage: 0);
              onLongPress(null, null);
              await getAllEmails(state.searchKey);
            }
          },
          textButton1: 'Cancel',
          textButton2: 'Add',
          callback: (value) {
            state = state.copyWith(selectedTagIds: value);
          },
        );
      },
    );
  }

  // ---------------------------
  // NAVIGATION: COMPOSE / REPLY / DETAIL
  // ---------------------------
  Future<void> gotoCompose() async {
    if (userData?['user']?['isFreeUser'] == true) {
      CommonService.animatedToast(freeUserWarning, 'warning', null, true);
      return;
    }
    final pageId = DateTime.now().microsecondsSinceEpoch;
    final offset = DateTime.now().timeZoneOffset.inMinutes;
    final data = ref.read(authProvider).userData;

    if (data != null) {
      userData = data;
      userId = data['user']?['id'];
      token = data['token'] ?? '';
    }
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    await ctx.push(
      AppRoutes.compose,
      extra: {
        'url':
            '${defaultBaseUrl}email/compose?pageId=$pageId&timeZone=$offset',
        'token': Descope.sessionManager.session?.sessionJwt ?? token,
        'pageId': pageId,
        'type': 'compose',
        'sourcePage': state.currentPath,
      },
    );

    // Always refresh the list after returning from compose
    // This ensures the sent folder shows new emails
    await refresh();
  }

  Future<void> gotoReply(int emailId, String type) async {
    // Refresh user data from storage to ensure we have current status
    if (userData == null) {
      userData = ref.read(authProvider).userData;
      if (userData == null) {
        await _getUserData();
        userData = ref.read(authProvider).userData;
      }
    }
    if (userData?['user']?['isFreeUser'] == true) {
      CommonService.animatedToast(freeUserWarning, 'warning', null, true);
      return;
    }
    final pageId = DateTime.now().microsecondsSinceEpoch;
    final offset = DateTime.now().timeZoneOffset.inMinutes;
    final data2 = ref.read(authProvider).userData;

    if (data2 != null) {
      userData = data2;
      userId = data2['user']?['id'];
      token = data2['token'] ?? '';
    }
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    await ctx.push(
      AppRoutes.compose,
      extra: {
        'type': type,
        'url':
            '${defaultBaseUrl}email/compose?emailId=$emailId&type=$type&pageId=$pageId&timeZone=$offset',
        'token': Descope.sessionManager.session?.sessionJwt ?? token,
        'emailId': emailId,
        'pageId': pageId,
        'sourcePage': state.currentPath,
      },
    );

    // Always refresh the list after returning from compose
    // This ensures the sent folder shows new forwarded/replied emails
    await refresh();
  }

  String _determineEmailTypeForView() {
    if (state.currentPath == trashPath) return "Trash";
    if (state.currentPath == archivePath) return "Archive";
    if (state.currentPath == sentPath) return "Sent";
    return "Inbox";
  }

  Future<void> gotoViewDetail(int emailId, int index) async {
    final tagProvider = ref.read(tagsProvider);

    state = state.copyWith(selectedIndex: -1);

    // Store initial read status before navigating
    bool wasUnread = false;
    if (index >= 0 && index < state.items.length) {
      wasUnread = !(state.items[index].receivers?[0].isRead ?? false);
    }

    if (state.readingPaneEnabled &&
        (kIsWeb || AppBreakpoints.isPhysicalTablet)) {
      // Hide checkboxes when opening email in reading pane
      if (state.showCheckboxes) {
        setShowCheckboxes(false);
      }

      final items = [...state.items];

      final itemIndex = items.indexWhere(
        (item) => item.receivers?.any((r) => r.emailId == emailId) ?? false,
      );

      if (itemIndex != -1 &&
          items[itemIndex].receivers != null &&
          items[itemIndex].receivers!.isNotEmpty) {
        final receiverIndex = items[itemIndex].receivers!.indexWhere(
          (r) => r.emailId == emailId,
        );

        if (receiverIndex != -1 &&
            !(items[itemIndex].receivers![receiverIndex].isRead ?? false)) {
          final updatedReceivers = [...items[itemIndex].receivers!];
          updatedReceivers[receiverIndex] = updatedReceivers[receiverIndex]
              .copyWith(isRead: true);
          items[itemIndex] = items[itemIndex].copyWith(
            receivers: updatedReceivers,
          );
          state = state.copyWith(items: items);

          _apiService
              .post(updateEmailStatusApi, {
                "key": 'isRead',
                "emailIds": [emailId],
                "value": true,
              })
              .then((resp) {
                if (resp['success'] == true && userId != null) {
                  SocketService().emitEventWithAck(
                    'unReadCount',
                    {"userId": userId},
                    ackCallback: (data) {
                      if (data != null) {
                        _updateBadgeFromSocket(data);
                      }
                    },
                  );
                }
              })
              .catchError((_) {
                // revert optimistic update
                final revertedReceivers = [...items[itemIndex].receivers!];
                revertedReceivers[receiverIndex] =
                    revertedReceivers[receiverIndex].copyWith(isRead: false);
                final revertedItems = [...state.items];
                revertedItems[itemIndex] = revertedItems[itemIndex].copyWith(
                  receivers: revertedReceivers,
                );
                state = state.copyWith(items: revertedItems);
              });
        }
      }

      final emailItem = items.firstWhere(
        (item) => item.receivers?.any((r) => r.emailId == emailId) ?? false,
        orElse: () => items[index],
      );

      state = state.copyWith(
        selectedEmailIdForReadingPane: emailId,
        selectedEmailTags: tagProvider.tagsList,
        selectedEmailIndex: index,
        selectedEmailSender: emailItem.senderEmail,
        showReadingPaneMenuOptions: false,
        lastClickedIndex: index,
      );
      return;
    }

    // full-screen view
    //print('[ArchiveNotifier] Taking FULL-SCREEN navigation path');
    final emailTypeForView = _determineEmailTypeForView();
    // print('[ArchiveNotifier] emailTypeForView: $emailTypeForView');

    // Update state to highlight the email when returning, even if reading pane is off
    String? senderEmail;
    if (index >= 0 && index < state.items.length) {
      senderEmail = state.items[index].senderEmail;
    }
    state = state.copyWith(
      selectedEmailIdForReadingPane: emailId,
      selectedEmailIndex: index,
      selectedEmailSender: senderEmail,
      lastClickedIndex: index,
    );
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    final result = await ctx.push(
      AppRoutes.viewEmailPath(emailId.toString(), emailTypeForView),
      extra: {
        'emailId': emailId,
        'emailType': emailTypeForView,
        'allTagsList': tagProvider.tagsList,
      },
    );

    if (_disposed) return;
    focusNode.unfocus();

    // Keep the selection for highlighting but the action ribbon logic
    // is handled in the layout (only shows when reading pane is active)

    // If email was sent (from reply/forward), refresh the list
    if (result == 'emailSent') {
      await refresh();
      return;
    }

    // For Sent folder, always refresh after returning from view to catch forwarded emails
    // This handles cases where the pop result might not propagate correctly
    if (state.currentPath == sentPath) {
      await refresh();
    }

    // Check if iOS/iPad and filters are applied
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final hasFilters = state.emailType != null || state.tagIdFilter.isNotEmpty;

    // If result is null and email was unread, mark it as read silently (for iOS with filters)
    if (result == null &&
        wasUnread &&
        isIOS &&
        hasFilters &&
        index >= 0 &&
        index < state.items.length) {
      final currentEmailId = state.items[index].receivers?[0].emailId;
      if (currentEmailId != null) {
        // Update local state first
        final items = [...state.items];
        _setItemReceiverIsRead(items, index, true);
        state = state.copyWith(items: items);

        // Make silent API call
        updateInboxEmailStatusSilent('isRead', [currentEmailId], index);
      }
      return;
    }

    if (result == null || result is! Map) {
      printLog(
        'ArchiveNotifier',
        'Result is null or not a Map - returning early',
      );
      return;
    }

    final items = [...state.items];

    if (index >= 0 && index < items.length) {
      final type = result['type'];
      final isTagsUpdated = result['isTagsUpdated'] == true;
      final tag = result['tag'];

      if (type == 'isRead') {
        _setItemReceiverIsRead(items, index, false);
      }

      if (isTagsUpdated && tag != null) {
        printLog(
          'ArchiveNotifier',
          'Updating tags - before: ${items[index].emailTag}',
        );
        items[index] = items[index].copyWith(emailTag: tag);
        printLog(
          'ArchiveNotifier',
          'Updating tags - after: ${items[index].emailTag}',
        );
      }

      if (type != 'isRead' &&
          type != 'isArchive' &&
          type != 'isDeleted' &&
          type != 'isTrash') {
        _setItemReceiverIsRead(items, index, true);

        // If iOS with filters, make silent API call to mark as read
        final currentEmailId = items[index].receivers?[0].emailId;
        if (isIOS && hasFilters && currentEmailId != null) {
          updateInboxEmailStatusSilent('isRead', [currentEmailId], index);
        }
      }

      state = state.copyWith(items: items);
      // print('[ArchiveNotifier] State updated with new items');

      // Refresh list when tags are updated to get accurate tag data from server
      if (isTagsUpdated) {
        //print('[ArchiveNotifier] Tags were updated, refreshing list...');
        await refresh();
        return;
      }

      // Handle "Mark as Unread" flag
      if (result['markedAsUnread'] == true) {
        // The email was already marked as unread in items list (line 998), no need for further action
        return;
      }

      if (result['undo'] == true) {
        final ids = [...state.selectedEmailIds, result['emailId'] as int];
        state = state.copyWith(selectedEmailIds: ids);

        // Check if iOS/iPad and filters are applied
        final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
        final hasFilters =
            state.emailType != null || state.tagIdFilter.isNotEmpty;

        if (isIOS && hasFilters) {
          // Silent update for iOS with filters applied
          updateInboxEmailStatusSilent(type, [result['emailId'] as int], 0);
        } else {
          // Normal flow for other cases
          changeEmailStatus(type, null, 'detail');
        }
      }
    }
  }

  // ---------------------------
  // SELECTION
  // ---------------------------
  void onLongPress(int? id, String? email) {
    final currentlyLongPress = state.longPressFlag;

    if (currentlyLongPress) {
      state = state.copyWith(
        longPressFlag: !currentlyLongPress,
        allEmailIdsFlag: false,
        selectedEmailIds: id != null ? [id] : [],
        selectedEmails: email != null ? [email] : [],
        showMenuOptions: false,
      );
    } else {
      state = state.copyWith(
        longPressFlag: !currentlyLongPress,
        allEmailIdsFlag: false,
        selectedEmailIds: [],
        selectedEmails: [],
        showMenuOptions: false,
      );
    }
  }

  void addAndRemoveKey(int id, String email) {
    final ids = List<int>.from(state.selectedEmailIds);
    final emails = List<String>.from(state.selectedEmails);

    if (ids.contains(id)) {
      ids.remove(id);
      emails.remove(email);
    } else {
      ids.add(id);
      emails.add(email);
    }

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: state.totalEmailCount == ids.length,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  bool get _hasListSelectionActive => state.selectedEmailIds.isNotEmpty;

  bool get _hasReadingPaneSelectionActive =>
      state.selectedEmailIdForReadingPane != null;

  bool get _isReadingPaneSelectionOnly =>
      _hasReadingPaneSelectionActive && !_hasListSelectionActive;

  List<int> _currentActionEmailIds() {
    if (state.selectedEmailIds.isNotEmpty) {
      return List<int>.from(state.selectedEmailIds);
    }
    if (state.selectedEmailIdForReadingPane != null) {
      return [state.selectedEmailIdForReadingPane!];
    }
    return [];
  }

  List<String> _currentActionEmailSenders() {
    if (state.selectedEmails.isNotEmpty) {
      return List<String>.from(state.selectedEmails);
    }
    if (state.selectedEmailSender != null &&
        state.selectedEmailSender!.isNotEmpty) {
      return [state.selectedEmailSender!];
    }
    return [];
  }

  void _clearReadingPaneSelection() {
    state = state.copyWith(
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
      selectedEmailTags: null,
    );
  }

  /// Removes an email from the list without making an API call.
  /// Used when ViewEmail (in reading pane mode) has already made the API call
  /// and needs to update the local list state.
  /// Marks an email as unread in the local list by emailId.
  /// Used when ViewEmail returns with a markedAsUnread flag.
  void markEmailAsUnreadById(int emailId) {
    final items = [...state.items];
    bool found = false;

    for (int i = 0; i < items.length; i++) {
      if (items[i].receivers != null && items[i].receivers!.isNotEmpty) {
        final receiverIdx = items[i].receivers!.indexWhere(
          (r) => r.emailId == emailId,
        );
        if (receiverIdx != -1) {
          final updatedReceivers = [...items[i].receivers!];
          updatedReceivers[receiverIdx] =
              updatedReceivers[receiverIdx].copyWith(isRead: false);
          items[i] = items[i].copyWith(receivers: updatedReceivers);
          found = true;
        }
      }
      if (found) break;
    }

    if (found) {
      state = state.copyWith(items: items);
    }
  }

  void updateEmailTagsInList(int emailId, List<EmailTag> tags) {
    final items = [...state.items];
    final idx = items.indexWhere(
      (item) =>
          item.receivers != null &&
          item.receivers!.isNotEmpty &&
          item.receivers![0].emailId == emailId,
    );
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(emailTag: tags);
    state = state.copyWith(items: items);
  }

  void removeEmailFromListById(int emailId) {
    final items = [...state.items];
    items.removeWhere(
      (item) =>
          item.receivers != null &&
          item.receivers!.isNotEmpty &&
          item.receivers![0].emailId == emailId,
    );

    // Check if the currently viewed email is being removed
    final bool isReadingPaneItemRemoved =
        state.selectedEmailIdForReadingPane == emailId;

    state = state.copyWith(
      items: items,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      longPressFlag: true,
      selectedEmailIdForReadingPane: isReadingPaneItemRemoved
          ? null
          : state.selectedEmailIdForReadingPane,
      selectedEmailSender: isReadingPaneItemRemoved
          ? null
          : state.selectedEmailSender,
      selectedEmailIndex: isReadingPaneItemRemoved
          ? null
          : state.selectedEmailIndex,
    );
  }

  // ---------------------------
  // BULK ACTIONS (delete / move / mark)
  // ---------------------------
  Future<void> _updateReadingPaneEmailStatus(String statusKey) async {
    if (state.selectedEmailIdForReadingPane == null ||
        state.selectedEmailIndex == null) {
      return;
    }

    final emailId = state.selectedEmailIdForReadingPane!;
    final items = [...state.items];
    // items.removeWhere((item) => item.receivers?[0].emailId == emailId);
    items.removeWhere(
      (item) =>
          item.receivers != null &&
          item.receivers!.isNotEmpty &&
          item.receivers![0].emailId == emailId,
    );

    state = state.copyWith(items: items, showReadingPaneMenuOptions: false);
    _clearReadingPaneSelection();

    await updateInboxEmailStatus(statusKey, [emailId], 0);
  }

  Future<void> _deleteReadingPaneEmailPermanently() async {
    if (state.selectedEmailIdForReadingPane == null) return;
    final emailId = state.selectedEmailIdForReadingPane!;

    // Don't remove email from list before confirmation - keep it visible until user confirms deletion
    // Show the delete modal first
    await deleteEmailModal([emailId]);

    // After deletion is confirmed and completed, clear reading pane selection
    if (!state.items.any(
      (item) => item.receivers?.any((r) => r.emailId == emailId) ?? false,
    )) {
      _clearReadingPaneSelection();
    }
  }

  Future<void> changeEmailStatus(
    String status, [
    bool? popup,
    String page = '',
  ]) async {
    final removedItems = <Emails>[];
    final removedItemIndices = <int, int>{};

    // ----- Read other providers via ref -----
    // Update navigation status
    ref.read(globalVariableProvider.notifier).updateGlobalEmailNavigation('1');

    // ----- Optimistic local update -----
    final currentItems = List<Emails>.from(state.items);

    final selectedIds = List<int>.from(state.selectedEmailIds);

    await updateEmailStatus(status, selectedIds, () async {
      if (userData != null && userData!['user'] != null) {
        onLongPress(null, null);

        SocketService().emitEventWithAck(
          'unReadCount',
          {'userId': userData!['user']['id']},
          ackCallback: (data) {
            if (data != null) {
              printLog("unReadCount", data);
              _updateBadgeFromSocket(data);
            }
          },
        );
      }
      for (int i = currentItems.length - 1; i >= 0; i--) {
        final item = currentItems[i];
        // For archive/sent/trash emails, use receivers[0].emailId to match selectedIds
        final int? itemEmailId =
            (item.receivers != null && item.receivers!.isNotEmpty)
            ? item.receivers![0].emailId
            : item.id;
        if (itemEmailId != null && selectedIds.contains(itemEmailId)) {
          removedItemIndices[itemEmailId] = i;
          removedItems.add(item);
          currentItems.removeAt(i);
        }
      }

      // H-04: Guard against writing state after the notifier is disposed.
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          isInProcess: false,
          items: currentItems,
        );
      }
    });

    /*

    // ----- Popup / Undo flow -----
    if (popup == null || popup == true) {
      bool undoStatus = false;

      // Increment request counter
      final currentRequest = ++_requestCounter;

      // ----- Undo action handler -----
      void undoAction() {
        updateNotifier.clearGlobalEmailNavigation();

        final restoredItems = List<Emails>.from(state.items);

        for (final item in removedItems) {
          // Use receivers[0].emailId for archive/sent/trash emails
          final int? itemEmailId =
              (item.receivers != null && item.receivers!.isNotEmpty)
                  ? item.receivers![0].emailId
                  : item.id;
          final index = removedItemIndices[itemEmailId];
          if (index != null && index <= restoredItems.length) {
            restoredItems.insert(index, item);
          }
        }

        undoStatus = true;
        removedItems.clear();
        removedItemIndices.clear();

        state = state.copyWith(
          items: restoredItems,
          selectedEmailIds: page == 'detail' ? [] : state.selectedEmailIds,
          isInProcess: false,
        );

        countNotifier.dynamicList.clear();
      }

      // Close existing toasts before showing Undo toast
      CommonService.dismissToast();

      CommonService.animatedToast(
        CommonService().undoStatus(
          status.replaceAll('is', ''),
          status == 'isTrash',
        ),
        undo,
        undoAction,
        true,
      );

      // ----- Toggle menu (except detail page) -----
      if (page != 'detail') {
        state = state.copyWith(
          showMenuOptions: !state.showMenuOptions,
        );
      }

      // Sync selected ids into count notifier
      countNotifier.dynamicList
        ..clear()
        ..addAll(selectedIds);

      if (page != 'detail') {
        onLongPress(null, null);
      }

      if (_requestCounter == currentRequest && !undoStatus) {
        await updateInboxEmailStatus(
          status,
          List<int>.from(countNotifier.dynamicList),
          0,
        );


        removeSelectedItem(selectedIds);
      }
    }

    // Reset isInProcess flag after operation completes
    state = state.copyWith(isInProcess: false);*/
  }

  void handleBulkOptInAction() {
    if (state.currentPath == sentPath) return;

    final senders = _currentActionEmailSenders();
    if (senders.isEmpty) return;

    final uniqueEmails = senders.toSet().toList();
    final names = <String, String?>{};
    for (final email in uniqueEmails) {
      final item = state.items.cast<Emails?>().firstWhere(
        (e) => e?.senderEmail == email,
        orElse: () => null,
      );
      final raw = item?.senderName?.trim();
      names[email] = (raw != null && raw.isNotEmpty) ? raw : null;
    }
    displayAddEmailModal(uniqueEmails, 0, senderNames: names);
  }

  Future<void> handleReplyAction(String type) async {
    final emailId = state.selectedEmailIdForReadingPane;
    if (emailId == null) return;

    await gotoReply(emailId, type);
  }

  // ---------------------------
  // MOVE DESTINATION PICKER
  // ---------------------------

  void handleMoveAction() {
    state = state.copyWith(
      showMenuOptions: false,
      showReadingPaneMenuOptions: false,
      showTagList: false,
      showMoveOverlay: true,
    );
  }

  void dismissMoveOverlay() {
    state = state.copyWith(showMoveOverlay: false);
  }

  void handleMoveToSystemFolder(String statusKey) {
    dismissMoveOverlay();

    if (_hasListSelectionActive) {
      changeEmailStatus(statusKey);
    } else if (_isReadingPaneSelectionOnly) {
      updateReadingPaneEmailStatus(statusKey);
    }
  }

  Future<void> handleMoveToTag(int tagId) async {
    dismissMoveOverlay();

    final ids = _currentActionEmailIds();
    if (ids.isEmpty) return;

    // Step 1: Tag the email(s)
    final emailId = ids.length == 1 ? ids.first : 0;
    await addEmailTags([tagId], emailId, 0, 'add');

    // Step 2: Archive (only if not already in archive)
    if (state.currentPath != archivePath) {
      if (_hasListSelectionActive) {
        changeEmailStatus('isArchive');
      } else if (_isReadingPaneSelectionOnly) {
        updateReadingPaneEmailStatus('isArchive');
      }
    }
  }

  void handleBulkArchiveAction() {
    if (state.currentPath != sentPath && state.currentPath != trashPath) return;

    if (_hasListSelectionActive) {
      changeEmailStatus('isArchive');
    } else if (_isReadingPaneSelectionOnly) {
      updateReadingPaneEmailStatus('isArchive');
    }
  }

  void handleBulkMoveToSentAction() {
    if (state.currentPath == sentPath) return;

    final targetIds = _currentActionEmailIds();
    if (targetIds.isEmpty) return;

    if (_hasListSelectionActive) {
      changeEmailStatus("isSent");
    } else if (_isReadingPaneSelectionOnly) {
      updateReadingPaneEmailStatus("isSent");
    }
  }

  void handleBulkMoveToInboxAction() {
    final targetIds = _currentActionEmailIds();
    if (targetIds.isEmpty) return;

    if (_hasListSelectionActive) {
      changeEmailStatus("isInbox");
    } else if (_isReadingPaneSelectionOnly) {
      updateReadingPaneEmailStatus('isInbox');
    }
  }

  void handleSingleEmailMoveToInbox(int emailId, int index) {
    // Check if this is a draft item in trash — restore to Drafts instead
    final item = index < state.items.length ? state.items[index] : null;
    if (state.currentPath == trashPath && item?.isDraft == true) {
      _restoreDraftFromTrash(emailId);
      return;
    }

    final updatedItems = List<Emails>.from(state.items)
      // ..removeWhere((item) => item.receivers?[0].emailId == emailId);
      ..removeWhere(
        (item) =>
            item.receivers != null &&
            item.receivers!.isNotEmpty &&
            item.receivers![0].emailId == emailId,
      );

    state = state.copyWith(items: updatedItems);

    if (state.selectedEmailIdForReadingPane == emailId) {
      _clearReadingPaneSelection();
    }

    updateInboxEmailStatus("isInbox", [emailId], index);
  }

  void handleSingleEmailArchive(int emailId, int index) {
    if (state.currentPath != sentPath && state.currentPath != trashPath) return;

    final updatedItems = List<Emails>.from(state.items)
      // ..removeWhere((item) => item.receivers?[0].emailId == emailId);
      ..removeWhere(
        (item) =>
            item.receivers != null &&
            item.receivers!.isNotEmpty &&
            item.receivers![0].emailId == emailId,
      );

    state = state.copyWith(items: updatedItems);

    if (state.selectedEmailIdForReadingPane == emailId) {
      _clearReadingPaneSelection();
    }

    updateInboxEmailStatus("isArchive", [emailId], index);
  }

  Future<void> handlePrint() async {
    final id = state.selectedEmailIdForReadingPane;
    if (id == null) return;

    ActionBiometricGuard.markDeparture();

    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;

    final sessionToken = Descope.sessionManager.session?.sessionJwt ?? token;
    final itemIndex = state.items.indexWhere(
      (item) => item.receivers?.any((r) => r.emailId == id) ?? false,
    );
    final emailSubject = itemIndex != -1 ? state.items[itemIndex].subject : null;
    await openSecurePrint(
      printUrl: '$printUrl$id',
      token: sessionToken,
      context: ctx,
      subject: emailSubject,
    );
  }

  void handleSingleEmailDelete(int emailId, int index) {
    // Check if this is a draft item in trash
    final item = index < state.items.length ? state.items[index] : null;
    if (state.currentPath == trashPath && item?.isDraft == true) {
      _permanentlyDeleteDrafts([emailId]);
      return;
    }

    if (state.currentPath == trashPath) {
      // For trash, show confirmation popup first - don't remove item until confirmed
      deleteEmailModal([emailId]);
    } else {
      // For other paths, optimistically remove and move to trash
      final updatedItems = List<Emails>.from(state.items)
        ..removeWhere(
          (item) =>
              item.receivers != null &&
              item.receivers!.isNotEmpty &&
              item.receivers![0].emailId == emailId,
        );

      state = state.copyWith(items: updatedItems);

      if (state.selectedEmailIdForReadingPane == emailId) {
        _clearReadingPaneSelection();
      }

      updateInboxEmailStatus("isTrash", [emailId], index);
    }
  }

  // ── Draft-specific trash actions ──

  Future<void> _restoreDraftFromTrash(int draftId) async {
    // Optimistically remove from list
    final updatedItems = List<Emails>.from(state.items)
      ..removeWhere((item) => item.isDraft == true && item.id == draftId);
    state = state.copyWith(items: updatedItems);

    if (state.selectedEmailIdForReadingPane == draftId) {
      _clearReadingPaneSelection();
    }

    final resp = await _archiveApi.restoreDraft(draftId);
    if (_disposed) return;
    final data = resp.data;
    if (data?['success'] == true) {
      CommonService.animatedToast('Restored to Drafts', 'success');
    } else {
      CommonService.animatedToast(
        data?['message'] as String? ?? 'Failed to restore draft',
        'error',
      );
      // Re-fetch to restore the item
      await getAllEmails('');
    }
  }

  Future<void> _permanentlyDeleteDrafts(List<int> draftIds) async {
    // Optimistically remove from list
    final updatedItems = List<Emails>.from(state.items)
      ..removeWhere(
        (item) => item.isDraft == true && draftIds.contains(item.id),
      );
    state = state.copyWith(items: updatedItems);

    if (draftIds.contains(state.selectedEmailIdForReadingPane)) {
      _clearReadingPaneSelection();
    }

    final resp = await _archiveApi.permanentlyDeleteDrafts({
      'draftIds': draftIds,
    });
    if (_disposed) return;
    final data = resp.data;
    if (data?['success'] != true) {
      CommonService.animatedToast(
        data?['message'] as String? ?? 'Failed to delete draft',
        'error',
      );
      await getAllEmails('');
    }
  }

  Future<void> updateReadingPaneEmailStatus(String statusKey) async {
    final emailId = state.selectedEmailIdForReadingPane;
    final emailIndex = state.selectedEmailIndex;

    if (emailId == null || emailIndex == null) return;

    // Remove email from contacts_riverpod optimistically
    final updatedItems = List<Emails>.from(state.items)
      // ..removeWhere((item) => item.receivers?[0].emailId == emailId);
      ..removeWhere(
        (item) =>
            item.receivers != null &&
            item.receivers!.isNotEmpty &&
            item.receivers![0].emailId == emailId,
      );

    // Clear reading-pane selection
    state = state.copyWith(
      items: updatedItems,
      showReadingPaneMenuOptions: false,
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
    );

    // Call API
    await updateInboxEmailStatus(statusKey, [emailId], emailIndex);
  }

  Future<void> handleBulkMarkUnreadAction() async {
    if (_hasListSelectionActive) {
      final selectionState = getSelectionState();
      if (selectionState == 'singleUnread' || selectionState == 'allUnread') {
        // Mark as Read
        await markSelectedAsRead(state.selectedEmailIds);
      } else {
        // Mark as Unread (for mixed, allRead, or singleRead)
        await markSelectedAsUnread(state.selectedEmailIds);

        // Close reading pane if the viewed email is among those being marked as unread
        if (state.selectedEmailIdForReadingPane != null &&
            state.selectedEmailIds.contains(
              state.selectedEmailIdForReadingPane,
            )) {
          _clearReadingPaneSelection();
        }
      }
      onLongPress(null, null);
    } else if (_isReadingPaneSelectionOnly &&
        state.selectedEmailIndex != null &&
        state.selectedEmailIdForReadingPane != null) {
      final emailId = state.selectedEmailIdForReadingPane!;
      final idx = state.items.indexWhere(
        (item) => item.receivers?.any((r) => r.emailId == emailId) ?? false,
      );
      if (idx != -1 &&
          state.items[idx].receivers != null &&
          state.items[idx].receivers!.isNotEmpty) {
        final receiverIdx = state.items[idx].receivers!.indexWhere(
          (r) => r.emailId == emailId,
        );
        if (receiverIdx != -1) {
          final isUnread =
              !(state.items[idx].receivers![receiverIdx].isRead ?? false);
          if (isUnread) {
            // Mark as Read
            await markSelectedAsRead([emailId]);
          } else {
            // Mark as Unread
            await markSelectedAsUnread([emailId]);
            final list = [...state.items];
            final updatedReceivers = [...list[idx].receivers!];
            updatedReceivers[receiverIdx] = updatedReceivers[receiverIdx]
                .copyWith(isRead: false);
            list[idx] = list[idx].copyWith(receivers: updatedReceivers);
            state = state.copyWith(items: list);
          }
          _clearReadingPaneSelection();
          state = state.copyWith(selectedEmailTags: null);
        }
      }
    }
  }

  void handleBulkTagAction() {
    // Close menu options first
    state = state.copyWith(
      showMenuOptions: false,
      showReadingPaneMenuOptions: false,
      showTagList: false,
    );

    List<int> existingTagIds = [];

    // Prioritize reading pane selection when email is open (similar to inbox)
    if (_isReadingPaneSelectionOnly &&
        state.selectedEmailIdForReadingPane != null) {
      // Compute index from email ID if not already set
      int emailIndex =
          state.selectedEmailIndex ??
          state.items.indexWhere(
            (item) =>
                item.receivers?.any(
                  (r) => r.emailId == state.selectedEmailIdForReadingPane,
                ) ??
                false,
          );

      if (emailIndex == -1) emailIndex = 0; // Fallback to 0 if not found

      // Get tags for reading pane email
      // Note: second parameter is receiver index (typically 0), not item index
      final emailId = state.selectedEmailIdForReadingPane!;
      existingTagIds = getExistingTagIdsForEmail(emailId, 0);
      state = state.copyWith(
        selectedTagIds: existingTagIds,
        showReadingPaneMenuOptions: false,
        selectedEmailIndex: emailIndex,
      );

      // Show the tag list dialog directly
      showList(emailId, emailIndex);
    } else if (_hasListSelectionActive) {
      if (state.selectedEmailIds.isEmpty) return;
      // For single selection, get existing tags
      if (state.selectedEmailIds.length == 1) {
        existingTagIds = getExistingTagIdsForEmail(
          state.selectedEmailIds.first,
          0,
        );
      }
      state = state.copyWith(selectedTagIds: existingTagIds);

      // Use post frame callback to ensure state update completes before showing modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showList(0, 1);
      });
    }
  }

  Future<void> handleBulkMarkAsReadAction() async {
    if (_hasListSelectionActive) {
      await markSelectedAsRead(state.selectedEmailIds);
      onLongPress(null, null);
    } else if (_isReadingPaneSelectionOnly &&
        state.selectedEmailIndex != null &&
        state.selectedEmailIdForReadingPane != null) {
      final emailId = state.selectedEmailIdForReadingPane!;
      await markSelectedAsRead([emailId]);
    }
  }

  Future<void> markSelectedAsReadWithUndo() async {
    if (_disposed) return;
    // Check if iOS/iPad and filters are applied
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final hasFilters = state.emailType != null || state.tagIdFilter.isNotEmpty;
    List<int> selectedEmailIds = state.selectedEmailIds;
    if (isIOS && hasFilters) {
      // Silent update for iOS with filters applied

      // Update local state first
      final list = [...state.items];
      for (final id in state.selectedEmailIds) {
        final idx = list.indexWhere((e) => e.id == id);
        if (idx != -1) {
          _setItemReceiverIsRead(list, idx, true);
        }
      }
      state = state.copyWith(items: list);

      // Make silent API call
      await updateInboxEmailStatusSilent('isRead', state.selectedEmailIds, 0);
      return;
    }

    // Normal flow for other cases
    try {
      Map<String, dynamic> resp = await _apiService.post(
        updateEmailStatusApi,
        {"key": 'isRead', "emailIds": state.selectedEmailIds, "value": true},
      );

      if (resp['success']) {
        final items = [...state.items];
        for (final emailId in selectedEmailIds) {
          // Use receivers[0].emailId for archive/sent/trash emails
          final idx = items.indexWhere(
            (item) => (item.receivers != null && item.receivers!.isNotEmpty)
                ? item.receivers![0].emailId == emailId
                : item.id == emailId,
          );
          _setItemReceiverIsRead(items, idx, true);
        }
        state = state.copyWith(items: items);

        // Emit unReadCount socket event to update counts
        if (userData != null && userData!['user'] != null) {
          SocketService().emitEventWithAck(
            'unReadCount',
            {"userId": userData!['user']['id']},
            ackCallback: (data) {
              if (data != null) {
                _updateBadgeFromSocket(data);
              }
            },
          );
        }
      } else {
        CommonService.animatedToast(resp['message'], 'error', null, true);
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  Future<void> markSelectedAsUnread(List<int> emailIds) async {
    await updateInboxEmailStatus('isRead', emailIds, 0);
    // Bug 11: Refresh sidebar counts after marking as unread.
    // markSelectedAsRead emits this event but markSelectedAsUnread did not,
    // causing stale sidebar counts in archive/trash.
    if (userData != null && userData!['user'] != null) {
      SocketService().emitEventWithAck(
        'unReadCount',
        {"userId": userData!['user']['id']},
        ackCallback: (data) {
          if (data != null) _updateBadgeFromSocket(data);
        },
      );
    }
  }

  Future<void> markSelectedAsRead(List<int> emailIds) async {
    // Check if iOS/iPad and filters are applied
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final hasFilters = state.emailType != null || state.tagIdFilter.isNotEmpty;

    if (isIOS && hasFilters) {
      // Silent update for iOS with filters applied

      // Update local state first
      final list = [...state.items];
      for (final id in emailIds) {
        final idx = list.indexWhere(
          (item) => item.receivers?.any((r) => r.emailId == id) ?? false,
        );
        if (idx != -1 &&
            list[idx].receivers != null &&
            list[idx].receivers!.isNotEmpty) {
          final receiverIdx = list[idx].receivers!.indexWhere(
            (r) => r.emailId == id,
          );
          if (receiverIdx != -1) {
            final updatedReceivers = [...list[idx].receivers!];
            updatedReceivers[receiverIdx] = updatedReceivers[receiverIdx]
                .copyWith(isRead: true);
            list[idx] = list[idx].copyWith(receivers: updatedReceivers);
          }
        }
      }
      state = state.copyWith(items: list);

      // Make silent API call
      await updateInboxEmailStatusSilent('isRead', emailIds, 0);

      // Update badge count after marking as read
      if (userData != null && userData!['user'] != null) {
        SocketService().emitEventWithAck(
          'unReadCount',
          {"userId": userData!['user']['id']},
          ackCallback: (data) {
            if (data != null) {
              _updateBadgeFromSocket(data);
            }
          },
        );
      }
      return;
    }

    // Normal flow for other cases
    try {
      Map<String, dynamic> resp = await _apiService.post(
        updateEmailStatusApi,
        {"key": 'isRead', "emailIds": emailIds, "value": true},
      );
      if (_disposed) return;
      if (resp['success']) {
        final list = [...state.items];

        for (final id in emailIds) {
          final idx = list.indexWhere(
            (item) => item.receivers?.any((r) => r.emailId == id) ?? false,
          );
          if (idx != -1 &&
              list[idx].receivers != null &&
              list[idx].receivers!.isNotEmpty) {
            final receiverIdx = list[idx].receivers!.indexWhere(
              (r) => r.emailId == id,
            );
            if (receiverIdx != -1) {
              final updatedReceivers = [...list[idx].receivers!];
              updatedReceivers[receiverIdx] = updatedReceivers[receiverIdx]
                  .copyWith(isRead: true);
              list[idx] = list[idx].copyWith(receivers: updatedReceivers);
            }
          }
        }
        state = state.copyWith(items: list);

        // Update badge count after marking as read
        if (userData != null && userData!['user'] != null) {
          SocketService().emitEventWithAck(
            'unReadCount',
            {"userId": userData!['user']['id']},
            ackCallback: (data) {
              if (data != null) {
                _updateBadgeFromSocket(data);
              }
            },
          );
        }
      } else {
        CommonService.animatedToast(resp['message'], 'error', null, true);
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
    setupNotificationListener();
  }

  String getSelectionState() {
    if (state.selectedEmailIds.isEmpty) return 'none';

    List<bool> statuses = [];
    for (final id in state.selectedEmailIds) {
      // Use receivers[0].emailId for archive/sent/trash emails
      final idx = state.items.indexWhere(
        (e) => (e.receivers != null && e.receivers!.isNotEmpty)
            ? e.receivers![0].emailId == id
            : e.id == id,
      );
      if (idx != -1) {
        final isRead = state.items[idx].receivers?[0].isRead ?? false;
        statuses.add(isRead);
      }
    }

    if (statuses.isEmpty) return 'none';

    if (state.selectedEmailIds.length == 1) {
      return statuses.first ? 'singleRead' : 'singleUnread';
    }

    final allRead = statuses.every((s) => s == true);
    final allUnread = statuses.every((s) => s == false);

    if (allRead) return 'allRead';
    if (allUnread) return 'allUnread';
    return 'mixed';
  }

  /// Returns 'allSent', 'allReceived', 'mixed', or 'none'
  /// based on whether selected emails were sent by the current user.
  String getSelectionOrigin() {
    if (state.selectedEmailIds.isEmpty) return 'none';
    bool hasSent = false;
    bool hasReceived = false;
    for (final id in state.selectedEmailIds) {
      final idx = state.items.indexWhere(
        (e) => (e.receivers != null && e.receivers!.isNotEmpty)
            ? e.receivers![0].emailId == id
            : e.id == id,
      );
      if (idx != -1) {
        if (state.items[idx].senderId == userId) {
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

  String computeMarkActionTitle() {
    if (state.selectedEmailIds.isEmpty) return 'Mark';
    List<bool> statuses = [];
    for (final id in state.selectedEmailIds) {
      // Use receivers[0].emailId for archive/sent/trash emails
      final idx = state.items.indexWhere(
        (e) => (e.receivers != null && e.receivers!.isNotEmpty)
            ? e.receivers![0].emailId == id
            : e.id == id,
      );
      if (idx != -1) {
        final isRead = state.items[idx].receivers?[0].isRead ?? false;
        statuses.add(isRead);
      }
    }
    if (statuses.isEmpty) return 'Mark';
    if (state.selectedEmailIds.length == 1) {
      return statuses.first ? markUnread : markRead;
    }
    final allRead = statuses.every((s) => s == true);
    final allUnread = statuses.every((s) => s == false);
    if (allRead) return markUnread;
    if (allUnread) return markRead;
    return markUnread;
  }

  Future<void> handleBulkDeleteAction() async {
    final targetIds = _currentActionEmailIds();
    if (targetIds.isEmpty) return;
    printLog(
      'ArchiveNotifier',
      'state.currentPath == trashPath: ${state.currentPath == trashPath}, hasListSelectionActive: $_hasListSelectionActive',
    );
    if (_hasListSelectionActive) {
      if (state.currentPath == trashPath) {
        await deleteEmailModal(targetIds);
        return;
      }
      if (state.items.length == state.selectedEmailIds.length &&
          state.inboxList?.data.nextPage == true) {
        await getAllEmails("");
        state = state.copyWith(previousPage: 0, currentPage: 1);
      }
      changeEmailStatus('isTrash');
    } else if (_isReadingPaneSelectionOnly) {
      if (state.currentPath == trashPath) {
        await _deleteReadingPaneEmailPermanently();
      } else {
        await _updateReadingPaneEmailStatus('isTrash');
      }
    }
  }

  Future<void> deleteEmailModal(List<int> emailIds) async {
    // Check if we're in selection mode before showing the dialog
    final wasInSelectionMode = !state.longPressFlag;

    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (ctx) {
        return CustomPopupModal(
          onPressedButton1: () {
            Navigator.of(ctx, rootNavigator: true).pop();
          },
          onPressedButton2: () async {
            if (state.items.length == state.selectedEmailIds.length &&
                state.inboxList?.data.nextPage == true) {
              await getAllEmails("");
              state = state.copyWith(previousPage: 0, currentPage: 1);
            }
            if (!ctx.mounted) return;
            await updateSentEmailStatus("isDeleted", emailIds);
            removeSelectedItem(emailIds);
            // Only toggle selection mode if we were in selection mode before
            if (wasInSelectionMode) {
              onLongPress(null, null);
            }
            // Refresh the list after deletion
            await getAllEmails(state.searchKey, silent: true);
          },
          textButton1: 'Cancel',
          textButton2: 'Delete',
          icon: null,
          title: 'Permanently Delete',
          subtitle: emailIds.length == 1
              ? 'Confirm you want to permanently delete this email.  Once deleted, it cannot be recovered.'
              : 'Confirm you want to permanently delete these emails. Once deleted, they cannot be recovered.',
        );
      },
    );
  }

  /// Handle opt-in action for a single email from hover
  void handleSingleEmailOptIn(String email, int index) {
    if (email.isEmpty) return;
    final item =
        (index >= 0 && index < state.items.length)
            ? state.items[index]
            : null;
    final raw = item?.senderName?.trim();
    final name = (raw != null && raw.isNotEmpty) ? raw : null;
    displayAddEmailModal([email], 0, senderNames: {email: name});
  }

  Future<void> displayAddEmailModal(
    List<String> emails,
    int index, {
    Map<String, String?> senderNames = const {},
  }) async {
    if (_disposed) return;
    // Base case: no more emails
    if (index >= emails.length) {
      if (emails.isNotEmpty && state.allEmailsTrue) {
        CommonService.animatedToast(
          'Emails are already present in a contact',
          'info',
        );
      }
      return;
    }

    final String email = emails[index];

    try {
      // Call API to check email status
      final Map<String, dynamic> resp = await _apiService.post(
        'contact/check-email',
        {"email": email},
      );

      if (resp['success']) {
        if (resp['data']['status'] == true) {
          await displayAddEmailModal(emails, index + 1, senderNames: senderNames);
          return;
        }

        // Update flag in Riverpod state
        state = state.copyWith(allEmailsTrue: false);
        final ctx = NavigationService.navigatorKey.currentContext;
        if (ctx == null) return;
        final result = await showDialog(
          context: ctx,
          builder: (BuildContext context) {
            return AddEmailModal(
              title: addEmail,
              type: emails.length > 1 ? "Multiple" : "longPress",
              subtitleFirst: email,
              subtitle: addEmailcontact,
              contact: null,
              saveFlag: () async {
                // Add logic here if required after saving
              },
              currentIndex: index,
              totalEmails: emails.length,
              senderDisplayName: senderNames[email],
            );
          },
        );

        // Handle dialog results
        if (result == 'skip_all') {
          // User clicked Skip All & Send - stop processing
          return;
        } else if (result == 'cancel-email') {
          // User clicked X close - stop processing
          return;
        } else if (result == 'existing_contact') {
          // User clicked Add to Existing - stop, user is navigating to contact selection
          return;
        } else if (result == 'skip') {
          // User clicked Skip - skip this contact, continue to next
          if (index < emails.length - 1) {
            displayAddEmailModal(emails, index + 1, senderNames: senderNames);
          }
          return;
        }

        // Save result - continue to next email if not at the end
        if (index < emails.length - 1) {
          displayAddEmailModal(emails, index + 1, senderNames: senderNames);
        }
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          'Error checking email',
          'error',
          null,
          true,
        );
      }
    }
  }

  void removeSelectedItem(List<int> ids) {
    final items = [...state.items];
    for (final emailId in ids) {
      // For trash/archive/sent emails, check receivers[0].emailId, otherwise check item.id
      final index = items.indexWhere((item) {
        if (item.receivers != null && item.receivers!.isNotEmpty) {
          return item.receivers![0].emailId == emailId;
        }
        return item.id == emailId;
      });
      if (index != -1) {
        items.removeAt(index);
      }
    }
    state = state.copyWith(
      items: items,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
    );
  }

  void toggleSearch() {
    state = state.copyWith(isSearch: !state.isSearch);
  }

  Future<void> onSearchChanged(String value) async {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (_disposed) return;
      state = state.copyWith(
        currentPage: 1,
        previousPage: 0,
        searchKey: value,
        // Clear reading pane selection when search changes
        selectedEmailIdForReadingPane: null,
        selectedEmailSender: null,
        selectedEmailIndex: null,
        showReadingPaneMenuOptions: false,
      );
      await getAllEmails(state.searchKey);
    });
  }

  void clearOverlayStates() {
    state = state.copyWith(
      showFilter: false,
      showTagList: false,
      isSearch: false,
      searchKey: '',
      showMenuOptions: false,
      showMoveOverlay: false,
      showReadingPaneMenuOptions: false,
      // Reset checkbox state when navigating between folders
      showCheckboxes: false,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      // Clear tag filters to prevent cross-folder contamination
      tagIdFilter: [],
      selectedTagIds: [],
      tagFilter: false,
    );
  }

  void toggleFilter() {
    state = state.copyWith(showFilter: !state.showFilter, showTagList: false);
  }

  void clearUnreadFilter() {
    // Determine the original emailType based on currentPath
    String originalEmailType = "archive";
    if (state.currentPath == archivePath) {
      originalEmailType = "archive";
    } else if (state.currentPath == sentPath) {
      originalEmailType = "sent";
    } else if (state.currentPath == trashPath) {
      originalEmailType = "trash";
    }

    state = state.copyWith(
      showFilter: false,
      currentPage: 1,
      previousPage: 0,
      emailType: originalEmailType,
    );

    getAllEmails(state.searchKey);
  }

  void clearTagFilter() {
    // Determine the original emailType based on currentPath
    String originalEmailType = "archive";
    if (state.currentPath == archivePath) {
      originalEmailType = "archive";
    } else if (state.currentPath == sentPath) {
      originalEmailType = "sent";
    } else if (state.currentPath == trashPath) {
      originalEmailType = "trash";
    }

    state = state.copyWith(
      showFilter: false,
      tagFilter: false,
      tagIdFilter: [],
      currentPage: 1,
      previousPage: 0,
      emailType: originalEmailType,
    );

    getAllEmails(state.searchKey);
  }

  void setSelectedEmails(List<int> ids, List<String> emails) {
    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      longPressFlag: ids.isEmpty,
      allEmailIdsFlag: ids.length == state.items.length,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      allEmailIdsFlag: false,
      longPressFlag: true,
      showCheckboxes: false,
      lastClickedIndex: -1,
    );
  }

  void selectAllFromList() {
    final ids = <int>[];
    final emails = <String>[];
    for (final item in state.items) {
      if (item.receivers != null && item.receivers!.isNotEmpty) {
        ids.add(item.receivers![0].emailId!);
        emails.add(item.senderEmail ?? '');
      }
    }
    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: true,
      longPressFlag: false,
    );
  }

  void selectRangeFromList(int fromIndex, int toIndex) {
    final items = state.items;
    if (items.isEmpty) return;
    final start = fromIndex.clamp(0, items.length - 1);
    final end = toIndex.clamp(0, items.length - 1);
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;

    final ids = {...state.selectedEmailIds};
    final emails = {...state.selectedEmails};

    for (int i = lo; i <= hi; i++) {
      final item = items[i];
      if (item.receivers != null && item.receivers!.isNotEmpty) {
        ids.add(item.receivers![0].emailId!);
        emails.add(item.senderEmail ?? '');
      }
    }

    state = state.copyWith(
      selectedEmailIds: ids.toList(),
      selectedEmails: emails.toList(),
      allEmailIdsFlag: ids.length == items.length,
      longPressFlag: false,
      showCheckboxes: true,
      lastClickedIndex: toIndex.clamp(0, items.length - 1),
    );
  }

  void toggleSingleSelectByIndex(int index) {
    final items = state.items;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    if (item.receivers == null || item.receivers!.isEmpty) return;
    final id = item.receivers![0].emailId!;
    final email = item.senderEmail ?? '';
    final ids = [...state.selectedEmailIds];
    final emails = [...state.selectedEmails];

    if (ids.contains(id)) {
      ids.remove(id);
      emails.remove(email);
    } else {
      ids.add(id);
      emails.add(email);
    }

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: ids.length == items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.length > 1 ? true : state.showCheckboxes,
      lastClickedIndex: index,
    );
  }

  void updateReadingPane({int? id, int? index, String? sender}) {
    state = state.copyWith(
      selectedEmailIdForReadingPane: id,
      selectedEmailIndex: index,
      selectedEmailSender: sender,
      showReadingPaneMenuOptions: false,
      lastClickedIndex: index ?? -1,
    );
  }

  void closeReadingPaneMenu() {
    state = state.copyWith(showReadingPaneMenuOptions: false);
  }

  void openReadingPaneMenu() {
    state = state.copyWith(showReadingPaneMenuOptions: true);
  }

  /// Set reading pane selection (used by mobile layout before navigation)
  void setReadingPaneSelection(int? id, int? index, String? sender) {
    state = state.copyWith(
      selectedEmailIdForReadingPane: id,
      selectedEmailIndex: index,
      selectedEmailSender: sender,
      lastClickedIndex: index ?? -1,
    );
  }

  /// Clear reading pane selection (used when returning from mobile view)
  void clearReadingPaneSelection() {
    state = state.copyWith(
      selectedEmailIdForReadingPane: null,
      selectedEmailIndex: null,
      selectedEmailSender: null,
    );
  }

  void toggleMenuOptions() {
    state = state.copyWith(showMenuOptions: !state.showMenuOptions);
  }

  void closeMenuOptions() {
    state = state.copyWith(showMenuOptions: false);
  }

  void closeFilter() {
    state = state.copyWith(showFilter: false);
  }

  // Apply unread filter
  void applyUnreadFilter() {
    _applyFilter("unread");
  }

  // Apply community filter
  void applyCommunityFilter() {
    _applyFilter("community");
  }

  // Common filter handler
  void _applyFilter(String filter) {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      emailType: filter,
      showFilter: false,
      // Clear reading pane selection when filter changes
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
      showReadingPaneMenuOptions: false,
    );

    getAllEmails(state.searchKey);
  }

  void closeTagList() {
    state = state.copyWith(showFilter: false, showTagList: false);
  }

  /// Apply tag filter
  void applyTagFilter(int tagId) {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      showTagList: false,
      tagFilter: true,
      tagIdFilter: [tagId],
      // Clear reading pane selection when filter changes
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
      showReadingPaneMenuOptions: false,
    );

    getAllEmails(state.searchKey);
  }

  // C-06: Immutably update receivers[0].isRead on items[idx].
  // Creates new Emails + Receivers objects so Freezed detects the state change.
  void _setItemReceiverIsRead(List<Emails> items, int idx, bool isRead) {
    if (idx == -1 ||
        items[idx].receivers == null ||
        items[idx].receivers!.isEmpty) {
      return;
    }
    items[idx] = items[idx].copyWith(
      receivers: [
        items[idx].receivers![0].copyWith(isRead: isRead),
        ...items[idx].receivers!.skip(1),
      ],
    );
  }

  /// Remove a globally-deleted tag from every archive email's in-memory tag list.
  void purgeDeletedTag(int tagId) {
    final updated = state.items.map((email) {
      final tags = email.emailTag;
      if (tags == null || tags.isEmpty) return email;
      final filtered = tags.where((t) => t.tagId != tagId).toList();
      return (filtered.length == tags.length)
          ? email
          : email.copyWith(emailTag: filtered);
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Reset archive state to initial state (used during logout)
  void reset() {
    debounce?.cancel();
    undoTimer?.cancel();
    trashMessageSub?.cancel();
    notificationSub?.cancel();
    tagsSub?.cancel();
    userData = null;
    userId = null;
    token = "";
    state = const ArchiveState();
  }
}
