import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/form_validation.dart';
import '../../../../widgets/common_web_button.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../../widgets/text_form_field.dart';

class EditContactTabletLayoutRiverpod extends StatelessWidget {
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
  final bool isLoading;

  const EditContactTabletLayoutRiverpod({
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
    this.isLoading = false,
  });

  bool _isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscape(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isLandscape
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _Header(onBack: onBack),
                  // const SizedBox(height: 24),
                  _SaveButton(onSave: onSave),
                  const SizedBox(height: 24),
                  Expanded(child: _FormSection(this)),
                ],
              )
            : SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  width: AppBreakpoints.formWidthTablet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SaveButton(onSave: onSave),
                      const SizedBox(height: 24),
                      // _Header(onBack: onBack),
                      const SizedBox(height: 24),
                      _FormSection(this),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Save Button
//////////////////////////////////////////////////////////////////////////////

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: CommonWebButton(
        onPressed: onSave,
        iconAsset: svgUpdateProfile,
        label: save,
        padding: EdgeInsets.zero,
        iconSize: 20,
        textStyle: AppTypography.labelLarge(context).copyWith(
          color: context.colors.onPrimary,
        ),
        backgroundColor: context.appColors.accent,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        iconColor: context.colors.onPrimary,
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Form Section
//////////////////////////////////////////////////////////////////////////////

class _FormSection extends StatelessWidget {
  final EditContactTabletLayoutRiverpod parent;

  const _FormSection(this.parent);

  @override
  Widget build(BuildContext context) {
    return DelayedLoadingOverlay(
      isLoading: parent.isLoading,
      child: SingleChildScrollView(
        controller: parent.scrollController,
        child: Form(
          key: parent.formKey,
          child: Column(
            children: [
              _textField(parent.firstNameController, firstName, autofillHints: const [AutofillHints.givenName]),
              _textField(parent.lastNameController, lastName, autofillHints: const [AutofillHints.familyName]),
              _textField(parent.companyController, company, autofillHints: const [AutofillHints.organizationName]),
              ..._emailFields(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    Iterable<String>? autofillHints,
  }) {
    return SimpleTextFormField(
      textCapitalization: true,
      inputAction: TextInputAction.next,
      controller: controller,
      labelText: label,
      autofillHints: autofillHints,
    );
  }

  List<Widget> _emailFields() {
    return parent.emailControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      final hasMultiple = parent.emailControllers.length > 1;
      final isLast = index == parent.emailControllers.length - 1;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SimpleTextFormField(
                    inputAction: TextInputAction.done,
                    controller: controller,
                    labelText: emailTxt,
                    validator: parent.formValidation.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: hasMultiple ? svgRemoveEmail : svgAddEmail,
                  onTap: () => parent.onAddRemoveEmail(
                    hasMultiple ? 'remove' : 'add',
                    index,
                  ),
                ),
              ],
            ),
          ),
          if (isLast && hasMultiple)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: _IconAction(
                  icon: svgAddEmail,
                  onTap: () => parent.onAddRemoveEmail('add', index),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Icon Button
//////////////////////////////////////////////////////////////////////////////

class _IconAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: IconButton(
        onPressed: onTap,
        icon: SvgPicture.asset(icon, height: 29, width: 29),
      ),
    );
  }
}
