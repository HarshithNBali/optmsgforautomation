import '../../constant/app_config.dart' as app_config;

class EndPoint {
  final String base;
  final String path;

  EndPoint({required this.base, required this.path});
}

// M-15: Consolidated to use app_config.dart (compile-time) as the single
// source of truth. The previous runtime AppEnvironment-based resolution
// has been removed to eliminate the sync risk and dev-port mismatch.
class EndPoints {
  static String get api {
    return '/api'; // Same for all environments
  }

  /// Host authority derived from compile-time [app_config.defaultBaseUrl].
  /// Used by [BaseAPIService] for [Uri.https] construction.
  static String get base {
    final uri = Uri.parse(app_config.defaultBaseUrl);
    // Include port if present (non-standard HTTPS port)
    return uri.hasPort && uri.port != 443
        ? '${uri.host}:${uri.port}'
        : uri.host;
  }

  /// Delegates to the compile-time [app_config.defaultBaseUrl].
  static String get baseUrl => app_config.defaultBaseUrl;

  /// Delegates to the compile-time [app_config.contactBaseUrl].
  static String get contactBaseUrl => app_config.contactBaseUrl;

  static const String success = "success";
  static const int code = 200;
  static const int insert = 201;
  static const int verifyCode = 0;
  static const int loginCode = 1;
  static const int signupCode = 2;

  // Removed leading slashes to prevent double slash with baseUrl
  static const auth = 'auth/';
  static const email = 'email/';
  static const contact = 'contact/';
  static const user = 'user/';

  //verify user
  static EndPoint get userVerify =>
      _getEndPointWithPath('${auth}descope-login-step-first');
  //login
  static EndPoint get login => _getEndPointWithPath('${auth}descope-login');
  //resend OTP
  static EndPoint get resenOTP => _getEndPointWithPath('${auth}resend-otp');
  //Verify  OTP
  static EndPoint get verifyOTP => _getEndPointWithPath('${auth}verify-otp');
  //get Draft Emails
  static EndPoint get getDraftEmail =>
      _getEndPointWithPath('${email}drafts-list');
  //delete draft
  static EndPoint get deleteDraft =>
      _getEndPointWithPath('${email}delete-drafts');
  //permanently delete trashed drafts
  static EndPoint get permanentlyDeleteDrafts =>
      _getEndPointWithPath('${email}permanently-delete-drafts');
  //restore trashed draft (append $id/restore)
  static String get restoreDraftBase => '${email}draft/';
  //trash-archive_riverpod-listv2
  static EndPoint get getTrash =>
      _getEndPointWithPath('${email}trash-archive-listv2');
  //sent-list
  static EndPoint get getSentMails => _getEndPointWithPath('${email}sent-list');
  //update-email-status
  static EndPoint get updateEmailStatus =>
      _getEndPointWithPath('${email}update-email-status');

  //tags-list
  static EndPoint get getTagsList => _getEndPointWithPath('${email}tags');
  //add-tags
  static EndPoint get addTags => _getEndPointWithPath('${email}add-tags');
  //edit-tag
  static EndPoint get editTag => _getEndPointWithPath('${email}edit-tag');
  //delete-tag
  static EndPoint get deleteTag => _getEndPointWithPath('${email}delete-tag');
  //get inbox emails
  static EndPoint get getInboxEmails => _getEndPointWithPath('${email}listv2');
  //get email tags
  static EndPoint get getEmailTags =>
      _getEndPointWithPath('${email}emails-tags');
  //contact upload
  // Kept global for now, but removed leading slash on contact constant
  static EndPoint get contactUpload => _getEndPointWithPath('${contact}upload');
  //check-email
  static EndPoint get checkEmail =>
      _getEndPointWithPath('${contact}check-email');

  //toggle-contact-synch
  static EndPoint get contactUploadToggleContactSync =>
      _getEndPointWithPath('${user}toggle-contact-synch');

  //contact/listv2
  static EndPoint get getContactList =>
      _getEndPointWithPath('${contact}listv2');
  //contact/details
  static EndPoint get getContactDetails =>
      _getEndPointWithPath('${contact}details');
  //contact/delete
  static EndPoint get contactDelete => _getEndPointWithPath('${contact}delete');
  // contact/add-delete-email
  static EndPoint get addDeleteEmail =>
      _getEndPointWithPath('${contact}add-delete-email');
  // contact/edit-contact
  static EndPoint get editContact =>
      _getEndPointWithPath('${contact}edit-contact');
  //contact/add-contact
  static EndPoint get addContact => _getEndPointWithPath('${contact}add');
  //notification
  static EndPoint get getNotification =>
      _getEndPointWithPath('${user}notification');
  //notification-delete
  static EndPoint get notificationDelete =>
      _getEndPointWithPath('${user}notification-delete');
  //notification-read
  static EndPoint get notificationRead =>
      _getEndPointWithPath('${user}notification-read');

  //Setting toggle-device-biometrics
  static EndPoint get deviceBiometric =>
      _getEndPointWithPath('${user}toggle-device-biometrics');
  //logout
  static EndPoint get logout => _getEndPointWithPath('${user}logout');
  //toggle-notification
  static EndPoint get toggleNotification =>
      _getEndPointWithPath('${user}toggle-notification');
  //contact-sort-toggle
  static EndPoint get contactSortToggle =>
      _getEndPointWithPath('${user}contact-sort-toggle');
  //toggle-contact-synch
  static EndPoint get toggleContactSynch =>
      _getEndPointWithPath('${user}toggle-contact-synch');
  //delete-account
  static EndPoint get deleteAccount =>
      _getEndPointWithPath('${user}delete-account');
  //payment-list
  static EndPoint get paymentList =>
      _getEndPointWithPath('${user}payment-list');
  //get-profile
  static EndPoint get getProfile => _getEndPointWithPath('${user}get-profile');
  //edit-profile
  static EndPoint get editProfile =>
      _getEndPointWithPath('${user}edit-profile');

  static EndPoint _getEndPointWithPath(String path) {
    return EndPoint(base: base, path: path);
  }
}
