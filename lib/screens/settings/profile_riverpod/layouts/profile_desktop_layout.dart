import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../widgets/common_web_button.dart';
import '../../../../widgets/profile_dob_picker.dart';
import '../../../../widgets/profile_view.dart';
import '../profile_notifier.dart';

class ProfileDesktopLayout extends ConsumerWidget {
  const ProfileDesktopLayout({super.key});

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
              _buildHeaderActions(context, ref, hasWidth: false),
              const SizedBox(height: 20),
              _buildProfileFormCard(context, ref),

              if (state.isEdit) const SizedBox(height: AppStyles.space8),
            ],
          ),
        ),
      ),
    );
  }

  /// Shared header actions for tablet/desktop layouts
  Widget _buildHeaderActions(BuildContext context, WidgetRef ref, {required bool hasWidth}) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!state.isEdit)
              SizedBox(
                width: hasWidth ? 170 : null,
                child: CommonWebButton(
                  onPressed: notifier.enableEdit,
                  label: editProfile,
                  iconAsset: svgCompose,
                  iconSize: 20,
                ),
              )
            else
              SizedBox(
                width: hasWidth ? 210 : null,
                child: CommonWebButton(
                  onPressed: () => notifier.submitProfile(),
                  label: "Update Profile",
                  iconAsset: svgUpdateProfile,
                  iconSize: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Shared profile form card for tablet/desktop layouts
  Widget _buildProfileFormCard(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomRowWidget(
                    iconPath: svgUser,
                    labelText: firstName,
                    editable: state.isEdit,
                    controller: notifier.firstNameCtrl,
                    validator: notifier.validator.validateFirstName,
                    applyBorder: state.isEdit,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: CustomRowWidget(
                    iconPath: svgUser,
                    labelText: lastName,
                    editable: state.isEdit,
                    controller: notifier.lastNameCtrl,
                    validator: notifier.validator.validateLastName,
                    applyBorder: state.isEdit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ProfileDobPicker(
                    iconPath: svgDob,
                    labelText: dob,
                    editable: state.isEdit,
                    controller: notifier.dobCtrl,
                    validator: notifier.validator.validateDob,
                    applyBorder: state.isEdit,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: CustomRowWidget(
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
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!state.isEdit)
              Row(
                children: [
                  Expanded(
                    child: CustomRowWidget(
                      iconPath: svgEmail,
                      labelText: emailTxt,
                      editable: false,
                      lastIconText: cantEdit,
                      controller: notifier.emailCtrl,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: CustomRowWidget(
                      iconPath: svgUser,
                      labelText: userName,
                      editable: false,
                      lastIconText: cantEdit,
                      controller: notifier.usernameCtrl,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
