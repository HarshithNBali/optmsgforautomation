abstract mixin class BaseCheckOut {
  void webWindowOpen(String url, [String? windowFeatures]);
  Future<void> downloadWebFile(String url, {String? suggestedName});
  void navigateToUrl(String url);
  void openStripeCheckout(String url);
  bool get isUsingPopup;
  bool webWindowNavigatorUserAgentContains();
  void showWebNotification(String title, String body, {String? icon});
  void closeWebWindow();
}
