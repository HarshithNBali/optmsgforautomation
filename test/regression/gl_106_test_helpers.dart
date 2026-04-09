/// Shared helpers for GL 1.0.6 regression tests.
///
/// Extends the existing test infrastructure (test/mocks/, test/helpers/) with
/// regression-specific utilities for verifying source-level patterns and
/// provider behavior related to the 31 QA bugs.
library;

import 'dart:io';

/// Reads a Dart source file and returns its contents as a string.
/// Used by regression tests that verify code patterns (e.g. "Scaffold must
/// have backgroundColor", "initState must not add controller listener").
String readSourceFile(String relativePath) {
  final file = File(relativePath);
  if (!file.existsSync()) {
    throw TestSourceFileNotFound(relativePath);
  }
  return file.readAsStringSync();
}

/// Returns true if [source] contains [pattern] (plain substring match).
bool sourceContains(String source, String pattern) {
  return source.contains(pattern);
}

/// Returns true if [source] contains a match for [regex].
bool sourceMatchesRegex(String source, RegExp regex) {
  return regex.hasMatch(source);
}

/// Returns all lines in [source] that contain [pattern].
List<String> sourceLinesContaining(String source, String pattern) {
  return source.split('\n').where((line) => line.contains(pattern)).toList();
}

/// Returns the 1-based line number of the first occurrence of [pattern],
/// or -1 if not found.
int sourceLineNumber(String source, String pattern) {
  final lines = source.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains(pattern)) return i + 1;
  }
  return -1;
}

class TestSourceFileNotFound implements Exception {
  final String path;
  TestSourceFileNotFound(this.path);
  @override
  String toString() => 'TestSourceFileNotFound: $path does not exist';
}
