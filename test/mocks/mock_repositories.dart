/// Mock classes for repository layer.
///
/// Repositories are the API boundary — mock these when testing notifiers
/// to avoid hitting real HTTP endpoints.
library;

import 'package:mocktail/mocktail.dart';
import 'package:optmsg/repositories/email/inbox_api.dart';
import 'package:optmsg/repositories/inbox/email_detail_repository.dart';
import 'package:optmsg/repositories/setting/setting_api.dart';
import 'package:optmsg/repositories/email/archive_api.dart';
import 'package:optmsg/repositories/email/draft_api.dart';
import 'package:optmsg/repositories/contact/contact_api.dart';
import 'package:optmsg/repositories/tags/tag_api.dart';
import 'package:optmsg/repositories/auth/auth_api.dart';
import 'package:optmsg/repositories/notification/notification_api.dart';
import 'package:optmsg/repositories/account/account_api.dart';

// ---------------------------------------------------------------------------
// Repository mocks
// ---------------------------------------------------------------------------

class MockInboxApi extends Mock implements InboxApi {}

class MockEmailDetailRepository extends Mock
    implements EmailDetailRepository {}

class MockSettingApi extends Mock implements SettingApi {}

class MockArchiveApi extends Mock implements ArchiveApi {}

class MockDraftApi extends Mock implements DraftApi {}

class MockContactApi extends Mock implements ContactApi {}

class MockTagApi extends Mock implements TagApi {}

class MockAuthApi extends Mock implements AuthApi {}

class MockNotificationApi extends Mock implements NotificationApi {}

class MockAccountApi extends Mock implements AccountApi {}
