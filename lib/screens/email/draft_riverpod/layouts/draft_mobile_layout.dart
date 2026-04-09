import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftMobileLayout extends ConsumerWidget {
  final DraftState state;
  final DraftNotifier notifier;
  final Function(int) onViewDetail;
  final TextEditingController searchController;
  final FocusNode focusNode;

  const DraftMobileLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.onViewDetail,
    required this.searchController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Search bar removed — now handled by ShellLayout AppBar.bottom
        Expanded(child: _buildDraftList()),
      ],
    );
  }

  // ===================== DRAFT LIST =====================

  Widget _buildDraftList() {
    return CustomDismissible(
      onLongPress: notifier.toggleSelectFromList,
      longPress: !state.longPressFlag,
      allEmailIdsFlag: state.allEmailIdsFlag,
      selectedEmailIds: state.selectedEmailIds,
      selectedEmails: state.selectedEmails,
      setSelectedEmailIds: notifier.setSelectedFromList,
      onRefresh: () => notifier.getAllEmails(state.searchKey, isRefresh: true),
      onEndReached: () => notifier.getAllEmails(state.searchKey),
      shouldShowStartPane: false,
      items: state.items,
      addEmailTags: (_, _, _, _) async {},
      emailType: 'draft',
      updateEmailStatus: (_, _, _) async {},
      tagsList: const [],
      rightActions: const ['', 'Trash', ''],
      viewDetail: onViewDetail,
      onDeleteEmail: (id, _) => notifier.deleteDrafts([id]),
      selectedEmailId: state.currentlyViewedEmailId,
    );
  }
}
