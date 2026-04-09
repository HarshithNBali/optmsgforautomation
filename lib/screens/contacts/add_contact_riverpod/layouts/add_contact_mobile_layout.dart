import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/form_validation.dart';
import '../../../../widgets/button_form_field.dart';
import '../../../../widgets/text_form_field.dart';

class AddContactMobileLayoutRiverpod extends StatelessWidget {
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

  const AddContactMobileLayoutRiverpod({
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Form(
                        key: formKey,
                        child: Column(
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
                                              emailControllers.length > 1 ? svgRemoveEmail : svgAddEmail,
                                              height: 29,
                                              width: 29,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index == emailControllers.length - 1 && emailControllers.length > 1)
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Save button at the bottom
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: formKey,
                  child: Column(
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
                                  SizedBox(
                                    width: screenWidth * 1 - 85,
                                    child: SimpleTextFormField(
                                      inputAction: TextInputAction.done,
                                      controller: controller,
                                      labelText: emailTxt,
                                      validator: formValidation.validateEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [AutofillHints.email],
                                    ),
                                  ),
                                  if (emailControllers.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 5),
                                      child: IconButton(
                                        onPressed: () {
                                          onAddRemoveEmail('remove', index);
                                        },
                                        icon: SvgPicture.asset(
                                          svgRemoveEmail,
                                          height: 29,
                                          width: 29,
                                        ),
                                      ),
                                    ),
                                  if (emailControllers.length == 1)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 5),
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
                                    )
                                ],
                              ),
                            ),
                            if (index == emailControllers.length - 1 && emailControllers.length > 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 2, bottom: 25),
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
                  ),
                ),
              ),
            ),
            // Save button at the bottom
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
