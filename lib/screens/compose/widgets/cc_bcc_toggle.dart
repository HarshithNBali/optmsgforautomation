import 'package:flutter/material.dart';

/// A small link button that toggles visibility of CC/BCC fields.
class CcBccToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const CcBccToggle({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            isExpanded ? 'Hide Cc/Bcc' : 'Cc/Bcc',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
