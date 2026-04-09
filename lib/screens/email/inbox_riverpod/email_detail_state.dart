import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:optmsg/model/view_email_model.dart';

part 'email_detail_state.freezed.dart';

/// Immutable state model for email detail view using Freezed.
///
/// This replaces the manual copyWith implementation with Freezed's
/// code generation for compile-time safety and less boilerplate.
@freezed
abstract class EmailDetailState with _$EmailDetailState {
  const factory EmailDetailState({
    @Default(false) bool isLoading,
    ViewEmailModel? emailData,
    @Default(false) bool showTagList,
    @Default(false) bool showMenuOptions,
    @Default(false) bool showAllAttachments,
    @Default(false) bool markedAsUnread,
    @Default(false) bool movedToArchive,
    @Default(false) bool movedToTrash,
    @Default([]) List<EmailRecipientTags> updatedTags,
    String? error,
    Map<String, dynamic>? userData,
    @Default('') String token,
    @Default(false) bool newNotification,
    @Default(false) bool fileDownloading,
    @Default(0.0) double downloadProgress,
    @Default(false) bool expandedView,
  }) = _EmailDetailState;

  // Private constructor for adding custom methods
  const EmailDetailState._();

  /// Computed properties for better readability
  bool get hasEmail => emailData != null;
  Email? get email => emailData?.data.email;
  List<Attachments> get attachments => email?.attachments ?? [];
  bool get hasAttachments => attachments.isNotEmpty;
  String get senderEmail => email?.senderEmail ?? '';
  String get subject => email?.subject ?? '';
  String get htmlContent => email?.message ?? '';
  bool get hasError => error != null;
  bool get canPerformActions => hasEmail && !isLoading;
  int get attachmentCount => attachments.length;

  /// Get email recipient tags from the first receiver (current user)
  List<EmailRecipientTags> get emailTags {
    final receivers = email?.receivers;
    if (receivers != null && receivers.isNotEmpty) {
      return receivers.first.emailRecipientTags ?? [];
    }
    return [];
  }
}
