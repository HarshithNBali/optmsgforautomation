import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/tag_list_overlay_widget.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/custom_dismissible.dart';
import 'filter_icon_widget.dart';
import 'filter_overlay_widget.dart';
import '../inbox_notifier.dart';
import 'menu_options_overlay_widget.dart';

class EmailListPane extends ConsumerWidget {
  final List tagsList;
  final String currentMenuLabel;

  const EmailListPane({
    super.key,
    required this.tagsList,
    required this.currentMenuLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxProvider);
    final notifier = ref.read(inboxProvider.notifier);

    return Column(
      children: [
        // ---------------- HEADER ----------------
        Builder(
          builder: (context) {
            final bool showCheckbox = kIsWeb &&
                (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);
            return Padding(
              // Adjust left padding to align with email list checkboxes (8px when checkbox shown)
              padding: EdgeInsets.fromLTRB(showCheckbox ? 8 : 16, 12, 16, 4),
              child: Row(
                children: [
                  /// Select all checkbox (Web)
                  if (showCheckbox) ...[
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Select all',
                        icon: state.allEmailIdsFlag
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                        onPressed: notifier.selectAllFromList,
                      ),
                    ),
                  ],

                  Text(
                    currentMenuLabel,
                    style: AppTypography.titleMedium(context),
                  ),

                  const Spacer(),

                  /// Toggle checkboxes (Web only)
                  if (kIsWeb)
                    IconButton(
                      tooltip:
                          showCheckbox ? 'Hide Checkboxes' : 'Show Checkboxes',
                      icon: Icon(
                        // Use actual checkbox visibility state for icon
                        showCheckbox
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      onPressed: () {
                        if (showCheckbox) {
                          // Currently showing checkboxes - hide them and clear selection
                          notifier.setShowCheckboxes(false);
                          notifier.clearSelection();
                        } else {
                          // Currently hidden - show checkboxes
                          notifier.setShowCheckboxes(true);
                        }
                      },
                    ),

                  filterIconWidget(ref, context),
                ],
              ),
            );
          },
        ),

        const Divider(height: 1),

        // ---------------- LIST BODY ----------------
        Expanded(
          child: Stack(
            children: [
              CustomDismissible(
                items: state.items,
                tagsList: tagsList,
                emailType: 'inbox',

                longPress: kIsWeb ? state.showCheckboxes : !state.longPressFlag,

                allEmailIdsFlag: state.allEmailIdsFlag,
                selectedEmailIds: state.selectedEmailIds,
                selectedEmails: state.selectedEmails,

                setSelectedEmailIds: (ids, mails) {
                  notifier.setSelectedFromList(ids, mails);
                },

                /// Single long press
                onLongPress: notifier.toggleSelectFromList,

                /// Pull refresh
                onRefresh: notifier.refresh,

                /// Pagination
                onEndReached: () {
                  if (!state.isLoading &&
                      state.inboxList?.data!.nextPage == true) {
                    notifier.getAllEmails(state.searchKey);
                  }
                },

                /// Details view - clear selections when clicking on an email
                viewDetail: (int? id, [List? tags, int? index]) {
                  // Clear any selections when viewing an email
                  if (state.selectedEmailIds.isNotEmpty) {
                    notifier.clearSelection();
                  }
                  notifier.setCurrentlyViewedEmailId(id, tags, index);
                },

                /// Single actions
                onArchiveEmail: (int id, int index) {
                  notifier.changeStatusWithUndo("isArchive", [id]);
                },

                onDeleteEmail: (int id, int index) {
                  notifier.changeStatusWithUndo("isTrash", [id]);
                },
                onOptInEmail: (String email, int index) {
                  notifier.handleSingleEmailOptIn(email, index);
                },

                selectedEmailId: state.currentlyViewedEmailId,

                rightActions: const ['More', 'Archive', 'Trash'],
                shouldShowStartPane: true,
                updateEmailStatus: notifier.updateEmailStatus,
                addEmailTags: notifier.addEmailTags,
              ),

              // ---------------- OVERLAYS ----------------
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
