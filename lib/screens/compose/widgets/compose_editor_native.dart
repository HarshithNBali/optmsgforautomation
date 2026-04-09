import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Wraps a locally-bundled Quill.js rich-text editor inside an [InAppWebView].
///
/// The editor HTML is loaded from `assets/editor/compose_editor.html` — no
/// server round-trip, no CORS, works offline. Communication with Flutter uses
/// the InAppWebView JavaScript handler bridge.
///
/// Height is reported back via the `onHeightChange` handler so the parent can
/// size a [SizedBox] and let a [SingleChildScrollView] handle scrolling (same
/// pattern as [NativeAppHtmlViewImpl] for email viewing).
class ComposeEditor extends StatefulWidget {
  /// Initial HTML content to load into the editor (for reply/forward/draft).
  final String? initialHtml;

  /// Called whenever the user edits the content, with the current HTML.
  final ValueChanged<String>? onContentChanged;

  /// Called when the editor reports a new content height (in logical pixels).
  final ValueChanged<double>? onHeightChanged;

  /// Called when the Quill.js editor is fully initialized and ready.
  final VoidCallback? onEditorReady;

  /// Called when the active text formats change (cursor position / selection).
  final ValueChanged<Map<String, dynamic>>? onActiveFormatsChanged;

  /// Called when the editor scroll reaches top (true) or scrolls away (false).
  final ValueChanged<bool>? onScrollAtTop;

  /// Whether to apply dark mode CSS variables.
  final bool isDarkMode;

  const ComposeEditor({
    super.key,
    this.initialHtml,
    this.onContentChanged,
    this.onHeightChanged,
    this.onEditorReady,
    this.onActiveFormatsChanged,
    this.onScrollAtTop,
    this.isDarkMode = false,
  });

  @override
  State<ComposeEditor> createState() => ComposeEditorState();
}

class ComposeEditorState extends State<ComposeEditor> {
  InAppWebViewController? _controller;
  bool _editorReady = false;
  String? _pendingHtml;
  String? _cachedAssetHtml;

  // ── Public API (called by ComposeNotifier / ComposeScreen) ──

  /// Returns the current HTML content from the Quill.js editor.
  Future<String> getContent() async {
    if (_controller == null) return '';
    final result = await _controller!.evaluateJavascript(
      source: 'window.getContent()',
    );
    if (result == null || result == 'null') return '';
    // evaluateJavascript may return a raw String or a JSON-encoded string
    if (result is String) {
      // Strip outer quotes if JSON-encoded
      if (result.startsWith('"') && result.endsWith('"')) {
        try {
          return jsonDecode(result) as String;
        } catch (_) {
          return result;
        }
      }
      return result;
    }
    return result.toString();
  }

  /// Returns the plain text content (for validation — e.g. checking emptiness).
  Future<String> getPlainText() async {
    if (_controller == null) return '';
    final result = await _controller!.evaluateJavascript(
      source: 'window.getPlainText()',
    );
    if (result == null || result == 'null') return '';
    if (result is String) {
      if (result.startsWith('"') && result.endsWith('"')) {
        try {
          return jsonDecode(result) as String;
        } catch (_) {
          return result;
        }
      }
      return result;
    }
    return result.toString();
  }

  /// Sets the editor content. Safe to call before the editor is ready —
  /// the content will be applied once `onEditorReady` fires.
  Future<void> setContent(String html) async {
    if (_editorReady && _controller != null) {
      final escaped = jsonEncode(html);
      await _controller!.evaluateJavascript(
        source: 'window.setContent($escaped)',
      );
    } else {
      _pendingHtml = html;
    }
  }

  /// Returns true if the editor content has been modified since the last
  /// [setContent] or [clearDirty] call.
  Future<bool> isDirty() async {
    if (_controller == null) return false;
    final result = await _controller!.evaluateJavascript(
      source: 'window.isDirty()',
    );
    return result == true || result == 'true';
  }

  /// Resets the dirty flag (call after a successful save).
  Future<void> clearDirty() async {
    await _controller?.evaluateJavascript(source: 'window.clearDirty()');
  }

  /// Focuses the Quill.js editor.
  Future<void> focusEditor() async {
    await _controller?.evaluateJavascript(source: 'window.focusEditor()');
  }

  /// Apply a format command to the Quill editor.
  Future<void> applyFormat(String format, dynamic value) async {
    final escaped = jsonEncode(value);
    await _controller?.evaluateJavascript(
      source: 'window.applyFormat("$format", $escaped)',
    );
  }

  Future<void> undo() async {
    await _controller?.evaluateJavascript(source: 'window.editorUndo()');
  }

  Future<void> redo() async {
    await _controller?.evaluateJavascript(source: 'window.editorRedo()');
  }

  /// Requests a fresh height measurement from the editor.
  Future<double> measureHeight() async {
    if (_controller == null) return 200;
    final result = await _controller!.evaluateJavascript(
      source: 'window.getContentHeight()',
    );
    if (result is num) return result.toDouble();
    if (result is String) {
      return double.tryParse(result) ?? 200;
    }
    return 200;
  }

  // ── Lifecycle ──

  @override
  void didUpdateWidget(covariant ComposeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _applyDarkMode();
    }
  }

  Future<void> _applyDarkMode() async {
    await _controller?.evaluateJavascript(
      source: 'window.setDarkMode(${widget.isDarkMode})',
    );
  }

  Future<void> _onEditorReady() async {
    _editorReady = true;

    // Apply dark mode if needed
    if (widget.isDarkMode) {
      await _applyDarkMode();
    }

    // Apply pending content
    final htmlToSet = _pendingHtml ?? widget.initialHtml;
    if (htmlToSet != null && htmlToSet.isNotEmpty) {
      await setContent(htmlToSet);
      _pendingHtml = null;
    }

    widget.onEditorReady?.call();
  }

  @override
  Widget build(BuildContext context) {
    // On web, InAppWebView with local data has limitations.
    // For now this widget targets native (iOS/Android) — web compose
    // will use the same widget once flutter_inappwebview web support
    // stabilizes, or a web-specific implementation can be added.
    return FutureBuilder<String>(
      future: _loadAssetHtml(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200);
        }
        return InAppWebView(
          initialData: InAppWebViewInitialData(
            data: snapshot.data!,
            mimeType: 'text/html',
            encoding: 'utf-8',
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            useHybridComposition: true,
            supportZoom: false,
            disableVerticalScroll: false,
            disableHorizontalScroll: true,
            transparentBackground: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;

            controller.addJavaScriptHandler(
              handlerName: 'onEditorChange',
              callback: (args) {
                if (kDebugMode) debugPrint('[CE_NATIVE] onEditorChange');
                final content = (args.isNotEmpty && args[0] is String)
                    ? args[0] as String
                    : '';
                widget.onContentChanged?.call(content);
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'onScrollAtTop',
              callback: (args) {
                if (args.isNotEmpty && args[0] is bool) {
                  widget.onScrollAtTop?.call(args[0] as bool);
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'onActiveFormats',
              callback: (args) {
                if (kDebugMode) debugPrint('[CE_NATIVE] onActiveFormats: $args');
                if (args.isNotEmpty && args[0] is Map) {
                  widget.onActiveFormatsChanged?.call(
                      Map<String, dynamic>.from(args[0] as Map));
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'onHeightChange',
              callback: (args) {
                if (kDebugMode) debugPrint('[CE_NATIVE] onHeightChange: $args');
                if (args.isNotEmpty && args[0] is num) {
                  final height = (args[0] as num).toDouble();
                  widget.onHeightChanged?.call(height);
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'onEditorReady',
              callback: (_) {
                if (kDebugMode) debugPrint('[CE_NATIVE] onEditorReady');
                _onEditorReady();
              },
            );
          },
          onLoadStop: (controller, url) async {
            if (kDebugMode) debugPrint('[CE_NATIVE] onLoadStop: editorReady=$_editorReady');
            // Fallback: if onEditorReady JS handler doesn't fire
            if (!_editorReady) {
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted && !_editorReady) {
                _onEditorReady();
              }
            }
          },
          onConsoleMessage: (controller, message) {
            if (kDebugMode) {
              debugPrint('[ComposeEditor] ${message.message}');
            }
          },
        );
      },
    );
  }

  Future<String> _loadAssetHtml() async {
    if (_cachedAssetHtml != null) return _cachedAssetHtml!;

    // Load all three assets in parallel
    final results = await Future.wait([
      rootBundle.loadString('assets/editor/compose_editor.html'),
      rootBundle.loadString('assets/editor/quill.snow.css'),
      rootBundle.loadString('assets/editor/quill.js'),
    ]);

    final html = results[0];
    final css = results[1];
    final js = results[2];

    // Replace CDN references with inline content
    _cachedAssetHtml = html
        .replaceFirst(
          '<link href="https://cdn.quilljs.com/1.3.7/quill.snow.css" rel="stylesheet">',
          '<style>\n$css\n</style>',
        )
        .replaceFirst(
          '<script src="https://cdn.quilljs.com/1.3.7/quill.min.js"></script>',
          '<script>\n$js\n</script>',
        );

    return _cachedAssetHtml!;
  }
}
