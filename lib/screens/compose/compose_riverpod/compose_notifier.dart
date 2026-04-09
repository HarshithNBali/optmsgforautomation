import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/app_config.dart';
import '../../../main.dart';
import '../../../model/signed_url_model.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/count_notifier.dart';
import '../../../services/file_picker_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/web_file_picker_service.dart';
import '../../auth/auth_riverpod/auth_notifier.dart';
import 'compose_state.dart';

/// Storage key for the local autosave draft.
const _localDraftKey = 'compose_local_draft';

/// Maximum total attachment size in bytes (25 MB).
const _maxAttachmentBytes = 25 * 1024 * 1024;

final composeProvider = NotifierProvider.autoDispose
    .family<ComposeNotifier, ComposeState, ComposeParams>(
  ComposeNotifier.new,
);

class ComposeNotifier extends Notifier<ComposeState> {
  ComposeNotifier(this._params);

  final ComposeParams _params;
  bool _disposed = false;
  bool _discarded = false;
  bool _creatingDraft = false;
  Timer? _autosaveTimer;

  /// Cached editor HTML — updated on every keystroke via [cacheBodyHtml],
  /// synced to state only before saves to avoid excessive Riverpod rebuilds.
  String _cachedBodyHtml = '';

  /// Whether the user explicitly discarded this draft.
  bool get isDiscarded => _discarded;

  SecureStorageService get _storage =>
      providerContainer.read(storageServiceProvider);
  SocketService get _socket => providerContainer.read(socketServiceProvider);

  @override
  ComposeState build() {
    _disposed = false;
    _discarded = false;
    _creatingDraft = false;
    _cachedBodyHtml = '';
    ref.onDispose(() {
      _disposed = true;
      _autosaveTimer?.cancel();
    });
    Future.microtask(() => _init(_params));
    return const ComposeState(isLoading: true);
  }

  // ── Initialization ──

  Future<void> _init(ComposeParams params) async {
    try {
      // Load user data — try AuthState first (in-memory), fall back to storage
      var userData = ref.read(authProvider).userData;
      userData ??= await _storage.readObjectData('userData');

      if (_disposed) return;

      final fromEmail =
          userData?['user']?['userName'] != null
              ? '${userData!['user']['userName']}$emailExtension'
              : '';
      final fromName =
          [
            userData?['user']?['firstName'] ?? '',
            userData?['user']?['lastName'] ?? '',
          ].where((s) => s.isNotEmpty).join(' ');

      state = state.copyWith(
        mode: params.mode,
        emailId: params.emailId,
        fromEmail: fromEmail,
        fromName: fromName,
        userData: userData,
      );

      // Pre-fill TO field if provided (e.g. compose from contact)
      if (params.toEmail != null && params.toEmail!.isNotEmpty) {
        state = state.copyWith(
          toRecipients: [params.toEmail!],
          showCcBcc: false,
        );
      }

      // Load email data for reply/forward/draft editing
      if (params.mode == ComposeMode.updateDraft && params.emailId != null) {
        await _loadDraftForEditing(params.emailId!);
      } else if (params.mode.isReplyOrForward && params.emailId != null) {
        await _loadEmailForReplyForward(params.emailId!, params.mode);
      }

      if (_disposed) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: 'Failed to initialize');
      if (kDebugMode) debugPrint('[ComposeNotifier] init error: $e');
    }
  }

  Future<void> _loadDraftForEditing(int draftId) async {
    try {
      // Try new REST endpoint first; fall back to email/detail if not deployed
      Map<String, dynamic> resp;
      try {
        resp = await ApiService().get('email/draft/$draftId');
      } catch (_) {
        resp = await ApiService().post('email/detail', {'emailId': draftId});
      }
      if (_disposed) return;

      if (resp['success'] == true) {
        final email = resp['data']?['email'];
        if (email == null) return;

        final receivers = email['receivers'] as List<dynamic>? ?? [];
        final toList = <String>[];
        final ccList = <String>[];
        final bccList = <String>[];

        for (final r in receivers) {
          final emailAddr = r['receiverEmail'] as String? ?? '';
          final type = r['type'] as String? ?? '';
          if (emailAddr.isEmpty) continue;
          switch (type.toLowerCase()) {
            case 'cc':
              ccList.add(emailAddr);
            case 'bcc':
              bccList.add(emailAddr);
            default:
              toList.add(emailAddr);
          }
        }

        final attachments = (email['attachments'] as List<dynamic>? ?? [])
            .map((a) => ComposeAttachment(
                  fileName: a['fileName'] as String? ??
                      (a['path'] as String? ?? '').split('/').last,
                  fileType: a['type'] as String? ?? '',
                  serverPath: a['path'] as String? ?? '',
                  sizeBytes: (a['size'] as num?)?.toInt() ?? 0,
                ))
            .toList();

        final totalBytes =
            attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);

        state = state.copyWith(
          draftId: draftId,
          subject: email['subject'] as String? ?? '',
          bodyHtml: email['message'] as String? ?? '',
          toRecipients: toList,
          ccRecipients: ccList,
          bccRecipients: bccList,
          showCcBcc: ccList.isNotEmpty || bccList.isNotEmpty,
          attachments: attachments,
          totalAttachmentBytes: totalBytes,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ComposeNotifier] loadDraft error: $e');
    }
  }

  Future<void> _loadEmailForReplyForward(
    int emailId,
    ComposeMode mode,
  ) async {
    try {
      final resp = await ApiService().post('email/detail', {
        'emailId': emailId,
      });
      if (_disposed) return;

      if (resp['success'] == true) {
        final email = resp['data']?['email'];
        if (email == null) return;

        final senderEmail = email['senderEmail'] as String? ?? '';
        final subject = email['subject'] as String? ?? '';
        final message = email['message'] as String? ?? '';

        // Build subject prefix
        String newSubject;
        if (mode == ComposeMode.forward) {
          newSubject =
              subject.startsWith('Fwd:') ? subject : 'Fwd: $subject';
        } else {
          newSubject = subject.startsWith('Re:') ? subject : 'Re: $subject';
        }

        // Pre-fill recipients
        final toList = <String>[];
        final ccList = <String>[];

        if (mode == ComposeMode.reply || mode == ComposeMode.replyAll) {
          toList.add(senderEmail);
        }
        if (mode == ComposeMode.replyAll) {
          final receivers = email['receivers'] as List<dynamic>? ?? [];
          for (final r in receivers) {
            final addr = r['receiverEmail'] as String? ?? '';
            final type = r['type'] as String? ?? '';
            if (addr.isEmpty || addr == state.fromEmail) continue;
            if (type.toLowerCase() == 'cc') {
              ccList.add(addr);
            } else if (type.toLowerCase() == 'to' && addr != senderEmail) {
              toList.add(addr);
            }
          }
        }

        // Compose body: empty line for user to type + quoted original
        final quotedBody = '<br><br>'
            '<p style="color:#666;font-size:12px;">--- Original Message ---</p>'
            '<blockquote style="border-left:2px solid #ccc;padding-left:12px;margin-left:0;color:#666;">'
            '$message</blockquote>';

        state = state.copyWith(
          emailId: emailId,
          subject: newSubject,
          bodyHtml: quotedBody,
          toRecipients: toList,
          ccRecipients: ccList,
          showCcBcc: ccList.isNotEmpty,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ComposeNotifier] loadEmail error: $e');
    }
  }

  // ── Field updates ──

  void updateToRecipients(List<String> recipients) {
    state = state.copyWith(toRecipients: recipients, isDirty: true);
    _startAutosaveTimer();
  }

  void updateCcRecipients(List<String> recipients) {
    state = state.copyWith(ccRecipients: recipients, isDirty: true);
    _startAutosaveTimer();
  }

  void updateBccRecipients(List<String> recipients) {
    state = state.copyWith(bccRecipients: recipients, isDirty: true);
    _startAutosaveTimer();
  }

  void updateSubject(String value) {
    state = state.copyWith(subject: value, isDirty: true);
    _startAutosaveTimer();
  }

  void updateBodyHtml(String html) {
    state = state.copyWith(bodyHtml: html, isDirty: true);
    _startAutosaveTimer();
  }

  void toggleCcBcc() {
    state = state.copyWith(showCcBcc: !state.showCcBcc);
  }

  void markDirty() {
    if (!state.isDirty) {
      state = state.copyWith(isDirty: true);
    }
    _startAutosaveTimer();
  }

  /// Cache the latest editor HTML without triggering a Riverpod rebuild.
  /// Called on every editor keystroke; synced to state only before saves.
  void cacheBodyHtml(String html) {
    _cachedBodyHtml = html;
  }

  /// Flush cached editor content into Riverpod state (triggers one rebuild).
  void syncCachedContent() {
    if (_cachedBodyHtml.isNotEmpty && _cachedBodyHtml != state.bodyHtml) {
      state = state.copyWith(bodyHtml: _cachedBodyHtml);
    }
  }

  /// Build the JSON payload used by both draft save and draft create.
  Map<String, dynamic> _buildDraftPayload() {
    return {
      'to': state.toRecipients,
      'cc': state.ccRecipients,
      'bcc': state.bccRecipients,
      'subject': state.subject,
      'body': state.bodyHtml,
      'attachments': state.attachments.map((a) => a.toServerJson()).toList(),
      if (state.emailId != null) 'replyToEmailId': state.emailId,
    };
  }

  // ── Attachments ──

  Future<void> addAttachment({
    required String fileName,
    required String fileType,
    required String serverPath,
    required int sizeBytes,
  }) async {
    if (state.totalAttachmentBytes + sizeBytes > _maxAttachmentBytes) {
      CommonService.animatedToast(
        'Total attachment size cannot exceed 25 MB',
        'error',
      );
      return;
    }

    final attachment = ComposeAttachment(
      fileName: fileName,
      fileType: fileType,
      serverPath: serverPath,
      sizeBytes: sizeBytes,
    );

    state = state.copyWith(
      attachments: [...state.attachments, attachment],
      totalAttachmentBytes: state.totalAttachmentBytes + sizeBytes,
      isDirty: true,
    );
    _startAutosaveTimer();
  }

  void removeAttachment(int index) {
    if (index < 0 || index >= state.attachments.length) return;
    final removed = state.attachments[index];
    final updated = List<ComposeAttachment>.from(state.attachments)
      ..removeAt(index);
    state = state.copyWith(
      attachments: updated,
      totalAttachmentBytes: state.totalAttachmentBytes - removed.sizeBytes,
      isDirty: true,
    );
    _startAutosaveTimer();
  }

  /// Pick and upload a file attachment. Handles both native and web platforms.
  Future<void> pickAndUploadFile() async {
    if (kIsWeb) {
      final file = await WebFilePickerService.pickFile();
      if (file == null) return;
      final bytes = file['bytes'] as Uint8List?;
      final name = file['name'] as String? ?? '';
      if (bytes == null || name.isEmpty) return;
      await _uploadAttachment(name, bytes.length, fileBytes: bytes);
    } else {
      final path = await FilePickerService.pickFile();
      if (path == null) return;
      final file = File(path);
      final size = await file.length();
      final name = path.split('/').last;
      await _uploadAttachment(name, size, filePath: path);
    }
  }

  /// Pick and upload an image from gallery. Native only.
  Future<void> pickAndUploadImage() async {
    if (kIsWeb) {
      final file = await WebFilePickerService.pickImageFile();
      if (file == null) return;
      final bytes = file['bytes'] as Uint8List?;
      final name = file['name'] as String? ?? '';
      if (bytes == null || name.isEmpty) return;
      await _uploadAttachment(name, bytes.length, fileBytes: bytes);
    } else {
      final path = await FilePickerService.pickImageFile();
      if (path == null) return;
      final file = File(path);
      final size = await file.length();
      final name = path.split('/').last;
      await _uploadAttachment(name, size, filePath: path);
    }
  }

  Future<void> _uploadAttachment(
    String fileName,
    int sizeBytes, {
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    // Size check
    if (state.totalAttachmentBytes + sizeBytes > _maxAttachmentBytes) {
      CommonService.animatedToast(
        'Total attachment size cannot exceed 25 MB',
        'error',
      );
      return;
    }

    // Add placeholder with uploading state
    final tempAttachment = ComposeAttachment(
      fileName: fileName,
      fileType: fileName.split('.').last,
      serverPath: '',
      sizeBytes: sizeBytes,
      isUploading: true,
    );
    final insertIndex = state.attachments.length;
    state = state.copyWith(
      attachments: [...state.attachments, tempAttachment],
      totalAttachmentBytes: state.totalAttachmentBytes + sizeBytes,
    );

    try {
      // Get signed URL
      final resp = await ApiService().post(
        'user/create-singed-url',
        {'location': '$bucketFolder$fileName'},
      );
      if (_disposed) return;

      if (resp['success'] != true || resp['data'] == null) {
        _removeAttachmentAtIndex(insertIndex);
        CommonService.animatedToast(
          resp['message'] as String? ?? 'Failed to get upload URL',
          'error',
        );
        return;
      }
      final signedModel = SignedUrlModel.fromJson(resp);

      // Upload to S3
      final request = http.Request('PUT', Uri.parse(signedModel.data.url));
      request.headers['Content-Length'] = '$sizeBytes';
      request.headers['Content-Type'] = 'application/octet-stream';

      if (fileBytes != null) {
        request.bodyBytes = fileBytes;
      } else if (filePath != null) {
        request.bodyBytes = await File(filePath).readAsBytes();
      }

      final response = await request.send();

      if (_disposed) return;

      if (response.statusCode == 200) {
        // Replace placeholder with completed attachment
        final completed = ComposeAttachment(
          fileName: fileName,
          fileType: fileName.split('.').last,
          serverPath: signedModel.data.fileName,
          sizeBytes: sizeBytes,
        );
        final updated = List<ComposeAttachment>.from(state.attachments);
        if (insertIndex < updated.length) {
          updated[insertIndex] = completed;
        }
        state = state.copyWith(attachments: updated, isDirty: true);
        _startAutosaveTimer();
      } else {
        _removeAttachmentAtIndex(insertIndex);
        CommonService.animatedToast('File upload failed', 'error');
      }
    } catch (e) {
      if (_disposed) return;
      _removeAttachmentAtIndex(insertIndex);
      CommonService.animatedToast('File upload failed', 'error');
      if (kDebugMode) debugPrint('[ComposeNotifier] upload error: $e');
    }
  }

  void _removeAttachmentAtIndex(int index) {
    if (index >= state.attachments.length) return;
    final removed = state.attachments[index];
    final updated = List<ComposeAttachment>.from(state.attachments)
      ..removeAt(index);
    state = state.copyWith(
      attachments: updated,
      totalAttachmentBytes: state.totalAttachmentBytes - removed.sizeBytes,
    );
  }

  // ── Autosave ──

  void _startAutosaveTimer() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 5), () {
      if (_disposed || !state.isDirty) return;
      _autoSave();
    });
  }

  /// Full autosave: sync cached content → local backup → server draft.
  Future<void> _autoSave() async {
    syncCachedContent();
    await autosaveToLocal();
    if (_disposed) return;

    if (state.draftId != null) {
      // Update existing server draft
      await saveDraftToServer(quiet: true);
    } else if (state.hasContent && !_creatingDraft) {
      // First meaningful edit — create draft on server
      await _createDraftOnServer();
    }
  }

  /// Create the initial server draft (called on first edit, not on compose open).
  Future<void> _createDraftOnServer() async {
    if (_creatingDraft || _disposed || state.draftId != null) return;
    _creatingDraft = true;
    try {
      final payload = _buildDraftPayload();
      final resp = await ApiService().post('email/draft', payload);
      if (_disposed) return;
      if (resp['success'] == true) {
        final draftId = resp['data']?['draftId'] as int?;
        state = state.copyWith(draftId: draftId, isDirty: false);
        _refreshCounts();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ComposeNotifier] create draft error: $e');
    } finally {
      _creatingDraft = false;
    }
  }

  Future<void> autosaveToLocal() async {
    try {
      final backup = {
        'mode': state.mode.name,
        'emailId': state.emailId,
        'draftId': state.draftId,
        'to': state.toRecipients,
        'cc': state.ccRecipients,
        'bcc': state.bccRecipients,
        'subject': state.subject,
        'bodyHtml': state.bodyHtml,
        'quotedHtml': state.quotedHtml,
        'attachments':
            state.attachments.map((a) => a.toServerJson()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };
      await _storage.writeObjectData(_localDraftKey, backup);
      if (!_disposed) {
        state = state.copyWith(hasLocalBackup: true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ComposeNotifier] autosave error: $e');
    }
  }

  /// Check if a local draft backup exists and return it (for recovery dialog).
  Future<Map<String, dynamic>?> getLocalDraftBackup() async {
    final backup = await _storage.readObjectData(_localDraftKey);
    if (backup == null) return null;

    // Expire backups older than 24 hours
    final savedAt = DateTime.tryParse(backup['savedAt'] as String? ?? '');
    if (savedAt != null &&
        DateTime.now().difference(savedAt).inHours > 24) {
      await _storage.deleteData(_localDraftKey);
      return null;
    }
    return backup;
  }

  /// Restore state from a local draft backup.
  void restoreFromBackup(Map<String, dynamic> backup) {
    final attachments =
        (backup['attachments'] as List<dynamic>? ?? []).map((a) {
      final map = a as Map<String, dynamic>;
      return ComposeAttachment(
        fileName: map['fileName'] as String? ?? '',
        fileType: map['type'] as String? ?? '',
        serverPath: map['path'] as String? ?? '',
        sizeBytes: (map['size'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    state = state.copyWith(
      mode: ComposeMode.fromString(backup['mode'] as String?),
      emailId: backup['emailId'] as int?,
      draftId: backup['draftId'] as int?,
      toRecipients: List<String>.from(backup['to'] ?? []),
      ccRecipients: List<String>.from(backup['cc'] ?? []),
      bccRecipients: List<String>.from(backup['bcc'] ?? []),
      showCcBcc: (backup['cc'] as List?)?.isNotEmpty == true ||
          (backup['bcc'] as List?)?.isNotEmpty == true,
      subject: backup['subject'] as String? ?? '',
      bodyHtml: backup['bodyHtml'] as String? ?? '',
      quotedHtml: backup['quotedHtml'] as String?,
      attachments: attachments,
      totalAttachmentBytes:
          attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes),
      isDirty: true,
      hasLocalBackup: true,
    );
  }

  Future<void> clearLocalDraftBackup() async {
    await _storage.deleteData(_localDraftKey);
    if (!_disposed) {
      state = state.copyWith(hasLocalBackup: false);
    }
  }

  // ── Draft save (server) ──

  /// Save draft to server. Pass [quiet] = true for background autosaves
  /// (no loading indicator, no error in state).
  Future<bool> saveDraftToServer({bool quiet = false}) async {
    syncCachedContent();

    if (!quiet) {
      state = state.copyWith(isSavingDraft: true, error: null);
    }

    try {
      final payload = _buildDraftPayload();

      Map<String, dynamic> resp;
      if (state.draftId != null) {
        resp = await ApiService().put(
          'email/draft/${state.draftId}',
          payload,
        );
      } else {
        resp = await ApiService().post('email/draft', payload);
      }

      if (_disposed) return false;

      if (resp['success'] == true) {
        final newDraftId = resp['data']?['draftId'] as int?;
        final isNewDraft = state.draftId == null && newDraftId != null;
        state = state.copyWith(
          draftId: newDraftId ?? state.draftId,
          isSavingDraft: false,
          isDirty: false,
        );
        await _storage.deleteData(_localDraftKey);
        state = state.copyWith(hasLocalBackup: false);
        if (isNewDraft) _refreshCounts();
        return true;
      } else {
        state = state.copyWith(
          isSavingDraft: false,
          error: quiet ? null : resp['message'] as String?,
        );
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        isSavingDraft: false,
        error: quiet ? null : 'Draft save failed',
      );
      return false;
    }
  }

  // ── Send ──

  Future<void> send({bool skipContactCheck = false}) async {
    // Client-side validation
    if (state.toRecipients.isEmpty) {
      state = state.copyWith(error: 'Please add at least one recipient');
      return;
    }

    // Recipient limit check
    final totalRecipients = state.toRecipients.length +
        state.ccRecipients.length +
        state.bccRecipients.length;
    if (totalRecipients > maxRecipientsPerEmail) {
      state = state.copyWith(
          error: 'Maximum $maxRecipientsPerEmail recipients per email');
      CommonService.animatedToast(
        'Maximum $maxRecipientsPerEmail recipients per email',
        'error',
      );
      return;
    }

    // Daily send limit check (client-side — server enforces independently)
    final todaySends = await _getTodaySendCount();
    if (todaySends >= maxDailySends) {
      state = state.copyWith(
          error: 'Daily send limit reached ($maxDailySends emails per day)');
      CommonService.animatedToast(
        'Daily send limit reached ($maxDailySends emails per day)',
        'error',
      );
      return;
    }

    // Save local backup first (insurance)
    await autosaveToLocal();

    state = state.copyWith(
      sendStatus: SendStatus.sending,
      error: null,
    );

    try {
      // Build payload
      final payload = {
        'to': state.toRecipients,
        'cc': state.ccRecipients,
        'bcc': state.bccRecipients,
        'subject': state.subject,
        'body': state.bodyHtml,
        'attachments':
            state.attachments.map((a) => a.toServerJson()).toList(),
        if (state.emailId != null) 'replyToEmailId': state.emailId,
        if (state.draftId != null) 'draftId': state.draftId,
        'type': state.mode.name,
        'skipContactCheck': skipContactCheck,
      };

      state = state.copyWith(sendStatus: SendStatus.confirming);
      final resp = await ApiService().post('email/send', payload);

      if (_disposed) return;

      if (resp['success'] == true) {
        // CONFIRMED sent
        final emailId = resp['data']?['emailId'] as int?;
        state = state.copyWith(
          sendStatus: SendStatus.sent,
          sentEmailId: emailId,
        );
        await _incrementSendCount();
        await _storage.deleteData(_localDraftKey);
        CommonService.animatedToast('Email sent', 'success');
        _refreshCounts();
      } else if (resp['data']?['unknownContacts'] != null) {
        // Server-side contact check — unknown contacts found.
        // Email was NOT sent. The UI layer will show the AddEmailModal
        // and re-call send(skipContactCheck: true) after resolution.
        final unknownContacts =
            List<String>.from(resp['data']['unknownContacts'] as List);
        state = state.copyWith(
          sendStatus: SendStatus.idle,
          error: 'unknownContacts:${jsonEncode(unknownContacts)}',
        );
      } else if (resp['data']?['failedRecipients'] != null) {
        // Partial success — internal recipients delivered, SES failed
        final failed =
            List<String>.from(resp['data']['failedRecipients'] as List);
        final emailId = resp['data']?['emailId'] as int?;
        state = state.copyWith(
          sendStatus: SendStatus.partialFailure,
          sentEmailId: emailId,
          failedRecipients: failed,
        );
        await _storage.deleteData(_localDraftKey);
        CommonService.animatedToast(
          'Sent, but delivery failed for: ${failed.join(", ")}',
          'warning',
        );
        _refreshCounts();
      } else {
        // Server rejected — save to drafts
        state = state.copyWith(
          sendStatus: SendStatus.failed,
          error: resp['message'] as String? ?? 'Failed to send email',
        );
        CommonService.animatedToast(
          resp['message'] as String? ??
              'Failed to send. Your draft has been saved.',
          'error',
        );
        await saveDraftToServer();
      }
    } catch (e) {
      if (_disposed) return;
      // Network/timeout error — save to drafts
      final draftSaved = await saveDraftToServer();
      if (!draftSaved) await autosaveToLocal();
      state = state.copyWith(
        sendStatus: SendStatus.failed,
        error: 'Send failed. Message saved to Drafts.',
      );
      CommonService.animatedToast(
        'Message could not be sent. Saved to Drafts.',
        'error',
      );
    }
  }

  // ── Discard draft ──

  /// Discard the current draft — deletes from server (soft-delete) and
  /// clears local backup. Sets [_discarded] so dispose won't re-save.
  Future<bool> discard() async {
    _discarded = true;
    _autosaveTimer?.cancel();

    if (state.draftId != null) {
      try {
        final resp = await ApiService().post('email/delete-drafts', {
          'draftIds': [state.draftId],
        });
        if (resp['success'] == true) {
          await _storage.deleteData(_localDraftKey);
          CommonService.animatedToast('Draft discarded', 'success', null, true);
          _refreshCounts();
          return true;
        } else {
          CommonService.animatedToast(
            resp['message'] as String? ?? 'Failed to discard draft',
            'error',
          );
          _discarded = false; // Allow dispose to save
          return false;
        }
      } catch (e) {
        if (e is! NoInternetException) {
          CommonService.animatedToast('Failed to discard draft', 'error');
        }
        _discarded = false;
        return false;
      }
    } else {
      // No server draft — just clear local backup
      await _storage.deleteData(_localDraftKey);
      return true;
    }
  }

  // ── Helpers ──

  // ── Daily send tracking (client-side) ──

  static String get _dailySendKey {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return 'daily_send_count_$today';
  }

  Future<int> _getTodaySendCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailySendKey) ?? 0;
  }

  Future<void> _incrementSendCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_dailySendKey) ?? 0;
    await prefs.setInt(_dailySendKey, current + 1);
  }

  void _refreshCounts() {
    final userId = state.userData?['user']?['id'];
    if (userId == null) return;
    _socket.emitEventWithAck(
      'unReadCount',
      {'userId': userId},
      ackCallback: (data) {
        if (data != null) {
          providerContainer.read(countProvider.notifier).updateCounts(
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
