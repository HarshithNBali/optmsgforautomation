import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';

/// Read-only "From:" field showing the sender's name and email.
class FromField extends StatelessWidget {
  final String fromName;
  final String fromEmail;

  const FromField({
    super.key,
    required this.fromName,
    required this.fromEmail,
  });

  @override
  Widget build(BuildContext context) {
    final display = fromName.isNotEmpty ? '$fromName <$fromEmail>' : fromEmail;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text('From: ', style: AppTypography.emailLabel(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              style: AppTypography.emailAddress(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
