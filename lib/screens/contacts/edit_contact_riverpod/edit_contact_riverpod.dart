import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constant/string_constant.dart';
import '../../../model/contact_email_details.dart';
import '../../../model/contact_list_model.dart';
import '../../../services/form_validation.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'edit_contact_notifier.dart';
import 'layouts/edit_contact_desktop_layout.dart';
import 'layouts/edit_contact_mobile_layout.dart';
import 'layouts/edit_contact_tablet_layout.dart';

class EditContactriverpod extends ConsumerStatefulWidget {
  final Contacts contact;
  final List<Contact> contactData;
  final bool isReadingPaneMode;

  const EditContactriverpod({
    super.key,
    required this.contact,
    required this.contactData,
    this.isReadingPaneMode = false,
  });

  @override
  ConsumerState<EditContactriverpod> createState() =>
      _EditContactriverpodState();
}

class _EditContactriverpodState extends ConsumerState<EditContactriverpod> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _validator = FormValidationService();

  @override
  void initState() {
    super.initState();
    _firstName.text = widget.contact.firstName;
    _lastName.text = widget.contact.lastName;
    _company.text = widget.contact.company;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShellLayout.of(context)?.setAppBarConfig(
          const AppBarConfig(title: editContact),
        );
      }
      List<Contact> effectiveData = widget.contactData;
      if (effectiveData.isEmpty) {
        final contactEmails = widget.contact.emails;
        if (contactEmails != null && contactEmails.isNotEmpty) {
          effectiveData = contactEmails
              .where((e) => e.email != null && e.email!.isNotEmpty)
              .map((e) => Contact(id: e.id, email: e.email))
              .toList();
        }
      }
      if (effectiveData.isEmpty) effectiveData = [Contact()];
      ref.read(editContactProvider.notifier).init(effectiveData);
    });
  }

  @override
  void dispose() {
    // Reset the provider state to ensure fresh state on next edit
    _scrollCtrl.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _company.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleBack() {
    if (context.canPop()) context.pop();
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(editContactProvider.notifier);
    final updated = await notifier.updateContact(
      formKey: _formKey,
      contact: widget.contact,
      contactData: widget.contactData,
      details: (
        // Wrap these 4 into one object
        firstName: _firstName,
        lastName: _lastName,
        company: _company,
        isReadingPaneMode: widget.isReadingPaneMode,
      ),
    );

    if (updated == null || !mounted) return;
    printLog("updated", updated.toJson());

    context.pop({'type': 'edit', 'contact': updated});
  }

  void _handleAddRemoveEmail(String type, int index) {
    ref.read(editContactProvider.notifier).updateEmailControllers(type, index);
    if (type == 'add') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editContactProvider);

    final emails = ref.read(editContactProvider.notifier).emailControllers;
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
          child: ResponsiveLayoutBuilder(
          mobile: (ctx, deviceType, width) =>
              MediaQuery.of(context).orientation == Orientation.landscape
              ? EditContactDesktopLayoutRiverpod(
                  formKey: _formKey,
                  firstNameController: _firstName,
                  lastNameController: _lastName,
                  companyController: _company,
                  emailControllers: emails,
                  scrollController: _scrollCtrl,
                  formValidation: _validator,
                  onSave: _handleSave,
                  onBack: _handleBack,
                  onAddRemoveEmail: _handleAddRemoveEmail,
                  isLoading: state.isLoading,
                )
              : EditContactMobileLayoutRiverpod(
                  formKey: _formKey,
                  firstNameController: _firstName,
                  lastNameController: _lastName,
                  companyController: _company,
                  emailControllers: emails,
                  scrollController: _scrollCtrl,
                  formValidation: _validator,
                  onSave: _handleSave,
                  onBack: _handleBack,
                  onAddRemoveEmail: _handleAddRemoveEmail,
                  isLoading: state.isLoading,
                ),
          tablet: (ctx, deviceType, width) =>
              MediaQuery.of(context).orientation == Orientation.landscape
              ? EditContactDesktopLayoutRiverpod(
                  formKey: _formKey,
                  firstNameController: _firstName,
                  lastNameController: _lastName,
                  companyController: _company,
                  emailControllers: emails,
                  scrollController: _scrollCtrl,
                  formValidation: _validator,
                  onSave: _handleSave,
                  onBack: _handleBack,
                  onAddRemoveEmail: _handleAddRemoveEmail,
                  isLoading: state.isLoading,
                )
              : EditContactTabletLayoutRiverpod(
                  formKey: _formKey,
                  firstNameController: _firstName,
                  lastNameController: _lastName,
                  companyController: _company,
                  emailControllers: emails,
                  scrollController: _scrollCtrl,
                  formValidation: _validator,
                  onSave: _handleSave,
                  onBack: _handleBack,
                  onAddRemoveEmail: _handleAddRemoveEmail,
                  isLoading: state.isLoading,
                ),
          desktop: (ctx, deviceType, width) => EditContactDesktopLayoutRiverpod(
            formKey: _formKey,
            firstNameController: _firstName,
            lastNameController: _lastName,
            companyController: _company,
            emailControllers: emails,
            scrollController: _scrollCtrl,
            formValidation: _validator,
            onSave: _handleSave,
            onBack: _handleBack,
            onAddRemoveEmail: _handleAddRemoveEmail,
            isLoading: state.isLoading,
          ),
        ),
        ),
      ),
    );
  }
}
