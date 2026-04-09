// Web build

import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:optmsg/webPackerHandler/base_check_out.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

const String _aboutBlank = 'about:blank';

class CheckOutImp extends BaseCheckOut {
  static web.Window? _popup;
  // Holds a tab pre-opened synchronously within a user gesture so that
  // async work (e.g. fetching a signed URL) can run before the tab is
  // populated.  Safari only allows window.open() inside a user gesture;
  // any await breaks that context, so we claim the tab first.
  static web.Window? _pendingTab;
  @override
  void webWindowOpen(String url, [String? features]) {
    if (kIsWeb && features != null) {
      _popup = web.window.open(url, 'popup', features);
      //closeWebWindow();
    } else if (kIsWeb) {
      // web.window.open(url, '_blank');
      web.window.open(url, '_self');
    }
  }

  /// Navigate to URL in the same window/tab (for Stripe payment)
  @override
  void navigateToUrl(String url) {
    if (kIsWeb) {
      web.window.location.href = url;
    }
  }

  /// Bug 20: Open Stripe Checkout in the pre-opened tab (from preOpenTab).
  /// If the tab was blocked by a popup blocker, falls back to same-tab
  /// navigation (existing recovery infrastructure handles that case).
  /// Transfers the tab reference to _popup so closeWebWindow() can close
  /// it after socket-based payment confirmation.
  @override
  void openStripeCheckout(String url) {
    if (_pendingTab != null && !_pendingTab!.closed) {
      (_pendingTab as JSObject)['location'] = url.toJS;
      _popup = _pendingTab; // Transfer so closeWebWindow() can close it
      _pendingTab = null;
      return;
    }
    // Fallback: popup was blocked — use same-tab navigation.
    // Existing localStorage recovery (Bug 20 fix) handles browser back.
    web.window.location.href = url;
  }

  @override
  bool get isUsingPopup => _popup != null;

  /// Pre-opens a blank tab synchronously within the user gesture so that
  /// Safari's popup blocker is satisfied before any async work begins.
  /// Call this before the first `await`, then call the appropriate open
  /// method afterwards — it will navigate the pending tab instead of
  /// opening a new one.
  void preOpenTab() {
    if (!kIsWeb) return;
    _pendingTab = web.window.open(_aboutBlank, '_blank');
    if (_pendingTab != null) {
      // Write a loading indicator that fades in after 600ms (matching the
      // app's standard DelayedLoadingOverlay delay) so fast loads never
      // flash a spinner.
      try {
        final doc = (_pendingTab as JSObject)['document'] as JSObject;
        doc.callMethod('write'.toJS, _loaderHtml.toJS);
        doc.callMethod('close'.toJS);
      } catch (_) {
        // Silently ignore — the tab will just stay blank.
      }
    }
  }

  /// Self-contained HTML loading page with a spinner that only appears after
  /// 600ms via CSS animation-delay — matches the app's standard delayed
  /// loading behaviour from [DelayedLoadingOverlay].
  static const _loaderHtml =
      '<!DOCTYPE html><html><head><meta charset="utf-8">'
      '<style>'
      'body{margin:0;height:100vh;display:flex;align-items:center;'
      'justify-content:center;background:#1a1a2e;font-family:system-ui}'
      '.spinner{width:40px;height:40px;border:3px solid rgba(255,255,255,.15);'
      'border-top-color:#6c63ff;border-radius:50%;'
      'opacity:0;animation:fadeIn .2s ease .6s forwards,spin .8s linear .6s infinite}'
      '@keyframes spin{to{transform:rotate(360deg)}}'
      '@keyframes fadeIn{to{opacity:1}}'
      'p{color:rgba(255,255,255,.6);margin-top:16px;font-size:14px;'
      'opacity:0;animation:fadeIn .2s ease .6s forwards}'
      '.wrap{text-align:center}'
      '</style></head><body><div class="wrap">'
      '<div class="spinner"></div><p>Loading attachment\u2026</p>'
      '</div></body></html>';

  /// Closes and discards the pending tab (e.g. when the API call fails
  /// and there is no content to show).
  void closeAndClearPendingTab() {
    if (_pendingTab != null) {
      if (!_pendingTab!.closed) _pendingTab!.close();
      _pendingTab = null;
    }
  }

  void webWindowOpenPrint(String url, [String? features]) {
    if (_pendingTab != null) {
      (_pendingTab as JSObject)['location'] = url.toJS;
      _pendingTab = null;
      return;
    }
    web.window.open(url, '_blank');
  }

  void addNewCard(String url, [String? features]) {
    // Bug 13: If a pre-opened tab exists (from preOpenTab called synchronously
    // in the button's onPressed), navigate it to the Stripe URL instead of
    // opening a new popup (which Safari would block after an async gap).
    if (_pendingTab != null && !_pendingTab!.closed) {
      (_pendingTab as JSObject)['location'] = url.toJS;
      _pendingTab = null;
      return;
    }
    web.window.open(
      url,
      'popup',
      features ?? "width=500,height=500,menubar=no,toolbar=no,location=no",
    );
  }

  @override
  Future<void> downloadWebFile(String url, {String? suggestedName}) async {
    if (!kIsWeb) return;
    // Use blob-based download for cross-origin URLs (works on all browsers including tablets)
    try {
      final windowObj = web.window as JSObject;
      final response =
          await (windowObj.callMethod('fetch'.toJS, url.toJS) as JSPromise)
              .toDart;
      final blob =
          await ((response as JSObject).callMethod('blob'.toJS) as JSPromise)
              .toDart;

      final urlObj = windowObj['URL'] as JSObject;
      final blobUrl =
          (urlObj.callMethod('createObjectURL'.toJS, blob) as JSString).toDart;

      final anchorElement = web.HTMLAnchorElement();
      anchorElement.href = blobUrl;
      final filename = suggestedName ?? url.split('/').last.split('?').first;
      anchorElement.download = filename.isNotEmpty ? filename : 'download';
      anchorElement.click();

      Future.delayed(const Duration(seconds: 30), () {
        urlObj.callMethod('revokeObjectURL'.toJS, blobUrl.toJS);
      });
    } catch (e) {
      // Fallback to direct anchor download
      final anchorElement = web.HTMLAnchorElement();
      anchorElement.href = url;
      anchorElement.download = suggestedName ?? url;
      anchorElement.click();
    }
  }

  // Prompts the user with a Save dialog and writes the downloaded file there (Chromium browsers).
  // Falls back to anchor download if the File System Access API is unavailable.
  Future<void> downloadWebFileWithPicker(
    String url, {
    String? suggestedName,
  }) async {
    if (!kIsWeb) return;
    try {
      final windowObj = web.window as JSObject;
      final hasSavePicker = windowObj.hasProperty('showSaveFilePicker'.toJS);
      if (hasSavePicker.toDart) {
        final options = <String, dynamic>{};
        if (suggestedName != null && suggestedName.isNotEmpty) {
          options['suggestedName'] = suggestedName;
        }
        final fileHandle =
            await (windowObj.callMethod(
                      'showSaveFilePicker'.toJS,
                      options.jsify(),
                    )
                    as JSPromise)
                .toDart;

        // Only fetch after the user has chosen a destination
        final response =
            await (windowObj.callMethod('fetch'.toJS, url.toJS) as JSPromise)
                .toDart;
        final blob =
            await ((response as JSObject).callMethod('blob'.toJS) as JSPromise)
                .toDart;
        final writable =
            await ((fileHandle as JSObject).callMethod('createWritable'.toJS)
                    as JSPromise)
                .toDart;
        await ((writable as JSObject).callMethod('write'.toJS, blob)
                as JSPromise)
            .toDart;
        await ((writable).callMethod('close'.toJS) as JSPromise).toDart;
        return;
      }
    } catch (e) {
      // If the user cancels the picker, do NOT fallback to auto-download
      try {
        final jsError = e as JSObject;
        final name = (jsError['name'] as JSString?)?.toDart;
        if (name == 'AbortError' ||
            name == 'NotAllowedError' ||
            name == 'SecurityError') {
          return; // user cancelled; no download
        }
      } catch (_) {}
      // Other errors: fall through to anchor fallback
    }

    // Fallback: Fetch as blob and use blob URL for download
    // This works for cross-origin URLs on all browsers including tablets
    try {
      final windowObj = web.window as JSObject;
      final response =
          await (windowObj.callMethod('fetch'.toJS, url.toJS) as JSPromise)
              .toDart;
      final blob =
          await ((response as JSObject).callMethod('blob'.toJS) as JSPromise)
              .toDart;

      // Create blob URL (same-origin, so download attribute works)
      final urlObj = windowObj['URL'] as JSObject;
      final blobUrl =
          (urlObj.callMethod('createObjectURL'.toJS, blob) as JSString).toDart;

      final anchorElement = web.HTMLAnchorElement();
      anchorElement.href = blobUrl;
      if (suggestedName != null && suggestedName.isNotEmpty) {
        anchorElement.download = suggestedName;
      } else {
        // Extract filename from URL
        final filename = url.split('/').last.split('?').first;
        anchorElement.download = filename.isNotEmpty ? filename : 'download';
      }
      anchorElement.click();

      // Clean up blob URL after a delay
      Future.delayed(const Duration(seconds: 30), () {
        urlObj.callMethod('revokeObjectURL'.toJS, blobUrl.toJS);
      });
    } catch (e) {
      // Last resort: direct anchor download (may not work for cross-origin)
      final anchorElement = web.HTMLAnchorElement();
      anchorElement.href = url;
      if (suggestedName != null && suggestedName.isNotEmpty) {
        anchorElement.download = suggestedName;
      } else {
        anchorElement.download = url;
      }
      anchorElement.click();
    }
  }

  /// Fetches [url], wraps the bytes in a new [web.Blob] with an explicit
  /// [mimeType], then opens the resulting blob URL in a new tab.
  ///
  /// This sidesteps two S3 issues at once:
  ///  - Content-Disposition: attachment (blob URLs carry no disposition header)
  ///  - X-Frame-Options blocking (no iframe involved — the tab navigates
  ///    directly to a same-origin blob URL)
  ///
  /// Falls back to a direct window.open if the fetch fails.
  Future<void> openBlobInNewTab(String url, {required String mimeType}) async {
    if (!kIsWeb) return;
    // Use a pre-opened pending tab if one was reserved synchronously within the
    // user gesture (required for Safari).  Otherwise fall back to opening a
    // blank tab here — this still works in Chrome/Firefox where the popup
    // blocker is more lenient.
    final newTab = _pendingTab ?? web.window.open(_aboutBlank, '_blank');
    _pendingTab = null;
    try {
      final windowObj = web.window as JSObject;
      final response =
          await (windowObj.callMethod('fetch'.toJS, url.toJS) as JSPromise)
              .toDart;
      final rawBlob =
          await ((response as JSObject).callMethod('blob'.toJS) as JSPromise)
              .toDart;
      // Re-wrap with the explicit MIME type so the browser's viewer activates
      // even when S3 returns Content-Type: application/octet-stream.
      final typedBlob = web.Blob(
        [rawBlob as JSAny].toJS,
        web.BlobPropertyBag(type: mimeType),
      );
      final urlObj = windowObj['URL'] as JSObject;
      final blobUrl =
          (urlObj.callMethod('createObjectURL'.toJS, typedBlob) as JSString)
              .toDart;
      if (newTab != null) {
        (newTab as JSObject)['location'] = blobUrl.toJS;
      } else {
        web.window.open(blobUrl, '_blank');
      }
      Future.delayed(const Duration(seconds: 60), () {
        urlObj.callMethod('revokeObjectURL'.toJS, blobUrl.toJS);
      });
    } catch (_) {
      // Fallback: navigate the already-opened tab to the signed URL directly.
      if (newTab != null) {
        (newTab as JSObject)['location'] = url.toJS;
      } else {
        web.window.open(url, '_blank');
      }
    }
  }

  /// Fetches an image from [url] as a blob, then wraps it in an HTML page
  /// using a blob `<img src>` so the image survives signed-URL expiry.
  /// Uses the pre-opened pending tab if available (Safari workaround).
  Future<void> openImageBlobInNewTab(String url) async {
    if (!kIsWeb) return;
    final newTab = _pendingTab ?? web.window.open(_aboutBlank, '_blank');
    _pendingTab = null;
    try {
      final windowObj = web.window as JSObject;
      final response =
          await (windowObj.callMethod('fetch'.toJS, url.toJS) as JSPromise)
              .toDart;
      final blob =
          await ((response as JSObject).callMethod('blob'.toJS) as JSPromise)
              .toDart;
      final urlObj = windowObj['URL'] as JSObject;
      final imgBlobUrl =
          (urlObj.callMethod('createObjectURL'.toJS, blob) as JSString).toDart;

      // Wrap the blob image URL in a minimal HTML viewer page.
      final html =
          '<!DOCTYPE html><html><head><meta charset="utf-8">'
          '<meta name="viewport" content="width=device-width,initial-scale=1.0">'
          '<style>html,body{height:100%;margin:0;background:#111;display:flex;'
          'align-items:center;justify-content:center}'
          'img{max-width:100%;max-height:100%;object-fit:contain}</style>'
          '</head><body><img src="$imgBlobUrl"/></body></html>';
      final htmlBlob = web.Blob(
        [html.toJS as JSAny].toJS,
        web.BlobPropertyBag(type: 'text/html'),
      );
      final htmlBlobUrl = web.URL.createObjectURL(htmlBlob);

      if (newTab != null) {
        (newTab as JSObject)['location'] = htmlBlobUrl.toJS;
      } else {
        web.window.open(htmlBlobUrl, '_blank');
      }
      // Don't revoke — the image blob URL is embedded inside the HTML blob.
      // Both will be garbage-collected when the tab closes.
    } catch (_) {
      // Fallback: open the signed URL directly (image may expire on revisit).
      if (newTab != null) {
        (newTab as JSObject)['location'] = url.toJS;
      } else {
        web.window.open(url, '_blank');
      }
    }
  }

  void openHtmlInNewTab(String html) {
    if (!kIsWeb) return;
    // Build a Blob URL instead of writing HTML directly to a new window or
    // using a data: URL — both are XSS vectors when the HTML string contains
    // any attacker-controlled content (e.g. server-supplied URLs or filenames).
    // A Blob URL is same-origin and revoked shortly after the page loads.
    final blob = web.Blob(
      [html.toJS as JSAny].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final blobUrl = web.URL.createObjectURL(blob);
    if (_pendingTab != null) {
      (_pendingTab as JSObject)['location'] = blobUrl.toJS;
      _pendingTab = null;
    } else {
      web.window.open(blobUrl, '_blank');
    }
    Future.delayed(const Duration(seconds: 60), () {
      web.URL.revokeObjectURL(blobUrl);
    });
  }

  @override
  bool webWindowNavigatorUserAgentContains() {
    if (kIsWeb) {
      return web.window.navigator.userAgent.contains('Safari') &&
          !web.window.navigator.userAgent.contains('Chrome');
    }
    return false;
  }

  // New web-specific utility methods
  String getCurrentUrl() {
    if (kIsWeb) {
      return web.window.location.href;
    }
    return '';
  }

  String getCurrentPath() {
    return kIsWeb ? web.window.location.pathname : '';
  }

  Map<String, String> getQueryParams() {
    if (kIsWeb) {
      final uri = Uri.parse(web.window.location.href);
      if (uri.queryParameters.isNotEmpty) {
        return uri.queryParameters;
      }

      // Fallback for hash-based routing where query params are inside the fragment
      if (uri.fragment.contains('?')) {
        final fragmentUri = Uri.parse(uri.fragment);
        return fragmentUri.queryParameters;
      }
    }
    return {};
  }

  /// Clear URL query parameters after processing (e.g., after Stripe redirect)
  void clearUrlParams() {
    if (kIsWeb) {
      final uri = Uri.parse(web.window.location.href);
      // Build clean URL with origin and path only (no query params)
      // For GoRouter hash-based routing, preserve the fragment if present
      String cleanUrl;
      if (uri.fragment.isNotEmpty) {
        // Hash-based routing: keep origin and fragment without query
        cleanUrl = '${uri.origin}/#${uri.fragment.split('?').first}';
      } else {
        // Path-based routing: keep origin and path without query
        cleanUrl = '${uri.origin}${uri.path}';
      }
      web.window.history.replaceState(null, '', cleanUrl);
    }
  }

  @override
  void showWebNotification(String title, String body, {String? icon}) {
    if (!kIsWeb) return;
    try {
      // W-3/H-01: Use the browser's native Notification API to show an
      // OS-level banner when the app is in the foreground.
      final permission = web.Notification.permission;
      if (permission == 'granted') {
        final options = web.NotificationOptions(
          body: body,
          icon: icon ?? 'favicon.png',
        );
        web.Notification(title, options);
      }
    } catch (e) {
      debugPrint('[WebNotification] Failed to show browser notification: $e');
    }
  }

  @override
  void closeWebWindow() {
    if (_popup != null && !_popup!.closed) {
      _popup!.close();
      _popup = null;
      debugPrint("Popup closed manually");
    } else {
      debugPrint("Popup already closed or blocked");
    }
  }
}
