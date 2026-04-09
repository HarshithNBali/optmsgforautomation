# Test Implementation Plan

**App Version:** 1.0.6+35
**Branch:** optmsgApp-v1.0.6
**Created:** 2026-03-24
**Documented Test Cases:** 1,395
**Implemented Before This Plan:** 2 files (1 real test)

---

## Phase 1: Test Infrastructure (COMPLETED)

### Dependencies Added
| Package | Version | Purpose |
|---------|---------|---------|
| mocktail | ^1.0.4 | Mock generation without codegen |
| fake_async | ^1.3.3 | Deterministic async testing |
| clock | ^1.1.2 | Controllable time for expiry tests |
| flutter_test | SDK | Core Flutter test framework |
| mockito | ^5.6.3 | Already present — retained for existing test |

### Infrastructure Files Created
| File | Purpose |
|------|---------|
| `test/helpers/test_helpers.dart` | Widget wrappers, ProviderContainer factory, pump helpers, screen size utilities |
| `test/helpers/riverpod_test_helpers.dart` | `RiverpodTestSetup` with pre-configured service mocks, `TestProviderObserver` |
| `test/helpers/barrel.dart` | Single-import barrel for all test infrastructure |
| `test/mocks/mock_services.dart` | Mocktail mocks for ApiService, SecureStorageService, BiometricService, AnalyticsService, SocketService + default stub helpers |
| `test/mocks/mock_repositories.dart` | Mocktail mocks for all 9 repository classes |
| `test/factories/test_data_factories.dart` | JSON factories for User, Login, InboxList, Email, Profile, Plan, Tag, error responses |
| `test/infrastructure_smoke_test.dart` | 9 smoke tests verifying infrastructure compiles and works |
| `scripts/run_tests.sh` | Test runner with --coverage, --unit, --widget, --file flags |

### Directory Structure
```
test/
├── helpers/
│   ├── barrel.dart
│   ├── riverpod_test_helpers.dart
│   └── test_helpers.dart
├── mocks/
│   ├── mock_services.dart
│   └── mock_repositories.dart
├── factories/
│   └── test_data_factories.dart
├── unit/
│   ├── models/
│   ├── services/
│   └── repositories/
├── widget/
├── integration/
├── infrastructure_smoke_test.dart
├── auth_notifier_test.dart (existing)
└── sample_test.dart (existing placeholder)
```

---

## Phase 2: Core Unit Tests (P0)

**Target:** ~120 tests | **Priority:** Critical
**Focus:** Pure logic with no platform dependencies

### 2A. Model Serialization (22 model files)
| Model | Tests | Key Assertions |
|-------|-------|----------------|
| LoginModel | fromJson, toJson, roundtrip, null defaults | Token, User fields populated |
| InboxListModel | fromJson, toJson, null data, empty emails | Null safety guards work |
| ViewEmailModel | fromJson, toJson, attachments, receivers | Nested model parsing |
| ProfileModel (MyProfile) | fromJson, toJson | All fields mapped |
| PlanListModel | fromJson, toJson, multiple plans | Dynamic charge field |
| RequestResponse<T> | data-only, error-only, both null | Generic wrapper |
| RequestError | String message, List errors, detail, match_format, field errors | All parse paths |
| FieldErrorModel | fromJson | Generated code |
| ContactListModel | fromJson, toJson | Contact fields |
| DraftListModel | fromJson, toJson | Draft fields |
| TagsListModel | fromJson, toJson | Tag list |
| SentListModel | fromJson, toJson | Sent email fields |
| NotificationListModel | fromJson, toJson | Notification fields |
| All remaining models | fromJson, toJson, edge cases | Null safety, defaults |

### 2B. AuthState (Freezed)
| Test | Assertion |
|------|-----------|
| AuthState.initial() | status=unauthenticated, isInitialized=false |
| AuthState.unauthenticated() | isInitialized=true |
| AuthState.authenticating() | isLoading=true |
| AuthState.authenticated(data) | isAuthenticated=true, userData set |
| AuthState.error(msg) | hasError=true, errorMessage set |
| Computed properties | isAwaitingOtp, isDescopeEnabled, etc. |
| copyWith | Freezed-generated copyWith works |

### 2C. isSubscriptionValid()
| Test | Input | Expected |
|------|-------|----------|
| Paid user | isFreeUser=false | true |
| Free user, future end date | isFreeUser=true, endDate=future | true |
| Free user, past end date | isFreeUser=true, endDate=past | false |
| Free user, null end date | isFreeUser=true, endDate=null | false |
| Seconds vs milliseconds | Raw timestamp conversion | Correct comparison |

### 2D. RequestError Parsing
| Test | Input | Expected |
|------|-------|----------|
| String message | `{message: "err"}` | error = "err" |
| List message | `{message: [{field,message}]}` | errors list populated |
| errors array | `{errors: [...]}` | FieldErrorModel list |
| detail field | `{detail: "msg"}` | error = "msg" |
| match_format | `{match_format: ["msg"]}` | error = "msg" |
| error field | `{error: "msg"}` | error = "msg" |
| singleMessage factory | String | error set |
| noUser / noToken | — | Specific messages |

---

## Phase 3: Notifier Unit Tests (P0)

**Target:** ~80 tests | **Priority:** Critical
**Focus:** State management logic with mocked services

### 3A. AuthNotifier
- build() → initial state
- _initialize() → unauthenticated when Descope not ready
- _initialize() → authenticated when valid session exists
- userVerify() → success → awaitingOtp
- userVerify() → network error → error state
- userLogin() → success → authenticated
- userLogin() → invalid subscription → error
- setAuthenticated(false) → unauthenticated
- OTP flow states
- _disposed guard after async gaps

### 3B. InboxNotifier
- build() → initial state with loading
- getAllEmails() → populates email list
- getAllEmails() → 401 returns empty message (no double toast)
- loadMore() → appends to list, nextPage flag
- markAsRead() → updates local state
- deleteEmail() → removes from list
- Error states and recovery

### 3C. SettingsNotifier
- build() → initial state
- performLogout() → setAuthenticated(false) FIRST, then cleanup
- clearSession() → does NOT call setAuthenticated(false)
- Profile update flows

### 3D. Other Notifiers
- DraftNotifier, ArchiveNotifier, TagsNotifier, ContactListNotifier
- ProfileNotifier, AccountNotifier, CheckoutNotifier
- GlobalVariableNotifier (addPath, clearPathList)

---

## Phase 4: Widget Tests (P1)

**Target:** ~60 tests | **Priority:** High
**Focus:** UI rendering and interaction

### Key Screens
- LoginScreen: renders form, validates input, triggers auth
- InboxScreen: renders email list, pull-to-refresh, empty state
- SettingsScreen: renders options, logout button
- EmailDetailScreen: renders email content, attachments
- OTP entry screen: pinput interaction, resend timer

### Shared Widgets
- CustomGradientButton, DelayedLoadingOverlay
- Responsive layout switching at breakpoints
- Toast/Snackbar display

---

## Phase 5: Integration Tests (P1-P2)

**Target:** ~30 tests | **Priority:** Medium
**Focus:** Multi-provider flows, navigation

- Full login flow: enter email → OTP → authenticated → inbox
- Session expiry: 401 → dialog → redirect to login
- Logout flow: tap logout → cleanup → login screen
- Email compose → send → appears in sent

---

## Phase 6: Documentation Updates

All documentation files in `docs/` updated with final results:
- TEST_CASE_DOCUMENTATION.md — status updates
- TEST_CASE_DOCUMENTATION.csv — implementation columns
- TEST_CASE_GAPS.csv — remaining gaps
- TEST_CASE_SUMMARY.csv — final counts
- TEST_CASE_VALIDATION_REPORT.csv — validation results
- TEST_IMPLEMENTATION_REPORT.md — comprehensive final report
- COVERAGE_EXCLUSIONS.md — excluded files with justifications
- BUGS_FOUND_DURING_TESTING.md — bugs discovered
- BUGS_REQUIRING_REVIEW.md — if applicable

---

## Execution Order

1. ~~Phase 1: Infrastructure~~ ✅
2. Phase 2A: Model serialization tests
3. Phase 2B-D: AuthState, isSubscriptionValid, RequestError tests
4. Phase 3A: AuthNotifier tests
5. Phase 3B: InboxNotifier tests
6. Phase 3C-D: Remaining notifier tests
7. Phase 4: Widget tests
8. Phase 5: Integration tests
9. Phase 6: Documentation updates

---

## Coverage Targets

| Category | Target | Rationale |
|----------|--------|-----------|
| Models (fromJson/toJson) | 90%+ | Pure logic, easy to test |
| Core services (ApiService, Storage) | 70%+ | Platform boundaries limit testability |
| Notifiers (state management) | 80%+ | Critical business logic |
| Widgets | 60%+ | Responsive layouts add complexity |
| Overall | 50%+ | Starting from ~1%, incremental |

## Constraints & Risks

- **No Descope test SDK**: Auth flows that call Descope directly need mocking at the notifier level, not integration level
- **Firebase not initialized in tests**: `firebaseReady = false` in test environment; AnalyticsService guards handle this
- **Platform channels**: BiometricService, SecureStorage, etc. require mocks — cannot integration-test on CI
- **No existing test culture**: First significant test suite — expect discovery of untestable patterns
