/// Web implementation of the compose editor using an iframe with Quill.js.
///
/// Uses [HtmlElementView] with `srcdoc` to load Quill.js directly in the
/// browser — no InAppWebView (which doesn't support `initialData` on web).
/// Communication uses `postMessage` (same pattern as native_app_html_view_web.dart).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:optmsg/constant/styles.dart';
import 'package:web/web.dart' as web;

/// Typed JS interop for reading postMessage data from the editor iframe.
extension type _EditorMessage._(JSObject _) implements JSObject {
  external String? get type;
  external String? get source;
  external double? get height;
  external String? get content;
  external bool? get dirty;
  external String? get formats;
  external bool? get atTop;
}

/// The public API shape is the same as ComposeEditorState (native),
/// so compose_screen.dart can use either implementation via GlobalKey.
class ComposeEditor extends StatefulWidget {
  final String? initialHtml;
  final ValueChanged<String>? onContentChanged;
  final ValueChanged<double>? onHeightChanged;
  final VoidCallback? onEditorReady;
  final ValueChanged<Map<String, dynamic>>? onActiveFormatsChanged;
  final ValueChanged<bool>? onScrollAtTop;
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
  late final String _viewType;
  web.HTMLIFrameElement? _iframe;
  StreamSubscription? _messageSub;
  bool _editorReady = false;
  bool _viewFactoryReady = false;
  String? _pendingHtml;
  String? _lastContent;
  Completer<String>? _contentCompleter;
  Completer<String>? _plainTextCompleter;
  Completer<bool>? _dirtyCompleter;

  // Cached Quill.js + CSS loaded from assets
  static String? _cachedQuillJs;
  static String? _cachedQuillCss;

  @override
  void initState() {
    super.initState();
    _viewType =
        'compose-editor-${identityHashCode(this)}-${DateTime.now().millisecondsSinceEpoch}';
    _listenForMessages();
    _loadAndRegister();
  }

  Future<void> _loadAndRegister() async {
    // Load Quill assets from bundle (cached across instances)
    _cachedQuillCss ??=
        await rootBundle.loadString('assets/editor/quill.snow.css');
    _cachedQuillJs ??= await rootBundle.loadString('assets/editor/quill.js');
    if (!mounted) return;
    _registerViewFactory();
    setState(() => _viewFactoryReady = true);
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ComposeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _postToIframe({'type': 'setDarkMode', 'isDark': widget.isDarkMode});
    }
  }

  // ── Public API (same as native ComposeEditorState) ──

  Future<String> getContent() async {
    _contentCompleter = Completer<String>();
    _postToIframe({'type': 'getContent'});
    return _contentCompleter!.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => _lastContent ?? '',
    );
  }

  Future<String> getPlainText() async {
    _plainTextCompleter = Completer<String>();
    _postToIframe({'type': 'getPlainText'});
    return _plainTextCompleter!.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => '',
    );
  }

  Future<void> setContent(String html) async {
    if (_editorReady && _iframe != null) {
      _postToIframe({'type': 'setContent', 'html': html});
    } else {
      _pendingHtml = html;
    }
  }

  Future<bool> isDirty() async {
    _dirtyCompleter = Completer<bool>();
    _postToIframe({'type': 'isDirty'});
    return _dirtyCompleter!.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => false,
    );
  }

  Future<void> clearDirty() async {
    _postToIframe({'type': 'clearDirty'});
  }

  Future<void> focusEditor() async {
    _postToIframe({'type': 'focusEditor'});
  }

  Future<double> measureHeight() async => 300;

  /// Apply a format command to the Quill editor.
  void applyFormat(String format, dynamic value) {
    _postToIframe({'type': 'format', 'format': format, 'value': value});
  }

  void undo() => _postToIframe({'type': 'undo'});
  void redo() => _postToIframe({'type': 'redo'});

  // ── iframe communication ──

  void _postToIframe(Map<String, dynamic> message) {
    _iframe?.contentWindow?.postMessage(
      message.jsify(),
      '*'.toJS,
    );
  }

  void _listenForMessages() {
    _messageSub = web.window.onMessage.listen((web.MessageEvent event) {
      final raw = event.data;
      if (raw == null || !raw.isA<JSObject>()) return;

      final msg = raw as _EditorMessage;
      final type = msg.type;
      if (type == null) return;

      // Filter out messages from other iframes (e.g. ViewEmail).
      // Only compose editor messages use these specific type values.
      const composeTypes = {
        'editorReady', 'editorChange', 'heightUpdate',
        'contentResponse', 'plainTextResponse', 'dirtyResponse',
        'activeFormats', 'scrollAtTop',
      };
      if (!composeTypes.contains(type)) return;

      if (kDebugMode && type != 'editorChange') {
        debugPrint('[CE_WEB] postMessage: type=$type');
      }

      switch (type) {
        case 'editorReady':
          _onEditorReady();
        case 'activeFormats':
          final fmtStr = msg.formats;
          if (fmtStr != null) {
            try {
              final map = Map<String, dynamic>.from(
                  jsonDecode(fmtStr) as Map);
              widget.onActiveFormatsChanged?.call(map);
            } catch (_) {}
          }
        case 'editorChange':
          _lastContent = msg.content;
          widget.onContentChanged?.call(_lastContent ?? '');
        case 'heightUpdate':
          final h = msg.height;
          if (kDebugMode) debugPrint('[CE_WEB] heightUpdate: $h');
          if (h != null && h > 0) widget.onHeightChanged?.call(h);
        case 'scrollAtTop':
          final top = msg.atTop;
          if (top != null) widget.onScrollAtTop?.call(top);
        case 'contentResponse':
          if (_contentCompleter != null && !_contentCompleter!.isCompleted) {
            _lastContent = msg.content ?? '';
            _contentCompleter!.complete(_lastContent);
          }
        case 'plainTextResponse':
          if (_plainTextCompleter != null &&
              !_plainTextCompleter!.isCompleted) {
            _plainTextCompleter!.complete(msg.content ?? '');
          }
        case 'dirtyResponse':
          if (_dirtyCompleter != null && !_dirtyCompleter!.isCompleted) {
            _dirtyCompleter!.complete(msg.dirty ?? false);
          }
      }
    });
  }

  void _onEditorReady() {
    _editorReady = true;
    if (widget.isDarkMode) {
      _postToIframe({'type': 'setDarkMode', 'isDark': true});
    }
    final htmlToSet = _pendingHtml ?? widget.initialHtml;
    if (htmlToSet != null && htmlToSet.isNotEmpty) {
      _postToIframe({'type': 'setContent', 'html': htmlToSet});
      _pendingHtml = null;
    }
    widget.onEditorReady?.call();
  }

  void _registerViewFactory() {
    final isDark = widget.isDarkMode;
    final htmlContent = _buildEditorHtml(isDark);

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
        iframe.setAttribute('srcdoc', htmlContent);
        // allow-scripts for Quill.js execution + postMessage
        // NO allow-same-origin — follows same security pattern as email viewer
        iframe.setAttribute('sandbox', 'allow-scripts');
        _iframe = iframe;
        return iframe;
      },
    );
  }

  // Build editor HTML using StringBuffer — Quill.js source contains $
  // characters that would break Dart string interpolation.
  String _buildEditorHtml(bool isDark) {
    final bg = isDark ? AppStyles.emailBgDark : AppStyles.emailBgLight;
    final fg = isDark ? AppStyles.emailFgDark : AppStyles.emailFgLight;
    final link = isDark ? AppStyles.emailLinkDark : AppStyles.emailLinkLight;
    final placeholder = isDark ? '#666' : '#aaa';
    final border = isDark ? '#3A3A3A' : '#e0e0e0';
    final tbBg = isDark ? '#1E1E1E' : '#ffffff';

    final sb = StringBuffer();
    sb.write('<!DOCTYPE html><html lang="en"><head>');
    sb.write('<meta charset="UTF-8">');
    sb.write('<meta name="viewport" content="width=device-width,initial-scale=1.0">');
    // Quill Snow CSS inlined from local asset
    sb.write('<style>');
    sb.write(_cachedQuillCss ?? '');
    sb.write('</style>');
    // Custom overrides
    sb.write('<style>');
    final iconColor = isDark ? '#9E9E9E' : '#747474';
    sb.write(':root{--editor-bg:$bg;--editor-fg:$fg;--editor-link:$link;');
    sb.write('--icon-color:$iconColor;');
    sb.write('--editor-placeholder:$placeholder;--editor-border:$border;--toolbar-bg:$tbBg}');
    sb.write('*{box-sizing:border-box;margin:0;padding:0}');
    sb.write('html,body{height:100%;overflow:hidden;background:var(--editor-bg);color:var(--editor-fg);');
    sb.write("font-family:'Noto Sans',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;font-size:14px}");
    sb.write('.ql-toolbar.ql-snow{border:none!important;border-bottom:.5px solid var(--editor-border)!important;');
    sb.write('background:var(--toolbar-bg);padding:4px 8px!important;overflow-x:auto;overflow-y:hidden;');
    sb.write('white-space:nowrap;-webkit-overflow-scrolling:touch;scrollbar-width:none}');
    sb.write('.ql-toolbar.ql-snow::-webkit-scrollbar{display:none}');
    sb.write('.ql-toolbar button{width:28px!important;height:28px!important;padding:4px!important}');
    sb.write('.ql-toolbar .ql-picker{height:28px!important}');
    sb.write('.ql-toolbar .ql-stroke{stroke:var(--icon-color)!important}');
    sb.write('.ql-toolbar .ql-fill{fill:var(--icon-color)!important}');
    sb.write('.ql-toolbar .ql-picker-label{color:var(--icon-color)!important}');
    sb.write('.ql-toolbar.ql-snow{display:none!important}');
    sb.write('body{display:flex;flex-direction:column}');
    sb.write('.ql-container.ql-snow{border:none!important;font-size:14px;flex:1;overflow:hidden}');
    sb.write('.ql-editor{padding:12px;height:100%;color:var(--editor-fg);');
    sb.write('background:var(--editor-bg);line-height:1.6;overflow-y:auto!important}');
    sb.write('.ql-editor.ql-blank::before{color:var(--editor-placeholder);font-style:italic}');
    sb.write('.ql-editor a{color:var(--editor-link)}');
    sb.write('.ql-editor img{max-width:100%!important;height:auto!important}');
    sb.write('.ql-editor blockquote{border-left:3px solid var(--editor-border);margin:4px 0;padding-left:12px}');
    sb.write('.ql-tooltip{display:none!important}');
    sb.write('</style></head><body>');
    sb.write('<div id="editor"></div>');
    // Quill JS inlined from local asset
    sb.write('<script>');
    sb.write(_cachedQuillJs ?? '');
    sb.write('</script>');
    // Editor init + postMessage bridge
    sb.write('<script>');
    sb.write(r"""
(function(){
  'use strict';
  var S='compose-editor';
  var quill=new Quill('#editor',{theme:'snow',modules:{toolbar:false},placeholder:'Compose your message...'});
  var dirty=false;
  function post(obj){obj.source=S;parent.postMessage(obj,'*');}
  function reportFormats(){
    var f=quill.getFormat();
    post({type:'activeFormats',formats:JSON.stringify(f)});
  }
  quill.on('text-change',function(){
    dirty=true;
    post({type:'editorChange',content:quill.root.innerHTML});
    var h=Math.max(document.body.scrollHeight||0,document.documentElement.scrollHeight||0);
    post({type:'heightUpdate',height:h});
  });
  window.addEventListener('message',function(e){
    var d=e.data;if(!d||!d.type)return;
    switch(d.type){
      case 'getContent':post({type:'contentResponse',content:quill.root.innerHTML});break;
      case 'getPlainText':post({type:'plainTextResponse',content:quill.getText().trim()});break;
      case 'setContent':
        var delta=quill.clipboard.convert(d.html||'');quill.setContents(delta,'silent');dirty=false;
        setTimeout(function(){var h=Math.max(document.body.scrollHeight||0,document.documentElement.scrollHeight||0);
        post({type:'heightUpdate',height:h});},100);break;
      case 'isDirty':post({type:'dirtyResponse',dirty:dirty});break;
      case 'clearDirty':dirty=false;break;
      case 'focusEditor':quill.focus();break;
      case 'format':
        var fmt=d.format,val=d.value;
        if(fmt==='clean'){quill.removeFormat(quill.getSelection()||{index:0,length:quill.getLength()});}
        else if(fmt==='link'){var url=prompt('Enter URL:');if(url)quill.format('link',url);}
        else if(fmt==='indent'){quill.format('indent',val==='+1'?'+1':'-1');}
        else if(val===false||val==='false'){quill.format(fmt,false);}
        else{quill.format(fmt,val===true||val==='true'?true:val);}
        reportFormats();break;
      case 'undo':quill.history.undo();break;
      case 'redo':quill.history.redo();break;
      case 'setDarkMode':
        var r=document.documentElement.style;
        if(d.isDark){r.setProperty('--editor-bg','#121212');r.setProperty('--editor-fg','#D1D5DB');
          r.setProperty('--icon-color','#9E9E9E');
          r.setProperty('--editor-link','#7EB3FF');r.setProperty('--editor-placeholder','#666');
          r.setProperty('--editor-border','#3A3A3A');r.setProperty('--toolbar-bg','#1E1E1E');
        }else{r.setProperty('--editor-bg','#ffffff');r.setProperty('--editor-fg','#000000');
          r.setProperty('--icon-color','#747474');
          r.setProperty('--editor-link','#1c5ad6');r.setProperty('--editor-placeholder','#aaa');
          r.setProperty('--editor-border','#ccc');r.setProperty('--toolbar-bg','#f8f8f8');
        }
        document.body.style.background=d.isDark?'#121212':'#ffffff';
        document.body.style.color=d.isDark?'#D1D5DB':'#000000';break;
    }
  });
  quill.on('selection-change',function(range){if(range)reportFormats();});
  var lastAtTop=true;
  var edEl=document.querySelector('.ql-editor');
  if(edEl){edEl.addEventListener('scroll',function(){
    var atTop=edEl.scrollTop<5;
    if(atTop!==lastAtTop){lastAtTop=atTop;post({type:'scrollAtTop',atTop:atTop});}
  });}
  setTimeout(function(){post({type:'editorReady'});},100);
})();
""");
    sb.write('</script></body></html>');
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewFactoryReady) {
      if (kDebugMode) debugPrint('[CE_WEB] build: viewFactory not ready');
      return const SizedBox(height: 200);
    }
    if (kDebugMode) debugPrint('[CE_WEB] build: viewFactory ready');
    return HtmlElementView(viewType: _viewType);
  }
}
