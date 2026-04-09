import 'package:flutter/material.dart';

/// Stub implementation of WebWebView for non-web platforms.
/// This widget is never actually rendered on mobile since the code
/// uses kIsWeb to conditionally show either InAppWebView or WebWebView.
class WebWebView extends StatelessWidget {
  final String htmlContent;
  final String token;
  final bool readingPaneEnabled;
  final void Function(String email)? onViewEditContact;
  final double? minHeight;

  const WebWebView({
    required this.htmlContent,
    required this.token,
    this.readingPaneEnabled = false,
    this.onViewEditContact,
    this.minHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // This should never be called on mobile platforms
    return const SizedBox.shrink();
  }
}
