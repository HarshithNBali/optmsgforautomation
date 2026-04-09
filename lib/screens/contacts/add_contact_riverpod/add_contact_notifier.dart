import 'package:optmsg/screens/contacts/add_contact_riverpod/add_contact_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/contact_list_model.dart';
import '../../../repositories/contact/contact_api.dart';
import '../../../router/app_router.dart' show rootNavigatorKey;
import '../../../services/common_service.dart';

final addContactProvider =
    NotifierProvider.autoDispose<AddContactNotifier, AddContactState>(
      AddContactNotifier.new,
    );

class AddContactNotifier extends Notifier<AddContactState> {
  bool _disposed = false;

  final List<TextEditingController> _emailControllers = [];
  List<TextEditingController> get emailControllers =>
      List.unmodifiable(_emailControllers);

  @override
  AddContactState build() {
    _disposed = false;
    _emailControllers.add(TextEditingController());
    ref.onDispose(() {
      _disposed = true;
      for (final c in _emailControllers) {
        c.dispose();
      }
      _emailControllers.clear();
    });
    return const AddContactState(emailFieldCount: 1);
  }

  /// Reset all controllers to initial state
  void reset() {
    for (final c in _emailControllers) {
      c.dispose();
    }
    _emailControllers.clear();
    _emailControllers.add(TextEditingController());
    state = const AddContactState(emailFieldCount: 1);
  }

  /// Add / remove email fields
  void updateEmailControllers(String type, int index) {
    if (type == 'add') {
      _emailControllers.add(TextEditingController());
    } else if (type == 'remove' && _emailControllers.length > 1) {
      _emailControllers[index].dispose();
      _emailControllers.removeAt(index);
    }

    state = state.copyWith(emailFieldCount: _emailControllers.length);
  }

  /// SUBMIT ADD CONTACT
  Future<void> addContact({
    required GlobalKey<FormState> formKey,
    required TextEditingController firstName,
    required TextEditingController lastName,
    required TextEditingController company,
  }) async {
    if (!formKey.currentState!.validate()) return;

    final fn = firstName.text.trim();
    final ln = lastName.text.trim();
    final comp = company.text.trim();

    if (fn.isEmpty && ln.isEmpty && comp.isEmpty) {
      CommonService.animatedToast(
        'Please fill in First Name, Last Name, or Company Name',
        'error',
      );
      return;
    }

    try {
      final emails =
          _emailControllers.map((e) => e.text.trim()).toList();
      await addContactData(
        company: comp,
        firstName: fn,
        lastName: ln,
        emails: emails,
      );
    } catch (e) {
      // ignore: empty_catches
    }
  }

  Future<void> addContactData({
    required String firstName,
    required String lastName,
    required String company,
    required List<String> emails,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final resp = await ContactApi().addContact({
        "firstName": firstName,
        "lastName": lastName,
        "company": company,
        "emails": emails,
      });
      if (_disposed) return;

      // Check if response data is null
      if (resp.data == null) {
        CommonService.animatedToast(
          'An error occurred while adding the contact',
          'error',
        );
        return;
      }

      final Map<String, dynamic> response = resp.data!;

      if (!response['success']) {
        CommonService.animatedToast(response['message'], 'error');
        return;
      }

      var contactData = response['data'];

      // Handle case where contact might be nested or direct
      Map<String, dynamic>? finalContactMap;

      if (contactData != null && contactData is Map<String, dynamic>) {
        if (contactData.isNotEmpty) {
          if (contactData.containsKey('contact') &&
              contactData['contact'] != null) {
            finalContactMap = contactData['contact'];
          } else if (contactData.containsKey('id')) {
            finalContactMap = contactData;
          }
        }
      }

      final ctx = rootNavigatorKey.currentContext;

      if (finalContactMap == null) {
        CommonService.animatedToast(
          response['message'] ?? 'Contact action successful',
          'success',
        );

        if (ctx != null) {
          debugPrint(
            'finalContactMap is null, handling navigation accordingly',
          );
          debugPrint('Contact data not available, refreshing list');

          // Fetch the updated contact list to find the newly added contact
          try {
            final contactsResp = await ContactApi().getContactList({
              "page": 1,
              "limit": 1000,
              "search": "",
            });

            if (contactsResp.data != null && contactsResp.data!.success) {
              final contacts = contactsResp.data!.data.contacts;

              // Find the newly added contact by matching firstName, lastName, and company
              Contacts? newContact;
              for (final contact in contacts) {
                if (contact.firstName.trim().toLowerCase() ==
                        firstName.trim().toLowerCase() &&
                    contact.lastName.trim().toLowerCase() ==
                        lastName.trim().toLowerCase() &&
                    contact.company.trim().toLowerCase() ==
                        company.trim().toLowerCase()) {
                  newContact = contact;
                  break;
                }
              }

              if (newContact != null &&
                  rootNavigatorKey.currentContext != null) {
                rootNavigatorKey.currentContext!.pop({
                  'type': 'add',
                  'contact': newContact,
                });
                return;
              }
            }
          } catch (e) {
            debugPrint('Error fetching contact list: $e');
          }

          // Fallback: if we couldn't find the contact, just refresh the list
          rootNavigatorKey.currentContext?.pop({'type': 'refresh'});
        }
        return;
      }

      final Contacts addedContact = Contacts.fromJson(finalContactMap);

      CommonService.animatedToast(
        response['message'] ?? 'Contact added successfully',
        'success',
      );

      // Pop back with the added contact
      rootNavigatorKey.currentContext?.pop({
        'type': 'add',
        'contact': addedContact,
      });
    } catch (e) {
      CommonService.animatedToast(
        'An error occurred while adding the contact',
        'error',
      );
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }
}
