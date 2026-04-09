import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/form_validation.dart';
import '../../../../widgets/common_web_button.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../../widgets/text_form_field.dart';

class EditContactDesktopLayoutRiverpod extends StatelessWidget {
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

  const EditContactDesktopLayoutRiverpod({
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

  @override
  Widget build(BuildContext context) {
    return DelayedLoadingOverlay(
      isLoading: isLoading,
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: AppBreakpoints.formWidthDesktop,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _saveButton(context),
                  const SizedBox(height: 24),
                  _formFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- HEADER --------------------

  Widget _saveButton(BuildContext context) {
    return SizedBox(
      width: 100,
      child: CommonWebButton(
        onPressed: onSave,
        iconAsset: svgUpdateProfile,
        label: save,
        iconSize: 20,
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          color: context.colors.onPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: context.appColors.accent,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        iconColor: context.colors.onPrimary,
      ),
    );
  }

  // -------------------- FORM --------------------

  Widget _formFields() {
    return Column(
      children: [
        _textField(
          controller: firstNameController,
          label: firstName,
          autofillHints: const [AutofillHints.givenName],
        ),
        _textField(
          controller: lastNameController,
          label: lastName,
          autofillHints: const [AutofillHints.familyName],
        ),
        _textField(
          controller: companyController,
          label: company,
          autofillHints: const [AutofillHints.organizationName],
        ),
        ..._emailFields(),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    Iterable<String>? autofillHints,
  }) {
    return SimpleTextFormField(
      textCapitalization: true,
      controller: controller,
      labelText: label,
      autofillHints: autofillHints,
    );
  }

  // -------------------- EMAIL FIELDS --------------------

  List<Widget> _emailFields() {
    return emailControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      final isLast = index == emailControllers.length - 1;
      final hasMultiple = emailControllers.length > 1;

      return Column(
        children: [
          _emailRow(controller, index, hasMultiple),
          if (isLast && hasMultiple) _addEmailButton(index),
        ],
      );
    }).toList();
  }

  Widget _emailRow(
      TextEditingController controller,
      int index,
      bool hasMultiple,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
            child: _emailActionButton(
              icon: hasMultiple ? svgRemoveEmail : svgAddEmail,
              onTap: () => _handleEmailAction(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addEmailButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: _emailActionButton(
            icon: svgAddEmail,
            onTap: () => onAddRemoveEmail('add', index),
          ),
        ),
      ],
    );
  }

  Widget _emailActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        icon,
        height: 29,
        width: 29,
      ),
    );
  }

  // -------------------- LOGIC --------------------

  void _handleEmailAction(int index) {
    if (emailControllers.length > 1) {
      onAddRemoveEmail('remove', index);
    } else {
      onAddRemoveEmail('add', index);
    }
  }
}
