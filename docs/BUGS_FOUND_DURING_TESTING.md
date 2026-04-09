# Bugs Found During Testing

| Bug ID | File | Line | Severity | Description | Status | Fix Description | Test Case | Related |
|--------|------|------|----------|-------------|--------|-----------------|-----------|---------|
| BUG-001 | lib/screens/auth/auth_riverpod/auth_notifier.dart | 139 | Medium | `_initialize()` sets `state = AuthState.unauthenticated()` in the Descope `LateInitializationError` catch block without checking `_disposed` first. If the ProviderContainer is disposed between `build()` and the microtask executing, this throws "Cannot use Ref after disposal". | Pending Review | Add `if (_disposed) return;` before line 139 | auth_notifier_extended_test.dart (skipped) | — |
| BUG-002 | lib/common/utilites/secure_url_helper.dart | 10 | Low | `stripTokenFromUri()` passes `queryParameters: null` to `Uri.replace()` when all params are token-related. Dart's `Uri.replace(queryParameters: null)` preserves the original query string — it does NOT clear it. Should use `query: ''` instead to fully strip the query string. | Pending Review | Change `uri.replace(queryParameters: params.isEmpty ? null : params)` to `uri.replace(queryParameters: params.isEmpty ? null : params, query: params.isEmpty ? '' : null)` | secure_url_helper_test.dart (skipped) | — |

| BUG-003 | lib/model/base_response/request_error.dart | 61,67,71 | Low | `RequestError` constructor crashes when `data['message']` is a `List` — `_parseError()` expects `Map<String, dynamic>` items but receives `String` items. Also crashes when `data` itself is a `List` — indexing by string key fails. | Pending Review | Add type checks in the list-message and list-data branches | model_constructors_batch2_test.dart (edge cases removed to avoid asserting wrong behavior) | — |

## Details

### BUG-001: Missing `_disposed` guard in AuthNotifier._initialize()

**Location:** `lib/screens/auth/auth_riverpod/auth_notifier.dart:127-141`

**Reproduction:** Dispose a ProviderContainer immediately after reading `authProvider` (before the `Future.microtask(_initialize)` completes).

**Root cause:** The `_initialize()` method's first try/catch for `Descope.sessionManager.session` catches `LateInitializationError` and immediately sets state without checking the `_disposed` flag. All other async paths in `_initialize()` correctly check `if (_disposed) return;` after awaits, but this synchronous catch path does not.

**Suggested fix:**
```dart
} catch (e) {
  if (e is! Error || !e.toString().contains('LateInitializationError')) rethrow;
  printLog(_tag, 'Descope not initialized yet — treating as unauthenticated');
  if (_disposed) return;  // ← ADD THIS
  state = AuthState.unauthenticated();
  return;
}
```

**Risk:** Low — the fix is a single guard line. The crash only occurs when a provider is disposed during initialization, which is uncommon but possible during widget tree rebuilds or hot refresh.

---

### BUG-002: `stripTokenFromUri` does not clear query when only token params exist

**Location:** `lib/common/utilites/secure_url_helper.dart:10`

**Reproduction:** Call `stripTokenFromUri(Uri.parse('https://example.com/page?token=secret&tokentype=jwt'))` — the returned URI still contains the token query params.

**Root cause:** `Uri.replace(queryParameters: null)` in Dart does not clear the existing query string. When `null` is passed, Dart preserves the original value. The `query` named parameter must be used instead to explicitly clear it.

**Suggested fix:**
```dart
return uri.replace(
  queryParameters: params.isEmpty ? null : params,
  query: params.isEmpty ? '' : null,
);
```

**Risk:** Low — only affects the edge case where a URL has only token/tokentype params and no other query params. In practice, most URLs have additional params (e.g., email ID).

---

### BUG-003: `RequestError` constructor crashes on list-typed `message` and list-typed `data`

- **File:** `lib/model/base_response/request_error.dart`
- **Lines:** 61, 67, 71
- **Severity:** Low
- **Description:** Two defensive gaps in the `RequestError({data})` constructor:
  1. When `data['message']` is a `List<String>` (e.g. `['Error 1', 'Error 2']`), line 63 calls `_parseError(data)` which calls `List.from(data['errors']).map(...)` expecting `Map<String, dynamic>` items, but receives `String` items → crashes with `type 'String' is not a subtype of type 'Map<String, dynamic>'`.
  2. When `data` itself is a `List` (e.g. `['Some error']`), line 71 tries `_error = data[0]` using an int index on what is expected to be a Map → crashes with `type 'String' is not a subtype of type 'int' of 'index'`.
- **Expected:** Both cases should be handled gracefully, extracting a human-readable error message.
- **Actual:** Both cases throw unhandled type errors.
- **Discovered by:** TC-DISC-MODEL-BATCH2 (edge case tests removed to avoid asserting wrong behavior per testing agent policy)
- **Suggested fix:**
```dart
// Line 61: Add type check before calling _parseError
else if (data['message'] != null) {
  if (data['message'] is String) {
    _error = data['message'];
  } else if (data['message'] is List) {
    _error = (data['message'] as List).join(', ');  // ← FIX
  } else {
    _parseError(data);
  }
}

// Line 71: Add type check for list data
else {
  if (data is List && data.isNotEmpty) {
    _error = data.first.toString();  // ← FIX
  } else {
    _error = data.toString();
  }
}
```
- **Impact:** Only triggers when the backend returns non-standard error formats (list-typed message or bare list response). These are edge cases that likely never occur in production with the current API, but could surface if the backend error format changes.
- **Status:** Pending Review
