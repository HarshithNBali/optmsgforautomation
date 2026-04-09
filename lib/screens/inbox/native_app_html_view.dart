/// Platform-conditional email HTML renderer.
///
/// On native (iOS/Android) this uses [InAppWebView] for full browser-engine
/// rendering.  On web this uses a raw iframe via [HtmlElementView] to avoid
/// flutter_inappwebview platform-view assertion issues.
library;

import 'native_app_html_view_native.dart'
    if (dart.library.js_interop) 'native_app_html_view_web.dart'
    as platform;

import 'package:flutter/material.dart';

class NativeAppHtmlView extends StatelessWidget {
  final String html;
  final Function(String)? onCallback;

  const NativeAppHtmlView({
    super.key,
    required this.html,
    this.onCallback,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return platform.NativeAppHtmlViewImpl(
      html: html,
      onCallback: onCallback,
      isDarkMode: isDark,
    );
  }
}
