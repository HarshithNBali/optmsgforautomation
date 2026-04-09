import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/app_typography.dart';

class DateOfBirthPicker extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String> validator;
  final bool? readOnly;

  const DateOfBirthPicker(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.validator,
      this.readOnly});

  @override

  /// A widget that displays a date picker.
  ///
  /// It displays a text field with a hint text and a calendar icon
  /// as a suffix icon. When the icon is tapped, a date picker dialog
  /// is shown. If the user selects a date, the date is formatted as
  /// 'MM/dd/yyyy' and set as the text of the text field.
  ///
  /// The widget also validates the input. If the input is not a valid
  /// date, an error message is displayed.
  ///
  /// The text field is decorated with a light grey border and a white
  /// background color. The hint text is in a light grey color.
  ///
  /// The calendar icon is a grey SVG image.
  ///
  /// The widget is typically used to input a date of birth.
  ///
  /// The [controller] parameter is the controller of the text field.
  /// The [labelText] parameter is the hint text of the text field.
  /// The [validator] parameter is the validator of the text field.
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        keyboardType: TextInputType.datetime,
        maxLength: 10,
        readOnly: readOnly ?? false,
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          String formattedValue = value
              .replaceAllMapped(
                RegExp(r'^(\d{2})(\d{1})$'),
                (match) => '${match.group(1)}/' '${match.group(2)}',
              )
              .replaceAllMapped(
                RegExp(r'^(\d{2}/\d{2})(\d+)$'),
                (match) => '${match.group(1)}/' '${match.group(2)}',
              )
              .replaceAll(RegExp(r'[^\d/]'), '');
          controller.value = TextEditingValue(
            text: formattedValue,
            selection: TextSelection.collapsed(offset: formattedValue.length),
          );
        },
        decoration: InputDecoration(
          counterText: '',
          helperText: ' ',
          hintText: labelText,
          suffixIcon: GestureDetector(
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (selectedDate != null) {
                String formattedDate =
                    DateFormat('MM/dd/yyyy').format(selectedDate);

                controller.text = formattedDate;
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                svgCalendar,
                height: 24,
                width: 24,
              ),
            ),
          ),
        ),
        style: AppTypography.appBarTitle1(context),
        validator: validator,
      ),
    );
  }
}
