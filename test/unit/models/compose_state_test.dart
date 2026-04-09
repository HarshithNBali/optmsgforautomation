// Implements: TC-DISC-COMPOSE-001 through TC-DISC-COMPOSE-040
// Source: lib/screens/compose/compose_riverpod/compose_state.dart
//         lib/constant/app_config.dart (SendLimits)
// Coverage target: 95%+ (critical — compose state drives entire compose feature)
// Bugs found: none

import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/constant/app_config.dart';

void main() {
  // ── ComposeMode ──

  group('ComposeMode.fromString', () {
    test('should return reply for "reply"', () {
      expect(ComposeMode.fromString('reply'), ComposeMode.reply);
    });

    test('should return replyAll for "replyAll"', () {
      expect(ComposeMode.fromString('replyAll'), ComposeMode.replyAll);
    });

    test('should return forward for "forward"', () {
      expect(ComposeMode.fromString('forward'), ComposeMode.forward);
    });

    test('should return updateDraft for "updateDraft"', () {
      expect(ComposeMode.fromString('updateDraft'), ComposeMode.updateDraft);
    });

    test('should return updateDraft for "draft"', () {
      expect(ComposeMode.fromString('draft'), ComposeMode.updateDraft);
    });

    test('should return newMessage for null', () {
      expect(ComposeMode.fromString(null), ComposeMode.newMessage);
    });

    test('should return newMessage for unknown string', () {
      expect(ComposeMode.fromString('compose'), ComposeMode.newMessage);
      expect(ComposeMode.fromString(''), ComposeMode.newMessage);
      expect(ComposeMode.fromString('garbage'), ComposeMode.newMessage);
    });
  });

  group('ComposeMode.isReplyOrForward', () {
    test('should be true for reply', () {
      expect(ComposeMode.reply.isReplyOrForward, isTrue);
    });

    test('should be true for replyAll', () {
      expect(ComposeMode.replyAll.isReplyOrForward, isTrue);
    });

    test('should be true for forward', () {
      expect(ComposeMode.forward.isReplyOrForward, isTrue);
    });

    test('should be false for newMessage', () {
      expect(ComposeMode.newMessage.isReplyOrForward, isFalse);
    });

    test('should be false for updateDraft', () {
      expect(ComposeMode.updateDraft.isReplyOrForward, isFalse);
    });
  });

  // ── ComposeParams ──

  group('ComposeParams', () {
    test('should have correct default values', () {
      const params = ComposeParams(mode: ComposeMode.newMessage);
      expect(params.mode, ComposeMode.newMessage);
      expect(params.emailId, isNull);
      expect(params.toEmail, isNull);
      expect(params.sourcePage, isNull);
    });

    test('should store all provided values', () {
      const params = ComposeParams(
        mode: ComposeMode.reply,
        emailId: 42,
        toEmail: 'test@optmsg.com',
        sourcePage: 'inbox',
      );
      expect(params.mode, ComposeMode.reply);
      expect(params.emailId, 42);
      expect(params.toEmail, 'test@optmsg.com');
      expect(params.sourcePage, 'inbox');
    });

    test('should be equal when all fields match', () {
      const a = ComposeParams(
        mode: ComposeMode.forward,
        emailId: 10,
        toEmail: 'x@y.com',
        sourcePage: 'draft',
      );
      const b = ComposeParams(
        mode: ComposeMode.forward,
        emailId: 10,
        toEmail: 'x@y.com',
        sourcePage: 'draft',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal when mode differs', () {
      const a = ComposeParams(mode: ComposeMode.newMessage);
      const b = ComposeParams(mode: ComposeMode.reply);
      expect(a, isNot(equals(b)));
    });

    test('should not be equal when emailId differs', () {
      const a = ComposeParams(mode: ComposeMode.newMessage, emailId: 1);
      const b = ComposeParams(mode: ComposeMode.newMessage, emailId: 2);
      expect(a, isNot(equals(b)));
    });

    test('should not be equal when toEmail differs', () {
      const a = ComposeParams(mode: ComposeMode.newMessage, toEmail: 'a@b.com');
      const b = ComposeParams(mode: ComposeMode.newMessage, toEmail: 'c@d.com');
      expect(a, isNot(equals(b)));
    });

    test('should not be equal when sourcePage differs', () {
      const a =
          ComposeParams(mode: ComposeMode.newMessage, sourcePage: 'inbox');
      const b =
          ComposeParams(mode: ComposeMode.newMessage, sourcePage: 'archive');
      expect(a, isNot(equals(b)));
    });

    test('should be equal to itself (identity)', () {
      const a = ComposeParams(mode: ComposeMode.newMessage);
      expect(a, equals(a));
    });

    test('should not be equal to a different type', () {
      const a = ComposeParams(mode: ComposeMode.newMessage);
      expect(a, isNot(equals('not a ComposeParams')));
    });
  });

  // ── ComposeAttachment ──

  group('ComposeAttachment', () {
    test('should create with required fields', () {
      const a = ComposeAttachment(
        fileName: 'doc.pdf',
        fileType: 'pdf',
        serverPath: 'email/doc.pdf',
        sizeBytes: 1024,
      );
      expect(a.fileName, 'doc.pdf');
      expect(a.fileType, 'pdf');
      expect(a.serverPath, 'email/doc.pdf');
      expect(a.sizeBytes, 1024);
      expect(a.isUploading, isFalse);
      expect(a.uploadProgress, 0.0);
      expect(a.error, isNull);
    });

    test('should create with optional fields', () {
      const a = ComposeAttachment(
        fileName: 'img.png',
        fileType: 'png',
        serverPath: '',
        sizeBytes: 500,
        isUploading: true,
        uploadProgress: 0.5,
        error: 'upload failed',
      );
      expect(a.isUploading, isTrue);
      expect(a.uploadProgress, 0.5);
      expect(a.error, 'upload failed');
    });

    test('toServerJson should produce correct map', () {
      const a = ComposeAttachment(
        fileName: 'report.xlsx',
        fileType: 'xlsx',
        serverPath: 'email/report.xlsx',
        sizeBytes: 2048,
      );
      final json = a.toServerJson();
      expect(json, {
        'fileName': 'report.xlsx',
        'type': 'xlsx',
        'path': 'email/report.xlsx',
        'size': 2048,
      });
    });

    test('toServerJson should handle empty serverPath', () {
      const a = ComposeAttachment(
        fileName: 'temp.txt',
        fileType: 'txt',
        serverPath: '',
        sizeBytes: 10,
      );
      expect(a.toServerJson()['path'], '');
    });

    test('copyWith should create modified copy', () {
      const original = ComposeAttachment(
        fileName: 'a.pdf',
        fileType: 'pdf',
        serverPath: 'email/a.pdf',
        sizeBytes: 100,
        isUploading: true,
      );
      final completed = original.copyWith(
        isUploading: false,
        serverPath: 'email/uploaded_a.pdf',
      );
      expect(completed.isUploading, isFalse);
      expect(completed.serverPath, 'email/uploaded_a.pdf');
      expect(completed.fileName, 'a.pdf'); // unchanged
      expect(completed.sizeBytes, 100); // unchanged
    });

    test('should support equality via Freezed', () {
      const a = ComposeAttachment(
        fileName: 'a.pdf',
        fileType: 'pdf',
        serverPath: 'path',
        sizeBytes: 100,
      );
      const b = ComposeAttachment(
        fileName: 'a.pdf',
        fileType: 'pdf',
        serverPath: 'path',
        sizeBytes: 100,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal when fields differ', () {
      const a = ComposeAttachment(
        fileName: 'a.pdf',
        fileType: 'pdf',
        serverPath: 'path',
        sizeBytes: 100,
      );
      const b = ComposeAttachment(
        fileName: 'b.pdf',
        fileType: 'pdf',
        serverPath: 'path',
        sizeBytes: 100,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ── ComposeState ──

  group('ComposeState defaults', () {
    test('should have correct default values', () {
      const s = ComposeState();
      expect(s.mode, ComposeMode.newMessage);
      expect(s.emailId, isNull);
      expect(s.draftId, isNull);
      expect(s.toRecipients, isEmpty);
      expect(s.ccRecipients, isEmpty);
      expect(s.bccRecipients, isEmpty);
      expect(s.showCcBcc, isFalse);
      expect(s.subject, '');
      expect(s.bodyHtml, '');
      expect(s.quotedHtml, isNull);
      expect(s.fromEmail, '');
      expect(s.fromName, '');
      expect(s.attachments, isEmpty);
      expect(s.totalAttachmentBytes, 0);
      expect(s.isLoading, isFalse);
      expect(s.isSending, isFalse);
      expect(s.isSavingDraft, isFalse);
      expect(s.isDirty, isFalse);
      expect(s.hasLocalBackup, isFalse);
      expect(s.sendStatus, SendStatus.idle);
      expect(s.sentEmailId, isNull);
      expect(s.failedRecipients, isEmpty);
      expect(s.error, isNull);
      expect(s.userData, isNull);
      expect(s.token, '');
    });
  });

  group('ComposeState.canSend', () {
    test('should be false when no recipients', () {
      const s = ComposeState();
      expect(s.canSend, isFalse);
    });

    test('should be true when has recipients and not loading/sending', () {
      const s = ComposeState(toRecipients: ['a@b.com']);
      expect(s.canSend, isTrue);
    });

    test('should be false when isSending is true', () {
      const s = ComposeState(toRecipients: ['a@b.com'], isSending: true);
      expect(s.canSend, isFalse);
    });

    test('should be false when isLoading is true', () {
      const s = ComposeState(toRecipients: ['a@b.com'], isLoading: true);
      expect(s.canSend, isFalse);
    });

    test('should be false when both isSending and isLoading', () {
      const s = ComposeState(
        toRecipients: ['a@b.com'],
        isSending: true,
        isLoading: true,
      );
      expect(s.canSend, isFalse);
    });
  });

  group('ComposeState.canSaveDraft', () {
    test('should be true when isDirty', () {
      const s = ComposeState(isDirty: true);
      expect(s.canSaveDraft, isTrue);
    });

    test('should be true when mode is newMessage even if not dirty', () {
      const s = ComposeState(mode: ComposeMode.newMessage, isDirty: false);
      expect(s.canSaveDraft, isTrue);
    });

    test('should be false when not dirty and not newMessage mode', () {
      const s = ComposeState(mode: ComposeMode.reply, isDirty: false);
      expect(s.canSaveDraft, isFalse);
    });
  });

  group('ComposeState.hasContent', () {
    test('should be false when completely empty', () {
      const s = ComposeState();
      expect(s.hasContent, isFalse);
    });

    test('should be true when has recipients', () {
      const s = ComposeState(toRecipients: ['a@b.com']);
      expect(s.hasContent, isTrue);
    });

    test('should be true when has subject', () {
      const s = ComposeState(subject: 'Hello');
      expect(s.hasContent, isTrue);
    });

    test('should be true when has body', () {
      const s = ComposeState(bodyHtml: '<p>Content</p>');
      expect(s.hasContent, isTrue);
    });

    test('should be true when has attachments', () {
      const s = ComposeState(attachments: [
        ComposeAttachment(
          fileName: 'a.pdf',
          fileType: 'pdf',
          serverPath: 'p',
          sizeBytes: 1,
        ),
      ]);
      expect(s.hasContent, isTrue);
    });
  });

  group('ComposeState.isOverSizeLimit', () {
    test('should be false when under 25 MB', () {
      const s = ComposeState(totalAttachmentBytes: 24 * 1024 * 1024);
      expect(s.isOverSizeLimit, isFalse);
    });

    test('should be false when exactly at 25 MB', () {
      const s = ComposeState(totalAttachmentBytes: 25 * 1024 * 1024);
      expect(s.isOverSizeLimit, isFalse);
    });

    test('should be true when over 25 MB', () {
      const s = ComposeState(totalAttachmentBytes: 25 * 1024 * 1024 + 1);
      expect(s.isOverSizeLimit, isTrue);
    });

    test('should be false when zero', () {
      const s = ComposeState();
      expect(s.isOverSizeLimit, isFalse);
    });
  });

  group('ComposeState.attachmentCount', () {
    test('should be 0 when empty', () {
      const s = ComposeState();
      expect(s.attachmentCount, 0);
    });

    test('should count attachments correctly', () {
      const s = ComposeState(attachments: [
        ComposeAttachment(
            fileName: 'a', fileType: 'a', serverPath: '', sizeBytes: 1),
        ComposeAttachment(
            fileName: 'b', fileType: 'b', serverPath: '', sizeBytes: 2),
        ComposeAttachment(
            fileName: 'c', fileType: 'c', serverPath: '', sizeBytes: 3),
      ]);
      expect(s.attachmentCount, 3);
    });
  });

  group('ComposeState.hasFailedRecipients', () {
    test('should be false when empty', () {
      const s = ComposeState();
      expect(s.hasFailedRecipients, isFalse);
    });

    test('should be true when has failed recipients', () {
      const s = ComposeState(failedRecipients: ['bad@email.com']);
      expect(s.hasFailedRecipients, isTrue);
    });
  });

  group('ComposeState.copyWith', () {
    test('should update specified fields and preserve others', () {
      const original = ComposeState(
        mode: ComposeMode.newMessage,
        subject: 'Original',
        toRecipients: ['a@b.com'],
      );
      final updated = original.copyWith(
        subject: 'Updated',
        isDirty: true,
      );
      expect(updated.subject, 'Updated');
      expect(updated.isDirty, isTrue);
      expect(updated.toRecipients, ['a@b.com']); // preserved
      expect(updated.mode, ComposeMode.newMessage); // preserved
    });
  });

  // ── SendStatus ──

  group('SendStatus', () {
    test('should have all expected values', () {
      expect(SendStatus.values, hasLength(6));
      expect(SendStatus.values, contains(SendStatus.idle));
      expect(SendStatus.values, contains(SendStatus.sending));
      expect(SendStatus.values, contains(SendStatus.confirming));
      expect(SendStatus.values, contains(SendStatus.sent));
      expect(SendStatus.values, contains(SendStatus.partialFailure));
      expect(SendStatus.values, contains(SendStatus.failed));
    });
  });

  // ── SendLimits ──

  group('SendLimits', () {
    setUp(() {
      // Reset to defaults before each test
      SendLimits.maxRecipientsPerEmail = 100;
      SendLimits.maxDailySends = 250;
    });

    test('should have correct compile-time defaults', () {
      expect(SendLimits.maxRecipientsPerEmail, 100);
      expect(SendLimits.maxDailySends, 250);
    });

    test('updateFromServer should update values from server payload', () {
      SendLimits.updateFromServer({
        'maxRecipientsPerEmail': 50,
        'maxDailySendsPerUser': 100,
      });
      expect(SendLimits.maxRecipientsPerEmail, 50);
      expect(SendLimits.maxDailySends, 100);
    });

    test('updateFromServer should handle null payload', () {
      SendLimits.updateFromServer(null);
      expect(SendLimits.maxRecipientsPerEmail, 100);
      expect(SendLimits.maxDailySends, 250);
    });

    test('updateFromServer should ignore non-int values', () {
      SendLimits.updateFromServer({
        'maxRecipientsPerEmail': 'not a number',
        'maxDailySendsPerUser': 3.14,
      });
      expect(SendLimits.maxRecipientsPerEmail, 100);
      expect(SendLimits.maxDailySends, 250);
    });

    test('updateFromServer should handle partial payload', () {
      SendLimits.updateFromServer({
        'maxRecipientsPerEmail': 75,
      });
      expect(SendLimits.maxRecipientsPerEmail, 75);
      expect(SendLimits.maxDailySends, 250); // unchanged
    });

    test('updateFromServer should handle empty map', () {
      SendLimits.updateFromServer({});
      expect(SendLimits.maxRecipientsPerEmail, 100);
      expect(SendLimits.maxDailySends, 250);
    });

    test('convenience getters should reflect SendLimits values', () {
      SendLimits.maxRecipientsPerEmail = 42;
      SendLimits.maxDailySends = 99;
      expect(maxRecipientsPerEmail, 42);
      expect(maxDailySends, 99);
    });
  });
}
