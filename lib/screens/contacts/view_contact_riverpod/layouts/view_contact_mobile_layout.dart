import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../model/contact_email_details.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';

class ViewContactMobileLayoutRiverpod extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String companyName;
  final List<Contact> emails;
  final bool loadingContactDetails;
  final Function(String, BuildContext) onEmailTap;
  final Function(String) onDeleteEmail;

  const ViewContactMobileLayoutRiverpod({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.emails,
    required this.loadingContactDetails,
    required this.onEmailTap,
    required this.onDeleteEmail,
  });

  @override
  Widget build(BuildContext context) {
    return switch (MediaQuery.of(context).orientation) {
      Orientation.landscape => _buildLandscapeLayout(context),
      Orientation.portrait  => _buildPortraitLayout(context),
    };
  /*  final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // if (isLandscape) {
    //   return _buildLandscapeLayout(context);
    // }
    return _buildPortraitLayout(context);*/
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SelectionArea(
                      child: Text(
                        _getFullName(
                          CommonService().capitalize(firstName),
                          CommonService().capitalize(lastName),
                        ),
                        style: AppTypography.headlineLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (companyName.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        company,
                        style: AppTypography.caption(context).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      SelectionArea(
                        child: Text(
                          CommonService().capitalize(companyName),
                          style: AppTypography.labelLarge(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: _buildEmailList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.space16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectionArea(
                child: Text(
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  _getFullName(
                    CommonService().capitalize(firstName),
                    CommonService().capitalize(lastName),
                  ),
                  style: AppTypography.headlineLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 40.0),
              if (companyName.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: AppTypography.caption(context).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.left,
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
                    const SizedBox(height: 20.0),
                  ],
                ),
              _buildEmailList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTypography.caption(context).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: AppStyles.space4),
        if (loadingContactDetails)
          const DelayedLoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          )
        else
          Column(
            children: [
              for (int index = 0; index < emails.length; index++)
                if (emails[index].email != null && emails[index].email != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => onEmailTap(
                              emails[index].email.toString(),
                              context,
                            ),
                            child: Text(
                              emails[index].email.toString(),
                              style: AppTypography.titleLarge(context).copyWith(
                                overflow: TextOverflow.ellipsis,
                                color: context.appColors.linkBlue,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(svgDelete),
                          onPressed: () {
                            onDeleteEmail(emails[index].email.toString());
                          },
                        ),
                      ],
                    ),
                  ),
            ],
          ),
      ],
    );
  }

  String _getFullName(String firstName, String lastName) {
    return '$firstName $lastName';
  }
}
