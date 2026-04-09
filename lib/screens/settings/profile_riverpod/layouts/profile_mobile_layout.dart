import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../services/adaptive_service.dart';
import '../../../../widgets/button_form_field.dart' show CustomGradientButton;
import '../../../../widgets/profile_dob_picker.dart';
import '../../../../widgets/profile_view.dart';
import '../profile_notifier.dart';

class ProfileMobileLayout extends ConsumerWidget {
  const ProfileMobileLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Form(
          key: notifier.formKey,
          child: Column(
            children: [
              if (!state.isEdit)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: notifier.enableEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(editProfile),
                  ),
                ),
              CustomRowWidget(
                iconPath: svgUser,
                labelText: firstName,
                editable: state.isEdit,
                controller: notifier.firstNameCtrl,
                validator: notifier.validator.validateFirstName,
                applyBorder: state.isEdit,
              ),

              const SizedBox(height: 20),

              CustomRowWidget(
                iconPath: svgUser,
                labelText: lastName,
                editable: state.isEdit,
                controller: notifier.lastNameCtrl,
                validator: notifier.validator.validateLastName,
                applyBorder: state.isEdit,
              ),

              const SizedBox(height: 20),

              ProfileDobPicker(
                iconPath: svgDob,
                labelText: dob,
                editable: state.isEdit,
                controller: notifier.dobCtrl,
                validator: notifier.validator.validateDob,
                applyBorder: state.isEdit,
              ),

              if (!state.isEdit) ...[
                const SizedBox(height: 20),
                CustomRowWidget(
                  iconPath: svgUser,
                  labelText: userName,
                  editable: false,
                  lastIconText: cantEdit,
                  controller: notifier.usernameCtrl,
                ),
                const SizedBox(height: 20),
                CustomRowWidget(
                  iconPath: svgEmail,
                  labelText: emailTxt,
                  editable: false,
                  lastIconText: cantEdit,
                  controller: notifier.emailCtrl,
                ),
              ],

              const SizedBox(height: 20),

              CustomRowWidget(
                iconPath: svgCall,
                labelText: mobileNumber,
                editable: state.isEdit,
                controller: notifier.phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatter:
                    FilteringTextInputFormatter.digitsOnly,
                validator: notifier.validator.validatePhoneNumber,
                applyBorder: state.isEdit,
              ),

              SizedBox(
                height: AdaptiveService.screenHeight(context) * 0.09,
              ),

              if (state.isEdit)
                CustomGradientButton(
                  text: 'Update Profile',
                  onPressed: () => notifier.submitProfile(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
