import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/string_constant.dart';
import '../../../../model/contact_email_details.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../contacts_riverpod/contact_list_notifier.dart';

class ViewContactTabletLayoutRiverpod extends ConsumerWidget {
  final String firstName;
  final String lastName;
  final String companyName;
  final List<Contact> emails;
  final bool loadingContactDetails;
  final Function(String, BuildContext) onEmailTap;
  final Function(String) onDeleteEmail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddEmail;
  final VoidCallback? onAddContact;
  final bool hideAppBar;

  const ViewContactTabletLayoutRiverpod({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.emails,
    required this.loadingContactDetails,
    required this.onEmailTap,
    required this.onDeleteEmail,
    this.onEdit,
    this.onDelete,
    this.onAddEmail,
    this.onAddContact,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactListProvider);

    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final showActions =
        !((kIsWeb || isNativeTabletLandscape) &&
            contactState.readingPaneEnabled) ||
        !hideAppBar;

    if (loadingContactDetails) {
      return const DelayedLoadingOverlay(
        isLoading: true,
        child: SizedBox.shrink(),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: isLandscape ? null : 500,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(context, showActions),
          ),
        ),
      ),
    );
  }

  /// ---------- Main Content ----------
  Widget _buildContent(BuildContext context, bool showActions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showActions) ...[
          _buildActionsRow(context),
          const SizedBox(height: 24),
        ],
        _buildHeader(context),
        const SizedBox(height: 32),
        _buildEmailSection(context),
      ],
    );
  }

  /// ---------- Action Buttons ----------
  Widget _buildActionsRow(BuildContext context) {
    if (onAddContact == null && onEdit == null && onDelete == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (onEdit != null) ...[
          _iconButton(context, svgEditForm, onEdit!, 'Edit'),
        ],
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          _iconButton(context, svgDelete, onDelete!, 'Delete'),
        ],
      ],
    );
  }

  Widget _iconButton(
    BuildContext context,
    String asset,
    VoidCallback onTap,
    String tooltip,
  ) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: SvgPicture.asset(
        asset,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(
          context.colors.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  /// ---------- Name + Company ----------
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionArea(
          child: Text(
            _getFullName(
              CommonService().capitalize(firstName),
              CommonService().capitalize(lastName),
            ),
            style: AppTypography.headlineLarge(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.fade,
          ),
        ),
        if (companyName.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            company,
            style: AppTypography.caption(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppStyles.space4),
          SelectionArea(
            child: Text(
              CommonService().capitalize(companyName),
              style: AppTypography.titleLarge(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ],
    );
  }

  /// ---------- Email Section ----------
  Widget _buildEmailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTypography.caption(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        ...emails.map(
          (e) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: InkWell(
              onTap: () => onEmailTap(e.email.toString(), context),
              child: Text(
                e.email.toString(),
                style: TextStyle(color: context.appColors.linkBlue),
              ),
            ),
            trailing: IconButton(
              icon: SvgPicture.asset(svgDelete),
              onPressed: () => onDeleteEmail(e.email.toString()),
            ),
          ),
        ),
      ],
    );
  }

  String _getFullName(String firstName, String lastName) =>
      '$firstName $lastName';
}
