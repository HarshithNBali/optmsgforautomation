class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String enterOtp = '/enter-otp';
  static const String enterOtpProfile = '/enter-otp-profile';
  static const String setupProfile = '/setup-profile';
  static const String forgotUsername = '/forgot-username';
  static const String usernameSuccess = '/username-success';
  static const String addPassKey = '/add-passkey';
  static const String successOtp = '/success-otp';
  static const String webOtpToken = '/web-otp';

  static const String home = '/';
  static const String inbox = '/inbox';
  static const String archive = '/archive';
  static const String sent = '/sent';
  static const String drafts = '/drafts';
  static const String trash = '/trash';
  static const String spam = '/spam';

  static const String compose = '/compose';
  @Deprecated('Use folder-specific email routes (inboxEmail, archiveEmail, etc.)')
  static const String emailView = '/email';
  static const String inboxEmail = '/inbox/email';
  static const String archiveEmail = '/archive/email';
  static const String sentEmail = '/sent/email';
  static const String draftsEmail = '/drafts/email';
  static const String trashEmail = '/trash/email';
  static const String spamEmail = '/spam/email';
  static const String reply = '/reply/:id';
  static const String forward = '/forward/:id';

  // ─────────────────────────────────────────────────────────────────────────
  static const String contacts = '/contacts';
  static const String viewContactriverpod = '/contacts/view-contact';
  static const String editContactriverpod = '/contacts/edit-contact';
  static const String addExistingContact = '/contacts/add-existing';
  static const String addContactriverpod = '/contacts/add-contact';

  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String account = '/settings/account';

  static const String plans = '/plans';
  static const String subscriptionDetail =
      '/settings/account/subscription';
  static const String changeSubscription = '/subscription/change';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String paymentMethod =
      '/settings/account/subscription/change_payment';
  static const String processingPayment = '/processing-payment';
  static const String notifications = '/notifications';
  static const String tags = '/tags';
  static const String tagEmails = '/tags';
  static const String helpCenter = '/help';
  static const String faq = '/help/faq';
  /// GR-6: Explicit static-page routes instead of a catch-all `/:module/:slug`.
  static const String helpStaticPage = '/help/:slug';
  static const String signupStaticPage = '/signup/:slug';

  @Deprecated('Menu is now a Scaffold.drawer in ShellLayout, not a route')
  static const String menu = '/menu';
  static const String onboarding = '/onboarding';

  /// Build email view path with ID under the correct folder.
  /// [emailType] should be 'Inbox', 'Archive', 'Sent', 'Drafts', 'Trash', or 'Spam'.
  static String viewEmailPath(String emailId, [String emailType = 'Inbox']) {
    final folder = switch (emailType.toLowerCase()) {
      'archive' => 'archive',
      'sent' => 'sent',
      'drafts' || 'draft' => 'drafts',
      'trash' => 'trash',
      'spam' => 'spam',
      _ => 'inbox',
    };
    return '/$folder/email?id=$emailId';
  }

  /// Build reply path with email ID
  static String replyPath(int id) => '/reply/$id';

  /// Build forward path with email ID
  static String forwardPath(int id) => '/forward/$id';

  /// Build compose with recipient email
  static String composeWithTo(String email) => '/compose?to=$email';

  /// Build tag emails path with tag ID
  static String tagEmailsPath(int tagId) => '/tags?id=$tagId';

  /// Build view contact path with ID
  static String viewContactriverpodPath(int id) =>
      '/contacts/view-contact?id=$id';

  /// Build edit contact path with ID
  static String editContactriverpodPath(int id) =>
      '/contacts/edit-contact?id=$id';

  /// Build static page path with slug and module
  static String staticPagePath(String slug, String module) => '/$module/$slug';
}
