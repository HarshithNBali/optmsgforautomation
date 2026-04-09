import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/form_validation.dart';
import '../../../../widgets/common_web_button.dart';
import '../../../../widgets/text_form_field.dart';

class AddContactTabletLayoutRiverpod extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController companyController;
  final List<TextEditingController> emailControllers;
  final ScrollController scrollController;
  final FormValidationService formValidation;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final Function(String, int) onAddRemoveEmail;

  const AddContactTabletLayoutRiverpod({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.companyController,
    required this.emailControllers,
    required this.scrollController,
    required this.formValidation,
    required this.onSave,
    required this.onBack,
    required this.onAddRemoveEmail,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeLayout(context);
    }
    return _buildPortraitLayout(context);
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: CommonWebButton(
                onPressed: onSave,
                iconData: Icons.save_outlined,
                label: 'Save',
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                iconSize: 20,
                spacing: 8,
                textStyle: AppTypography.labelLarge(context).copyWith(
                  color: context.colors.onPrimary,
                ),
                backgroundColor: context.appColors.accent,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                iconColor: context.colors.onPrimary,
              ),
            ),
           /* const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    svgLeftArrow,
                    height: 30,
                    width: 30,
                  ),
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                Text(
                  newContact,
                  style: AppStyles.webRouteText,
                ),
              ],
            ),*/
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: formKey,
                  child: _buildFormFields(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: AppBreakpoints.formWidthTablet,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: CommonWebButton(
                    onPressed: onSave,
                    iconData: Icons.save_outlined,
                    label: 'Save',
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 0.0),
                    iconSize: 20,
                    spacing: 8,
                    textStyle: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: context.appColors.accent,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    iconColor: context.colors.onPrimary,
                  ),
                ),
              /*  const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        svgLeftArrow,
                        height: 30,
                        width: 30,
                      ),
                      onPressed: onBack,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      newContact,
                      style: AppStyles.webRouteText,
                    ),
                  ],
                ),*/
                const SizedBox(height: 24),
                Form(
                  key: formKey,
                  child: _buildFormFields(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        SimpleTextFormField(
          textCapitalization: true,
          inputAction: TextInputAction.next,
          controller: firstNameController,
          labelText: firstName,
          autofillHints: const [AutofillHints.givenName],
        ),
        SimpleTextFormField(
          textCapitalization: true,
          inputAction: TextInputAction.next,
          controller: lastNameController,
          labelText: lastName,
          autofillHints: const [AutofillHints.familyName],
        ),
        SimpleTextFormField(
          textCapitalization: true,
          inputAction: TextInputAction.next,
          controller: companyController,
          labelText: company,
          autofillHints: const [AutofillHints.organizationName],
        ),
        ...emailControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SimpleTextFormField(
                        inputAction: TextInputAction.done,
                        controller: controller,
                        labelText: emailTxt,
                        validator: formValidation.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: IconButton(
                        onPressed: () {
                          if (emailControllers.length > 1) {
                            onAddRemoveEmail('remove', index);
                          } else {
                            onAddRemoveEmail('add', index);
                          }
                        },
                        icon: SvgPicture.asset(
                          emailControllers.length > 1
                              ? svgRemoveEmail
                              : svgAddEmail,
                          height: 29,
                          width: 29,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index == emailControllers.length - 1 &&
                  emailControllers.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 0, bottom: 25),
                      child: IconButton(
                        onPressed: () {
                          onAddRemoveEmail('add', index);
                        },
                        icon: SvgPicture.asset(
                          svgAddEmail,
                          height: 29,
                          width: 29,
                        ),
                      ),
                    ),
                  ],
                )
            ],
          );
        }),
      ],
    );
  }
}
