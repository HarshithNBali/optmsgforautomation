import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';

void main() {
  late HtmlSanitizerService sanitizer;

  setUp(() {
    sanitizer = HtmlSanitizerService();
  });

  group('htmlReplaceString', () {
    test('should return empty string for empty input', () {
      expect(sanitizer.htmlReplaceString(''), '');
    });

    test('should strip HTML tags', () {
      expect(sanitizer.htmlReplaceString('<p>Hello</p>'), 'Hello');
    });

    test('should decode &nbsp;', () {
      expect(sanitizer.htmlReplaceString('Hello&nbsp;World'), 'Hello World');
    });

    test('should decode &amp;', () {
      expect(sanitizer.htmlReplaceString('A&amp;B'), 'A&B');
    });

    test('should decode &lt; and &gt;', () {
      expect(sanitizer.htmlReplaceString('&lt;tag&gt;'), '<tag>');
    });

    test('should decode &quot;', () {
      expect(sanitizer.htmlReplaceString('&quot;quoted&quot;'), '"quoted"');
    });

    test('should decode &#39; and &apos;', () {
      expect(sanitizer.htmlReplaceString("it&#39;s"), "it's");
      expect(sanitizer.htmlReplaceString("it&apos;s"), "it's");
    });

    test('should decode numeric HTML entities', () {
      expect(sanitizer.htmlReplaceString('&#65;'), 'A');
    });

    test('should decode hex HTML entities', () {
      expect(sanitizer.htmlReplaceString('&#x41;'), 'A');
    });

    test('should strip protocol prefixes', () {
      final result = sanitizer.htmlReplaceString('Visit https://example.com');
      expect(result, isNot(contains('https:')));
    });

    test('should remove known empty-document template', () {
      const template =
          '<html><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body> </body></html>';
      final result = sanitizer.htmlReplaceString(template);
      // Template is removed, then remaining whitespace is stripped of tags
      expect(result.trim(), isEmpty);
    });

    test('should strip newlines', () {
      expect(sanitizer.htmlReplaceString('line1\nline2'), 'line1line2');
    });
  });

  group('isPlainUrl', () {
    test('should return true for plain HTTP URL', () {
      expect(sanitizer.isPlainUrl('https://example.com'), true);
    });

    test('should return true for URL with path', () {
      expect(sanitizer.isPlainUrl('https://example.com/path/to/page'), true);
    });

    test('should return false for text with URL', () {
      expect(sanitizer.isPlainUrl('Visit https://example.com'), false);
    });

    test('should return false for plain text', () {
      expect(sanitizer.isPlainUrl('just text'), false);
    });

    test('should handle leading/trailing whitespace', () {
      expect(sanitizer.isPlainUrl('  https://example.com  '), true);
    });
  });

  group('sanitizeEmailHtml', () {
    test('should return empty string for empty input', () {
      expect(sanitizer.sanitizeEmailHtml(''), '');
    });

    test('should remove script tags', () {
      final result = sanitizer
          .sanitizeEmailHtml('<p>Hello</p><script>alert("xss")</script>');
      expect(result, isNot(contains('script')));
      expect(result, contains('Hello'));
    });

    test('should remove iframe tags', () {
      final result =
          sanitizer.sanitizeEmailHtml('<p>Hello</p><iframe src="evil.com"></iframe>');
      expect(result, isNot(contains('iframe')));
    });

    test('should remove self-closing script tags', () {
      final result = sanitizer.sanitizeEmailHtml('<script src="evil.js"/>');
      expect(result, isNot(contains('script')));
    });

    test('should remove event handler attributes', () {
      final result =
          sanitizer.sanitizeEmailHtml('<img src="a.png" onerror="alert(1)">');
      expect(result, isNot(contains('onerror')));
    });

    test('should neutralize javascript: URIs', () {
      final result =
          sanitizer.sanitizeEmailHtml('<a href="javascript:alert(1)">click</a>');
      expect(result, isNot(contains('javascript:')));
    });

    test('should remove tracking pixels (1px images)', () {
      final result = sanitizer
          .sanitizeEmailHtml('<img src="track.gif" height="1" width="1">');
      expect(result, isNot(contains('track.gif')));
    });

    test('should remove empty tables', () {
      final result =
          sanitizer.sanitizeEmailHtml('<table>   </table><p>keep</p>');
      expect(result, isNot(contains('<table')));
      expect(result, contains('keep'));
    });

    test('should remove dangerous tags (object, embed, applet, form, base)',
        () {
      final result = sanitizer.sanitizeEmailHtml(
          '<object data="x"></object><embed src="y"><applet></applet><form action="z"></form>');
      expect(result, isNot(contains('<object')));
      expect(result, isNot(contains('<embed')));
      expect(result, isNot(contains('<applet')));
      expect(result, isNot(contains('<form')));
    });

    test('should remove structural HTML tags', () {
      final result = sanitizer
          .sanitizeEmailHtml('<html><head></head><body>Content</body></html>');
      expect(result, isNot(contains('<html')));
      expect(result, isNot(contains('<body')));
      expect(result, contains('Content'));
    });

    test('should remove float CSS', () {
      final result = sanitizer.sanitizeEmailHtml(
          '<div style="float: left;">content</div>');
      expect(result, isNot(contains('float')));
    });

    test('should preserve safe HTML', () {
      const html =
          '<p>Hello <strong>World</strong></p><a href="https://safe.com">link</a>';
      final result = sanitizer.sanitizeEmailHtml(html);
      expect(result, contains('<strong>World</strong>'));
      expect(result, contains('https://safe.com'));
    });
  });

  group('buildEmailHtml', () {
    test('should wrap content in complete HTML document', () {
      final result = sanitizer.buildEmailHtml('<p>Hello</p>');
      expect(result, contains('<!DOCTYPE html>'));
      expect(result, contains('<meta name="viewport"'));
      expect(result, contains('Hello'));
    });

    test('should include responsive CSS', () {
      final result = sanitizer.buildEmailHtml('<p>test</p>');
      expect(result, contains('max-width:100%'));
      expect(result, contains('box-sizing: border-box'));
    });

    test('should include JS width normalizer', () {
      final result = sanitizer.buildEmailHtml('<table></table>');
      expect(result, contains('normalizeWidths'));
    });
  });

  group('convertPlainUrlToHtml', () {
    test('should linkify plain URLs in non-HTML text', () {
      final result =
          sanitizer.convertPlainUrlToHtml('Visit https://example.com today');
      expect(result, contains('<a href="https://example.com"'));
      expect(result, contains('target="_blank"'));
      expect(result, contains('rel="noopener noreferrer"'));
    });

    test('should not double-linkify URLs already in HTML', () {
      const html = '<a href="https://example.com">link</a>';
      final result = sanitizer.convertPlainUrlToHtml(html);
      // Should not wrap the existing link in another <a>
      expect(result, isNot(contains('<a href="<a')));
    });

    test('should proxy non-HTTPS img sources', () {
      const html = '<img src="http://insecure.com/img.jpg">';
      final result = sanitizer.convertPlainUrlToHtml(html);
      expect(result, contains('image-proxy'));
      expect(result, isNot(contains('src="http://insecure.com')));
    });

    test('should not proxy HTTPS img sources', () {
      const html = '<img src="https://secure.com/img.jpg">';
      final result = sanitizer.convertPlainUrlToHtml(html);
      expect(result, contains('https://secure.com/img.jpg'));
      expect(result, isNot(contains('image-proxy')));
    });
  });
}
