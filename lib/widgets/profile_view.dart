import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import 'package:optmsg/constant/app_typography.dart';

class CustomRowWidget extends StatelessWidget {
  final TextCapitalization textCapitalization;
  final String iconPath;
  final String labelText;
  final bool editable;
  final String? hintText;
  final String? lastIconPath;
  final String? lastIconText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onPressedFormField;
  final TextInputFormatter? inputFormatter;
  final TextInputAction? inputAction;
  final bool applyBorder;

  const CustomRowWidget({
    super.key,
    this.textCapitalization = TextCapitalization.none,
    required this.iconPath,
    required this.labelText,
    required this.editable,
    this.hintText,
    this.lastIconPath,
    this.lastIconText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputDecoration,
    this.textStyle,
    this.onTap,
    this.onPressedFormField,
    this.inputFormatter,
    this.inputAction,
    this.validator,
    this.applyBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              context.colors.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: AppTypography.caption(context).copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                textCapitalization: textCapitalization,
                textInputAction: inputAction,
                inputFormatters:
                    inputFormatter != null ? [inputFormatter!] : null,
                controller: controller,
                keyboardType: keyboardType,
                enabled: editable,
                style: textStyle ??
                    AppTypography.titleMedium(context).copyWith(
                      color: context.colors.onSurface,
                    ),
                validator: validator,
                onTap: onPressedFormField,
                decoration: inputDecoration ?? _buildDecoration(context),
              ),
            ],
          ),
        ),
        if (lastIconPath != null) ...[
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: onTap,
                child: SvgPicture.asset(
                  lastIconPath!,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (lastIconText != null)
                Text(lastIconText!, style: AppTypography.cantEdit(context)),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final hintStyle = AppTypography.titleMedium(context).copyWith(
      color: context.colors.onSurfaceVariant,
    );

    if (!applyBorder) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.outlineVariant),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.outlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.primary),
      ),
    );
  }
}
