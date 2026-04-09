import 'package:freezed_annotation/freezed_annotation.dart';

part 'compose_state.freezed.dart';

/// The mode of the compose screen — determines how fields are pre-filled
/// and which API endpoints are called.
enum ComposeMode {
  newMessage,
  reply,
  replyAll,
  forward,
  updateDraft;

  /// Parse from route extra string (e.g. 'reply', 'forward', 'compose').
  static ComposeMode fromString(String? value) {
    switch (value) {
      case 'reply':
        return ComposeMode.reply;
      case 'replyAll':
        return ComposeMode.replyAll;
      case 'forward':
        return ComposeMode.forward;
      case 'updateDraft':
      case 'draft':
        return ComposeMode.updateDraft;
      default:
        return ComposeMode.newMessage;
    }
  }

  bool get isReplyOrForward =>
      this == reply || this == replyAll || this == forward;
}

/// Send lifecycle states — drives UI (spinner, retry button, success toast).
enum SendStatus {
  idle,
  sending,
  confirming,
  sent,
  partialFailure,
  failed,
}

/// Parameters passed to the compose provider via the family key.
class ComposeParams {
  final ComposeMode mode;
  final int? emailId;
  final String? toEmail;
  final String? sourcePage;

  const ComposeParams({
    required this.mode,
    this.emailId,
    this.toEmail,
    this.sourcePage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComposeParams &&
          mode == other.mode &&
          emailId == other.emailId &&
          toEmail == other.toEmail &&
          sourcePage == other.sourcePage;

  @override
  int get hashCode => Object.hash(mode, emailId, toEmail, sourcePage);
}

/// A single attachment in the compose form.
@freezed
abstract class ComposeAttachment with _$ComposeAttachment {
  const factory ComposeAttachment({
    required String fileName,
    required String fileType,
    required String serverPath,
    required int sizeBytes,
    @Default(false) bool isUploading,
    @Default(0.0) double uploadProgress,
    String? error,
  }) = _ComposeAttachment;

  const ComposeAttachment._();

  /// Serialize for the draft/send REST payload.
  Map<String, dynamic> toServerJson() => {
        'fileName': fileName,
        'type': fileType,
        'path': serverPath,
        'size': sizeBytes,
      };
}

/// Immutable state for the compose screen.
@freezed
abstract class ComposeState with _$ComposeState {
  const factory ComposeState({
    // Mode
    @Default(ComposeMode.newMessage) ComposeMode mode,
    int? emailId,
    int? draftId,

    // Recipients
    @Default([]) List<String> toRecipients,
    @Default([]) List<String> ccRecipients,
    @Default([]) List<String> bccRecipients,
    @Default(false) bool showCcBcc,

    // Content
    @Default('') String subject,
    @Default('') String bodyHtml,
    String? quotedHtml,

    // Sender
    @Default('') String fromEmail,
    @Default('') String fromName,

    // Attachments
    @Default([]) List<ComposeAttachment> attachments,
    @Default(0) int totalAttachmentBytes,

    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool isSending,
    @Default(false) bool isSavingDraft,
    @Default(false) bool isDirty,
    @Default(false) bool hasLocalBackup,

    // Send lifecycle
    @Default(SendStatus.idle) SendStatus sendStatus,
    int? sentEmailId,
    @Default([]) List<String> failedRecipients,

    // Error
    String? error,

    // User data
    Map<String, dynamic>? userData,
    @Default('') String token,
  }) = _ComposeState;

  const ComposeState._();

  // ── Computed properties ──

  bool get canSend =>
      toRecipients.isNotEmpty && !isSending && !isLoading;

  bool get canSaveDraft => isDirty || mode == ComposeMode.newMessage;

  bool get hasContent =>
      toRecipients.isNotEmpty ||
      subject.isNotEmpty ||
      bodyHtml.isNotEmpty ||
      attachments.isNotEmpty;

  bool get isOverSizeLimit =>
      totalAttachmentBytes > 25 * 1024 * 1024; // 25 MB

  int get attachmentCount => attachments.length;

  bool get hasFailedRecipients => failedRecipients.isNotEmpty;
}
