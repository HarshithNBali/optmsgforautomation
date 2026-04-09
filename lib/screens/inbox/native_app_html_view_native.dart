// Native (iOS/Android) implementation — uses InAppWebView for full browser-engine rendering.
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class NativeAppHtmlViewImpl extends StatefulWidget {
  final String html;
  final Function(String)? onCallback;
  final bool isDarkMode;

  const NativeAppHtmlViewImpl({
    super.key,
    required this.html,
    this.onCallback,
    this.isDarkMode = false,
  });

  @override
  State<NativeAppHtmlViewImpl> createState() => _NativeAppHtmlViewImplState();
}

class _NativeAppHtmlViewImplState extends State<NativeAppHtmlViewImpl> {
  final ValueNotifier<double> _heightNotifier = ValueNotifier<double>(0);
  InAppWebViewController? controller;

  /// PC-04: Cache the built HTML so sanitization only runs once per widget
  /// lifecycle, not on every ValueListenableBuilder rebuild.
  String? _builtHtml;

  /// Tracks whether the first measurement has been applied.
  /// First measurement uses docEl.scrollHeight (reliable on iOS even when
  /// body has height:100%). Subsequent measurements use body.scrollHeight
  /// (accurate after the SizedBox has grown past the viewport).
  bool _firstMeasurementDone = false;

  /// Tracks the last applied scale factor to avoid redundant CSS transform
  /// evaluateJavascript calls.
  double _lastScaleFactor = -1;

  @override
  void dispose() {
    _heightNotifier.dispose();
    super.dispose();
  }

  /// Build platform-aware HTML with a one-time JS normalization script.
  /// Height measurement is driven from Dart via evaluateJavascript in
  /// onLoadStop + timed retries — no element walks or ResizeObservers.
  String _buildPlatformHtml(String rawHtml) {
    final maxScale = Platform.isIOS ? '1.0' : '10.0';
    final userScalable = Platform.isIOS ? 'no' : 'yes';
    final cleaned = HtmlSanitizerService().sanitizeEmailHtml(rawHtml);

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=$maxScale, user-scalable=$userScalable">
${widget.isDarkMode ? '<meta name="color-scheme" content="dark">' : ''}
<style>
  html, body {
    margin: 0;
    padding: 0;
    font-family: Arial, Helvetica, sans-serif;
    word-wrap: break-word;
    background: ${AppStyles.emailBg(widget.isDarkMode)};
    color: ${AppStyles.emailFg(widget.isDarkMode)};
    -webkit-text-size-adjust: 100%;
  }
  *, *::before, *::after { box-sizing: border-box !important; }
  img { max-width: 100% !important; height: auto !important; }
  table { max-width: 100% !important; border-collapse: collapse; }
  td, th { overflow-wrap: break-word; }
  a { overflow-wrap: break-word; color: ${AppStyles.emailLink(widget.isDarkMode)}; }
  blockquote { margin-left: 8px; padding-left: 8px; border-left: 2px solid ${AppStyles.emailQuoteBorder(widget.isDarkMode)}; }
  .email-body { width: 100% !important; max-width: 100% !important; }
${widget.isDarkMode ? '''
  /* Force dark-mode colors over inline styles from email HTML */
  body, body * { color: ${AppStyles.emailFgDark} !important; }
  body a, body a * { color: ${AppStyles.emailLinkDark} !important; }
  [style*="background"], td, th, div, p, span {
    background-color: transparent !important;
    background: transparent !important;
  }
''' : ''}
</style>
</head>
<body style="margin: 0; padding: 0; background-color: ${AppStyles.emailBg(widget.isDarkMode)}; color: ${AppStyles.emailFg(widget.isDarkMode)};">
<div class="email-body">$cleaned</div>
<script>
(function() {
  // Force body/html height to auto — marketing emails (Nextdoor etc.)
  // set body { height: 100% !important } which locks body to viewport.
  document.body.style.setProperty('height', 'auto', 'important');
  document.body.style.setProperty('min-height', '0', 'important');
  document.body.style.setProperty('max-height', 'none', 'important');
  document.documentElement.style.setProperty('height', 'auto', 'important');
  document.documentElement.style.setProperty('min-height', '0', 'important');
  document.documentElement.style.setProperty('max-height', 'none', 'important');

  // Strip width/height HTML attributes from tables and large images.
  // Preserves inline CSS width styles (e.g. td style="width: 1%").
  document.querySelectorAll('table').forEach(function(el) {
    el.removeAttribute('width');
    el.removeAttribute('height');
    el.style.maxWidth = '100%';
  });
  document.querySelectorAll('td,th').forEach(function(el) {
    el.removeAttribute('width');
    el.removeAttribute('height');
  });
  document.querySelectorAll('img').forEach(function(el) {
    var w = parseInt(el.getAttribute('width'), 10) || 0;
    if (w === 0 || w > 100) {
      el.removeAttribute('width');
      el.removeAttribute('height');
      el.style.maxWidth = '100%';
      el.style.height = 'auto';
    }
  });
})();
</script>
</body>
</html>''';
  }

  /// Measure content dimensions via evaluateJavascript and update the
  /// SizedBox height. Uses docEl.scrollHeight on the first call (reliable
  /// on iOS even when body height is clamped), then body.scrollHeight for
  /// subsequent calls (accurate once SizedBox has grown past viewport).
  Future<void> _measureAndScale(
    InAppWebViewController c,
    double screenWidth,
  ) async {
    // First measurement: use max(body.scrollHeight, docEl.scrollHeight).
    // docEl.scrollHeight is reliable on iOS even when body has height:100%.
    //
    // Subsequent measurements: use only body.scrollHeight.
    // docEl.scrollHeight must be excluded because it reflects the SizedBox
    // viewport height once the viewport exceeds content, causing a +50px
    // feedback loop from the SizedBox padding.
    final String js = _firstMeasurementDone
        ? '''
          (function() {
            var w = Math.max(document.body.scrollWidth || 0, document.body.offsetWidth || 0);
            var h = document.body.scrollHeight || 0;
            return JSON.stringify({ width: w, height: h });
          })();
        '''
        : '''
          (function() {
            var w = Math.max(document.body.scrollWidth || 0, document.body.offsetWidth || 0);
            var h = Math.max(
              document.body.scrollHeight || 0,
              document.documentElement.scrollHeight || 0
            );
            return JSON.stringify({ width: w, height: h });
          })();
        ''';

    final result = await c.evaluateJavascript(source: js);
    if (result == null || result == 'null') return;

    // evaluateJavascript may return a String or an already-parsed Map
    // depending on the platform/plugin version.
    final Map<String, dynamic> dims;
    if (result is String) {
      dims = jsonDecode(result) as Map<String, dynamic>;
    } else if (result is Map) {
      dims = Map<String, dynamic>.from(result);
    } else {
      return;
    }

    final originalWidth = (dims['width'] as num).toDouble();
    final originalHeight = (dims['height'] as num).toDouble();

    if (kDebugMode) {
      debugPrint('[EMAIL_HEIGHT] w=$originalWidth h=$originalHeight '
          'current=${_heightNotifier.value} first=${!_firstMeasurementDone}');
    }

    if (originalWidth <= 0 || originalHeight <= 0) return;

    final scaleFactor = (screenWidth / originalWidth).clamp(0.0, 1.0);
    final scaledHeight = originalHeight * scaleFactor;

    // Only grow — prevents late clamped measurements from shrinking.
    if (scaledHeight <= _heightNotifier.value) return;

    // Apply CSS transform only when the scale factor changes.
    if ((scaleFactor - _lastScaleFactor).abs() > 0.001) {
      _lastScaleFactor = scaleFactor;
      await c.evaluateJavascript(source: '''
        (function() {
          document.body.style.overflow = "hidden";
          document.body.style.transformOrigin = "top left";
          document.body.style.transform = "scale($scaleFactor)";
        })();
      ''');
    }

    if (mounted) {
      _heightNotifier.value = scaledHeight;
      _firstMeasurementDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    _builtHtml ??= _buildPlatformHtml(widget.html);

    final initialHeight = MediaQuery.of(context).size.height * 0.7;

    return ValueListenableBuilder<double>(
      valueListenable: _heightNotifier,
      builder: (context, measuredHeight, child) {
        final height = measuredHeight > 0
            ? measuredHeight + 50
            : initialHeight;

        return SizedBox(
          height: height,
          width: screenWidth,
          child: InAppWebView(
            gestureRecognizers: {
              Factory<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(
                  () => ScaleGestureRecognizer()),
            },
            initialData: InAppWebViewInitialData(
              data: _builtHtml!,
              baseUrl: WebUri("https://localhost"),
            ),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              useShouldOverrideUrlLoading: true,
              supportMultipleWindows: false,
              javaScriptCanOpenWindowsAutomatically: false,
              supportZoom: true,
              enableViewportScale: true,
              javaScriptEnabled: true,
              useWideViewPort: true,
              disableHorizontalScroll: false,
              disableVerticalScroll: false,
              useHybridComposition: true,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (c) => controller = c,
            onLoadStop: (c, url) async {
              // Measure immediately, then retry for late-loading content.
              await _measureAndScale(c, screenWidth);

              for (final delay in [300, 1000, 2500]) {
                await Future.delayed(Duration(milliseconds: delay));
                if (!mounted) return;
                await _measureAndScale(c, screenWidth);
              }
            },
            onConsoleMessage: kDebugMode
                ? (controller, consoleMessage) {
                    debugPrint('[EMAIL_JS] ${consoleMessage.message}');
                  }
                : null,
            shouldOverrideUrlLoading: (controller, navAction) async {
              final uri = navAction.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;

              if (uri.host.contains("localhost")) {
                return NavigationActionPolicy.ALLOW;
              }

              if (uri.scheme == "mailto") {
                widget.onCallback?.call(
                  uri.toString().replaceFirst("mailto:", ""),
                );
                return NavigationActionPolicy.CANCEL;
              }

              if (uri.scheme == "http" || uri.scheme == "https") {
                ActionBiometricGuard.markDeparture();
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.CANCEL;
            },
          ),
        );
      },
    );
  }
}
