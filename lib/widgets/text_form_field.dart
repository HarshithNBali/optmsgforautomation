import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextCapitalization textCapitalization;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool readOnly;
  final TextInputType keyboardType; // New parameter for keyboard type
  final bool showRightIcon;
  final VoidCallback? onChange; // New parameter for onChange event
  final TextInputFormatter? inputFormatter;
  final String? rightIcon;
  final TextInputAction? inputAction;
  final String? name;
  final Color? borderColor;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final Iterable<String>? autofillHints;
  const CustomTextFormField(
      {super.key,
      required this.controller,
      this.textCapitalization = TextCapitalization.none,
      required this.labelText,
      this.validator,
      this.isPassword = false,
      this.readOnly = false,
      this.keyboardType = TextInputType.text, // Default to TextInputType.text
      this.showRightIcon = false,
      this.onChange, // Optional onChange event
      this.inputFormatter,
      this.rightIcon,
      this.inputAction,
      this.name,
      this.borderColor,
      this.fillColor,
      this.hintStyle,
      this.style,
      this.autofillHints});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override

  /// Builds a custom text form field widget.
  ///
  /// It displays a text field with a hint text and a border.
  /// If the user types something in the text field, the `onChanged` callback is called.
  /// If the user focuses the text field, the border is styled with a blue color.
  /// If the user unfocuses the text field, the border is styled with a light grey color.
  /// If the user taps the text field, the `onTap` callback is called.
  /// The text field is also decorated with a padding of 10.0 horizontally and 5.0 vertically.
  /// The text field is also styled with a light grey background color.
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        textCapitalization: widget.textCapitalization,
        autocorrect: false,
        enableIMEPersonalizedLearning: false,
        enableSuggestions: false,
        autofillHints: widget.autofillHints,
        textInputAction: widget.inputAction,
        controller: widget.controller,
        inputFormatters:
            widget.inputFormatter != null ? [widget.inputFormatter!] : null,
        onChanged: (value) {
          if (widget.onChange != null) {
            widget.onChange!(); // Call onChange event if provided
          }
          if (widget.name == 'username' ||
              widget.name == 'first name' ||
              widget.name == 'last name') {
            final cursorPosition = widget.controller.selection.baseOffset;
            final spacesBeforeCursor =
                value.substring(0, cursorPosition).split(' ').length - 1;
            final newText = value.replaceAll(' ', '');
            final newCursorPosition = cursorPosition - spacesBeforeCursor;

            // Update the controller's text and adjust the cursor position
            widget.controller.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: newCursorPosition),
            );
          }
          setState(() {
            widget.showRightIcon;
          });
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          helperText: ' ',
          errorStyle: const TextStyle(color: AppStyles.clickableTextColor),
          errorMaxLines: 2,
          hintText: widget.labelText,
          hintStyle: widget.hintStyle ?? TextStyle(color: Theme.of(context).extension<AppColorsExtension>()?.formFieldHint ?? AppStyles.grey, fontSize: 14.0, fontWeight: FontWeight.w400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).extension<AppColorsExtension>()?.formFieldBorder ?? AppStyles.secondaryColor, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).extension<AppColorsExtension>()?.formFieldBorder ?? AppStyles.secondaryColor, width: 0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: widget.fillColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
          suffixIconConstraints:
              const BoxConstraints(maxHeight: AppBreakpoints.actionSheetMaxWidth, maxWidth: AppBreakpoints.actionSheetMaxWidth),
          suffixIcon: widget.showRightIcon && widget.controller.text.length >= 3
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    widget.rightIcon!,
                  ),
                )
              : null,
        ),
        style: widget.style ?? AppTypography.titleMedium(context).copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        validator: widget.validator,
        readOnly: widget.readOnly,
        obscureText: widget.isPassword,
        keyboardType: widget.keyboardType, // Use specified keyboard type
      ),
    );
  }
}

class SimpleTextFormField extends StatelessWidget {
  final bool? textCapitalization;
  final TextEditingController? controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool readOnly;
  final TextInputFormatter? inputFormatter;
  final TextInputType keyboardType; // New parameter for keyboard type
  final void Function(String)? onChanged; // New parameter for onChange
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? inputAction;
  final Iterable<String>? autofillHints;
  const SimpleTextFormField({
    super.key,
    this.textCapitalization,
    this.controller,
    required this.labelText,
    this.validator,
    this.inputFormatter,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text, // Default to TextInputType.text
    this.onChanged,
    this.onFieldSubmitted,
    this.inputAction,
    this.autofillHints,
  });

  @override

  /// Builds a widget that displays a customizable text form field.
  ///
  /// The widget is wrapped in padding and a sized box to maintain consistent
  /// layout. The text form field provides various customization options
  /// including text capitalization, input action, keyboard type, and validation.
  ///
  /// The text form field's appearance is customized with a hint text, hint style,
  /// and border styles. It supports both enabled and focused states with distinct
  /// border styles. The background color is light grey with a slight opacity.
  ///
  /// Various properties such as `textCapitalization`, `inputAction`, `controller`,
  /// `keyboardType`, and `validator` can be configured. The field can be set to
  /// read-only or password mode based on the provided parameters. The text form
  /// field also supports `onChanged` and `onFieldSubmitted` callbacks.

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        child: TextFormField(
          cursorColor: Theme.of(context).colorScheme.onSurface,
          textCapitalization: textCapitalization != null
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          textInputAction: inputAction,
          autofillHints: autofillHints,
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: AppTypography.slogan(context),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          ),
          style: AppTypography.inboxTitle(context), // Input text color
          validator: validator,
          readOnly: readOnly,
          obscureText: isPassword,
          keyboardType: keyboardType, // Use specified keyboard type
          onChanged: onChanged,
          onFieldSubmitted:
              onFieldSubmitted, // Pass the callback to the TextFormField
        ),
      ),
    );
  }
}

class GrayTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String> validator;
  final bool isPassword;
  final Iterable<String>? autofillHints;

  const GrayTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.isPassword = false,
    this.autofillHints,
  });

  @override

  /// Builds a [TextFormField] widget with a light gray background, a bottom
  /// border, and a hint text. The field is validated based on the provided
  /// [validator] callback. The field can be set to read-only or password mode
  /// based on the provided parameters. The field also supports `onChanged` and
  /// `onFieldSubmitted` callbacks.
  ///
  /// The widget is styled with a light gray background, a bottom border, and a
  /// hint text. The field is filled with a light gray color and has a padding of
  /// 10.0 horizontally and 8.0 vertically. The border is an [OutlineInputBorder]
  /// with a light gray border color and a border width of 1.0. The field is also
  /// styled with a default border radius of 12.0.
  ///
  /// The [TextFormField] widget is constructed with the provided [controller],
  /// [labelText], [validator], and [isPassword] parameters. The field is set to
  /// read-only or password mode based on the value of [isPassword].
  ///
  /// The [TextFormField] widget also supports `onChanged` and `onFieldSubmitted`
  /// callbacks. The `onChanged` callback is called when the text field is changed.
  /// The `onFieldSubmitted` callback is called when the text field is submitted.
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      ),
      validator: validator,
      obscureText: isPassword, // Set this to true for password fields
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.text, // Customize keyboard type
    );
  }
}

// H-10: Converted to StatefulWidget so TapGestureRecognizer instances are
// created once and properly disposed, preventing gesture arena slot leaks
// that occurred when recognizers were created on every build() call.
class ClickableText extends StatefulWidget {
  final String firstText;
  final Color firstTextColor;
  final String secondText;
  final Color secondTextColor;
  final VoidCallback? onTap;

  final String? thirdText;
  final Color? thirdTextColor;
  final String? fourthText;
  final Color? fourthTextColor;
  final VoidCallback? onTap2;

  const ClickableText({
    super.key,
    required this.firstText,
    required this.firstTextColor,
    required this.secondText,
    required this.secondTextColor,
    this.onTap,
    this.thirdText,
    this.thirdTextColor,
    this.fourthText,
    this.fourthTextColor,
    this.onTap2,
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  late final TapGestureRecognizer _recognizer2;
  late final TapGestureRecognizer _recognizer4;

  @override
  void initState() {
    super.initState();
    _recognizer2 = TapGestureRecognizer()..onTap = widget.onTap;
    _recognizer4 = TapGestureRecognizer()..onTap = widget.onTap2;
  }

  @override
  void didUpdateWidget(ClickableText old) {
    super.didUpdateWidget(old);
    if (widget.onTap != old.onTap) _recognizer2.onTap = widget.onTap;
    if (widget.onTap2 != old.onTap2) _recognizer4.onTap = widget.onTap2;
  }

  @override
  void dispose() {
    _recognizer2.dispose();
    _recognizer4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.firstText,
            style: AppTypography.labelLarge(context).copyWith(
                color: widget.firstTextColor,
                fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: widget.secondText,
            style: AppTypography.labelLarge(context).copyWith(
                color: widget.secondTextColor,
                fontWeight: FontWeight.w600),
            recognizer: _recognizer2,
          ),
          TextSpan(
            text: widget.thirdText,
            style: AppTypography.labelLarge(context).copyWith(
                color: widget.thirdTextColor,
                fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: widget.fourthText,
            style: AppTypography.labelLarge(context).copyWith(
                color: widget.fourthTextColor,
                fontWeight: FontWeight.w600),
            recognizer: _recognizer4,
          ),
        ],
      ),
    );
  }
}
