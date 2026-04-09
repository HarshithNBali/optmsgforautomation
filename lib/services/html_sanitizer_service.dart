import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/styles.dart';

/// Dedicated service for HTML email sanitization and rendering.
///
/// Extracted from CommonService to provide a focused, maintainable home for:
/// - Security sanitization (XSS, script injection, dangerous URIs)
/// - Rendering normalization (responsive tables, images, layout)
/// - Plain-text URL linkification and image proxying
/// - HTML stripping for list-view previews
class HtmlSanitizerService {
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  // H-PERF-02: Static cache for htmlReplaceString results.
  // Keyed by input string, capped at 200 entries to prevent unbounded growth.
  // Survives across HtmlSanitizerService() instantiations (it's a factory-style
  // usage). Cleared on logout via clearPreviewCache().
  static final Map<String, String> _previewCache = {};
  static const int _previewCacheMaxSize = 200;

  /// Clears the preview text cache. Call on logout/session clear.
  static void clearPreviewCache() => _previewCache.clear();

  /// Strips HTML tags and decodes entities for email list preview text.
  String htmlReplaceString(String input) {
    if (input.isEmpty) return '';

    // H-PERF-02: Return cached result if available.
    final cached = _previewCache[input];
    if (cached != null) return cached;

    // Remove a known empty-document template some messages carry
    String result = input.replaceAll(
      '<html><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body> </body></html>',
      '',
    );

    // Strip all HTML tags
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities
    result = result
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    }).replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    // Clean up escaped quotes and newlines
    result = result.replaceAll(r'\"', '"');
    result = result.replaceAll('\n', '');

    // Strip protocol prefixes (noise in preview text)
    result = result.replaceAll(
      RegExp(r'https?:', caseSensitive: false),
      ' ',
    );

    // H-PERF-02: Cache the result. Evict oldest entries when full.
    if (_previewCache.length >= _previewCacheMaxSize) {
      // Remove the oldest quarter to amortise eviction cost.
      final keysToRemove = _previewCache.keys.take(_previewCacheMaxSize ~/ 4).toList();
      for (final k in keysToRemove) {
        _previewCache.remove(k);
      }
    }
    _previewCache[input] = result;

    return result;
  }

  /// Returns `true` when [text] is a bare URL with no surrounding content.
  bool isPlainUrl(String text) {
    final t = text.trim();
    return RegExp(r'^https?:\/\/\S+$', caseSensitive: false).hasMatch(t);
  }

  /// Sanitizes raw email HTML for safe, accurate rendering.
  ///
  /// Pipeline order:
  /// 1. Linkify plain-text URLs & proxy non-HTTPS images
  /// 2. Remove dangerous tags (script, iframe, object, embed, …)
  /// 3. Strip event-handler attributes (onclick, onerror, …)
  /// 4. Neutralize javascript:/vbscript:/data: URIs
  /// 5. Remove CSS expressions & JS-in-style
  /// 6. Remove tracking pixels (1 px images)
  /// 7. Remove empty tables
  String sanitizeEmailHtml(String html) {
    if (html.isEmpty) return html;

    // Linkify plain-text URLs and proxy non-HTTPS images
    html = convertPlainUrlToHtml(html);

    return html
        // remove script tags and their content
        .replaceAll(_scriptTagRegex, '')
        // remove iframe tags
        .replaceAll(_iframeTagRegex, '')
        // remove self-closing/unclosed script and iframe tags
        .replaceAll(_selfClosingDangerousRegex, '')
        // H-11: remove dangerous tags (object, embed, applet, form, base)
        .replaceAll(_dangerousTagRegex, '')
        // H-SEC-06: remove SVG elements (XSS via <svg onload=…>, nested <script>, <use xlink:href>)
        .replaceAll(_svgTagRegex, '')
        .replaceAll(_svgSelfClosingRegex, '')
        // H-SEC-06: remove MathML elements (XSS via <math> mutation/nesting bypasses)
        .replaceAll(_mathTagRegex, '')
        .replaceAll(_mathSelfClosingRegex, '')
        // H-SEC-06: strip srcdoc attribute (embeds unsanitized HTML in iframes)
        .replaceAll(_srcdocAttrRegex, '')
        // remove nested html/head/body/meta
        .replaceAll(_structuralTagRegex, '')
        // H-11: strip event handler attributes (onclick, onerror, onload, etc.)
        .replaceAll(_eventHandlerRegex, '')
        // H-11: neutralize javascript:/vbscript:/data: URIs
        .replaceAll(_dangerousUriRegex, r'$1="about:blank"')
        // H-11: remove CSS expressions and javascript in style attributes
        .replaceAll(_cssExpressionRegex, '')
        // remove tracking pixels (1px images)
        .replaceAll(_trackingPixelRegex, '')
        // display:none is left intact — both WebView and HtmlWidget correctly
        // hide these elements; stripping it exposes preheader text
        // remove float layout (important for email rendering)
        .replaceAll(_floatRegex, '')
        // remove empty tables
        .replaceAll(_emptyTableRegex, '');
  }

  /// Wraps sanitized email HTML in a complete document with responsive CSS
  /// and JS width normalization for accurate rendering in WebView / iframe.
  String buildEmailHtml(String rawHtml, {bool isDarkMode = false}) {
    final cleaned = sanitizeEmailHtml(rawHtml);
    final bg = isDarkMode ? AppStyles.emailBgDark : 'transparent';
    final fg = AppStyles.emailFg(isDarkMode);
    final linkColor = AppStyles.emailLink(isDarkMode);
    final quoteBorder = AppStyles.emailQuoteBorder(isDarkMode);

    return """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
${isDarkMode ? '<meta name="color-scheme" content="dark">' : ''}

<style>
  html, body {
    margin:0;
    padding:0 0 28px 0;
    height: auto !important;
    min-height: 0 !important;
    font-family: Arial, Helvetica, sans-serif;
    word-wrap: break-word;
    overflow-x: hidden;
    overflow-y: auto;
    /* Hide the scrollbar visually — the SizedBox is sized to the full content
       height by _updateHeightWeb so the iframe has no actual overflow.
       Using overflow: hidden here breaks document.documentElement.scrollHeight
       measurement in Chromium (returns viewport height instead of content
       height), which prevents the SizedBox from ever expanding. */
    scrollbar-width: none;
    -ms-overflow-style: none;
    background: $bg;
    color: $fg;
    -webkit-text-size-adjust:100%;
  }
  html::-webkit-scrollbar, body::-webkit-scrollbar {
    display: none;
    width: 0;
    height: 0;
  }

  *, *::before, *::after { box-sizing: border-box !important; }
  img { max-width:100% !important; height:auto !important; }
  table { max-width:100% !important; border-collapse:collapse; }
  td, th { overflow-wrap:break-word; }
  /* Do NOT apply max-width: 100% !important to div/p/span — it destroys
     intentional max-width constraints (e.g. myQ logo wrapper max-width: 105px).
     Tables already have max-width: 100% which constrains overall width. */
  a { overflow-wrap: break-word; color: $linkColor; }

  blockquote {
    margin-left:8px;
    padding-left:8px;
    border-left:2px solid $quoteBorder;
  }
${isDarkMode ? '''
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

<body>
$cleaned
<div style="height:28px;"></div>
<style>
  /* Override cascade: placed AFTER email content so it beats any !important
     height/width rules from marketing email <style> blocks (e.g. Nextdoor's
     "body { height: 100% !important }") that would lock the body to viewport
     height and break height measurement. */
  html, body {
    height: auto !important;
    min-height: 0 !important;
    max-height: none !important;
  }
</style>
<script>
  (function() {
    function normalizeWidths() {
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
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', normalizeWidths);
    } else {
      normalizeWidths();
    }
  })();
</script>
</body>
</html>
""";
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  bool _containsHtml(String text) {
    return RegExp(r'<[^>]+>').hasMatch(text);
  }

  /// Linkifies plain-text URLs and proxies non-HTTPS `<img>` sources through
  /// the backend image-proxy endpoint.
  String convertPlainUrlToHtml(String html) {
    String result = html;
    if (!_containsHtml(result)) {
      result = result.replaceAllMapped(
        RegExp(
          r'(?<!href=")(?<!src=")(?<!">)(https?:\/\/[^\s<]+)',
          caseSensitive: false,
        ),
        (match) {
          final url = match.group(0)!;
          return '<a href="$url" target="_blank" rel="noopener noreferrer">$url</a>';
        },
      );
    }
    result = result.replaceAllMapped(
      RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false),
      (match) {
        final originalUrl = match.group(1)!;
        if (originalUrl.startsWith('https://')) {
          return match.group(0)!;
        }
        final proxyUrl =
            '$baseUrl/image-proxy?url=${Uri.encodeComponent(originalUrl)}';
        return match.group(0)!.replaceFirst(originalUrl, proxyUrl);
      },
    );
    return result;
  }

  // ---------------------------------------------------------------------------
  // Compiled regex patterns (static for performance)
  // ---------------------------------------------------------------------------

  static final _scriptTagRegex =
      RegExp('<script[^>]*>[\\s\\S]*?</script>', caseSensitive: false);
  static final _iframeTagRegex =
      RegExp('<iframe[^>]*>[\\s\\S]*?</iframe>', caseSensitive: false);
  static final _selfClosingDangerousRegex =
      RegExp('<(script|iframe)[^>]*/?>', caseSensitive: false);
  static final _structuralTagRegex =
      RegExp('<\\/?(html|head|body|meta)[^>]*>', caseSensitive: false);
  static final _trackingPixelRegex = RegExp(
      '<img[^>]+height=["\\\']?1["\\\']?[^>]*>', caseSensitive: false);
  static final _floatRegex =
      RegExp(r'float\s*:\s*(left|right)\s*;?', caseSensitive: false);
  static final _emptyTableRegex =
      RegExp('<table[^>]*>\\s*</table>', caseSensitive: false);
  // H-11: Event handler attributes (onclick, onerror, onload, etc.)
  static final _eventHandlerRegex =
      RegExp(r'\s+on\w+\s*=\s*["\u0027][^"\u0027]*["\u0027]',
          caseSensitive: false);
  // H-11: javascript:/vbscript:/data: URIs in href, src, action, formaction
  static final _dangerousUriRegex = RegExp(
      r'(href|src|action|formaction|xlink:href)\s*=\s*["\u0027]\s*(javascript|vbscript|data)\s*:',
      caseSensitive: false);
  // H-11: CSS expression() / url("javascript:...") in style attributes
  static final _cssExpressionRegex = RegExp(
      r'style\s*=\s*["\u0027][^"\u0027]*(expression\s*\(|url\s*\(\s*["\u0027]?\s*javascript\s*:)[^"\u0027]*["\u0027]',
      caseSensitive: false);
  // H-11: Dangerous tags beyond script/iframe (object, embed, applet, form, base)
  static final _dangerousTagRegex = RegExp(
      '<\\/?(object|embed|applet|form|base|link[^>]*rel\\s*=\\s*["\u0027]import)[^>]*>',
      caseSensitive: false);
  // H-SEC-06: SVG elements (content + self-closing)
  static final _svgTagRegex =
      RegExp('<svg[^>]*>[\\s\\S]*?</svg>', caseSensitive: false);
  static final _svgSelfClosingRegex =
      RegExp('<svg[^>]*/?>',caseSensitive: false);
  // H-SEC-06: MathML elements (content + self-closing)
  static final _mathTagRegex =
      RegExp('<math[^>]*>[\\s\\S]*?</math>', caseSensitive: false);
  static final _mathSelfClosingRegex =
      RegExp('<math[^>]*/?>', caseSensitive: false);
  // H-SEC-06: srcdoc attribute (embeds unsanitized HTML)
  static final _srcdocAttrRegex =
      RegExp(r'''\s+srcdoc\s*=\s*["'\u0027][^"'\u0027]*["'\u0027]''',
          caseSensitive: false);
}
