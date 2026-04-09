import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/screens/auth/setupProfile/widgets/setup_profile_form_widget.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupProfileMobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final FormValidationService formValidation;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final bool? readOnly;

  const SetupProfileMobileLayout(
      {super.key,
      required this.formKey,
      required this.firstNameController,
      required this.lastNameController,
      required this.dobController,
      required this.formValidation,
      required this.onSubmit,
      required this.onLogin,
      this.readOnly});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return _buildScaffold(
      context,
      child: isLandscape
          ? _buildLandscapeContent(context)
          : _buildPortraitContent(context),
    );
  }

  /// ---------- Common Scaffold ----------
  Widget _buildScaffold(BuildContext context, {required Widget child}) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  /// ---------- Landscape ----------
  Widget _buildLandscapeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildIconAndTitle(context, iconSize: 40),
          ),
          const SizedBox(width: AppStyles.space32),
          Expanded(
            child: Center(child: _buildForm()),
          ),
        ],
      ),
    );
  }

  /// ---------- Portrait ----------
  Widget _buildPortraitContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final iconSize = (height * 0.08).clamp(35.0, 70.0);
        final spacing = (height * 0.015).clamp(8.0, 15.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconAndTitle(context, iconSize: iconSize),
              _buildForm(spacing: spacing),
            ],
          ),
        );
      },
    );
  }

  /// ---------- Reusable Widgets ----------
  Widget _buildIconAndTitle(BuildContext context, {required double iconSize}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(svgIcon, height: iconSize),
        const SizedBox(height: 8),
        _buildTitle(context),
      ],
    );
  }

  Widget _buildForm({double? spacing}) {
    return SetupProfileFormWidget(
      formKey: formKey,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      dobController: dobController,
      formValidation: formValidation,
      onSubmit: onSubmit,
      onLogin: onLogin,
      spacing: spacing,
      readOnly: readOnly ?? false,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(setupProfile, style: AuthStyles.heroTitle(context)),
        const SizedBox(height: AppStyles.space4),
        Text(
          setupProfileText,
          style: AuthStyles.subTitle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        CommonService().getCopyrightNotice(),
        textAlign: TextAlign.center,
        style: AuthStyles.copyright(context),
      ),
    );
  }
}
