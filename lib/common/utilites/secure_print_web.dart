import 'package:flutter/material.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Web implementation: fetches the email HTML with auth headers, injects it
/// into a hidden iframe, and calls `contentWindow.print()`.
///
/// The browser print dialog appears without any visible tab or window.
/// When the user prints or cancels, the iframe is cleaned up automatically.
///
/// Uses a Blob URL (same-origin) so `contentWindow.print()` works without
/// cross-origin restrictions.
Future<void> openWebPrint({
  required String printUrl,
  required String token,
  required BuildContext context,
  String? subject,
}) async {
  // Show a brief loading spinner while fetching
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Fetch the email HTML with auth headers using JS fetch()
    final windowObj = web.window as JSObject;
    final headers = {
      'authorization': token,
      'tokentype': 'descope',
    }.jsify();
    final options = {'headers': headers}.jsify();

    final response = await (windowObj.callMethod(
            'fetch'.toJS, printUrl.toJS, options) as JSPromise)
        .toDart;
    final html =
        await ((response as JSObject).callMethod('text'.toJS) as JSPromise)
            .toDart;
    var htmlString = (html as JSString).toDart;

    // Inject a <title> tag for save-as-PDF filename
    final title = subject?.isNotEmpty == true ? subject! : 'Print Email';
    if (!htmlString.contains('<title>')) {
      htmlString = htmlString.replaceFirst(
        '<head>',
        '<head><title>${_escapeHtml(title)}</title>',
      );
    }

    // Create a Blob URL from the HTML content (same-origin, so
    // contentWindow.print() works without cross-origin restrictions)
    final blob = web.Blob(
      [htmlString.toJS as JSAny].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final blobUrl = web.URL.createObjectURL(blob);

    // Create a hidden iframe and inject it into the DOM
    final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
    iframe.style.position = 'fixed';
    iframe.style.width = '0';
    iframe.style.height = '0';
    iframe.style.border = 'none';
    iframe.style.visibility = 'hidden';
    iframe.src = blobUrl;
    web.document.body?.append(iframe);

    // Dismiss the loading spinner
    if (context.mounted) Navigator.of(context).pop();

    // When the iframe loads, trigger print on its content window
    (iframe as JSObject).callMethod(
      'addEventListener'.toJS,
      'load'.toJS,
      (JSAny _) {
        try {
          final contentWindow = iframe.contentWindow;
          if (contentWindow == null) {
            _cleanup(iframe, blobUrl);
            return;
          }
          final cw = contentWindow as JSObject;

          // Register afterprint to clean up when user finishes
          cw.callMethod(
            'addEventListener'.toJS,
            'afterprint'.toJS,
            (JSAny _) {
              _cleanup(iframe, blobUrl);
            }.toJS,
          );

          // Trigger the browser print dialog
          cw.callMethod('print'.toJS);
        } catch (e) {
          // If hidden iframe print fails, fall back to new-tab approach
          _cleanup(iframe, blobUrl);
          _fallbackNewTab(blobUrl: blobUrl, blob: blob);
        }
      }.toJS,
    );

    // Safety: clean up after 60 seconds regardless
    Future.delayed(const Duration(seconds: 60), () {
      _cleanup(iframe, blobUrl);
    });
  } catch (e) {
    // Dismiss loading spinner if still showing
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) {
      CommonService.animatedToast('Print failed: $e', 'error');
    }
  }
}

/// Remove the iframe from the DOM and revoke the blob URL.
void _cleanup(web.HTMLIFrameElement iframe, String blobUrl) {
  try {
    iframe.remove();
  } catch (_) {}
  try {
    web.URL.revokeObjectURL(blobUrl);
  } catch (_) {}
}

/// Fallback: open a new tab if hidden iframe print doesn't work.
void _fallbackNewTab({required String blobUrl, required web.Blob blob}) {
  // Re-create blob URL since the previous one may have been revoked
  final freshUrl = web.URL.createObjectURL(blob);
  final win = web.window.open(freshUrl, '_blank');
  if (win != null) {
    final winObj = win as JSObject;
    winObj.callMethod(
      'addEventListener'.toJS,
      'load'.toJS,
      (JSAny _) {
        winObj.callMethod(
          'addEventListener'.toJS,
          'afterprint'.toJS,
          (JSAny _) {
            win.close();
            web.URL.revokeObjectURL(freshUrl);
          }.toJS,
        );
        winObj.callMethod('print'.toJS);
      }.toJS,
    );
  }
}

/// Escapes HTML special characters for safe insertion into HTML content.
String _escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
