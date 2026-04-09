import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class PromoCodeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool readOnly;
  final TextInputType keyboardType;
  final bool showRightText;
  final VoidCallback? onChange;
  final TextInputFormatter? inputFormatter;
  final String? rightText;
  final TextInputAction? inputAction;
  final String? name;
  final bool isEnabled;
  final VoidCallback? onSuffixTap;
  final FocusNode? focusNode;

  const PromoCodeTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.showRightText = false,
    this.onChange,
    this.inputFormatter,
    this.rightText,
    this.inputAction,
    this.name,
    this.isEnabled = true,
    this.onSuffixTap,
    this.focusNode,
  });

  @override
  State<PromoCodeTextField> createState() => _PromoCodeTextFieldState();
}

class _PromoCodeTextFieldState extends State<PromoCodeTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(color: context.appColors.formFieldBorder, width: 0.5),
      ),
      child: TextFormField(
        enabled: widget.isEnabled,
        focusNode: widget.focusNode,
        textInputAction: widget.inputAction,
        controller: widget.controller,
        inputFormatters:
            widget.inputFormatter != null ? [widget.inputFormatter!] : null,
        onChanged: (value) {
          if (widget.onChange != null) {
            widget.onChange!();
          }
          setState(() {});
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          helperText: null,
          errorText: null,
          errorStyle: TextStyle(color: context.appColors.accent),
          errorMaxLines: 2,
          hintText: widget.labelText,
          hintStyle: AppTypography.hintText(context),
          contentPadding: const EdgeInsets.only(
              left: 10, right: 10, top: 16, bottom: 16),
          filled: false,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: widget.showRightText
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onSuffixTap,
                    child: Center(
                      widthFactor: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.rightText ?? '',
                          style: TextStyle(
                              color: context.appColors.accent),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 80, minHeight: 48),
        ),
        style: AppTypography.appBarTitle1(context),
        validator: widget.validator,
        readOnly: widget.readOnly,
        obscureText: widget.isPassword,
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
