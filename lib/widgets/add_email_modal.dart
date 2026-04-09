import 'dart:io';

import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/model/contact_list_model.dart';
// ignore: unused_import
import 'package:optmsg/screens/email/inbox_riverpod/inbox_responsive.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:optmsg/router/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/footer_button.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/email_sender_service.dart';

class AddEmailModal extends ConsumerStatefulWidget {
  final String? icon;
  final String title;
  final String? subtitleFirst;
  final String subtitle;
  final String type;
  final Contacts? contact;
  final dynamic saveFlag;
  final int currentIndex;
  final int totalEmails;
  final String? senderDisplayName;
  const AddEmailModal({
    super.key,
    this.icon,
    this.title = "",
    this.subtitleFirst = "",
    this.type = "",
    this.subtitle = "",
    this.saveFlag,
    this.contact,
    this.currentIndex = 0,
    this.totalEmails = 1,
    this.senderDisplayName,
  });

  @override
  ConsumerState<AddEmailModal> createState() => _AddEmailModalState();
}

class _AddEmailModalState extends ConsumerState<AddEmailModal> {
  final GlobalKey<FormState> _addContactFormKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _companyController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final _formValidationService = FormValidationService();

  @override
  void dispose() {
    // H-08: Dispose all controllers to prevent memory leaks (dialog shown frequently).
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    printLog("widget.type", widget.type);
    super.initState();
    setState(() {
      if (widget.contact != null) {
        _firstNameController.text = widget.contact!.firstName;
        _lastNameController.text = widget.contact!.lastName;
        _companyController.text = widget.contact!.company;
      } else if (widget.senderDisplayName != null &&
          widget.senderDisplayName!.trim().isNotEmpty) {
        final raw = widget.senderDisplayName!.trim();
        final parts = raw
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .toList();
        if (parts.length == 2) {
          final cap = CommonService().capitalize;
          _firstNameController.text = cap(parts[0].toLowerCase());
          _lastNameController.text = cap(parts[1].toLowerCase());
        } else {
          // 1 word or 3+ words → Company Name (preserve original casing)
          _companyController.text = raw;
        }
      }
      _emailController.text = widget.subtitleFirst!;
    });
  }

  bool get _isMultiple => widget.totalEmails > 1;
  bool get _isLastEmail => widget.currentIndex >= widget.totalEmails - 1;
  int get _remaining => widget.totalEmails - widget.currentIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.radiusXXL)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final double screenWidth = AppBreakpoints.screenWidth(context);
    final double dialogWidth =
        AppBreakpoints.isMobile(screenWidth) ? screenWidth * 0.8 : 500;
    return Stack(
      children: <Widget>[
        Center(
          child: PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26),
                    offset: const Offset(0, 10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _addContactFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // X close button (top-right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => context.pop('cancel-email'),
                            icon: Icon(Icons.close, size: 22, color: context.colors.onSurfaceVariant),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (widget.icon != null)
                        SvgPicture.asset(
                          widget.icon!,
                          width: widget.icon != null
                              ? AppBreakpoints.screenWidth(context) * 0.120
                              : 0,
                          height: widget.icon != null
                              ? AppBreakpoints.screenHeight(context) * 0.120
                              : 0,
                        ),
                      if (widget.title.isNotEmpty)
                        Text(
                          widget.title,
                          style: AppTypography.popUpTitle(context),
                          textAlign: TextAlign.center,
                        ),
                      // Progress indicator for multiple emails
                      if (_isMultiple)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Contact ${widget.currentIndex + 1} of ${widget.totalEmails}',
                            style: AppTypography.slogan(context).copyWith(
                              fontSize: 13,
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (widget.subtitle.isNotEmpty)
                        SizedBox(
                          height: AppBreakpoints.screenHeight(context) * 0.010,
                        ),
                      if (widget.subtitle.isNotEmpty)
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Add ",
                            style: AppTypography.slogan(context).copyWith(height: 1.4),
                            children: [
                              TextSpan(
                                text: "${widget.subtitleFirst} ",
                                style: AppTypography.inboxSubTitle(context).copyWith(
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: widget.subtitle,
                                style: AppTypography.slogan(context).copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: AppBreakpoints.screenHeight(context) * 0.010,
                      ),
                      SimpleTextFormField(
                        textCapitalization: true,
                        inputAction: TextInputAction.next,
                        controller: _firstNameController,
                        labelText: firstName,
                      ),
                      SimpleTextFormField(
                        textCapitalization: true,
                        inputAction: TextInputAction.next,
                        controller: _lastNameController,
                        labelText: lastName,
                      ),
                      SimpleTextFormField(
                        textCapitalization: true,
                        inputAction: TextInputAction.next,
                        controller: _companyController,
                        labelText: company,
                      ),
                      SimpleTextFormField(
                        readOnly: true,
                        inputAction: TextInputAction.done,
                        controller: _emailController,
                        labelText: emailTxt,
                        validator: _formValidationService.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: AppBreakpoints.screenHeight(context) * 0.010,
                      ),
                      // Primary row: Skip (outlined) + Save (filled)
                      FooterButton(
                        button1Color: context.colors.surface,
                        button1TextColor: context.colors.onSurface,
                        button1BorderColor: context.colors.outlineVariant,
                        button2Color: context.appColors.accent,
                        button2TextColor: context.colors.onPrimary,
                        button2BorderColor: Colors.transparent,
                        onPressedButton1: () async {
                          context.pop('skip');
                        },
                        onPressedButton2: () async {
                          FocusScope.of(context).unfocus();
                          if (_addContactFormKey.currentState!.validate()) {
                            final firstNameVal = _firstNameController.text
                                .trim();
                            final lastNameVal = _lastNameController.text.trim();
                            final companyVal = _companyController.text.trim();

                            if (firstNameVal.isEmpty &&
                                lastNameVal.isEmpty &&
                                companyVal.isEmpty) {
                              CommonService.animatedToast(
                                'Please fill in First Name, Last Name, or Company Name',
                                'error',
                              );
                              return;
                            }
                            await addContact(context);
                          }
                        },
                        textButton1: 'Skip',
                        textButton2: save,
                      ),
                      // Secondary: Add to Existing button
                      if (widget.type == "Multiple" ||
                          widget.type == "longPress" ||
                          widget.type == "Single" ||
                          widget.type == "optin")
                        SizedBox(
                          height: AppBreakpoints.screenHeight(context) * 0.010,
                        ),
                      if (widget.type == "Multiple" ||
                          widget.type == "longPress" ||
                          widget.type == "Single" ||
                          widget.type == "optin")
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: addExisting,
                                child: Container(
                                  height: 57,
                                  decoration: BoxDecoration(
                                    color: context.colors.onSurfaceVariant,
                                    border: Border.all(color: context.colors.outlineVariant),
                                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Add to Existing",
                                      style: AppTypography.button(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      // Tertiary: Skip All & Send (text link, only for multiple with 2+ remaining)
                      if (_isMultiple && !_isLastEmail)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextButton(
                            onPressed: () => context.pop('skip_all'),
                            child: Text(
                              'Skip All & Send ($_remaining remaining)',
                              style: AppTypography.alfaSelectedListText(context).copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void addExisting() {
    context.pop('existing_contact');
  }

  Future<void> addContact(BuildContext context) async {
    String url = widget.contact != null
        ? 'contact/edit-contact'
        : 'contact/add';
    Map<String, dynamic> data;
    if (widget.contact != null) {
      data = {
        "contactId": widget.contact!.id,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "company": _companyController.text,
        "contacts": [
          {"emails": _emailController.text},
        ],
      };
    } else {
      data = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "company": _companyController.text,
        "emails": _emailController.text,
      };
    }

    try {
      final response = await ApiService().post(url, data);
      if (response.isNotEmpty) {
        if (response['success']) {
          CommonService.animatedToast(response['message'], 'success');
          if (context.mounted) {
            final isDesktop = AppBreakpoints.isDesktopLayout(context);
            if (isDesktop) {
              final emailService = EmailSenderService();
              await emailService.thenFunc(context, 'save');
            }
          }

          if (widget.saveFlag != null) {
            widget.saveFlag();
          }
          if (context.mounted) {
            context.pop();
          }
        } else {
          CommonService.animatedToast(response['message'], 'error');
          if (context.mounted) {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.pop();
      }
    }
  }
}
