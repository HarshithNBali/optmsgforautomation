import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';

/// Semantic variants for empty state messages throughout the app.
enum EmptyStateVariant {
  inbox(Icons.mail_outline, "Nothing left to read.\nYou're all caught up!"),
  notifications(Icons.notifications_none, 'No notifications yet'),
  tags(Icons.label_outline, 'No tags found'),
  contacts(Icons.person_outline, 'No contacts found'),
  emailDetail(Icons.mail_outline, 'Email not found'),
  generic(Icons.info_outline, 'No data found');

  const EmptyStateVariant(this.icon, this.defaultTitle);
  final IconData icon;
  final String defaultTitle;
}

class EmptyState extends StatelessWidget {
  final EmptyStateVariant variant;
  final String? title;
  const EmptyState({required this.variant, this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          // If the parent provides bounded height (e.g. inside Expanded/Center),
          // use it. If unbounded (inside ListView), use a sensible fill height.
          height: constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  variant.icon,
                  size: 64,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  title ?? variant.defaultTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.inboxTitle(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
