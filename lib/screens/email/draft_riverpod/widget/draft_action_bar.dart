import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DraftActionBar extends StatelessWidget {
  final DraftState state;
  final DraftNotifier notifier;
  final bool hasAnySelection;

  const DraftActionBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.hasAnySelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(width: 1, color: context.colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          _ComposeButton(
            notifier: notifier,
          ),
          const SizedBox(width: 16),
          if (state.selectedEmailIds.isNotEmpty &&
              AppBreakpoints.isMobileLayout(context)) ...[
            Text(
              '${state.selectedCount} selected',
              style: AppTypography.bodyMedium(context).copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (hasAnySelection && state.hasEmails)
            IconButton(
              icon: SvgPicture.asset(
                svgDelete,
                height: 20,
                width: 20,
                colorFilter:
                    ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
              ),
              onPressed: () {
                if (state.selectedEmailIds.isNotEmpty) {
                  notifier.deleteDrafts(state.selectedEmailIds);
                } else if (state.selectedEmailIdForReadingPane != null) {
                  notifier.deleteDrafts([state.selectedEmailIdForReadingPane!]);
                  notifier.setSelectedEmailIdForReadingPane(null);
                }
              },
              tooltip: 'Delete',
            ),
        ],
      ),
    );
  }
}

class _ComposeButton extends StatelessWidget {
  final DraftNotifier notifier;

  const _ComposeButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return CommonWebButton(
      iconAsset: svgCompose,
      label: 'Compose',
      onPressed: () => notifier.gotoCompose(),
    );
  }
}
