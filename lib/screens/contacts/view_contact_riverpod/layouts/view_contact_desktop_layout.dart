import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/string_constant.dart';
import '../../../../model/contact_email_details.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../contacts_riverpod/contact_list_notifier.dart';
import '../view_contact_notifier.dart';

class ViewContactDesktopLayoutRiverpod extends ConsumerWidget {
  final String firstName;
  final String lastName;
  final String companyName;
  final List<Contact> emails;
  final bool loadingContactDetails;
  final Function(String, BuildContext) onEmailTap;
  final Function(String) onDeleteEmail;
  final VoidCallback onAddEmail;
  final bool hideAppBar;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ViewContactDesktopLayoutRiverpod({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.emails,
    required this.loadingContactDetails,
    required this.onEmailTap,
    required this.onDeleteEmail,
    required this.onAddEmail,
    this.hideAppBar = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 Contact list state (selection / reading pane)
    final ContactListNotifier contactNotifier = ref.read(
      contactListProvider.notifier,
    );

    // 🔹 View contact state (EMAILS COME FROM HERE ✅)
    final viewState = ref.watch(viewContactProvider);
    final emails = viewState.emails;

    final bool showActions =
        !(contactNotifier.readingPaneEnabled) || !hideAppBar;
    return loadingContactDetails
        ? const DelayedLoadingOverlay(isLoading: true, child: SizedBox.shrink())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: AppBreakpoints.formWidthDesktop,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showActions) ...[
                      // Show Add, Edit and Delete actions when reading pane is OFF on web
                      Row(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              svgEditForm,
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                context.colors.onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              svgDelete,
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                context.colors.onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: onDelete,
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    SelectionArea(
                      child: Text(
                        _getFullName(
                          CommonService().capitalize(firstName),
                          CommonService().capitalize(lastName),
                        ),
                        style: AppTypography.headlineLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (companyName.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        company,
                        style: AppTypography.caption(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space4),
                      SelectionArea(
                        child: Text(
                          CommonService().capitalize(companyName),
                          style: AppTypography.titleLarge(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Email',
                      style: AppTypography.caption(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...emails.map((e) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: InkWell(
                          child: Text(
                            e.email.toString(),
                            style: TextStyle(color: context.appColors.linkBlue),
                          ),
                          onTap: () => onEmailTap(e.email.toString(), context),
                        ),
                        trailing: IconButton(
                          icon: SvgPicture.asset(svgDelete),
                          onPressed: () {
                            onDeleteEmail(e.email.toString());
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
  }

  String _getFullName(String firstName, String lastName) {
    return '$firstName $lastName';
  }
}
