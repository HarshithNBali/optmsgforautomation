import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/webPackerHandler/base_check_out.dart';

class CheckOutImp extends BaseCheckOut {
  @override
  /// Opens a new browser window with the given [url].
  ///
  /// On web, this is not supported, so it throws an exception.
  ///
  /// Optional [features] parameter is not used on web.
  ///
  void webWindowOpen(String url, [String? features]) {
    throw Exception(stubImplementation);
  }

  @override
  /// Downloads a file from the given [url].
  ///
  /// On web, this is not supported, so it throws an exception.
  ///
  Future<void> downloadWebFile(String url, {String? suggestedName}) async {
    throw Exception(stubImplementation);
  }

  @override
  /// Navigates to the given [url] in the current window.
  ///
  /// On stub, this is not supported, so it throws an exception.
  ///
  void navigateToUrl(String url) {
    throw Exception(stubImplementation);
  }

  @override
  /// Checks if the navigator user agent contains the given [userAgent].
  webWindowNavigatorUserAgentContains() {
    throw Exception(stubImplementation);
  }

  @override
  void showWebNotification(String title, String body, {String? icon}) {
    throw Exception(stubImplementation);
  }

  @override
  void closeWebWindow() {
    throw Exception(stubImplementation);
  }

  @override
  void openStripeCheckout(String url) {
    throw Exception(stubImplementation);
  }

  @override
  bool get isUsingPopup => false;
}
