/// Test data factories for creating model instances with sensible defaults.
///
/// Every `make*` function returns a valid instance with optional named
/// overrides so tests can customise only the fields they care about.
///
/// Usage:
/// ```dart
/// final user = makeUser(firstName: 'Jane', isSubscribed: true);
/// final loginJson = makeLoginJson(userId: 42);
/// ```
library;

// ---------------------------------------------------------------------------
// JSON factories — produce raw Map<String, dynamic> payloads that can be
// fed directly to `Model.fromJson()`. This avoids coupling tests to the
// constructor while exercising the deserialization path.
// ---------------------------------------------------------------------------

/// Produces a valid User JSON map (as returned by the API).
Map<String, dynamic> makeUserJson({
  int id = 1,
  String firstName = 'Test',
  String lastName = 'User',
  String userName = 'testuser',
  String? otp,
  String dob = '1990-01-01',
  String countryCode = '+1',
  String mobile = '5551234567',
  bool isSubscribed = true,
  int? subscriptionEndDate,
  int? subscriptionStartDate,
  String? deviceToken,
  int? authTokenIssuedAt,
  bool isNotification = true,
  bool? contactSynch,
  bool isAcceptTerms = true,
  bool sortLastName = false,
  bool isSuspended = false,
  bool isDeleted = false,
  String created = '2024-01-01T00:00:00.000Z',
  String updated = '2024-01-01T00:00:00.000Z',
  String boardingSteps = 'completed',
  bool? webauth,
  bool? isFreeUser = false,
  bool isBiomatrix = false,
  bool isDeviceBiometrics = false,
}) {
  return {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'userName': userName,
    'otp': otp,
    'dob': dob,
    'countryCode': countryCode,
    'mobile': mobile,
    'isSubscribed': isSubscribed,
    'subscriptionEndDate': subscriptionEndDate,
    'subscriptionStartDate': subscriptionStartDate,
    'deviceToken': deviceToken,
    'authTokenIssuedAt': authTokenIssuedAt,
    'platform': null,
    'isNotification': isNotification,
    'contactSynch': contactSynch,
    'isAcceptTerms': isAcceptTerms,
    'sortLastName': sortLastName,
    'isSuspended': isSuspended,
    'isDeleted': isDeleted,
    'created': created,
    'updated': updated,
    'boardingSteps': boardingSteps,
    'webauth': webauth,
    'isFreeUser': isFreeUser,
    'isBiomatrix': isBiomatrix,
    'isDeviceBiometrics': isDeviceBiometrics,
  };
}

/// Produces a valid LoginModel JSON response.
Map<String, dynamic> makeLoginJson({
  bool success = true,
  String message = 'Login successful',
  String token = 'test-jwt-token-123',
  Map<String, dynamic>? userJson,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'user': userJson ?? makeUserJson(),
      'token': token,
    },
  };
}

/// Produces a valid Sender JSON map.
Map<String, dynamic> makeSenderJson({
  int? id = 1,
  String? firstName = 'Sender',
  String? lastName = 'Name',
  String? created = '2024-01-01T00:00:00.000Z',
}) {
  return {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'created': created,
  };
}

/// Produces a valid Email JSON map (inside an inbox item).
Map<String, dynamic> makeEmailJson({
  int id = 100,
  int? senderId = 2,
  String senderEmail = 'sender@test.com',
  String subject = 'Test Subject',
  String message = '<p>Test message</p>',
  String? messageText = 'Test message',
  String created = '2024-06-15T10:30:00.000Z',
  List<Map<String, dynamic>>? attachments,
  Map<String, dynamic>? sender,
}) {
  return {
    'id': id,
    'senderId': senderId,
    'senderEmail': senderEmail,
    'subject': subject,
    'message': message,
    'messageText': messageText,
    'created': created,
    'attachments': attachments ?? [],
    'sender': sender ?? makeSenderJson(),
  };
}

/// Produces a valid Emails (inbox list item) JSON map.
Map<String, dynamic> makeInboxEmailJson({
  int id = 1,
  int emailId = 100,
  int receiverId = 1,
  bool isRead = false,
  Map<String, dynamic>? email,
  List<Map<String, dynamic>>? emailRecipientTags,
}) {
  return {
    'id': id,
    'emailId': emailId,
    'draftId': null,
    'receiverId': receiverId,
    'isRead': isRead,
    'email': email ?? makeEmailJson(id: emailId),
    'emailRecipientTags': emailRecipientTags ?? [],
  };
}

/// Produces a valid InboxListModel JSON response.
Map<String, dynamic> makeInboxListJson({
  bool success = true,
  String message = '',
  List<Map<String, dynamic>>? emails,
  bool nextPage = false,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'emails': emails ?? [makeInboxEmailJson()],
      'nextPage': nextPage,
    },
  };
}

/// Produces a valid Tag JSON map.
Map<String, dynamic> makeTagJson({
  int id = 1,
  String tag = 'Important',
}) {
  return {
    'id': id,
    'tag': tag,
  };
}

/// Produces a valid EmailRecipientTags JSON map.
Map<String, dynamic> makeEmailRecipientTagJson({
  int id = 1,
  int tagId = 1,
  int emailRecipientsId = 1,
  Map<String, dynamic>? tag,
}) {
  return {
    'id': id,
    'tagId': tagId,
    'emailRecipientsId': emailRecipientsId,
    'tag': tag ?? makeTagJson(id: tagId),
  };
}

/// Produces a valid MyProfile JSON response.
Map<String, dynamic> makeProfileJson({
  bool success = true,
  String message = 'Profile fetched',
  int id = 1,
  String firstName = 'Test',
  String lastName = 'User',
  String userName = 'testuser',
  String dob = '1990-01-01',
  String countryCode = '+1',
  String mobile = '5551234567',
  bool isSubscribed = true,
  bool isNotification = true,
  bool isAcceptTerms = true,
  bool isSuspended = false,
  bool isDeleted = false,
  String created = '2024-01-01T00:00:00.000Z',
  String updated = '2024-01-01T00:00:00.000Z',
  bool isBiomatrix = false,
  bool isDeviceBiometrics = false,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'otp': null,
      'dob': dob,
      'countryCode': countryCode,
      'mobile': mobile,
      'isSubscribed': isSubscribed,
      'deviceToken': null,
      'authTokenIssuedAt': null,
      'platform': null,
      'isNotification': isNotification,
      'isAcceptTerms': isAcceptTerms,
      'isSuspended': isSuspended,
      'isDeleted': isDeleted,
      'created': created,
      'updated': updated,
      'isBiomatrix': isBiomatrix,
      'isDeviceBiometrics': isDeviceBiometrics,
    },
  };
}

/// Produces a valid Attachment JSON map.
Map<String, dynamic> makeAttachmentJson({
  int id = 1,
  String? type,
  String? path,
  String? draftId,
}) {
  return {
    'id': id,
    'type': type,
    'path': path,
    'draftId': draftId,
  };
}

/// Produces a valid Plans JSON map.
Map<String, dynamic> makePlanJson({
  int id = 1,
  String title = 'Pro Plan',
  dynamic charge = 999,
  String type = 'paid',
  int chargeFrequency = 30,
  String? stripeProductId = 'prod_test123',
  String? stripeProductPriceId = 'price_test123',
  String description = 'Full access plan',
  List<String> features = const ['Feature 1', 'Feature 2'],
  String nextPaymentDate = '2025-01-01',
}) {
  return {
    'id': id,
    'title': title,
    'charge': charge,
    'type': type,
    'chargeFrequency': chargeFrequency,
    'stripeProductId': stripeProductId,
    'stripeProductPriceId': stripeProductPriceId,
    'description': description,
    'features': features,
    'nextPaymentDate': nextPaymentDate,
  };
}

/// Produces a valid PlanListModel JSON response.
Map<String, dynamic> makePlanListJson({
  bool success = true,
  String message = 'Plans fetched',
  List<Map<String, dynamic>>? plans,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'plans': plans ?? [makePlanJson()],
    },
  };
}

/// Produces a generic API success response envelope.
Map<String, dynamic> makeSuccessResponse({
  String message = 'Success',
  Map<String, dynamic>? data,
}) {
  return {
    'success': true,
    'message': message,
    'data': data ?? {},
  };
}

/// Produces a generic API error response envelope.
Map<String, dynamic> makeErrorResponse({
  String message = 'Something went wrong',
  int? statusCode,
}) {
  return {
    'success': false,
    'message': message,
    'statusCode': ?statusCode,
  };
}

/// Produces an API error response with field-level errors.
Map<String, dynamic> makeFieldErrorResponse({
  List<Map<String, dynamic>>? errors,
}) {
  return {
    'success': false,
    'errors': errors ??
        [
          {'field': 'email', 'message': 'Email is required'},
        ],
  };
}
