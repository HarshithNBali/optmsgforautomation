// Web implementation — uses a raw iframe via HtmlElementView.
// This avoids flutter_inappwebview platform-view assertion issues on web
// and gives native browser text selection, CSS rendering, and table layout.
//
// Scroll strategy: the iframe has pointer-events:none so all touch/mouse
// events pass straight through to Flutter's SingleChildScrollView (native
// physics, momentum, deceleration).  A GestureDetector overlay forwards
// tap coordinates into the iframe via postMessage so links still work.
// Desktop wheel scroll also passes through to Flutter natively.
import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:optmsg/services/html_sanitizer_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

/// Typed JS interop for reading postMessage data from the iframe.
extension type _MessageData._(JSObject _) implements JSObject {
  external String? get type;
  external String? get url;
  external double? get height;
}

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
  late final String _viewType;
  double _height = 300;
  StreamSubscription? _messageSub;
  bool _heightUpdateScheduled = false;
  double _pendingHeight = 0;
  web.HTMLIFrameElement? _iframe;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _viewType =
        'email-iframe-${identityHashCode(this)}-${DateTime.now().millisecondsSinceEpoch}';
    _listenForMessages();
    _registerViewFactory();
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  void _listenForMessages() {
    _messageSub = web.window.onMessage.listen((web.MessageEvent event) {
      // Only accept messages from sandboxed iframes (origin 'null') or same origin.
      final origin = event.origin;
      if (origin != 'null' && origin != web.window.location.origin) return;

      final raw = event.data;
      if (raw == null) return;
      if (!raw.isA<JSObject>()) return;

      final msg = raw as _MessageData;
      final type = msg.type;
      if (type == null) return;

      if (type == 'emailLinkClick') {
        final url = msg.url;
        if (url != null) _handleLinkClick(url);
      } else if (type == 'emailHeightUpdate') {
        final h = msg.height;
        if (h != null && h > 0) _deferHeightUpdate(h);
      }
    });
  }

  /// Defer height setState via microtask to avoid platform-view assertions.
  void _deferHeightUpdate(double h) {
    _pendingHeight = h;
    if (_heightUpdateScheduled) return;
    _heightUpdateScheduled = true;
    Future.microtask(() {
      _heightUpdateScheduled = false;
      final newH = _pendingHeight;
      if (!mounted || newH <= 0 || (newH - _height).abs() <= 1) return;
      setState(() => _height = newH);
    });
  }

  void _handleLinkClick(String url) {
    if (url.startsWith('mailto:')) {
      final email = url.replaceFirst('mailto:', '');
      widget.onCallback?.call(email);
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _registerViewFactory() {
    final htmlContent = _buildWebHtml(widget.html);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId, {Object? params}) {
        final iframe = web.document.createElement('iframe')
            as web.HTMLIFrameElement;
        iframe.style.setProperty('width', '100%');
        iframe.style.setProperty('height', '100%');
        iframe.style.setProperty('border', 'none');
        iframe.style.setProperty('overflow', 'hidden');
        iframe.style.setProperty('display', 'block');
        // pointer-events:none — all touch/mouse events pass through to Flutter.
        // Links are handled via GestureDetector overlay → postMessage → iframe JS.
        iframe.style.setProperty('pointer-events', 'none');
        iframe.setAttribute('srcdoc', htmlContent);
        // allow-scripts: needed for JS (height measurement, link coordinate checking)
        // NO allow-same-origin: iframe must not share origin with parent (SEC-01)
        // NO allow-popups: links are handled exclusively via postMessage → Dart launchUrl
        iframe.setAttribute('sandbox', 'allow-scripts');
        _iframe = iframe;

        return iframe;
      },
    );
  }

  /// Send tap coordinates to the iframe so it can check if a link was hit.
  void _handleTapUp(TapUpDetails details) {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 300) {
      return;
    }
    _lastTapTime = now;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || _iframe == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final x = details.globalPosition.dx - offset.dx;
    final y = details.globalPosition.dy - offset.dy;

    _iframe!.contentWindow?.postMessage(
      <String, Object>{'type': 'checkTap', 'x': x, 'y': y}.jsify(),
      '*'.toJS,
    );
  }

  String _buildWebHtml(String rawHtml) {
    final base = HtmlSanitizerService().buildEmailHtml(rawHtml, isDarkMode: widget.isDarkMode);

    // JS inside the iframe:
    // 1. Measures content height and posts it to parent (for SizedBox sizing)
    // 2. Listens for 'checkTap' messages from the GestureDetector overlay,
    //    checks if a link exists at those coordinates, and posts back 'emailLinkClick'
    // 3. Click listener as fallback for desktop (pointer-events:none is on the
    //    iframe element, but the click listener still works for programmatic clicks)
    const script = r'''
<script>
(function() {
  // --- Height measurement ---
  function measureAndPost() {
    var h = Math.max(
      document.body.scrollHeight || 0,
      document.body.offsetHeight || 0,
      document.documentElement.scrollHeight || 0,
      document.documentElement.offsetHeight || 0
    );
    if (h > 0) {
      window.parent.postMessage({
        type: 'emailHeightUpdate',
        height: h
      }, '*');
    }
  }
  measureAndPost();
  setTimeout(measureAndPost, 300);
  setTimeout(measureAndPost, 1000);
  setTimeout(measureAndPost, 2000);

  if (typeof ResizeObserver !== 'undefined') {
    new ResizeObserver(measureAndPost).observe(document.body);
  }

  // --- Disable internal scroll (content is sized to fit via parent SizedBox) ---
  document.documentElement.style.overflow = 'hidden';
  document.body.style.overflow = 'hidden';

  // --- Tap-to-link: receive coordinates from Flutter GestureDetector overlay ---
  var lastTapTime = 0;
  window.addEventListener('message', function(event) {
    if (!event.data || event.data.type !== 'checkTap') return;
    var now = Date.now();
    if (now - lastTapTime < 300) return;
    lastTapTime = now;

    var x = event.data.x;
    var y = event.data.y;
    var el = document.elementFromPoint(x, y);
    while (el && el.tagName !== 'A') el = el.parentElement;
    if (el && el.href) {
      window.parent.postMessage({
        type: 'emailLinkClick',
        url: el.href
      }, '*');
    }
  });

  // --- Fallback click listener (for any direct clicks that reach the iframe) ---
  document.addEventListener('click', function(e) {
    var anchor = e.target.closest ? e.target.closest('a') : null;
    if (!anchor) {
      var el = e.target;
      while (el && el.tagName !== 'A') el = el.parentElement;
      anchor = el;
    }
    if (anchor && anchor.href) {
      e.preventDefault();
      e.stopPropagation();
      window.parent.postMessage({
        type: 'emailLinkClick',
        url: anchor.href
      }, '*');
      return false;
    }
  }, true);
})();
</script>
''';

    final idx = base.lastIndexOf('</body>');
    if (idx != -1) {
      return '${base.substring(0, idx)}$script${base.substring(idx)}';
    }
    return '$base$script';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          HtmlElementView(viewType: _viewType),
          // Transparent overlay captures taps and forwards coordinates
          // to the iframe via postMessage for link hit-testing.
          // pointer-events:none on the iframe means Flutter gets all
          // touch/scroll events natively (full physics, momentum, etc).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: _handleTapUp,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
