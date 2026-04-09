import 'package:flutter/foundation.dart' show debugPrint;
import 'package:url_launcher/url_launcher.dart';
import 'package:optmsg/webPackerHandler/base_check_out.dart';

class CheckOutImp extends BaseCheckOut {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  void webWindowOpen(String url, [String? features]) {
    _launchUrl(url);
  }

  @override
  Future<void> downloadWebFile(String url, {String? suggestedName}) async {
    await _launchUrl(url);
  }

  @override
  void navigateToUrl(String url) {
    _launchUrl(url);
  }

  @override
  bool webWindowNavigatorUserAgentContains() {
    return false;
  }

  void webWindowOpenPrint(String url, [String? features]) {
    _launchUrl(url);
  }

  void addNewCard(String url, [String? features]) {
    _launchUrl(url);
  }

  Future<void> downloadWebFileWithPicker(
    String url, {
    String? suggestedName,
  }) async {
    await _launchUrl(url);
  }

  @override
  void openStripeCheckout(String url) {
    _launchUrl(url);
  }

  @override
  bool get isUsingPopup => false;

  // Web-only utilities — no-op on mobile
  Future<void> openBlobInNewTab(String url, {required String mimeType}) async {}
  Future<void> openImageBlobInNewTab(String url) async {}
  void openHtmlInNewTab(String html) {}
  void preOpenTab() {}
  void closeAndClearPendingTab() {}

  String getCurrentUrl() => '';

  String getCurrentPath() => '';

  Map<String, String> getQueryParams() => {};

  void clearUrlParams() {}

  @override
  void showWebNotification(String title, String body, {String? icon}) {
    // No-op on mobile — native push notifications are handled by the OS
  }

  @override
  void closeWebWindow() {
    // No-op on mobile — cannot close external browser
  }
}
