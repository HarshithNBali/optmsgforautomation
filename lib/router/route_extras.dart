/// Safely extracts the `extra` map from a GoRouter state.
/// Returns an empty map if extra is null or not a `Map<String, dynamic>`.
Map<String, dynamic> safeExtras(Object? extra) {
  if (extra is Map<String, dynamic>) return extra;
  return const {};
}

/// Safely reads a string value from extras with a fallback.
String extraString(Map<String, dynamic> extras, String key, [String fallback = '']) {
  final value = extras[key];
  return value is String ? value : fallback;
}

/// Safely reads a bool value from extras with a fallback.
bool extraBool(Map<String, dynamic> extras, String key, [bool fallback = false]) {
  final value = extras[key];
  return value is bool ? value : fallback;
}

/// Safely reads a typed value from extras, returning null if the type doesn't match.
T? extraTyped<T>(Map<String, dynamic> extras, String key) {
  final value = extras[key];
  return value is T ? value : null;
}
