import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/main.dart';
import 'package:optmsg/services/storage_service.dart';

class EmailSenderService {
  final _storage = SecureStorageService();

  Future<void> triggerEmail({
    required BuildContext context,
  }) async {
    var composeEmailData =
        await _storage.readObjectData('composeEmailData');
    if (composeEmailData == null) {
      //CommonService.animatedToast('Email data not found', 'error');
      return;
    }
    try {
      SocketService().emitEventWithAck('sendMessage', {
        "pageId": composeEmailData['pageId'],
        "userId": composeEmailData['userId'],
      }, ackCallback: (data) async {
        if (data != null && data == 'yes') {
          if (composeEmailData['type'] == 'forward' ||
              composeEmailData['type'] == 'replyAll' ||
              composeEmailData['type'] == 'reply' ||
              composeEmailData['type'] == 'contact') {
            CommonService.animatedToast('Email sent', 'success');
            await _storage.deleteData('composeEmailData');
          } else {
            CommonService.animatedToast('Email sent', 'success', null, true);
            await _storage.deleteData('composeEmailData');
          }
          // Navigate back to inbox after sending email
          if (context.mounted) {
            _navigateToInbox(context);
          }
        } else {
          if (context.mounted) {
            _navigateToInbox(context);
          }
          CommonService.animatedToast('Something went wrong', 'error');
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Navigate back to inbox after email is sent
  void _navigateToInbox(BuildContext context) {
    // For desktop, pop compose from internal navigator and go to inbox
    // For desktop, pop compose from internal navigator and go to inbox
    if (kIsWeb ||
        (context.mounted && !AppBreakpoints.isMobileLayout(context))) {
      appRouter.go(AppRoutes.inbox);
    } else if (context.canPop()) {
      // For mobile, just pop to go back
      context.pop();
    }
  }

  /// Display the add email modal for the given email — iterative to avoid stack overflow.
  Future<void> displayAddEmailModal(
      BuildContext context, List<String> emails, int index) async {
    FocusScope.of(context).unfocus();

    for (int i = index; i < emails.length; i++) {
      String email = emails[i];

      // Call API to check if email is already added to a contact
      try {
        Map<String, dynamic> resp =
            await ApiService().post('contact/check-email', {"email": email});
        if (resp['success']) {
          if (resp['data']['status']) {
            // Email is already added to a contact — skip to next
            continue;
          }

          // Email is not added to any contact, proceed to display modal
          if (!context.mounted) return;
          final result = await showDialog(
            useRootNavigator: true,
            context: context,
            builder: (BuildContext context) {
              return AddEmailModal(
                title: addEmail,
                type: emails.length > 1 ? "Multiple" : "Single",
                subtitleFirst: email,
                subtitle: addEmailcontact,
                contact: null,
                saveFlag: () async {},
                currentIndex: i,
                totalEmails: emails.length,
              );
            },
          );

          // Handle dialog results
          if (result == 'skip_all') {
            // User clicked Skip All & Send - send without adding remaining contacts
            if (!context.mounted) return;
            triggerEmail(context: context);
            return;
          } else if (result == 'cancel-email') {
            // User clicked X close - don't send email, stay on compose page
            return;
          } else if (result == 'skip') {
            // User clicked Skip - skip this contact, continue to next
            continue;
          } else if (result == 'existing_contact') {
            // User clicked Add to Existing - navigate to picker and await
            if (!context.mounted) return;
            final pickerResult = await context.push(
                AppRoutes.addExistingContact,
                extra: {'prevEmail': email, 'type': 'optin'});

            if (pickerResult == 'success') {
              // Success — continue to next email in loop
              continue;
            }
            // Picker cancelled/failed — stop
            return;
          }
          // Any other result (save) — continue to next email
        } else {
          CommonService.animatedToast(resp['message'], 'error');
        }
      } catch (error) {
        if (error is! NoInternetException) {
          CommonService.animatedToast('Error checking email', 'error');
        }
      }
    }

    // All emails processed — trigger email send
    if (context.mounted) triggerEmail(context: context);
  }

  /// Trigger the email for the next email in the list.
  Future<void> thenFunc(
    BuildContext context,
    var result,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? elist = prefs.getStringList('currentEmail');
    int? ind = prefs.getInt('currentIndex');

    // Handle null cases - trigger email directly
    if (elist == null || ind == null) {
      if (!context.mounted) return;
      triggerEmail(context: context);
      return;
    }

    if (result == 'skip_all') {
      if (!context.mounted) return;
      triggerEmail(context: context);
      return;
    }

    // Check if this is the last email or we've processed all
    if (ind + 1 >= elist.length) {
      if (!context.mounted) return;
      triggerEmail(context: context);
      return;
    }

    // Display next modal for the next email
    if (!context.mounted) return;
    displayAddEmailModal(
      context,
      elist,
      ind + 1,
    );
  }
}
