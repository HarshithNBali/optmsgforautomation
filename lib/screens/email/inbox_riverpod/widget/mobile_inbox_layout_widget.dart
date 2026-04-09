import 'package:optmsg/screens/email/inbox_riverpod/widget/tag_list_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/custom_dismissible.dart';
import 'filter_overlay_widget.dart';
import '../inbox_notifier.dart';
import 'menu_options_overlay_widget.dart';

class MobileInboxLayout extends ConsumerWidget {
  final List tagsList;

  const MobileInboxLayout({
    super.key,
    required this.tagsList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxProvider);
    final notifier = ref.read(inboxProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomDismissible(
                // ---------- SELECTION ----------
                onLongPress: notifier.toggleSelectFromList,

                longPress: !state.longPressFlag,

                allEmailIdsFlag: state.allEmailIdsFlag,
                selectedEmailIds: state.selectedEmailIds,
                selectedEmails: state.selectedEmails,

                setSelectedEmailIds: notifier.setSelectedFromList,

                // ---------- REFRESH ----------
                onRefresh: notifier.refresh,

                // ---------- PAGINATION ----------
                onEndReached: () {
                  if (!state.isLoading &&
                      state.inboxList?.data!.nextPage == true) {
                    notifier.getAllEmails(state.searchKey);
                  }
                },

                shouldShowStartPane: true,
                items: state.items,

                // ---------- TAGS ----------
                addEmailTags: notifier.addEmailTags,
                tagsList: tagsList,

                // ---------- EMAIL STATUS ----------
                emailType: 'inbox',
                updateEmailStatus: notifier.updateEmailStatus,

                // ---------- DETAIL VIEW ----------
                viewDetail: notifier.setCurrentlyViewedEmailId,

                rightActions: const ['More', 'Archive', 'Trash'],

                // ---------- SINGLE ACTIONS ----------
                onArchiveEmail: (id, _) =>
                    notifier.changeStatusWithUndo("isArchive", [id]),

                onDeleteEmail: (id, _) =>
                    notifier.changeStatusWithUndo("isTrash", [id]),

                onOptInEmail: (email, index) =>
                    notifier.handleSingleEmailOptIn(email, index),

                selectedEmailId: state.currentlyViewedEmailId,
              ),

              // ---------- OVERLAYS ----------
              if (state.showFilter) filterOverlayWidget(ref, context),
              if (state.showTagList)
                TagListOverlayWidget(
                  isForAddingTags: state.selectedEmailIds.isNotEmpty ||
                      state.selectedEmailIdForReadingPane != null,
                ),
              if (state.showMenuOptions) menuOptionsOverlayWidget(ref, context),
            ],
          ),
        ),
      ],
    );
  }
}
