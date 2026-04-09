import 'package:optmsg/common/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constant/string_constant.dart';
import '../../../services/common_service.dart';
import '../../../services/form_validation.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'add_contact_notifier.dart';
import 'layouts/add_contact_desktop_layout.dart';
import 'layouts/add_contact_mobile_layout.dart';
import 'layouts/add_contact_tablet_layout.dart';

class AddContactriverpod extends ConsumerStatefulWidget {
  const AddContactriverpod({super.key});

  @override
  ConsumerState<AddContactriverpod> createState() => _AddContactriverpodState();
}

class _AddContactriverpodState extends ConsumerState<AddContactriverpod> {
  final GlobalKey<FormState> _addContactFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _formValidationService = FormValidationService();

  @override
  void initState() {
    super.initState();
    // addContactProvider is autoDispose — a fresh notifier (with fresh email
    // controllers) is created every time this screen opens. We must NOT call
    // reset() here because it disposes the initial controller while it is
    // still attached to the widget tree, and since the state value doesn't
    // change (emailFieldCount stays 1) Freezed equality suppresses the
    // rebuild, leaving a disposed controller in the live widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShellLayout.of(context)?.setAppBarConfig(
          const AppBarConfig(title: newContact),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    // Reset provider state when widget is disposed
    // This ensures no validation errors occur during pop, but state is clean for next use
    // Using a microtask to avoid modifying provider during build/dispose cycle lock if any

    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSave() {
    FocusScope.of(context).unfocus();
    ref
        .read(addContactProvider.notifier)
        .addContact(
          formKey: _addContactFormKey,
          firstName: _firstNameController,
          lastName: _lastNameController,
          company: _companyController,
        );
  }

  void _handleBack() {
    // Clear fields immediately
    _firstNameController.clear();
    _lastNameController.clear();
    _companyController.clear();
    _addContactFormKey.currentState?.reset();
    // Reset provider state
    _addContactFormKey.currentState?.reset();
    // Reset provider state is handled in dispose()
    // Navigate back immediately
    context.pop();
  }

  void _handleAddRemoveEmail(String type, int index) {
    ref.read(addContactProvider.notifier).updateEmailControllers(type, index);
    if (type == 'add') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERF-03: Only rebuild when emailFieldCount changes, not on isLoading etc.
    ref.watch(addContactProvider.select((s) => s.emailFieldCount));
    final emailControllers = ref.read(addContactProvider.notifier).emailControllers;
    return PopScope(
      canPop: CommonService().getPlatform() == 'ios' ? false : true,
      onPopInvokedWithResult: (didPop, result) {
        // Reset state when navigating back via system gesture (iOS)
        if (!didPop && CommonService().getPlatform() == 'ios') {
          // Clear fields immediately
          _firstNameController.clear();
          _lastNameController.clear();
          _companyController.clear();
          _addContactFormKey.currentState?.reset();
          // Reset provider state
          ref.read(addContactProvider.notifier).reset();
          // Navigate back immediately
          if (mounted) {
            context.pop();
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
            child: ResponsiveLayoutBuilder(
              mobile: (ctx, deviceType, width) =>
                  AddContactMobileLayoutRiverpod(
                    formKey: _addContactFormKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    companyController: _companyController,
                    emailControllers: emailControllers,
                    scrollController: _scrollController,
                    formValidation: _formValidationService,
                    onSave: _handleSave,
                    onBack: _handleBack,
                    onAddRemoveEmail: _handleAddRemoveEmail,
                  ),
              tablet: (ctx, deviceType, width) =>
                  AddContactTabletLayoutRiverpod(
                    formKey: _addContactFormKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    companyController: _companyController,
                    emailControllers: emailControllers,
                    scrollController: _scrollController,
                    formValidation: _formValidationService,
                    onSave: _handleSave,
                    onBack: _handleBack,
                    onAddRemoveEmail: _handleAddRemoveEmail,
                  ),
              desktop: (ctx, deviceType, width) =>
                  AddContactDesktopLayoutRiverpod(
                    formKey: _addContactFormKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    companyController: _companyController,
                    emailControllers: emailControllers,
                    scrollController: _scrollController,
                    formValidation: _formValidationService,
                    onSave: _handleSave,
                    onBack: _handleBack,
                    onAddRemoveEmail: _handleAddRemoveEmail,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
