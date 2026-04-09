import 'package:optmsg/repositories/account/account_api.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/string_constant.dart';
import '../../../model/profile_model.dart';
import '../../../router/app_router.dart' show rootNavigatorKey;
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/form_validation.dart';
import '../../../services/storage_service.dart';
import '../../auth/auth_riverpod/auth_notifier.dart';

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<ProfileState> {
  bool _disposed = false;

  late final ApiService apiService;
  late final SecureStorageService secureStorageService;
  late final AccountApi _accountApi;

  final FormValidationService validator = FormValidationService();

  final formKey = GlobalKey<FormState>();
  // H-16: Controllers declared late and recreated in build() to avoid
  // use-after-dispose when the notifier is invalidated and build() reruns.
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController dobCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController usernameCtrl;

  late String formattedDate;

  @override
  ProfileState build() {
    apiService = ref.read(apiServiceProvider);
    secureStorageService = ref.read(storageServiceProvider);
    _accountApi = ref.read(accountApiProvider);
    _disposed = false;
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    dobCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    usernameCtrl = TextEditingController();
    ref.onDispose(() {
      _disposed = true;
      firstNameCtrl.dispose();
      lastNameCtrl.dispose();
      dobCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
      usernameCtrl.dispose();
    });
    Future.microtask(() => fetchProfile());
    return const ProfileState();
  }

  // -------------------------------------------------------
  // FETCH PROFILE
  // -------------------------------------------------------

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final resp = await _accountApi.getProfile({});
      if (_disposed) return;
      final response = resp.data ?? {};

      // Guard: offline error responses can't be parsed as MyProfile.
      // The global connectivity snackbar already notifies the user.
      if (response['success'] == false) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final profile = MyProfile.fromJson(response);

      if (profile.success) {
        firstNameCtrl.text = profile.data.firstName;
        lastNameCtrl.text = profile.data.lastName;
        dobCtrl.text = formatDate(profile.data.dob);
        usernameCtrl.text = profile.data.userName;
        emailCtrl.text = '${profile.data.userName}$emailExtension';
        phoneCtrl.text = _formatPhoneDisplay(
          profile.data.countryCode,
          profile.data.mobile,
        );

        state = state.copyWith(isLoading: false, profile: profile);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (_disposed) return;
      CommonService.animatedToast('Failed to load profile', 'error');

      state = state.copyWith(isLoading: false);
    }
  }

  // -------------------------------------------------------
  // EDIT MODE
  // -------------------------------------------------------

  void enableEdit() {
    if (state.profile != null) {
      // Set phone without country code (only show mobile number)
      phoneCtrl.text = state.profile!.data.mobile;
    }
    state = state.copyWith(isEdit: true);
  }

  void disableEdit() {
    // Reset controllers to original profile values when canceling edit
    if (state.profile != null) {
      firstNameCtrl.text = state.profile!.data.firstName;
      lastNameCtrl.text = state.profile!.data.lastName;
      dobCtrl.text = formatDate(state.profile!.data.dob);
      phoneCtrl.text = _formatPhoneDisplay(
        state.profile!.data.countryCode,
        state.profile!.data.mobile,
      );
    }
    state = state.copyWith(isEdit: false);
  }

  // -------------------------------------------------------
  // DOB PICKER
  // -------------------------------------------------------

  Future<void> pickDob() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      dobCtrl.text = DateFormat(monthFormate).format(selected);
    }
  }

  // -------------------------------------------------------
  // SUBMIT PROFILE
  // -------------------------------------------------------

  Future<bool> submitProfile() async {
    final form = formKey.currentState?.validate() ?? false;

    if (!form) return false;
    if (state.isLoading) return false; // M-12: prevent double-submit

    state = state.copyWith(isLoading: true);
    try {
      final resp = await _accountApi.editProfile({
        "firstName": firstNameCtrl.text,
        "lastName": lastNameCtrl.text,
        "dob": formatDateForApi(dobCtrl.text),
        "mobile": phoneCtrl.text,
      });
      if (_disposed) return false;
      final response = resp.data ?? {};

      if (response['success']) {
        await secureStorageService.writeObjectData(
          'userProfileData',
          response['data'],
        );
        if (_disposed) return false;

        state = state.copyWith(isEdit: false, isLoading: false);

        if (response['data']['tempMobile'] != "") {
          rootNavigatorKey.currentContext?.push(AppRoutes.enterOtpProfile);
        } else {
          CommonService.animatedToast(response['message'], 'success');
        }

        return true;
      } else {
        CommonService.animatedToast(response['message'], 'error');
      }
    } catch (_) {
      if (_disposed) return false;
      CommonService.animatedToast(catchError, 'error');
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }

    return false;
  }

  // -------------------------------------------------------
  // DATE HELPERS
  // -------------------------------------------------------

  Future<bool> resendOtp(String otpId) async {
    try {
      final response = await apiService.post('auth/resend-otp', {"id": otpId});
      if (_disposed) return false;
      if (response['success']) {
        CommonService.animatedToast(response['message'], 'success');
        return true;
      } else {
        CommonService.animatedToast(response['message'], 'error');
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    }
    return false;
  }

  Future<bool> verifyNewMobile(String otp) async {
    try {
      final response = await apiService.post('user/verify-new-mobile', {
        "otp": otp,
      });
      if (_disposed) return false;
      if (response['success']) {
        CommonService.animatedToast(response['message'], 'success');
        return true;
      } else {
        CommonService.animatedToast(response['message'], 'error');
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    }
    return false;
  }

  String formatDateForApi(String input) {
    try {
      DateTime parsed;

      try {
        parsed = DateFormat('MMMM dd, yyyy').parse(input);
      } catch (_) {
        try {
          parsed = DateFormat(monthFormate).parse(input);
        } catch (_) {
          parsed = DateTime.parse(input);
        }
      }

      return DateFormat(yearFormate).format(parsed);
    } catch (_) {
      throw const FormatException('Invalid date');
    }
  }

  /// Format phone number for display, e.g. "+1 (312) 952-6651".
  String _formatPhoneDisplay(String countryCode, String mobile) {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      final area = digits.substring(0, 3);
      final prefix = digits.substring(3, 6);
      final line = digits.substring(6);
      final code = countryCode.isNotEmpty ? '$countryCode ' : '';
      return '$code($area) $prefix-$line';
    }
    // Non-10-digit: just prepend country code
    if (countryCode.isNotEmpty) return '$countryCode $mobile';
    return mobile;
  }

  String formatDate(String apiDate) {
    try {
      return DateFormat('MMMM dd, yyyy').format(DateTime.parse(apiDate));
    } catch (_) {
      return "N/A";
    }
  }
}
