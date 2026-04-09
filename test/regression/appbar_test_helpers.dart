/// Shared helpers for AppBar state regression tests.
///
/// Extends the existing test infrastructure with AppBar-specific utilities
/// for verifying source-level patterns in shell_layout.dart and screen files.
///
/// Reuses readSourceFile / sourceContains / sourceLinesContaining from
/// gl_106_test_helpers.dart — import both in your test file.
library;

import 'gl_106_test_helpers.dart';

/// Extracts the body of a named method from [source].
/// Returns everything between the first `{` after the method definition and
/// its matching `}`, or null if not found.
///
/// Matches method DEFINITIONS (preceded by a return type on the same line),
/// not method CALLS (preceded by `.` or just invoked inline).
String? extractMethodBody(String source, String methodName) {
  // Find the line that defines this method — it will have a return type
  // or keyword before the method name (void, Widget, List, static, etc.)
  // and will NOT be just a call like `_pushAppBarConfig();`
  final defPattern = RegExp(
    r'^\s*(?:@\w+\s+)*'               // optional annotations
    r'(?:static\s+)?'                  // optional static
    r'(?:[\w<>,?]+\s+)'               // return type (required for definition)
    '${RegExp.escape(methodName)}'
    r'\s*\(',
    multiLine: true,
  );

  final match = defPattern.firstMatch(source);
  if (match == null) return null;

  // Walk past the parameter list
  var parenDepth = 0;
  var i = source.indexOf('(', match.start + match.group(0)!.lastIndexOf(methodName));
  for (; i < source.length; i++) {
    if (source[i] == '(') parenDepth++;
    if (source[i] == ')') parenDepth--;
    if (parenDepth == 0) break;
  }

  // Find opening brace (the method body)
  var braceStart = source.indexOf('{', i);
  if (braceStart == -1) return null;

  // Ensure the brace is on the same or next line (not some random brace later)
  final gapText = source.substring(i + 1, braceStart).trim();
  // Between `)` and `{` there can only be `async`, whitespace, or nothing
  if (gapText.isNotEmpty && gapText != 'async') return null;

  // Walk braces to find the matching close
  var depth = 0;
  for (var j = braceStart; j < source.length; j++) {
    if (source[j] == '{') depth++;
    if (source[j] == '}') depth--;
    if (depth == 0) {
      return source.substring(braceStart + 1, j);
    }
  }
  return null;
}

/// Returns all `AppBarConfig(...)` constructor call substrings within [source].
/// Each entry is the text from `AppBarConfig(` through its closing `)`.
List<String> extractAppBarConfigCalls(String source) {
  final results = <String>[];
  final pattern = 'AppBarConfig(';
  var searchFrom = 0;

  while (true) {
    final start = source.indexOf(pattern, searchFrom);
    if (start == -1) break;

    // Find matching closing paren
    var depth = 0;
    var parenStart = start + pattern.length - 1; // index of '('
    for (var i = parenStart; i < source.length; i++) {
      if (source[i] == '(') depth++;
      if (source[i] == ')') depth--;
      if (depth == 0) {
        results.add(source.substring(start, i + 1));
        searchFrom = i + 1;
        break;
      }
    }
    if (depth != 0) break; // unbalanced — stop
  }
  return results;
}

/// Returns all `setAppBarConfig(...)` call substrings within [source].
List<String> extractSetAppBarConfigCalls(String source) {
  return sourceLinesContaining(source, 'setAppBarConfig(');
}

/// Checks that a method body does NOT use InkWell to wrap SVG icon actions.
/// Returns a list of offending lines (empty = pass).
///
/// Looks for the pattern: `InkWell(` ... `SvgPicture.asset(` within the
/// method body. IconButton is the correct wrapper for proper touch targets.
List<String> findInkWellSvgActions(String source, String methodName) {
  final body = extractMethodBody(source, methodName);
  if (body == null) return [];

  final lines = body.split('\n');
  final offending = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('InkWell(') || line.contains('child: InkWell(')) {
      // Check if InkWell contains an SVG icon within the next few lines
      final lookahead = lines.skip(i).take(8).join('\n');
      if (lookahead.contains('SvgPicture.asset(')) {
        offending.add('Line ~${i + 1} in $methodName: $line');
      }
    }
  }
  return offending;
}

/// Verifies that a method body contains all [requiredFields] in at least one
/// AppBarConfig constructor call. Returns missing fields.
List<String> verifyAppBarConfigFields(
  String source,
  String methodName,
  List<String> requiredFields,
) {
  final body = extractMethodBody(source, methodName);
  if (body == null) return requiredFields;

  final configs = extractAppBarConfigCalls(body);
  if (configs.isEmpty) return requiredFields;

  // Check if any config call contains all required fields
  for (final config in configs) {
    final missing = requiredFields.where((f) => !config.contains(f)).toList();
    if (missing.isEmpty) return []; // Found a config with all fields
  }

  // Return fields missing from the first (most likely normal-mode) config
  return requiredFields
      .where((f) => !configs.first.contains(f))
      .toList();
}
