import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/form_validation.dart';
import '../../../../widgets/button_form_field.dart';
import '../../../../widgets/text_form_field.dart';

class EditContactMobileLayoutRiverpod extends StatelessWidget {
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

  const EditContactMobileLayoutRiverpod({
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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isPortrait ? 8 : 16,
          8,
          isPortrait ? 8 : 16,
          15,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: formKey,
                  child: _formFields(context, isPortrait),
                ),
              ),
            ),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // -------------------- FORM --------------------

  Widget _formFields(BuildContext context, bool isPortrait) {
    return Column(
      children: [
        _textField(firstNameController, firstName, autofillHints: const [AutofillHints.givenName]),
        _textField(lastNameController, lastName, autofillHints: const [AutofillHints.familyName]),
        _textField(companyController, company, autofillHints: const [AutofillHints.organizationName]),
        ..._emailFields(context, isPortrait),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String label, {Iterable<String>? autofillHints}) {
    return SimpleTextFormField(
      textCapitalization: true,
      inputAction: TextInputAction.next,
      controller: controller,
      labelText: label,
      autofillHints: autofillHints,
    );
  }

  // -------------------- EMAIL FIELDS --------------------

  List<Widget> _emailFields(BuildContext context, bool isPortrait) {
    return emailControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      final isLast = index == emailControllers.length - 1;
      final hasMultiple = emailControllers.length > 1;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _emailRow(
              context: context,
              controller: controller,
              index: index,
              isPortrait: isPortrait,
              hasMultiple: hasMultiple,
            ),
          ),
          if (isLast && hasMultiple) _addEmailButton(index, isPortrait),
        ],
      );
    }).toList();
  }

  Widget _emailRow({
    required BuildContext context,
    required TextEditingController controller,
    required int index,
    required bool isPortrait,
    required bool hasMultiple,
  }) {
    final emailField = SimpleTextFormField(
      inputAction: TextInputAction.done,
      controller: controller,
      labelText: emailTxt,
      validator: formValidation.validateEmail,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPortrait)
          SizedBox(
            width: MediaQuery.of(context).size.width - 85,
            child: emailField,
          )
        else
          Expanded(child: emailField),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: _emailActionButton(
            icon: hasMultiple ? svgRemoveEmail : svgAddEmail,
            onTap: () => _handleEmailAction(index, hasMultiple),
          ),
        ),
      ],
    );
  }

  Widget _addEmailButton(int index, bool isPortrait) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: isPortrait ? 2 : 0,
            bottom: 25,
          ),
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

  void _handleEmailAction(int index, bool hasMultiple) {
    onAddRemoveEmail(hasMultiple ? 'remove' : 'add', index);
  }

  // -------------------- SAVE BUTTON --------------------

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: CustomGradientButton(
          onPressed: onSave,
          text: save,
          leadingIcon: SvgPicture.asset(
            svgUpdateProfile,
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }
}
