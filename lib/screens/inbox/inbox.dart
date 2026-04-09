import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_responsive.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_responsive.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_responsive.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_riverpod.dart';
import 'package:optmsg/screens/helpCenter/help_center_riverpod.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_riverpod.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_riverpod.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_list_riverpod.dart';
import 'package:flutter/material.dart';
import '../../router/app_routes.dart';

class Inbox extends StatelessWidget {
  final String? initialRoute;
  final Widget? child;
  final String? pageName;
  final int? selectedEmailId;
  final int? tagId;
  final String? tagName;

  const Inbox({
    super.key,
    this.initialRoute,
    this.child,
    this.pageName,
    this.selectedEmailId,
    this.tagId,
    this.tagName,
  });

  @override
  Widget build(BuildContext context) {
    // If a child is provided (e.g. from Settings wrapper), return it directly
    if (child != null) {
      return child!;
    }

    // Otherwise, dispatch to the correct responsive widget based on the route
    // This widget is primarily used as a container for Desktop/Tablet views
    // where we want to ensure specific content is rendered within the ShellLayout

    final route = initialRoute ?? pageName ?? AppRoutes.inbox;

    switch (route) {
      case AppRoutes.inbox:
        return InboxResponsive(
          key: const ValueKey('inbox-responsive'),
          type: 'inbox',
          selectedEmailId: selectedEmailId,
        );

      case AppRoutes.contacts:
      case AppRoutes.addExistingContact:
        return const ContactListriverpod();

      case AppRoutes.trash:
        return ArchiveResponsive(
          parentRoute: AppRoutes.trash,
          selectedEmailId: selectedEmailId,
        );

      case AppRoutes.drafts:
        return DraftResponsive(selectedEmailId: selectedEmailId);

      case AppRoutes.archive:
        return ArchiveResponsive(
          parentRoute: AppRoutes.archive,
          selectedEmailId: selectedEmailId,
        );

      case AppRoutes.sent:
        return ArchiveResponsive(
          parentRoute: AppRoutes.sent,
          selectedEmailId: selectedEmailId,
        );

      case AppRoutes.tags:
        if (tagId != null) {
          return InboxResponsive(
            key: ValueKey('tag-$tagId'),
            type: 'all',
            selectedEmailId: selectedEmailId,
            tagId: tagId,
            tagName: tagName,
          );
        }
        return const TagsListriverpod();

      case AppRoutes.settings:
        return const Settingriverpod();

      case AppRoutes.helpCenter:
        return const HelpCenterriverpod();

      case AppRoutes.account:
        return const Accountriverpod();

      default:
        // Fallback or default content
        return InboxResponsive(
          key: const ValueKey('inbox-responsive'),
          type: 'inbox',
          selectedEmailId: selectedEmailId,
        );
    }
  }
}

class ViewEmailArgs {
  final int emailId;
  final String emailType;
  final TagsListModel? tagsList;

  ViewEmailArgs({
    required this.emailId,
    required this.emailType,
    required this.tagsList,
  });
}
