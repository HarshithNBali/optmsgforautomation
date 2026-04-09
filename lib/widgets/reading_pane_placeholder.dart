import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';

/// Standardized placeholder shown in the reading pane when no item is selected.
/// Matches the visual style across inbox, archive, draft, and contacts.
class ReadingPanePlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ReadingPanePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = 'You have not selected anything',
  });

  /// Inbox / Archive reading pane placeholder.
  const ReadingPanePlaceholder.inbox({super.key})
      : icon = Icons.mail_outline,
        title = 'Select a message to read',
        subtitle = 'You have not selected anything';

  /// Draft reading pane placeholder.
  const ReadingPanePlaceholder.draft({super.key})
      : icon = Icons.mail_outline,
        title = 'Select a draft to edit',
        subtitle = 'You have not selected anything';

  /// Contacts reading pane placeholder.
  const ReadingPanePlaceholder.contacts({super.key})
      : icon = Icons.person_outline,
        title = 'Select a contact to view details',
        subtitle = 'You have not selected anything';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.inboxTitle(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodySmall(context).copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
