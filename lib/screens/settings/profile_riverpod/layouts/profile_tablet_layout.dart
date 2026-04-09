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

class ProfileTabletLayout extends ConsumerWidget {
  const ProfileTabletLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Form(
          key: notifier.formKey,
          child: Column(
            children: [
              _HeaderActions(onSubmit: () => notifier.submitProfile()),
              const SizedBox(height: 20),
              const _ProfileFormCard(),
              if (state.isEdit) const SizedBox(height: AppStyles.space8),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Header Actions
//////////////////////////////////////////////////////////////////////////////

class _HeaderActions extends ConsumerWidget {
  final VoidCallback onSubmit;

  const _HeaderActions({
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Row(
      children: [
        SizedBox(
          width: state.isEdit ? 210 : 170,
          child: CommonWebButton(
            onPressed:
            state.isEdit ? onSubmit : notifier.enableEdit,
            label: state.isEdit ? 'Update Profile' : editProfile,
            iconAsset:
            state.isEdit ? svgUpdateProfile : svgCompose,
            iconSize: 20,
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Profile Card
//////////////////////////////////////////////////////////////////////////////

class _ProfileFormCard extends ConsumerWidget {
  const _ProfileFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfileFieldRow(
            left: _profileField(
              icon: svgUser,
              label: firstName,
              controller: notifier.firstNameCtrl,
              editable: state.isEdit,
              validator: notifier.validator.validateFirstName,
            ),
            right: _profileField(
              icon: svgUser,
              label: lastName,
              controller: notifier.lastNameCtrl,
              editable: state.isEdit,
              validator: notifier.validator.validateLastName,
            ),
          ),
          const SizedBox(height: 20),

          _ProfileFieldRow(
            left: ProfileDobPicker(
              iconPath: svgDob,
              labelText: dob,
              editable: state.isEdit,
              controller: notifier.dobCtrl,
              validator: notifier.validator.validateDob,
              applyBorder: state.isEdit,
            ),
            right: _profileField(
              icon: svgCall,
              label: mobileNumber,
              controller: notifier.phoneCtrl,
              editable: state.isEdit,
              keyboardType: TextInputType.phone,
              inputFormatter:
              FilteringTextInputFormatter.digitsOnly,
              validator:
              notifier.validator.validatePhoneNumber,
            ),
          ),
          const SizedBox(height: 20),

          if (!state.isEdit)
            _ProfileFieldRow(
              left: _readonlyField(
                icon: svgEmail,
                label: emailTxt,
                controller: notifier.emailCtrl,
              ),
              right: _readonlyField(
                icon: svgUser,
                label: userName,
                controller: notifier.usernameCtrl,
              ),
            ),
        ],
      ),
    );
  }

  static Widget _profileField({
    required String icon,
    required String label,
    required TextEditingController controller,
    required bool editable,
    TextInputType? keyboardType,
    TextInputFormatter? inputFormatter,
    String? Function(String?)? validator,
  }) {
    return CustomRowWidget(
      iconPath: icon,
      labelText: label,
      editable: editable,
      controller: controller,
      inputFormatter: inputFormatter,
      validator: validator,
      applyBorder: editable,
    );
  }

  static Widget _readonlyField({
    required String icon,
    required String label,
    required TextEditingController controller,
  }) {
    return CustomRowWidget(
      iconPath: icon,
      labelText: label,
      editable: false,
      lastIconText: cantEdit,
      controller: controller,
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Shared Row Wrapper
//////////////////////////////////////////////////////////////////////////////

class _ProfileFieldRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ProfileFieldRow({
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 32),
        Expanded(child: right),
      ],
    );
  }
}

