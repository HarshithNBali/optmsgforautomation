import 'package:optmsg/repositories/account/account_api.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_state.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';

import '../../../common/app_manger/app_cache.dart';
import '../../../router/app_router.dart' show rootNavigatorKey;

final accountProvider = NotifierProvider<AccountNotifier, AccountState>(
  AccountNotifier.new,
);

class AccountNotifier extends Notifier<AccountState> {
  bool _disposed = false;

  late final SecureStorageService secureStorageService;
  late final AccountApi _accountApi;

  @override
  AccountState build() {
    secureStorageService = ref.read(storageServiceProvider);
    _accountApi = ref.read(accountApiProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Read auth data synchronously so the initial state has the date
    final data = ref.read(authProvider).userData;
    final initialDate = _formatCreatedDate(data);

    if (data != null) {
      return AccountState(
        userData: data,
        subscriptionDate: initialDate,
      );
    }

    // Auth data not ready yet — fall back to async storage read
    Future.microtask(_loadUser);
    return const AccountState();
  }

  // -------------------------------------------------
  // FORMAT CREATED DATE
  // -------------------------------------------------
  String _formatCreatedDate(Map<String, dynamic>? data) {
    final created = data?['user']?['created'];
    if (created is String && created.isNotEmpty) {
      try {
        return DateFormat('MMM d, yyyy').format(DateTime.parse(created));
      } catch (_) {}
    }
    return '';
  }

  // -------------------------------------------------
  // LOAD USER DATA (async fallback)
  // -------------------------------------------------
  Future<void> _loadUser() async {
    state = state.copyWith(isLoading: true);

    try {
      Map<String, dynamic>? data = ref.read(authProvider).userData;
      data ??= await secureStorageService.readObjectData('userData');

      if (_disposed) return;

      if (data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(
        userData: data,
        subscriptionDate: _formatCreatedDate(data),
        isLoading: false,
      );
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Re-load user data (e.g. after auth state changes).
  Future<void> loadUser() => _loadUser();

  // -------------------------------------------------
  // DELETE-PROFILE POPUP
  // -------------------------------------------------
  void showDeleteDialog() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (_) => CustomPopupModal(
        icon: svgDeleteAccount,
        title: deleteAccount,
        subtitle: deleteAccountText,
        textButton1: "No",
        textButton2: "Yes",
        onPressedButton1: () {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null) Navigator.of(ctx, rootNavigator: true).pop();
        },
        onPressedButton2: () => deleteAccountData(),
      ),
    );
  }

  // -------------------------------------------------
  // DELETE ACCOUNT API
  // -------------------------------------------------
  Future<void> deleteAccountData() async {
    // ✅ Close ONLY the dialog
    Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop();

    try {
      final response = await _accountApi.deleteAccount({});
      if (_disposed) return;
      final resp = response.data ?? {};

      // Clear all user data
      await secureStorageService.clearAllData();
      if (_disposed) return;

      // Schedule auth state update for NEXT frame to avoid navigator disposal conflicts
      // This allows current widget tree to finish disposing before GoRouter redirects
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).setAuthenticated(false);
      });

      if (resp['success']) {
        CommonService.animatedToast(resp['message'], 'success');
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      await secureStorageService.clearAllData();
      if (_disposed) return;
      // Schedule auth state update for NEXT frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).setAuthenticated(false);
      });
    }
  }

  // -------------------------------------------------
  // FETCH BILLING DETAILS
  // -------------------------------------------------
  Future<void> navigateToBillingDetails() async {
    try {
      final response = await _accountApi.paymentList({});
      if (_disposed) return;
      final resp = response.data ?? {};

      // Guard: offline error responses return success=false.
      // The global connectivity snackbar already notifies the user.
      if (resp['success'] != true) return;

      if (resp['data']['paymentList'] != null &&
          resp['data']['paymentList'].isNotEmpty) {
        final paymentData = resp['data']['paymentList'][0];
        AppCache().setSubscriptionCacheData({'listData': paymentData});
        rootNavigatorKey.currentContext?.push(
          AppRoutes.subscriptionDetail,
          extra: {'listData': paymentData},
        );
      } else {
        CommonService.animatedToast('No subscription data found', 'error');
      }
    } catch (_) {
      CommonService.animatedToast(
        'Failed to load subscription details',
        'error',
      );
    }
  }

  // -------------------------------------------------
  // FORMAT METHOD
  // -------------------------------------------------
  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return DateFormat('MMM d, yyyy').format(date);
  }
}
