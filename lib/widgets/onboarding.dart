import 'dart:async';

import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/string_constant.dart' show sendNotificationApi;
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/main.dart' show providerContainer;
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  final String status;
  const OnboardingScreen({required this.status, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final SecureStorageService secureStorageService = SecureStorageService();
  Map<String, dynamic>? userData;
  bool alreadyPressed = false;
  bool _syncContact = true;
  bool _isLoading = false;
  // A3: Guard against duplicate onDatabaseChange listeners.
  bool _listenerAdded = false;
  StreamSubscription<void>? _dbChangeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await getUserData();

    // Determine the actual status - use widget status if provided, otherwise read from storage
    String status = widget.status;
    if (status.isEmpty || status == 'welcome') {
      // On browser refresh, status might be missing - read from storage
      final storedStatus = userData?['user']?['boardingSteps'];
      if (storedStatus != null && storedStatus.isNotEmpty) {
        status = storedStatus;
      }
    }

    if (mounted) {
      setState(() {
        if (status == 'welcome') {
          screenCount = 1;
        } else if (status == 'synch') {
          screenCount = 2;
        } else if (status == 'forward') {
          screenCount = 3;
        } else {
          screenCount = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _dbChangeSubscription?.cancel();
    super.dispose();
  }

  List<Map<String, String>> items = [
    {
      'title': 'Welcome to the OptMsg \n Revolution!',
      'subTitle': "Let's complete your setup.",
      'icon': svgOnboarding1,
      'buttonText': 'Continue',
    },
    {
      'title': 'Sync your \n Contacts',
      'subTitle':
          'We can sync your contacts to make it easier to compose emails and find recipients.',
      'icon': svgOnboarding2,
      'buttonText': 'Continue',
    },
    {
      'title': 'Forward other email \n accounts to OptMsg',
      'subTitle':
          'Login to your existing email accounts.  Under settings, select forward your email.  Enter your new email address.  You now have one Inbox to rule them all!',
      'icon': svgOnboarding3,
      'buttonText': 'Continue',
    },
    {
      'title': 'Check your \n Notifications',
      'subTitle':
          'The orange dot on the Notifications icon means new and exciting ways to use OptMsg.',
      'icon': svgOnboarding4,
      'buttonText': 'Complete',
    }
  ];
  int screenCount = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GradientBackground(
              bottomSafeArea: true,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: AppBreakpoints.screenHeight(context) * 0.010,
                      ),
                      SvgPicture.asset(
                        svgIcon,
                        height: 50,
                      ),
                      const SizedBox(
                        height: AppStyles.space8,
                      ),
                      Text(
                        items[screenCount]['title']!,
                        style: AppTypography.titleLarge(context).copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: AppStyles.space20,
                      ),
                      Expanded(
                        child: SvgPicture.asset(
                          items[screenCount]['icon']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0, // Adjust to control the overlap amount
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: AppStyles.space8,
                          ),
                          Text(
                            items[screenCount]['subTitle']!,
                            style: AppTypography.inboxTitle(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: AppStyles.space8,
                          ),
                          DelayedLoadingOverlay(
                            isLoading: _isLoading,
                            child: CustomGradientButton(
                              onPressed: () async {
                                // Prevent multiple presses
                                if (_isLoading) return;
                                setState(() => _isLoading = true);

                                try {
                                  if (screenCount <= 3) {
                                    if (screenCount == 0) {
                                      await updateSendNotification('welcome');
                                    } else if (screenCount == 1) {
                                      // Sync contacts step — request permission on native, skip on web
                                      if (kIsWeb) {
                                        await updateSendNotification('synch');
                                      } else {
                                        await filterContactsToJson();
                                      }
                                    } else if (screenCount == 2) {
                                      await updateSendNotification('forward');
                                    } else if (screenCount == 3) {
                                      await updateSendNotification(
                                          'notification');
                                    }
                                  }
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              },
                              text: items[screenCount]['buttonText']!,
                            ),
                          ),
                          // L-10: Skip button — persists completion to storage so the
                          // user is not shown onboarding again on the next launch.
                          if (screenCount < 3)
                            TextButton(
                              onPressed: _skipOnboarding,
                              child: Text(
                                'Skip',
                                style: TextStyle(color: context.colors.primary),
                              ),
                            ),
                          const SizedBox(
                            height: AppStyles.space24,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  // L-10: Persist onboarding completion and navigate to inbox immediately.
  // Fires the final API call in the background so the user isn't blocked by
  // a loading spinner when they explicitly choose to skip.
  Future<void> _skipOnboarding() async {
    if (userData != null && userData!['user'] != null) {
      await providerContainer.read(authProvider.notifier).updateUserField('boardingSteps', 'notification');
      userData = providerContainer.read(authProvider).userData;
    }
    // Persist device-local flag so onboarding is never shown again on this
    // device, even after logout (this key is not cleared by clearAllData).
    await secureStorageService.writeData('hasCompletedOnboarding', 'true');
    AppCache().setHasCompletedOnboarding(true);
    // Notify server in the background — failure is acceptable for a skip action.
    ApiService()
        .post(sendNotificationApi, {'type': 'notification'})
        .timeout(const Duration(seconds: 15))
        .ignore();
    if (!mounted) return;
    context.go(AppRoutes.inbox);
  }

  /// Sends a notification of a specific type to the server and updates the user's onboarding steps.
  ///
  /// This function makes a POST request to the server to send a notification of the given [type].
  /// It then increments the [screenCount] to move to the next screen in the onboarding process.
  /// The user's onboarding steps are updated in the secure storage. If the [type] is 'notification',
  /// the user is redirected to the main app screen. If any error occurs, an error toast is displayed.
  ///
  /// [type] - A string representing the type of notification to be sent.

  /// Sends a notification of a specific type to the server and updates the user's onboarding steps.
  ///
  /// This function makes a POST request to the server to send a notification of the given [type].
  /// It then increments the [screenCount] to move to the next screen in the onboarding process.
  /// The user's onboarding steps are updated in the secure storage. If the [type] is 'notification',
  /// the user is redirected to the main app screen. If any error occurs, an error toast is displayed.
  ///
  /// [type] - A string representing the type of notification to be sent.
  Future<void> updateSendNotification(String type) async {
    try {
      await ApiService().post(
        sendNotificationApi,
        {"type": type},
      ).timeout(const Duration(seconds: 15));
      if (screenCount < 3) {
        if (!mounted) return;
        setState(() {
          screenCount = screenCount + 1;
        });
      }
      // Only update storage if userData is available
      if (userData != null && userData!['user'] != null) {
        await providerContainer.read(authProvider.notifier).updateUserField('boardingSteps', type);
        userData = providerContainer.read(authProvider).userData;
      }
      if (type == 'notification') {
        // Persist device-local flag so onboarding is never shown again on this
        // device, even after logout (this key is not cleared by clearAllData).
        await secureStorageService.writeData('hasCompletedOnboarding', 'true');
        AppCache().setHasCompletedOnboarding(true);
        if (!mounted) return;
        context.go(AppRoutes.inbox);
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
            'Something went wrong. Please try again.', 'error');
      }
      // Still allow user to proceed on error to prevent getting stuck
      if (screenCount < 3) {
        if (!mounted) return;
        setState(() {
          screenCount = screenCount + 1;
        });
      }
      if (type == 'notification') {
        await secureStorageService.writeData('hasCompletedOnboarding', 'true');
        AppCache().setHasCompletedOnboarding(true);
        if (!mounted) return;
        context.go(AppRoutes.inbox);
      }
    }
  }

  /// Silent notification update - sends to server without incrementing screen
  Future<void> updateSendNotificationSilent(String type) async {
    try {
      await ApiService().post(
        sendNotificationApi,
        {"type": type},
      ).timeout(const Duration(seconds: 15));
      // Only update storage if userData is available
      if (userData != null && userData!['user'] != null) {
        await providerContainer.read(authProvider.notifier).updateUserField('boardingSteps', type);
        userData = providerContainer.read(authProvider).userData;
      }
    } catch (error) {
      // Silently fail for background sync notification
    }
  }

  /// Retrieves the user data from secure storage, and updates the [userData] field.
  ///
  /// This is called when the widget is initialized.
  ///
  /// It also updates the subtitle of the third onboarding screen with the user's
  /// registered email address.

  Future<void> getUserData() async {
    try {
      final data = providerContainer.read(authProvider).userData;
      if (data != null && data['user'] != null) {
        if (!mounted) return;
        setState(() {
          userData = data;
          _syncContact = data['user']['contactSynch'] ?? false;
          // Update forward screen subtitle (at index 2)
          items[2]['subTitle'] =
              'Login to your existing email accounts.  Under settings, select forward your email.  Enter your new ${userData!['user']['userName']}$emailExtension email address.  You now have one Inbox to rule them all!';
        });
      }
    } catch (e) {
      debugPrint('Onboarding: failed to fetch user data: $e');
    }
  }

  /// contacts permission function.
  Future<void> filterContactsToJson() async {
    String? isContactsAlreadySync =
        await secureStorageService.readData('isContactAlreadySync');
    await Permission.contacts.onDeniedCallback(() async {
      await updateSendNotification('synch');
    }).onGrantedCallback(() async {
      // A3: Guard against duplicate listeners; store subscription for dispose().
      if (!_listenerAdded) {
        _listenerAdded = true;
        _dbChangeSubscription = FlutterContacts.onDatabaseChange.listen((_) async {
          await secureStorageService.writeData("contactListner", "yes");
          await secureStorageService.writeData(
              'userContactPermission', 'permitted');
          await secureStorageService.writeData('isContactAlreadySync', 'no');
        });
      }
      // If contacts need to be synced, do the full sync process
      if (isContactsAlreadySync != 'yes' && _syncContact == true) {
        // A4: await so the loading dialog lifecycle is predictable.
        await filterContacts();
      } else {
        // Contacts already synced or sync disabled - just proceed to next screen
        await updateSendNotification('synch');
      }
    }).onPermanentlyDeniedCallback(() async {
      // handleDeniedPermission(context);
      await updateSendNotification('synch');
    }).onRestrictedCallback(() async {
      // handleDeniedPermission(context);
      await updateSendNotification('synch');
    }).onLimitedCallback(() async {
      // handleDeniedPermission(context);
      await updateSendNotification('synch');
    }).onProvisionalCallback(() async {
      // handleDeniedPermission(context);
      await updateSendNotification('synch');
    }).request();
  }

  /// Filters contacts based on their email addresses and company names.
  /// B-04: Contact fetching is async (platform channel) but the heavy
  /// filtering/serialisation is moved to a background isolate via compute()
  /// to avoid blocking the UI thread on devices with thousands of contacts.
  Future<String> filterContacts() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from being dismissed
      builder: (BuildContext context) {
        return const Center(child: LoaderIndicator());
      },
    );
    try {
      await syncContacts(true);
      if (!mounted) return '';
      // A1: allProperties excludes photos/thumbnails in flutter_contacts v2.0.0,
      // avoiding 50-200MB of image data on devices with 1000+ contacts.
      // Do NOT switch to ContactProperties.all (which includes photos).
      // TODO: Re-enable photos when local storage caching is implemented.
      List<Contact> contacts =
          await FlutterContacts.getAll(properties: ContactProperties.allProperties);

      // B-04: Run heavy filtering/serialisation in a background isolate.
      final jsonContacts = await compute(
        _filterContactsIsolate,
        contacts.map((c) => c.toJson()).toList(),
      );
      if (!mounted) return '';

      await ApiService().post('contact/upload', {'data': jsonContacts}).timeout(
          const Duration(seconds: 30));
      if (!mounted) return '';

      await secureStorageService.writeData("isContactAlreadySync", "yes");
      if (!mounted) return '';

      await updateSendNotification('synch');
      if (!mounted) return '';
      setState(() {
        alreadyPressed = false;
      });
      context.pop();
      return '';
    } catch (e) {
      if (!mounted) return '';
      context.pop();
      if (!mounted) return '';
      // Still progress to next step even if sync contacts fails
      await updateSendNotification('synch');
      if (!mounted) return '';
      setState(() {
        alreadyPressed = false;
      });
      return '';
    }
  }

  /// Show an alert dialog to the user when the app is denied permission to access
  /// the contacts list.
  ///
  /// The dialog displays a message asking the user to grant permission and provides
  /// two options: "Cancel" and "Settings". If the user selects "Cancel", the
  /// `_syncContact` is set to `false` and the `syncContacts` function is called.
  /// If the user selects "Settings", the app settings are opened.
  void handleDeniedPermission(BuildContext context) async {
    setState(() {
      alreadyPressed = false;
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('"OptMsg" Would Like to Access Your Contacts'),
          content: Column(
            children: <Widget>[
              const SizedBox(height: AppStyles.space8),
              Text(
                'We need access to your contact list to help you quickly add recipients when composing emails and to sync your contacts for easier communication.',
                style: AppTypography.bodySmall(context),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: context.colors.primary),
              ),
              onPressed: () async {
                await secureStorageService.writeData(
                    'userContactPermission', 'permanentDenied');
                await syncContacts(false);
                if (context.mounted) {
                  context.pop();
                }
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Settings',
                style: TextStyle(color: context.colors.primary),
              ),
              onPressed: () async {
                await openAppSettings();
                if (context.mounted) {
                  context.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Toggle the contact synch value and update the user data in secure storage
  Future<void> syncContacts(bool value) async {
    try {
      await ApiService().post('user/toggle-contact-synch',
          {'contactSynch': value}).timeout(const Duration(seconds: 15));
      // Only update storage if userData is available
      if (userData != null && userData!['user'] != null) {
        await providerContainer.read(authProvider.notifier).updateUserField('contactSynch', value);
        userData = providerContainer.read(authProvider).userData;
      }
    } catch (error) {
      // Silently fail to prevent blocking the flow
    }
  }
}

/// B-04: Top-level function for compute() — runs contact filtering in a
/// background isolate to avoid freezing the UI on devices with many contacts.
/// Accepts raw JSON maps (isolates cannot receive platform objects).
List<Map<String, dynamic>> _filterContactsIsolate(
    List<Map<String, dynamic>> rawContacts) {
  final List<Map<String, dynamic>> filtered = [];

  for (final json in rawContacts) {
    final emails = json['emails'] as List? ?? [];
    if (emails.isEmpty) continue;

    final name = json['name'] as Map<String, dynamic>? ?? {};
    final firstName = ((name['first'] ?? '') as String).trim();
    final lastName = ((name['last'] ?? '') as String).trim();
    final organizations = json['organizations'] as List? ?? [];
    final hasValidFirstName = firstName.isNotEmpty;
    final hasValidCompany = organizations.any((org) {
      final orgMap = org as Map<String, dynamic>? ?? {};
      return ((orgMap['company'] ?? '') as String).trim().isNotEmpty;
    });

    if (!hasValidFirstName && !hasValidCompany) continue;

    final phones = json['phones'] as List? ?? [];
    filtered.add({
      'phoneId': json['id'] ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'phones': phones.map((p) => (p as Map<String, dynamic>)['number'] ?? '').toList(),
      'emails': emails.map((e) => (e as Map<String, dynamic>)['address'] ?? '').toList(),
      'company': organizations
          .map((org) => ((org as Map<String, dynamic>)['company'] ?? '') as String)
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList(),
      'data': json,
    });
  }

  return filtered;
}
