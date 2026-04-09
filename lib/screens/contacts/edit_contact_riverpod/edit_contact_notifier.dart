import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/contact_email_details.dart';
import '../../../model/contact_list_model.dart';
import '../../../repositories/contact/contact_api.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../view_contact_riverpod/view_contact_notifier.dart';
import 'edit_contact_state.dart';

final editContactProvider =
    NotifierProvider.autoDispose<EditContactNotifier, EditContactState>(EditContactNotifier.new);

class EditContactNotifier extends Notifier<EditContactState> {
  bool _disposed = false;

  final List<TextEditingController> _emailControllers = [];
  List<TextEditingController> get emailControllers =>
      List.unmodifiable(_emailControllers);

  @override
  EditContactState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      for (final c in _emailControllers) {
        c.dispose();
      }
      _emailControllers.clear();
    });
    return const EditContactState();
  }

  /// Initialize fields with existing data
  void init(List<Contact> contacts) {
    for (final c in _emailControllers) {
      c.dispose();
    }
    _emailControllers.clear();

    _emailControllers.addAll(
      contacts.map((e) => TextEditingController(text: e.email)),
    );

    state = state.copyWith(emailFieldCount: _emailControllers.length);
  }

  /// Reset state - call this when leaving the edit screen
  void reset() {
    for (final c in _emailControllers) {
      c.dispose();
    }
    _emailControllers.clear();
    state = const EditContactState();
  }

  /// Add / Remove email fields
  void updateEmailControllers(String type, int index) {
    if (type == 'add') {
      _emailControllers.add(TextEditingController());
    } else if (type == 'remove' && _emailControllers.length > 1) {
      _emailControllers[index].dispose();
      _emailControllers.removeAt(index);
    }

    state = state.copyWith(emailFieldCount: _emailControllers.length);
  }

  /// Perform API submit — context is no longer needed; caller handles navigation
  Future<Contacts?> updateContact({
    required GlobalKey<FormState> formKey,
    required Contacts contact,
    required List<Contact> contactData,
    required ({
      TextEditingController firstName,
      TextEditingController lastName,
      TextEditingController company,
      bool isReadingPaneMode
    }) details,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    state = state.copyWith(isLoading: true);

    try {
      final List<Map<String, dynamic>> contacts = [];

      for (int i = 0; i < _emailControllers.length; i++) {
        final email = _emailControllers[i].text.trim();
        if (email.isEmpty) continue;

        final data = <String, dynamic>{'emails': email};

        if (contactData.isNotEmpty && i < contactData.length && contactData[i].id != null) {
          data['contactEmailId'] = contactData[i].id;
        }

        contacts.add(data);
      }
      final response = await ContactApi().editContact({
        "contactId": contact.id,
        "firstName": details.firstName.text,
        "lastName": details.lastName.text,
        "company": details.company.text,
        "contacts": contacts,
      });
      if (_disposed) return null;
      Map<String, dynamic> res = response.data ?? {};

      if (!res['success']) {
        CommonService.animatedToast(res['message'], 'error');
        return null;
      }

      CommonService.animatedToast(res['message'], 'success');

      // Bug 5: Force the view screen to re-fetch fresh data instead of
      // showing stale cached state after a successful edit.
      ref.invalidate(viewContactProvider);

      final updated = Contacts(
        id: contact.id,
        firstName: details.firstName.text,
        lastName: details.lastName.text,
        company: details.company.text,
        phones: contact.phones,
        emails: List.generate(
          _emailControllers.length,
          (i) => Emails(
            id: (i < contactData.length) ? contactData[i].id : 0,
            email: _emailControllers[i].text.trim(),
          ),
        ),
      );

      return updated;
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(
            'An error occurred while updating the contact', 'error');
      }
      return null;
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }
}
