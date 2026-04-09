import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'secure_print_web_stub.dart'
    if (dart.library.js_interop) 'secure_print_web.dart' as web_print;

/// Opens the OS/browser print dialog for the given email.
///
/// - **Web**: fetches the email HTML with auth headers, injects it into a
///   hidden iframe, and calls `contentWindow.print()`.
/// - **Mobile/Desktop**: loads the email in a hidden WebView, triggers
///   `printCurrentPage()`, then shows a "Done" button to dismiss.
///   The WebView must stay alive while the OS print sheet is showing
///   because iOS maintains a live reference to the WebView content.
///
/// The [subject] is used to set the document title in the print dialog
/// (affects the default filename when saving as PDF).
Future<void> openSecurePrint({
  required String printUrl,
  required String token,
  required BuildContext context,
  String? subject,
}) async {
  if (kIsWeb) {
    await web_print.openWebPrint(
      printUrl: printUrl,
      token: token,
      context: context,
      subject: subject,
    );
  } else {
    _openMobilePrint(
        printUrl: printUrl, token: token, context: context, subject: subject);
  }
}

// ---------------------------------------------------------------------------
// Mobile / Desktop
// ---------------------------------------------------------------------------

void _openMobilePrint({
  required String printUrl,
  required String token,
  required BuildContext context,
  String? subject,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _MobilePrintLoader(
      printUrl: printUrl,
      token: token,
      subject: subject,
    ),
  );
}

/// Full-screen print preview dialog (iOS + Android):
/// 1. Shows a loading spinner while the WebView loads the email HTML
/// 2. Reveals the email preview with a print button in the AppBar
/// 3. User taps print → `window.print()` triggers the native OS print dialog
/// 4. Close button always available to return to the message
///
/// Uses `evaluateJavascript('window.print()')` instead of `printCurrentPage()`
/// because iOS requires a user gesture context for the print sheet to stay
/// open — programmatic/auto-triggered calls cause iOS to dismiss immediately.
class _MobilePrintLoader extends StatefulWidget {
  final String printUrl;
  final String token;
  final String? subject;

  const _MobilePrintLoader({
    required this.printUrl,
    required this.token,
    this.subject,
  });

  @override
  State<_MobilePrintLoader> createState() => _MobilePrintLoaderState();
}

class _MobilePrintLoaderState extends State<_MobilePrintLoader> {
  bool _printTriggered = false;
  bool _isLoading = true;
  InAppWebViewController? _webViewController;

  Map<String, String> get _authHeaders => {
        'authorization': widget.token,
        'tokentype': 'descope',
      };

  void _onLoadFinished(InAppWebViewController controller) async {
    if (_printTriggered) return;
    _printTriggered = true;
    if (!mounted) return;

    // Set document title for save-as-PDF filename
    if (widget.subject != null && widget.subject!.isNotEmpty) {
      final escaped = widget.subject!
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'");
      await controller.evaluateJavascript(
        source: "document.title = '$escaped';",
      );
    }

    // Store the controller so the print button can use it.
    _webViewController = controller;
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handlePrint() async {
    if (_webViewController == null) return;

    // Suppress biometric lock during the print dialog lifecycle transitions.
    ActionBiometricGuard.markDeparture();

    try {
      // Must use evaluateJavascript('window.print()') — iOS requires a user
      // gesture context for the print sheet to stay open. printCurrentPage()
      // and auto-triggered calls both cause iOS to dismiss immediately.
      await _webViewController!.evaluateJavascript(source: 'window.print();');
    } catch (_) {}

    ActionBiometricGuard.markReturn();
  }

  void _dismiss() {
    ActionBiometricGuard.markReturn();
    if (mounted) Navigator.of(context).pop();
  }

  void _onError() {
    if (!mounted || _printTriggered) return;
    _printTriggered = true;
    Navigator.of(context).pop();
    CommonService.animatedToast('Failed to load email for printing.', 'error');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Print Preview'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: _dismiss,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print',
              onPressed: _isLoading ? null : _handlePrint,
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.printUrl),
                headers: _authHeaders,
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                useHybridComposition: true,
                transparentBackground: false,
              ),
              onLoadStop: (controller, url) {
                _onLoadFinished(controller);
              },
              onReceivedError: (controller, request, error) {
                _onError();
              },
              onReceivedHttpError: (controller, request, response) {
                _onError();
              },
            ),
            if (_isLoading)
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
