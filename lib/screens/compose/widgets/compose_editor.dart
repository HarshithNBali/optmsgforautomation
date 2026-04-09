/// Platform-conditional compose editor.
///
/// On native (iOS/Android) this uses [InAppWebView] with a locally-bundled
/// Quill.js asset.  On web this uses a raw iframe via [HtmlElementView]
/// since InAppWebView's `initialData` doesn't support CDN script loading
/// on web (cross-origin sandbox restrictions).
library;

export 'compose_editor_native.dart'
    if (dart.library.js_interop) 'compose_editor_web.dart';
