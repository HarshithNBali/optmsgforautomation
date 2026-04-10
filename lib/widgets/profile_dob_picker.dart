import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:intl/intl.dart';

class ProfileDobPicker extends StatelessWidget {
  final String iconPath;
  final String labelText;
  final bool editable;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onPressedFormField;
  final TextInputFormatter? inputFormatter;
  final String? currentDate;
  final bool applyBorder;
  final String? testId;

  const ProfileDobPicker({
    super.key,
    required this.iconPath,
    required this.labelText,
    required this.editable,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textStyle,
    this.onPressedFormField,
    this.inputFormatter,
    this.validator,
    this.currentDate,
    this.applyBorder = false,
    this.testId,
  });

  @override

  /// A widget that displays a text field with a hint text and a calendar icon
  /// as a suffix icon. When the icon is tapped, a date picker dialog is shown.
  /// If the user selects a date, the date is formatted as 'MM/dd/yyyy' and set
  /// as the text of the text field.
  ///
  /// The widget also validates the input. If the input is not a valid date,
  /// an error message is displayed.
  ///
  /// The text field is decorated with a light grey border and a white background
  /// color. The hint text is in a light grey color.
  ///
  /// The calendar icon is a grey SVG image.
  ///
  /// The widget is typically used to input a date of birth.
  ///
  /// The [controller] parameter is the controller of the text field.
  /// The [labelText] parameter is the hint text of the text field.
  /// The [validator] parameter is the validator of the text field.
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                    key: testId != null ? Key(testId!) : null,
                    enabled: editable,
                    readOnly:
                        editable, // Make read-only when editable so calendar icon works
                    style: textStyle ??
                        AppTypography.titleMedium(context).copyWith(
                          color: context.colors.onSurface,
                        ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: controller,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.datetime,
                    maxLength: 10,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      // Allow the display format (dd MMMM, yyyy) to be entered
                      // No auto-formatting needed as date picker handles the formatting
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: hintText,
                      hintStyle: AppTypography.titleMedium(context).copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 0,
                      ),
                      border: applyBorder
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.outlineVariant,
                              ),
                            )
                          : InputBorder.none,
                      enabledBorder: applyBorder
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.outlineVariant,
                              ),
                            )
                          : InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: applyBorder
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.primary,
                              ),
                            )
                          : InputBorder.none,
                      suffixIconConstraints: const BoxConstraints(
                        maxHeight: 32,
                        maxWidth: 32,
                      ),
                      suffixIcon: editable
                          ? InkWell(
                              key: testId != null ? Key('${testId}_calendar') : null,
                              onTap: () async {
                                DateTime initialDate = DateTime.now();
                                if (currentDate != null &&
                                    currentDate!.isNotEmpty) {
                                  try {
                                    // Try parsing display format first (dd MMMM, yyyy) - this is what's shown when editing
                                    DateTime? parsedDate =
                                        DateFormat('dd MMMM, yyyy')
                                            .parse(currentDate!, true);
                                    initialDate = parsedDate;
                                  } catch (e) {
                                    try {
                                      // If that fails, try parsing MM/dd/yyyy format
                                      DateTime? parsedDate =
                                          DateFormat('MM/dd/yyyy')
                                              .parse(currentDate!, true);
                                      initialDate = parsedDate;
                                    } catch (e2) {
                                      try {
                                        // If that fails, try parsing ISO format (yyyy-MM-dd)
                                        initialDate =
                                            DateTime.parse(currentDate!);
                                      } catch (e3) {
                                        // If all parsing fails, use current date
                                        initialDate = DateTime.now();
                                      }
                                    }
                                  }
                                }

                                DateTime? selectedDate = await showDatePicker(
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );

                                if (selectedDate != null) {
                                  // Format as display format: dd MMMM, yyyy (e.g., "12 September, 2004")
                                  String formattedDate =
                                      DateFormat('MMMM dd, yyyy')
                                          .format(selectedDate);
                                  controller.text = formattedDate;
                                }
                              },
                              child: SvgPicture.asset(
                                svgCalendar,
                                height: 20,
                                width: 20,
                                colorFilter: ColorFilter.mode(
                                    context.colors.onSurfaceVariant, BlendMode.srcIn),
                              ),
                            )
                          : null,
                    ),
                    validator: validator,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
