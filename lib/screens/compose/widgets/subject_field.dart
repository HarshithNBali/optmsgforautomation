import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';

/// Subject text field for the compose screen.
class SubjectField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SubjectField({
    super.key,
    required this.controller,
    this.onChanged,
    this.testId,
  });

  final String? testId;

  static const _noBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).nextFocus(),
        child: Row(
          children: [
            Text('Subject: ', style: AppTypography.emailLabel(context)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
              key: testId != null ? Key(testId!) : null,
              controller: controller,
              style: AppTypography.emailAddress(context),
              decoration: const InputDecoration(
                border: _noBorder,
                enabledBorder: _noBorder,
                focusedBorder: _noBorder,
                errorBorder: _noBorder,
                disabledBorder: _noBorder,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                hintText: '',
              ),
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
            ),
          ),
          ],
        ),
      ),
    );
  }
}
