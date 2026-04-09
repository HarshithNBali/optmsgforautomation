import 'dart:convert';

import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_state.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../../common/utilites/logger.dart';
import '../../../constant/string_constant.dart';
import '../../../model/contact_email_details.dart';
import '../../../model/contact_list_model.dart';
import '../../../repositories/contact/contact_api.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';

final viewContactProvider =
    NotifierProvider.autoDispose<ViewContactNotifier, ViewContactState>(
      ViewContactNotifier.new,
    );

class ViewContactNotifier extends Notifier<ViewContactState> {
  final SecureStorageService secureStorageService = SecureStorageService();
  late bool readingPaneEnabled = true;
  bool _disposed = false;

  @override
  ViewContactState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    return const ViewContactState();
  }

  /// ========= INIT =========
  Future<void> init(int contactId) async {
    await loadContactDetails(contactId);
  }

  Future<void> initialize(Contacts contact) async {
    await getUserData();
    updateContact(contact);
    // Set preview from list model data immediately so emails are visible
    // before the detail API responds, and as fallback if it fails.
    if (contact.emails != null && contact.emails!.isNotEmpty) {
      state = state.copyWith(
        emails: contact.emails!
            .where((e) => e.email != null && e.email!.isNotEmpty)
            .map((e) => Contact(id: e.id, email: e.email))
            .toList(),
      );
    }
    await loadContactDetails(contact.id);
  }

  /// ========= USER DATA =========
  Future<void> getUserData() async {
    try {
      final data = ref.read(authProvider).userData;

      final readingPaneValue = await secureStorageService.readData(
        'readingPaneEnabled',
      );
      readingPaneEnabled = readingPaneValue == null
          ? true
          : readingPaneValue == 'true';
      if (data != null) {
        state = state.copyWith(
          token: data['token'] ?? '',
          readingPaneEnabled: readingPaneEnabled,
        );
      }
    } catch (_) {}
  }

  /// ========= CONTACT DETAILS =========
  Future<void> loadContactDetails(int id) async {
    state = state.copyWith(loadingContactDetails: true);

    try {
      final data = await ContactApi().getContactDetails({"id": id});
      final Map<String, dynamic> res = data.data ?? {};

      if (res['success']) {
        final parsed = contactEmailDetailsModelFromJson(jsonEncode(res));
        if (!_disposed) {
          state = state.copyWith(emails: parsed.data?.contacts ?? []);
        }
      }
    } catch (_) {
    } finally {
      if (!_disposed) {
        state = state.copyWith(loadingContactDetails: false);
      }
    }
  }

  /// ========= ADD / DELETE EMAIL =========
  Future<void> addOrDeleteEmail({
    required String type,
    required String email,
    required int contactId,
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final resp = await ContactApi().addDeleteEmail({
        "email": email,
        "contactId": contactId,
        "type": type,
      });
      final res = resp.data ?? {};

      if (!res['success']) {
        CommonService.animatedToast(res['message'], 'error');
        return;
      }

      // update email list locally
      final list = [...state.emails];

      if (type == 'add') {
        list.add(
          Contact(
            id: res['data']['newEmail'][0]['id'],
            email: res['data']['newEmail'][0]['email'],
          ),
        );
      } else {
        list.removeWhere((e) => e.email == email);
      }

      state = state.copyWith(emails: list);

      CommonService.animatedToast(res['message'], 'success');
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(catchError, 'error');
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// ========= DELETE CONTACT =========
  Future<bool> deleteContact(int contactId) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final resp = await ContactApi().contactDelete({"id": contactId});
      final res = resp.data ?? {};

      if (res['success']) {
        CommonService.animatedToast(res['message'], 'success');
        return true;
      } else {
        CommonService.animatedToast(res['message'], 'error');
      }
    } catch (e) {
      if (e is! NoInternetException) {
        CommonService.animatedToast(catchError, 'error');
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }

    return false;
  }

  /// ========= UPDATE CONTACT =========
  void updateContact(Contacts contact) {
    printLog("Contacts Calling", contact.toJson());
    state = state.copyWith(contact: contact);
  }
}
