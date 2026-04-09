import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class TagInputField extends StatefulWidget {
  final void Function(String)? onSubmitted;
  final StringTagController tagController;
  final String prefixText;
  final IconData? icon;
  final VoidCallback? onPressed;

  const TagInputField(
      {super.key,
      this.onSubmitted,
      required this.tagController,
      required this.prefixText,
      this.icon,
      this.onPressed});

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  @override

  /// This method is called when the widget is inserted into the tree.
  ///
  /// It calls the [initState] method of its superclass.
  ///
  /// This method does not return a value.
  void initState() {
    super.initState();
  }

  @override

  /// Builds a widget that displays a prefix text, a text field, and a suffix icon.
  ///
  /// The prefix text is displayed with the style of [AppStyles.emailLabel].
  ///
  /// The text field is displayed with the style of [AppStyles.email].
  /// The text field is also displayed with a bottom border of [AppStyles.stroke].
  /// The text field is also displayed with a horizontal padding of 10.0.
  /// The text field is also displayed with a vertical padding of 8.0.
  /// The text field is also displayed with a focus node of [widget.tagController.getFocusNode].
  /// The text field is also displayed with a text editing controller of [widget.tagController].
  /// The text field is also displayed with a text separator of [' ', ','].
  /// The text field is also displayed with a letter case of [LetterCase.normal].
  /// The text field is also displayed with a validator that checks if the entered text is a valid email address.
  /// The text field is also displayed with a validator that checks if the entered text is already in the list of tags.
  /// The text field is also displayed with a suffix icon of [widget.icon].
  /// The text field is also displayed with an onSubmitted callback that calls the [widget.onSubmitted] callback with the entered tag value.
  ///
  /// The suffix icon is displayed with an onPressed callback that calls the [widget.onPressed] callback.
  ///
  /// The widget is returned as a [Container] with a height of 60.0.
  /// The widget is returned as a [Container] with a padding of 10.0.
  /// The widget is returned as a [Container] with a decoration of [BoxDecoration] with a border of [Border] with a bottom border of [BorderSide] with a color of [AppStyles.stroke] and a width of 1.0.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: context.colors.outlineVariant, width: 1))),
      height: 60, // Adjust the height as needed
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Text(
            widget.prefixText,
            style: AppTypography.emailLabel(context),
          ),
          const SizedBox(
              width: 10), // Adjust spacing between prefix and TextField
          Expanded(
            child: TextFieldTags<String>(
              textfieldTagsController: widget.tagController,
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                if (!_isValidEmail(tag)) {
                  return 'Please enter a valid email address';
                } else if (widget.tagController.getTags!.contains(tag)) {
                  return 'You\'ve already entered that';
                }
                return null;
              },
              inputFieldBuilder: (context, inputFieldValues) {
                return TextField(
                  onTap: () {
                    widget.tagController.getFocusNode?.requestFocus();
                  },
                  controller: inputFieldValues.textEditingController,
                  focusNode: inputFieldValues.focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    errorText: inputFieldValues.error,
                    prefixIconConstraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    prefixIcon: inputFieldValues.tags.isNotEmpty
                        ? SingleChildScrollView(
                            controller: inputFieldValues.tagScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 8,
                              ),
                              child: Wrap(
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children:
                                    inputFieldValues.tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      color: context.appColors.tintSecondary,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          child:
                                              Text(tag, style: AppTypography.emailAddress(context)),
                                          onTap: () {},
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          onTap: () {
                                            inputFieldValues.onTagRemoved(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(widget.icon),
                      onPressed: widget.onPressed,
                    ), // Icon at the end
                  ),
                  onChanged: inputFieldValues.onTagChanged,
                  onSubmitted: (value) {
                    // Call the onSubmitted callback with the entered tag value
                    if (widget.onSubmitted != null) {
                      widget.onSubmitted!(value);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Validates if the given email string is in a proper email format.
  ///
  /// Uses a regular expression to ensure the email follows a standard
  /// pattern, with an '@' symbol separating the local part and domain,
  /// and a valid domain extension.
  ///
  /// Returns `true` if the email is valid, otherwise `false`.

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
}
