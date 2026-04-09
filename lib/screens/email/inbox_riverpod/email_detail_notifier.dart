import 'dart:async';
import 'package:descope/descope.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_state.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/model/view_email_model.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/string_constant.dart' show catchError, failedToLoadEmail, updateEmailStatusApi;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

/// Provider for email detail state.
///
/// PC-01 Phase 2 TODO: This provider is currently unused — ReadingPaneWidget
/// no longer watches it (Phase 1 eliminated the duplicate email/detail fetch).
/// ViewEmail maintains its own local state via getEmailViewDetail().
///
/// To complete Phase 2, migrate ViewEmail to consume this provider instead of
/// its local fetch. This requires:
///   1. Move AddEmailModal trigger (community emails) to the provider or parent
///   2. Compute categorizedData in UI from email.receivers (not in provider state)
///   3. Validate tag field equivalence (emailRecipientTags vs emailTags)
///   4. Centralize socket listeners (both ViewEmail and this notifier set them up)
///   5. Test mark-as-read timing (provider uses HTTP, ViewEmail uses socket ack)
///
/// Once ViewEmail is migrated, remove getEmailViewDetail() from view_email.dart
/// and make this provider the single source of truth for email detail data.
final emailDetailProvider = NotifierProvider.autoDispose
    .family<EmailDetailNotifier, EmailDetailState, int>(
      EmailDetailNotifier.new,
    );

/// Notifier for managing email detail state.
///
/// This handles all business logic for viewing and interacting with a single email.
/// NO BuildContext dependency - all navigation and UI interactions are handled by the UI layer.
class EmailDetailNotifier extends Notifier<EmailDetailState> {
  EmailDetailNotifier(this.emailId);

  final int emailId;
  late final SocketService _socket;
  late final ApiService _apiService;

  StreamSubscription? _notificationSub;
  bool _disposed = false;

  @override
  EmailDetailState build() {
    _socket = ref.read(socketServiceProvider);
    _apiService = ref.read(apiServiceProvider);
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _notificationSub?.cancel();
    });
    Future.microtask(_init);
    return const EmailDetailState();
  }

  /// Initialize the notifier by loading user data and email details
  Future<void> _init() async {
    await _loadUserData();
    await loadEmailDetail();
    await _setupSocketListeners();
  }

  /// Load user data from secure storage
  Future<void> _loadUserData() async {
    final userData = ref.read(authProvider).userData;
    if (userData != null) {
      state = state.copyWith(
        userData: userData,
        token: userData['token'] ?? '',
      );
    }
  }

  /// Load email detail from API
  Future<void> loadEmailDetail({String? emailType}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post('email/detail', {
        'emailId': emailId,
      });

      if (_disposed) return;

      if (response['success']) {
        final emailData = ViewEmailModel.fromJson(response);
        final receivers = emailData.data.email.receivers;
        final firstReceiver = receivers.isNotEmpty ? receivers.first : null;

        state = state.copyWith(
          emailData: emailData,
          updatedTags: firstReceiver?.emailRecipientTags ?? [],
          isLoading: false,
        );

        // Mark as read if not already
        if (firstReceiver != null && !firstReceiver.isRead) {
          _markAsReadInBackground();
        }
      } else {
        state = state.copyWith(
          error: response['message'] ?? failedToLoadEmail,
          isLoading: false,
        );
        CommonService.animatedToast(
          response['message'] ?? failedToLoadEmail,
          'error',
          null,
          true,
        );
      }
    } catch (error) {
      if (_disposed) return;

      state = state.copyWith(error: failedToLoadEmail, isLoading: false);

      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    } finally {
      // no-op: timer removed — delay is now handled by the UI layer
    }
  }

  /// Mark email as read in background (no UI feedback needed)
  Future<void> _markAsReadInBackground() async {
    try {
      await _apiService.post(updateEmailStatusApi, {
        'key': 'isRead',
        'emailIds': [emailId],
        'value': true,
      });

      // Update unread count via socket
      if (state.userData != null && state.userData!['user'] != null) {
        _socket.emitEventWithAck('unReadCount', {
          'userId': state.userData!['user']['id'],
        }, ackCallback: (_) {});
      }
    } catch (e) {
      // Silently fail - marking as read is not critical
    }
  }

  /// Setup socket listeners for real-time updates
  Future<void> _setupSocketListeners() async {
    if (_disposed) return;
    if (state.userData == null || state.userData!['user'] == null) return;

    final userId = state.userData!['user']['id'];

    // Listen for notification updates
    _notificationSub = _socket.onEvent('notificationExists').listen((data) {
      if (!_disposed) {
        final hasNotification = data != null && data != 'no' && data != false;
        state = state.copyWith(newNotification: hasNotification);
      }
    });

    // Request initial notification status
    _socket.emitEventWithAck(
      'notificationExists',
      {'userId': userId},
      ackCallback: (data) {
        if (!_disposed && data != null) {
          final hasNotification = data != 'no' && data != false;
          state = state.copyWith(newNotification: hasNotification);
        }
      },
    );
  }

  /// Mark email as unread
  Future<void> markAsUnread() async {
    try {
      final response = await _apiService.post(updateEmailStatusApi, {
        'key': 'isRead',
        'emailIds': [emailId],
        'value': false,
      });
      if (_disposed) return;

      if (response['success']) {
        state = state.copyWith(markedAsUnread: true);

        // Update unread count
        if (state.userData != null && state.userData!['user'] != null) {
          _socket.emitEventWithAck('unReadCount', {
            'userId': state.userData!['user']['id'],
          }, ackCallback: (_) {});
        }

        // No success toast — the visual state change (bold text) is sufficient feedback
      } else {
        CommonService.animatedToast(
          response['message'] ?? 'Failed to mark as unread',
          'error',
          null,
          true,
        );
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

  /// Move email to archive
  Future<void> moveToArchive() async {
    try {
      final response = await _apiService.post(updateEmailStatusApi, {
        'key': 'isArchive',
        'emailIds': [emailId],
        'value': true,
      });
      if (_disposed) return;

      if (response['success']) {
        state = state.copyWith(movedToArchive: true);
        CommonService.animatedToast('Moved to archive', 'success', null, true);
      } else {
        CommonService.animatedToast(
          response['message'] ?? 'Failed to archive',
          'error',
          null,
          true,
        );
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

  /// Move email to trash
  Future<void> moveToTrash() async {
    try {
      final response = await _apiService.post(updateEmailStatusApi, {
        'key': 'isTrash',
        'emailIds': [emailId],
        'value': true,
      });
      if (_disposed) return;

      if (response['success']) {
        state = state.copyWith(movedToTrash: true);
        CommonService.animatedToast('Moved to trash', 'success', null, true);
      } else {
        CommonService.animatedToast(
          response['message'] ?? 'Failed to move to trash',
          'error',
          null,
          true,
        );
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

  /// Add tags to email
  Future<void> addTags(List<int> tagIds) async {
    try {
      final response = await _apiService.post('email/emails-tags', {
        'emailIds': [emailId],
        'tagsId': tagIds,
        'type': 'add',
      });
      if (_disposed) return;

      if (response['success']) {
        // PM-03: Update tags from mutation response instead of re-fetching.
        _updateTagsFromResponse(response);
        CommonService.animatedToast('Tags added', 'success', null, true);
      } else {
        CommonService.animatedToast(
          response['message'] ?? 'Failed to add tags',
          'error',
          null,
          true,
        );
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

  /// Remove tags from email
  Future<void> removeTags(List<int> tagIds) async {
    try {
      final response = await _apiService.post('email/emails-tags', {
        'emailIds': [emailId],
        'tagsId': tagIds,
        'type': 'delete',
      });
      if (_disposed) return;

      if (response['success']) {
        // PM-03: Update tags from mutation response instead of re-fetching.
        _updateTagsFromResponse(response);
        CommonService.animatedToast('Tags removed', 'success', null, true);
      } else {
        CommonService.animatedToast(
          response['message'] ?? 'Failed to remove tags',
          'error',
          null,
          true,
        );
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

  /// PM-03: Update tags in state from the mutation response.
  void _updateTagsFromResponse(Map<String, dynamic> response) {
    if (_disposed) return;
    final email = response['data']?['email'];
    if (email == null) return;

    // Update emailRecipientTags (used by updatedTags in state)
    final recipientTagsJson =
        email['emailRecipientTags'] as List<dynamic>? ?? [];
    final newRecipientTags = recipientTagsJson
        .map((e) => EmailRecipientTags.fromJson(e as Map<String, dynamic>))
        .toList();
    state = state.copyWith(updatedTags: newRecipientTags);

    // Update emailTags on the model (used by UI tag display)
    final emailTagsJson = email['emailTags'] as List<dynamic>?;
    if (emailTagsJson != null && state.emailData != null) {
      state.emailData!.data.email.emailTags
        ..clear()
        ..addAll(
          emailTagsJson
              .map((e) => EmailTags.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
    }
  }

  /// Toggle tag list visibility
  void toggleTagList() {
    state = state.copyWith(
      showTagList: !state.showTagList,
      showMenuOptions: false,
    );
  }

  /// Toggle menu options visibility
  void toggleMenuOptions() {
    state = state.copyWith(
      showMenuOptions: !state.showMenuOptions,
      showTagList: false,
    );
  }

  /// Toggle show all attachments
  void toggleShowAllAttachments() {
    state = state.copyWith(showAllAttachments: !state.showAllAttachments);
  }

  /// Toggle expanded view
  void toggleExpandedView() {
    state = state.copyWith(expandedView: !state.expandedView);
  }

  /// Prepare compose parameters for reply/forward
  Map<String, dynamic> prepareComposeParams(String type) {
    final pageId = DateTime.now().microsecondsSinceEpoch;
    final offset = DateTime.now().timeZoneOffset.inMinutes;

    return {
      'url':
          '${defaultBaseUrl}api/email/compose?pageId=$pageId&emailId=$emailId&type=$type&timeZone=$offset',
      'token': Descope.sessionManager.session?.sessionJwt ?? state.token,
      'pageId': pageId,
      'type': type,
      'emailId': emailId,
    };
  }

  /// Prepare print URL (token-free; auth is sent via HTTP headers)
  String preparePrintUrl() {
    return '$printUrl$emailId';
  }

  /// Returns the session token for secure print auth headers.
  String get printToken =>
      Descope.sessionManager.session?.sessionJwt ?? state.token;

}
