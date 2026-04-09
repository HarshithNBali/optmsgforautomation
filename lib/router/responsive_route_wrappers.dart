import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/subscription/change_subscription/change_subscription.dart';
import 'package:optmsg/screens/subscription/checkout/check_out.dart';
import 'package:optmsg/screens/subscription/change_payment/payment_method.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_riverpod.dart';
import 'package:optmsg/screens/staticPages/static_pages.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_responsive.dart';
import 'package:optmsg/screens/compose/web_compose.dart';
import 'package:optmsg/screens/compose/compose_screen.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/screens/subscription/plans/select_plan.dart';
import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_riverpod.dart';
import 'package:optmsg/screens/contacts/edit_contact_riverpod/edit_contact_riverpod.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_riverpod.dart';
import 'package:optmsg/screens/helpCenter/help_center_riverpod.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_riverpod.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_riverpod.dart';
import 'package:optmsg/screens/inbox/view_email.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_list_riverpod.dart';
import 'package:optmsg/screens/tags/tag_email_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/screens/inbox/inbox.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_responsive.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_responsive.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_riverpod.dart';
import 'package:optmsg/model/contact_email_details.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart'
    show authProvider;
import 'package:optmsg/screens/staticPages/faq_static_page.dart';
import 'package:optmsg/screens/contacts/add_contact_riverpod/add_contact_riverpod.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_list_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsiveInboxWrapper extends StatelessWidget {
  final int? selectedEmailId;
  const ResponsiveInboxWrapper({super.key, this.selectedEmailId});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape =
        !kIsWeb &&
        AppBreakpoints.isTabletLayout(context) &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('inbox-desktop'),
        initialRoute: AppRoutes.inbox,
        selectedEmailId: selectedEmailId,
      );
    }
    return InboxResponsive(
      key: const ValueKey('inbox-mobile'),
      type: 'inbox',
      onLongPress: () {},
    );
  }
}

class ResponsiveArchiveWrapper extends StatelessWidget {
  final int? selectedEmailId;
  const ResponsiveArchiveWrapper({super.key, this.selectedEmailId});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('archive-desktop'),
        initialRoute: AppRoutes.archive,
        selectedEmailId: selectedEmailId,
      );
    }
    return const ArchiveResponsive(
      key: ValueKey('archive-mobile'),
      parentRoute: AppRoutes.archive,
    );
  }
}

class ResponsiveSentWrapper extends StatelessWidget {
  final int? selectedEmailId;
  const ResponsiveSentWrapper({super.key, this.selectedEmailId});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('sent-desktop'),
        initialRoute: AppRoutes.sent,
        selectedEmailId: selectedEmailId,
      );
    }
    return const ArchiveResponsive(
      key: ValueKey('sent-mobile'),
      parentRoute: AppRoutes.sent,
    );
  }
}

class ResponsiveDraftWrapper extends StatelessWidget {
  final int? selectedEmailId;
  const ResponsiveDraftWrapper({super.key, this.selectedEmailId});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('draft-desktop'),
        initialRoute: AppRoutes.drafts,
        selectedEmailId: selectedEmailId,
      );
    }
    return const DraftResponsive(key: ValueKey('draft-mobile'));
  }
}

class ResponsiveTrashWrapper extends StatelessWidget {
  final int? selectedEmailId;
  const ResponsiveTrashWrapper({super.key, this.selectedEmailId});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('trash-desktop'),
        initialRoute: AppRoutes.trash,
        selectedEmailId: selectedEmailId,
      );
    }
    return const ArchiveResponsive(
      key: ValueKey('trash-mobile'),
      parentRoute: AppRoutes.trash,
    );
  }
}

class ResponsiveSpamWrapper extends StatelessWidget {
  const ResponsiveSpamWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('spam-desktop'),
        initialRoute: AppRoutes.spam,
      );
    }
    return const ArchiveResponsive(
      key: ValueKey('spam-mobile'),
      parentRoute: AppRoutes.spam,
    );
  }
}

class ResponsiveContactsWrapper extends StatelessWidget {
  const ResponsiveContactsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('contacts-desktop'),
        initialRoute: AppRoutes.contacts,
      );
    }
    return const ContactListriverpod(key: ValueKey('contacts-mobile'));
  }
}

class ResponsiveSettingsWrapper extends StatelessWidget {
  const ResponsiveSettingsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('settings-desktop'),
        pageName: AppRoutes.settings,
        child: Settingriverpod(),
      );
    }
    return const Settingriverpod(key: ValueKey('settings-mobile'));
  }
}

class ResponsiveHelpCenterWrapper extends StatelessWidget {
  const ResponsiveHelpCenterWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('help-center-desktop'),
        pageName: AppRoutes.helpCenter,
        child: HelpCenterriverpod(),
      );
    }
    return const HelpCenterriverpod(key: ValueKey('help-center-mobile'));
  }
}

class ResponsiveProfileWrapper extends StatelessWidget {
  const ResponsiveProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('profile-desktop'),
        pageName: AppRoutes.settings,
        child: Profileriverpod(),
      );
    }
    return const Profileriverpod(key: ValueKey('profile-mobile'));
  }
}

class ResponsiveAccountWrapper extends StatelessWidget {
  const ResponsiveAccountWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('account-desktop'),
        pageName: AppRoutes.settings,
        child: Accountriverpod(),
      );
    }
    return const Accountriverpod(key: ValueKey('account-mobile'));
  }
}

class ResponsiveViewEmailWrapper extends StatelessWidget {
  final int emailId;
  final String emailType;
  final TagsListModel? allTagsList;

  const ResponsiveViewEmailWrapper({
    super.key,
    required this.emailId,
    required this.emailType,
    this.allTagsList,
  });

  String _getPageNameForEmailType() {
    switch (emailType.toLowerCase()) {
      case 'sent':
        return AppRoutes.sent;
      case 'archive':
        return AppRoutes.archive;
      case 'trash':
        return AppRoutes.trash;
      case 'drafts':
      case 'draft':
        return AppRoutes.drafts;
      default:
        return AppRoutes.inbox;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('view-inbox-desktop-$emailId'),
        pageName: _getPageNameForEmailType(),
        child: ViewEmail(
          emailId: emailId,
          emailType: emailType,
          allTagsList: allTagsList,
        ),
      );
    }
    return ViewEmail(
      key: ValueKey('view-inbox-mobile-$emailId'),
      emailId: emailId,
      emailType: emailType,
      allTagsList: allTagsList,
    );
  }
}

class ResponsivePlansWrapper extends ConsumerWidget {
  const ResponsivePlansWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // M-18: Only rebuild when isAuthenticated changes, not on every auth state update
    final isAuthenticated = ref.watch(
      authProvider.select((s) => s.isAuthenticated),
    );
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if (((kIsWeb && !isMobile) || isTabletLandscape) && isAuthenticated) {
      return const Inbox(
        key: ValueKey('plans-desktop'),
        pageName: AppRoutes.plans,
        child: Plans(),
      );
    }
    return const Plans(key: ValueKey('plans-mobile'));
  }
}

class ResponsiveViewContactriverpodWrapper extends StatelessWidget {
  final dynamic contact;
  final String? page;
  final Future<void> Function(Map<String, dynamic>)? onContactUpdated;
  final bool hideAppBar;

  const ResponsiveViewContactriverpodWrapper({
    super.key,
    required this.contact,
    this.page,
    this.onContactUpdated,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    // Ensure we have a proper model, as GoRouter 'extra' can sometimes be a Map on Web.
    final Contacts effectiveContact = contact is Map<String, dynamic>
        ? Contacts.fromJson(contact)
        : contact as Contacts;

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('view-contact-rp-desktop-${effectiveContact.id}'),
        pageName: AppRoutes.contacts,
        child: ViewContactriverpod(
          contact: effectiveContact,
          page: page,
          onContactUpdated: onContactUpdated,
          hideAppBar: hideAppBar,
        ),
      );
    }
    return ViewContactriverpod(
      key: ValueKey('view-contact-rp-mobile-${effectiveContact.id}'),
      contact: effectiveContact,
      page: page,
      onContactUpdated: onContactUpdated,
      hideAppBar: hideAppBar,
    );
  }
}

class ResponsiveEditContactriverpodWrapper extends StatelessWidget {
  final dynamic contact;
  final List<Contact> contactData;
  final bool isReadingPaneMode;

  const ResponsiveEditContactriverpodWrapper({
    super.key,
    required this.contact,
    required this.contactData,
    this.isReadingPaneMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('edit-contact-rp-desktop-${contact?.id ?? "new"}'),
        pageName: AppRoutes.contacts,
        child: EditContactriverpod(
          contact: contact,
          contactData: contactData,
          isReadingPaneMode: isReadingPaneMode,
        ),
      );
    }
    return EditContactriverpod(
      key: ValueKey('edit-contact-rp-mobile-${contact?.id ?? "new"}'),
      contact: contact,
      contactData: contactData,
      isReadingPaneMode: isReadingPaneMode,
    );
  }
}

class ResponsivePaymentMethodWrapper extends StatelessWidget {
  const ResponsivePaymentMethodWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('payment-method-desktop'),
        pageName: AppRoutes.paymentMethod,
        child: PaymentMethod(),
      );
    }
    return const PaymentMethod(key: ValueKey('payment-method-mobile'));
  }
}

class ResponsiveChangeSubscriptionWrapper extends StatelessWidget {
  const ResponsiveChangeSubscriptionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('change-subscription-desktop'),
        pageName: AppRoutes.changeSubscription,
        child: ChangeSubscription(),
      );
    }
    return const ChangeSubscription(
      key: ValueKey('change-subscription-mobile'),
    );
  }
}

class ResponsiveCheckOutWrapper extends StatelessWidget {
  final String page;

  const ResponsiveCheckOutWrapper({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return CheckOutRiverpod(key: ValueKey('checkout-$page'), page: page);
  }
}

class ResponsiveSubscriptionWrapper extends StatelessWidget {
  final Map<String, dynamic> listData;

  const ResponsiveSubscriptionWrapper({super.key, required this.listData});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);
    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: const ValueKey('subscription-detail-desktop'),
        pageName: AppRoutes.settings,
        child: SubscriptionRiverpod(listData: listData),
      );
    }
    return SubscriptionRiverpod(
      key: const ValueKey('subscription-detail-mobile'),
      listData: listData,
    );
  }
}

class ResponsiveStaticPagesWrapper extends ConsumerWidget {
  final String pageKey;
  final bool isSignupFlow;

  const ResponsiveStaticPagesWrapper({
    super.key,
    required this.pageKey,
    this.isSignupFlow = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Signup flow: not logged in, render with own AppBar (no shell)
    if (isSignupFlow) {
      return StaticPages(
        key: ValueKey('static-page-signup-$pageKey'),
        pageKey: pageKey,
        showOwnAppBar: true,
      );
    }

    // M-18: Only rebuild when isAuthenticated changes, not on every auth state update
    final isAuthenticated = ref.watch(
      authProvider.select((s) => s.isAuthenticated),
    );
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if (((kIsWeb && !isMobile) || isTabletLandscape) && isAuthenticated) {
      return Inbox(
        key: ValueKey('static-page-desktop-$pageKey'),
        pageName: AppRoutes.helpCenter,
        child: StaticPages(pageKey: pageKey),
      );
    }
    return StaticPages(
      key: ValueKey('static-page-mobile-$pageKey'),
      pageKey: pageKey,
    );
  }
}

class ResponsiveWebComposeWrapper extends StatelessWidget {
  final String type;
  final String? url;
  final String? token;
  final int? pageId;
  final String? email;
  final int? emailId;
  final String? sourcePage;

  const ResponsiveWebComposeWrapper({
    super.key,
    required this.type,
    this.url,
    this.token,
    this.pageId,
    this.email,
    this.emailId,
    this.sourcePage,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('compose-desktop-$type'),
        pageName: sourcePage ?? AppRoutes.inbox,
        child: WebCompose(
          type: type,
          url: url,
          token: token,
          pageId: pageId,
          email: email,
          emailId: emailId,
          sourcePage: sourcePage,
        ),
      );
    }
    return WebCompose(
      key: ValueKey('compose-mobile-$type'),
      type: type,
      url: url,
      token: token,
      pageId: pageId,
      email: email,
      emailId: emailId,
      sourcePage: sourcePage,
    );
  }
}

/// Native Flutter compose wrapper — feature-flag replacement for
/// [ResponsiveWebComposeWrapper]. Wraps [ComposeScreen] in the Inbox shell
/// on desktop/tablet, or renders full-screen on mobile.
class ResponsiveComposeWrapper extends StatelessWidget {
  final ComposeParams params;

  const ResponsiveComposeWrapper({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('native-compose-desktop-${params.mode.name}'),
        pageName: params.sourcePage ?? AppRoutes.inbox,
        child: ComposeScreen(params: params),
      );
    }
    return ComposeScreen(
      key: ValueKey('native-compose-mobile-${params.mode.name}'),
      params: params,
    );
  }
}

class ResponsiveFaqWrapper extends StatelessWidget {
  const ResponsiveFaqWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('faq-desktop'),
        pageName: AppRoutes.helpCenter,
        child: FabStaticPage(pageKey: faq),
      );
    }
    return const FabStaticPage(key: ValueKey('faq-mobile'), pageKey: faq);
  }
}

class ResponsiveAddContactWrapper extends StatelessWidget {
  const ResponsiveAddContactWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('add-contact-desktop'),
        pageName: AppRoutes.contacts,
        child: AddContactriverpod(),
      );
    }
    return const AddContactriverpod(key: ValueKey('add-contact-mobile'));
  }
}

class ResponsiveAddExistingContactWrapper extends StatelessWidget {
  final String? prevEmail;
  final String? type;
  final List<String>? multipleEmails;

  const ResponsiveAddExistingContactWrapper({
    super.key,
    this.prevEmail,
    this.type,
    this.multipleEmails,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('add-existing-contact-desktop-$prevEmail'),
        pageName: AppRoutes.contacts,
        child: ContactListriverpod(
          prevEmail: prevEmail,
          type: type,
          multipleEmails: multipleEmails,
        ),
      );
    }
    return ContactListriverpod(
      key: ValueKey('add-existing-contact-mobile-$prevEmail'),
      prevEmail: prevEmail,
      type: type,
      multipleEmails: multipleEmails,
    );
  }
}

class ResponsiveTagsWrapper extends StatelessWidget {
  final int? tagId;
  final String? tagName;
  final dynamic tagsList;

  const ResponsiveTagsWrapper({
    super.key,
    this.tagId,
    this.tagName,
    this.tagsList,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return Inbox(
        key: ValueKey('tags-desktop-$tagId'),
        initialRoute: AppRoutes.tags,
        tagId: tagId,
        tagName: tagName,
      );
    }
    // Mobile: use TagEmailList directly (no reading pane)
    if (tagId != null) {
      return TagEmailList(
        key: ValueKey('tag-mobile-$tagId'),
        data: {'tagId': tagId, 'tagName': tagName ?? '', 'tagsList': tagsList},
        tagsList: tagsList,
      );
    }
    return const TagsListriverpod(key: ValueKey('tags-mobile'));
  }
}

class ResponsiveNotificationWrapper extends StatelessWidget {
  const ResponsiveNotificationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTabletLandscape = AppBreakpoints.isTabletLayout(context);

    if ((kIsWeb && !isMobile) || isTabletLandscape) {
      return const Inbox(
        key: ValueKey('notifications-desktop'),
        pageName: AppRoutes.notifications,
        child: NotificationList(),
      );
    }
    return const NotificationList(key: ValueKey('notifications-mobile'));
  }
}
