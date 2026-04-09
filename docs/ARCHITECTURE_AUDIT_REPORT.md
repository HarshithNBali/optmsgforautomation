# OptMsg Flutter App — Principal Architecture Audit Report

**Date:** 2026-03-17
**Branch:** `optmsgApp-v1.0.6`
**Auditor:** Claude Code (AI Architecture Audit)
**Flutter SDK constraint:** `>=3.41.4 <4.0.0`

---

## Executive Summary

The codebase shows a high degree of deliberate engineering maturity: the session-management layer, GoRouter redirect guard, Riverpod notifier lifecycle patterns, and real-time socket architecture are all notably well-thought-out for an app at this stage. The most serious systemic risk is **unbounded in-memory state** — all email and contact lists are loaded entirely into memory with no eviction or virtual-window strategy, which will cause crashes or severe jank at realistic production email volumes. The second systemic risk is **pervasive `ApiService()` direct instantiation** (92 call-sites across 32 files) which makes the HTTP layer untestable and scattered. All other findings are isolated and fixable.

---

## Category 1 — Architecture & Extensibility

### CRITICAL

#### A-01 · InboxNotifier is a god object
**File:** `lib/screens/email/inbox_riverpod/inbox_notifier.dart`
**Size:** ~1,400 lines in a single class
**Impact:** Adding Calendar/Dashboard/AI Chat features will require modifying this file. The notifier owns socket subscription, contact sync, tag management, UI overlay state, pagination, undo buffers, badge updates, and email CRUD — 9+ distinct responsibilities. Any new feature that touches email (e.g., an AI summarise button) must reach into this class.
**Fix:** Extract into focused sub-notifiers: `InboxSocketNotifier`, `InboxSelectionNotifier`, `InboxPaginationNotifier`. Coordinate via `ref.read()` calls or a thin `InboxCoordinator`. Each stays under 300 lines.

#### A-02 · `ApiService` is directly instantiated at 92 call-sites across 32 files
**Files:** 32 files — see grep output (`ApiService()` count)
**Impact:** Zero testability; cannot mock the HTTP layer; refactoring the API layer requires 32 simultaneous touch-points; `post()` silently reaches into the global `providerContainer` for loading indicator state, creating invisible coupling.
**Fix:** Inject `ApiService` via Riverpod: `final apiServiceProvider = Provider((ref) => ApiService())`. All call-sites use `ref.read(apiServiceProvider)`. The `providerContainer` reach-in from inside `ApiService.post()` at line 272 of `api_service.dart` should be replaced by a proper Riverpod provider.

#### A-03 · GoRouter route file is a 865-line monolith that must be edited for every new feature
**File:** `lib/router/app_router.dart`
**Impact:** Every new top-level destination (Calendar, Dashboard, AI Chat) requires editing the single route file. Two developers working on different features will produce merge conflicts on every PR.
**Fix:** Adopt a `RouteRegistry` pattern: each feature folder exports a `List<RouteBase> routes` constant, collected via a barrel in `app_router.dart`. The main file only assembles them. GoRouter 7+ supports nested `routes:` declarations that can live next to the feature.

---

### HIGH

#### A-04 · `AppCache` is global mutable state with no type safety
**File:** `lib/common/app_manger/app_cache.dart`
**Impact:** `AppCache` stores auth-critical redirect flags (`isCheckout`, `signupInProgress`, `subscriptionPage`) as `String?` with no compile-time contracts. Callers compare raw strings (`== 'true'`). A typo anywhere silently breaks the entire checkout/signup redirect flow. Adding multi-account support is impossible without a complete rewrite.
**Fix:** Replace raw string flags with a typed `RedirectState` Freezed class stored in a `redirectStateProvider`. Eliminates string comparisons and enables proper testing.

#### A-05 · Two parallel HTTP client stacks (`ApiService` + `BaseAPIService`) diverge silently
**Files:** `lib/services/api_service.dart`, `lib/repositories/base/base_api_service.dart`
**Impact:** Both classes duplicate TLS config, header assembly, Firebase Performance tracing, session-refresh logic, and 401 retry. Any change (e.g., adding a new security header) must be made in two places. Currently `BaseAPIService.make()` calls `CommonService().getAppVersion()` on every request (uncached), while `ApiService` caches `_cachedAppVersion` — a silent performance discrepancy.
**Fix:** Merge into a single `CoreHttpClient` used by both. `ApiService` becomes a thin wrapper for legacy callers.

#### A-06 · `CommonService` is a utility god object (966 lines, 30+ unrelated methods)
**File:** `lib/services/common_service.dart`
**Impact:** Date formatting, toast display, platform detection, file-size formatting, badge updates, opt-in modals, update dialogs, connectivity banners, and download logic all live in one class. Any feature that needs one utility pulls in all of them.
**Fix:** Extract into domain-specific utilities: `DateFormatService`, `ToastService`, `PlatformService`, `BadgeService`. `CommonService` can delegate for backward compat during migration.

#### A-07 · Contacts fetches all pages (limit: 1,000) in a tight loop with no cap
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart`, lines 100–127
**Impact:** A user with 10,000 contacts triggers 10 sequential API calls on login, loads 10,000 objects into memory, then copies the list on every sort/filter/search operation. On low-end Android devices this will OOM.
**Fix:** Server-side search with debounce (already in place for inbox). Local cache first 500 contacts; virtualize the scroll view. See also S-01 (scalability).

#### A-08 · `SocketService` stores streams in a `Map<String, StreamController>` that is never bounded
**File:** `lib/services/socket_service.dart`, lines 23, 200–202
**Impact:** Every unique event string passed to `onEvent()` creates a permanent `StreamController.broadcast()`. If callers ever pass dynamic event names (e.g., per-email-id events), the map grows unboundedly. Currently safe because event names are static, but one future refactor could introduce a leak.
**Fix:** Seal the allowed event set with a Dart enum or `const Set`. Add an assertion in `onEvent()`.

#### A-09 · No feature flag / remote config system
**File:** `lib/constant/app_config.dart`
**Impact:** The `env` constant is compile-time only (`--dart-define=ENV=`). There is no mechanism to toggle features, roll out to a percentage of users, or A/B test without a full app deploy. Adding AI Chat to 10% of users would require a backend API, a client-side flag check, and infrastructure that doesn't exist yet.
**Fix:** Integrate Firebase Remote Config (already have firebase_core). Add a `FeatureFlagService` that reads remote values with local fallbacks.

---

### MEDIUM

#### A-10 · `HtmlSanitizerService` is instantiated as a new object on every `build()` call
**Files:** `lib/widgets/email_list.dart` line 272, `lib/widgets/sent_email_list.dart` line 424, `lib/widgets/draft_email_list.dart`
**Impact:** The service has no mutable state but is re-constructed on every widget rebuild. Flutter's `ListView` rebuilds frequently. While Dart's GC handles this, it is unnecessary allocation churn.
**Fix:** Make it a singleton or a `const` factory, or inject a shared instance from a Riverpod `Provider`.

#### A-11 · `NavigationService.navigatorKey` is used as a fallback navigation mechanism in 8+ non-widget classes
**Files:** `lib/services/common_service.dart` (multiple), `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 468, 532
**Impact:** Business logic (notifiers, services) is directly controlling navigation, bypassing GoRouter. This breaks deep-link handling, back-button behavior, and web URL synchronization.
**Fix:** Notifiers should emit navigation events (via state fields or callbacks) that widgets consume. For the contact notifier specifically, use `GoRouter.of(rootNavigatorKey.currentContext!)` only as a last resort and only for simple `push`/`pop`.

#### A-12 · `SharedPreferences` is used alongside `SecureStorageService` with no unification
**Files:** 19 files import `shared_preferences`
**Impact:** Two storage systems for different data with no documented contract. `SharedPreferences` data is unencrypted on Android (world-readable before Android 7). Auth-adjacent flags like `triggerUpgradePopupOnInbox` in `inbox_responsive.dart` line 117 are stored in plain SharedPreferences.
**Fix:** Route all persistent storage through `SecureStorageService`. Non-sensitive UI preferences (e.g., upgrade popup triggers) can use an in-memory provider with `keepAlive: true` instead of storage.

---

## Category 2 — Performance

### HIGH

#### P-01 · The entire inbox list is held in memory — no pagination window / virtualization
**File:** `lib/widgets/custom_dismissible.dart`, line 457 (`FlatList` with full `data: widget._items`)
**Impact:** The `FlatList` from the `flat_list` package receives the complete `state.items` list. With pagination enabled (50 items/page), items accumulate: page 2 appends to page 1, page 3 to that, etc. (inbox_notifier.dart lines 839–842). At 10,000 emails (~200 pages), the full list is in memory and passed to `FlatList` on every state change. This is the primary scalability risk.
**Fix:** Use `ListView.builder` with `itemExtent` set to the known item height. Only keep the current page window plus a small buffer. Reset to page 1 on filter/search change (already done) but also discard earlier pages when the user has scrolled past them.

#### P-02 · `ref.watch(inboxProvider)` watches the entire 1,400-line state object in 4 layout files
**Files:** `lib/screens/email/inbox_riverpod/layouts/inbox_mobile_layout.dart` line 90, `inbox_desktop_layout.dart`, `inbox_tablet_layout.dart`, `inbox_responsive.dart`
**Impact:** Any mutation to any field of `InboxState` (including `emailListPaneWidth`, `readingPaneHeight`, and other UI micro-state) triggers a full rebuild of the entire email list. A mouse move that changes `readingPaneHeight` rebuilds the full 50-item list.
**Fix:** Use `inboxProvider.select()` for each consumer. The list widget should only watch `(s) => s.items`. The app bar should only watch `(s) => s.isLoading`. Already done well in overlay widgets (9 files use `.select()`); apply consistently to layouts.

#### P-03 · `HtmlSanitizerService().htmlReplaceString()` runs regex chains on every `EmailList` build
**File:** `lib/widgets/email_list.dart` line 272, `lib/widgets/sent_email_list.dart` line 424
**Impact:** 8 regex replacements execute synchronously on the main thread on every list item rebuild. For a list of 50 items, this is 400 regex operations per frame during scroll. The stripped text is never cached.
**Fix:** Pre-process and cache `strippedText` in the `Emails` model or in the notifier when items are loaded. The result is immutable per email.

#### P-04 · `BaseAPIService.make()` calls `CommonService().getAppVersion()` uncached on every request
**File:** `lib/repositories/base/base_api_service.dart` line 89
**Impact:** `PackageInfo.fromPlatform()` is an async platform channel call. `ApiService` correctly caches the result in `_cachedAppVersion` (line 31), but `BaseAPIService.make()` calls it unconditionally every time. Every API call through the `BaseAPIService` path adds a platform channel round-trip.
**Fix:** Cache in `BaseAPIService` the same way `ApiService` does, or share a `cachedAppVersionProvider`.

#### P-05 · Search debounce is 1,000 ms (1 second) — unusually high
**File:** `lib/screens/email/inbox_riverpod/inbox_notifier.dart` line 474
**Impact:** Users experience a visible 1-second lag before search results appear. Industry standard is 300–500 ms.
**Fix:** Reduce to `const Duration(milliseconds: 300)`.

#### P-06 · `TextEditingController` is re-created on every `build()` in mobile inbox search
**File:** `lib/screens/email/inbox_riverpod/layouts/inbox_mobile_layout.dart` line 112
`controller: TextEditingController(text: state.searchKey)`
**Impact:** A new controller is allocated on every state change, causing the cursor to jump to the end of the text field and losing focus state mid-typing.
**Fix:** Hoist the controller to `ConsumerStatefulWidget` state, update it in `didUpdateWidget` when `state.searchKey` changes externally.

---

### MEDIUM

#### P-07 · `FlatList` (from `flat_list: ^0.1.14`) has no `itemExtent` and no documented virtualization guarantees
**File:** `lib/widgets/custom_dismissible.dart` line 457, `lib/screens/tags/tag_email_list.dart` line 145, `lib/screens/notifications/notification_riverpod/notification_list_riverpod.dart` line 65
**Impact:** `flat_list` is a micro-package with 14 pub points, last published 2023. Its virtualization behavior is not documented or audited. For long lists, `ListView.builder` with known `itemExtent` is the Flutter-idiomatic approach and measurably faster.
**Fix:** Replace `FlatList` with `ListView.builder`. The `onEndReached` callback maps directly to a `ScrollController` listener.

#### P-08 · Contact list client-side sort runs `List.sort()` on every add/update/delete
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 242–280
**Impact:** For 1,000+ contacts, sorting on every mutation is O(n log n). Contacts updates can be frequent when importing from device.
**Fix:** Use a sorted insert (binary search + insert at index) rather than sorting the full list on every mutation. Or use a `SplayTreeMap` keyed by sort key.

---

## Category 3 — Stability

### CRITICAL

#### ST-01 · No global `FlutterError.onError` / `ErrorWidget.builder` outside Crashlytics
**File:** `lib/main.dart`
**Impact:** `FirebaseCrashlytics.instance.recordFlutterFatalError` is registered as `FlutterError.onError` only when `firebaseReady && !kIsWeb`. On web and during Firebase initialization failures, unhandled Flutter framework errors produce a blank red screen with no recovery path. There is no `ErrorWidget.builder` fallback for individual widget subtrees.
**Fix:** Add `ErrorWidget.builder = (details) => _AppErrorWidget(details)` unconditionally in `main()`. Add a web-safe `FlutterError.onError` path (e.g., log to analytics or a custom endpoint).

#### ST-02 · Notification handler calls `await Future.delayed(const Duration(seconds: 2))` on the main thread
**File:** `lib/services/notification_service.dart` line 140
**Impact:** A 2-second blocking delay in `handleNotification()` before navigating. During this window the app is non-interactive. If the user taps again, a second navigation may fire.
**Fix:** Remove the delay. Navigation should be immediate or use `WidgetsBinding.instance.addPostFrameCallback` for a single-frame deferral.

---

### HIGH

#### ST-03 · Notification ID is hardcoded to `0` — all local notifications overwrite each other
**File:** `lib/services/notification_service.dart` line 192
`id: 0,`
**Impact:** If two emails arrive within the 3-second auto-dismiss window, only one notification is displayed. The first is silently replaced. Users will miss notifications.
**Fix:** Use `emailId` or a derived hash as the notification ID: `id: message.data['emailId'].hashCode`.

#### ST-04 · `_handleNotificationPayload` calls `jsonDecode` on raw user-controlled data with no try-catch
**File:** `lib/services/notification_service.dart` lines 154–168 → `_parsePath` line 234
**Impact:** If the push notification `PATH` field is malformed or null, `jsonDecode` throws a `FormatException` which is caught at the outer level and shows a generic toast. The root error is silently swallowed. A backend bug or a crafted push message can cause silent failures.
**Fix:** Already has outer try-catch, but `_parsePath` itself should validate that `rawPath` is non-empty and contains the expected keys before accessing them.

#### ST-05 · `ContactListNotifier` has two `SecureStorageService` instances (`api` and `_secureStorage`)
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 44–46
```dart
final ApiService api = ApiService();
final SecureStorageService storage = SecureStorageService();
final SecureStorageService _secureStorage = SecureStorageService();
```
**Impact:** Two identical singleton references is confusing and a latent bug — if the class is ever modified to hold instance state, the duplication becomes a real problem.
**Fix:** Remove `storage`, use only `_secureStorage`. Both are singletons so there is no functional difference, but the code signals intent incorrectly.

#### ST-06 · `_asyncRedirect` in GoRouter uses `await Descope.passkey.isSupported()` — can throw
**File:** `lib/router/app_router.dart` lines 351–354
```dart
try {
  passkeySupported = await Descope.passkey.isSupported();
} catch (_) {}
```
**Impact:** This async call runs on every navigation event where the user is authenticated and on an auth route. If Descope SDK throws unexpectedly, the entire redirect is silently swallowed and returns `null`. The user is stuck at the current route with no feedback. The `catch (_)` discards all information.
**Fix:** Log the exception. Consider caching `passkeySupported` after the first successful check to avoid repeated async calls during navigation.

---

### MEDIUM

#### ST-07 · `CommonService.animatedToast()` uses `static OverlayEntry? overlayEntry` — global mutable state
**File:** `lib/services/common_service.dart` lines 93–94
**Impact:** A global static `OverlayEntry` means only one toast can exist at a time. If two rapid errors fire (e.g., a 401 during a batch operation), the second toast silently fails if the overlay state for the first hasn't been cleaned up yet. The `_toastDismissTimer` cancellation on line 192 partially mitigates this.
**Fix:** Use a queue-based approach. The existing `toastification` dependency (in `pubspec.yaml`) already provides this — it is listed as a dependency but `CommonService` uses a custom overlay implementation instead. Either use `toastification` consistently or remove it.

#### ST-08 · `AppLifecycleState.resumed` triggers `socket.reconnectIfNeeded()` but does NOT refresh the inbox
**File:** `lib/main.dart` (lifecycle handler)
**Impact:** When the app is resumed after backgrounding (e.g., 30+ minutes), the socket reconnects but the inbox is not refreshed. New emails that arrived while backgrounded are only shown when a socket `newMessage` event fires. If the socket's `reconnectionAttempts: 10` was exhausted while backgrounded, `reconnectIfNeeded()` reconnects the socket but no `newMessage` event fires for missed emails — they only appear on the next manual refresh.
**Fix:** On `AppLifecycleState.resumed`, call `inboxProvider.notifier.reloadList()` in addition to socket reconnect.

---

## Category 4 — Scalability

### CRITICAL

#### SC-01 · All emails accumulate in a single `List<Emails>` — no upper bound, no eviction
**File:** `lib/screens/email/inbox_riverpod/inbox_notifier.dart` lines 839–842
```dart
final List<Emails> newItems =
    s.currentPage > 1 && s.currentPage != s.previousPage
    ? [...s.items, ...inboxList.data!.emails]
    : inboxList.data!.emails;
```
**Impact:** Each page appends to the previous. At 50 items/page, 200 pages = 10,000 emails all in memory simultaneously. Each `Emails` object contains an `Email` object with `messageText` (raw HTML), `sender`, `attachments`, and `emailRecipientTags`. The memory footprint per item is easily 5–20 KB, giving 50–200 MB at 10,000 emails. On iOS, this will trigger memory pressure warnings and eventual jank or crash.
**Fix:** Implement a sliding window: keep only the visible window ± 2 pages. Discard items outside this range and re-fetch on scroll-back. Use a `Map<int, Emails>` keyed by email ID for O(1) lookup.

#### SC-02 · Contacts fetches all pages with `limit: 1,000` — 10,000 contacts = 10 sequential API calls on every login
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 107–126
**Impact:** `getContacts()` runs a `while (hasNext)` loop fetching 1,000 contacts per page. 10,000 contacts = 10 API calls before the contacts screen becomes interactive. The `merged = [...state.allContacts, ...allFetched]` spread creates a new list on every iteration — 10,000 contacts creates 9 intermediate list copies during loading.
**Fix:** Implement server-side search. Only load the first page (100–200 contacts) on init. Use the server's search endpoint when the user types. Local sort only applies to the visible page.

#### SC-03 · No attachment streaming — attachments require the client to construct full S3 URLs in-memory
**File:** `lib/services/common_service.dart` line 566 (`downloadFile`)
**Impact:** Attachment downloads launch the full URL via `launchUrl`. Large attachments (video, ZIP) are fully downloaded to the platform browser before any progress feedback. No streaming, no progress indicator, no cancellation.
**Fix:** For native platforms, use `dio` (already a dependency) with `downloadFile()` and a progress callback. Show a `LinearProgressIndicator` in the UI.

---

### HIGH

#### SC-04 · Push notification architecture routes all notifications through a single Firebase channel
**File:** `lib/services/notification_service.dart`
**Impact:** There is one `AndroidNotificationChannel` (`high_importance_channel`) for all notification types. As volume increases (community recommendations, system alerts, email notifications), there is no way to differentiate notification priority, sound, or grouping without a new app release.
**Fix:** Define separate channels per type (`email_channel`, `system_channel`, `community_channel`) now, before the user base scales.

#### SC-05 · In-memory `AppCache` has no eviction for `_queryParms` beyond manual `setQueryParms({})`
**File:** `lib/common/app_manger/app_cache.dart` lines 34, 70–72
**Impact:** `_queryParms` is a `Map<String, dynamic>?` that is only cleared in `clear()` (logout) or explicitly. If the Stripe payment flow is interrupted mid-session, stale params may persist across navigation events and trigger spurious redirects to `/processing-payment`.
**Fix:** Add a TTL to `_queryParms` (store timestamp alongside, expire after 5 minutes).

---

## Category 5 — Code Quality

### HIGH

#### CQ-01 · `HtmlSanitizerService.buildEmailHtml()` injects a `<script>` tag into the email content it sanitizes
**File:** `lib/services/html_sanitizer_service.dart` lines 162–184
**Impact:** `sanitizeEmailHtml()` strips `<script>` tags as a security measure, then `buildEmailHtml()` wraps the output in a `<script>` block for table/image normalization. While this is the app's own script (not user-controlled), it creates a philosophical inconsistency and complicates future security reviews. The regex sanitizer is also not a fully hardened HTML sanitizer — a sufficiently malformed email could still bypass the regex-based `_eventHandlerRegex` via encoding tricks.
**Fix:** Replace the embedded `<script>` with equivalent CSS rules (tables are already addressed by CSS). For a production email client, consider using a purpose-built HTML sanitizer package or sanitizing on the server before delivery.

#### CQ-02 · Commented-out dead code blocks in critical paths
**Files:**
- `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 375–376, 446–449, 570–573 (dead API calls)
- `lib/services/common_service.dart` lines 583–594 (dead logout code)
- `lib/screens/email/inbox_riverpod/inbox_notifier.dart` lines 920–927, 982–989, 1071–1078 (old `ApiService` calls commented out next to new calls)
**Impact:** Commented-out code creates confusion about which path is authoritative. In a security audit, the dead logout code in `CommonService` (which bypasses `setAuthenticated`) is a liability — a developer might uncomment it.
**Fix:** Delete all commented-out code blocks. Source control (`git log`) preserves history.

#### CQ-03 · `ContactListNotifier.handleEditContact()` navigates via `GoRouter.of(navigatorContext).push()` inside a Notifier
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart` lines 476–485
**Impact:** The notifier awaits a navigation push and then mutates state based on the result. This is an anti-pattern in Riverpod: notifiers should not hold references to `BuildContext` or drive navigation directly. It makes the notifier untestable and couples business logic to the navigation stack.
**Fix:** Expose a `pendingEditContact` state field. The widget layer observes it, triggers navigation, and calls back into the notifier with the result via a method (same pattern as `pendingOptInEmail` in `InboxNotifier`).

#### CQ-04 · Inconsistent `const` usage on `StatelessWidget` constructors throughout
**Files:** `lib/widgets/email_list.dart`, `lib/widgets/sent_email_list.dart`, and layout files
**Impact:** `EmailList` and `SentEmailList` are `StatefulWidget`s (necessary for hover state) and cannot be `const`. However, inner widgets like `_buildCheckbox()`, `_buildReadIndicator()`, and `_buildTags()` return newly constructed widgets on every call that could use `const` constructors. The `_RouteErrorScaffold` in `app_router.dart` line 388 does use `const` correctly — this inconsistency needs systematic application.
**Impact:** Each unnecessary non-const widget allocation adds to GC pressure during fast scroll.
**Fix:** Run `flutter analyze` with `prefer_const_constructors` lint enabled. Apply `const` where applicable.

#### CQ-05 · `SentEmailList` is a near-duplicate of `EmailList` (588 vs 339 lines) with divergent logic
**Files:** `lib/widgets/sent_email_list.dart`, `lib/widgets/email_list.dart`
**Impact:** Both widgets implement the same hover logic, checkbox display, swipe actions, tag rendering, and HTML preview. Changes to one must be manually mirrored to the other. The tag-rendering code in `SentEmailList` lines 443–494 is notably more complex (handles both `Map` and model object cases) than `EmailList` — this inconsistency causes subtly different behavior for sent vs inbox emails.
**Fix:** Extract a `BaseEmailListItem` widget parameterized by an `EmailListAdapter` interface, then create thin `InboxEmailListItem` and `SentEmailListItem` subclasses.

#### CQ-06 · `ContactListNotifier` duplicates search filter logic in three methods
**File:** `lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart`
- `getContacts()` lines 133–144
- `deleteContactRecord()` lines 287–299
- `searchFilterContact()` lines 355–367
All three implement the same `firstName + lastName + company` string matching. If the search logic changes (e.g., to support accent-insensitive matching), all three must be updated.
**Fix:** Extract `_applyFilter(List<Contacts> contacts, String query) → List<Contacts>` private helper and call it from all three.

#### CQ-07 · No widget tests for any critical UI component
**Files:** `test/` directory (empty or absent)
**Impact:** Zero automated test coverage. The auth flow, inbox loading states, skeleton loader visibility, and form validation are completely untested. Regressions in the login → OTP → inbox path can only be caught by manual testing.
**Fix:** Add golden tests for `EmailListItemSkeleton`, widget tests for `OtpFormWidget`, and integration tests for the login flow using `flutter_test` + `mockito` (both already in `dev_dependencies`).

---

### MEDIUM

#### CQ-08 · `env` defaults to `'stage'` in production builds that omit `--dart-define=ENV=`
**File:** `lib/constant/app_config.dart` line 7
```dart
const String env = String.fromEnvironment('ENV', defaultValue: 'stage');
```
**Impact:** A CI step that forgets to pass `--dart-define=ENV=prod` silently ships a production binary pointing at `staging-api.optmsg.com`. This is a silent, hard-to-detect misconfiguration.
**Fix:** Change `defaultValue` to `'prod'`, or better, remove the default and add a compile-time assertion: `assert(env == 'prod' || env == 'stage' || env == 'dev', 'ENV must be set')`. Add the flag to all CI pipeline build steps explicitly.

#### CQ-09 · `_RedirectState` is a module-level global mutable variable (not a class instance)
**File:** `lib/router/app_router.dart` line 63
`_RedirectState _rs = _RedirectState();`
**Impact:** Module-level mutable state survives between test runs unless explicitly reset. `_rs.reset()` is called in `createRouter()`, which mitigates this during hot restart, but it makes the redirect logic inherently non-isolable for unit testing.
**Fix:** Pass `_rs` as a parameter to `_asyncRedirect()` or scope it inside `createRouter()` as a closure-captured local variable.

#### CQ-10 · `descope` SDK pinned to `^0.9.18` — pre-1.0, no stability guarantees
**File:** `pubspec.yaml` line 43
**Impact:** Pre-1.0 Dart packages have no semantic versioning stability guarantee. A `0.9.19` patch release could introduce breaking changes. The entire auth flow depends on this package.
**Fix:** Monitor for a 1.0 release. Until then, pin to an exact version (`descope: 0.9.18`) to prevent accidental breaking updates via `flutter pub upgrade`.

#### CQ-11 · `flat_list: ^0.1.14` is an unmaintained package (14 pub points, 2023 last update)
**File:** `pubspec.yaml` line 51
**Impact:** No maintenance, no null-safety guarantee for future Dart versions, no documented virtualization behavior. Used in the email list, tags list, and notification list.
**Fix:** Replace with Flutter's built-in `ListView.builder`. See P-07.

#### CQ-12 · `analysis_options.yaml` has `deprecated_member_use: ignore` commented out
**File:** `pubspec.yaml` lines 107–109 (analyzer section)
**Impact:** The comment `#deprecated_member_use: ignore` suggests the team was considering suppressing deprecation warnings globally. Two routes in `app_routes.dart` are already `@Deprecated` and actively used with `// ignore:` suppression. Accumulating technical debt in route constants.
**Fix:** Schedule removal of `emailDetail` and the legacy `staticPage` route. Remove the deprecated route definitions and their callers after confirming no deep-links in the wild use them.

---

## Category 6 — Dependencies Audit

| Package | Version | Risk |
|---|---|---|
| `descope` | `^0.9.18` | PRE-1.0 — pin to exact version |
| `flat_list` | `^0.1.14` | Unmaintained — replace |
| `toastification` | `^3.0.3` | Unused (custom toast used instead — dead dependency) |
| `responsive_framework` | `^1.5.1` | Imported but `AppBreakpoints` is the actual breakpoint system |
| `media_store_plus` | `^0.1.3` | Only used for `MediaStore.appFolder` init in notification service — low risk |
| `youtube_player_iframe` | `^5.1.7` | Only in help/FAQ — fine but adds 3.2 MB to Android APK |
| `mockito` | `^5.6.3` | In dev_dependencies but no tests exist — wasted dep |

---

## Summary Table

| ID | Severity | Category | One-line description |
|---|---|---|---|
| A-01 | CRITICAL | Architecture | InboxNotifier is a god object (~1,400 lines) |
| A-02 | CRITICAL | Architecture | ApiService directly instantiated at 92 call-sites |
| A-03 | CRITICAL | Architecture | GoRouter is a 865-line monolith |
| A-04 | HIGH | Architecture | AppCache stores auth flags as raw strings |
| A-05 | HIGH | Architecture | Two parallel HTTP stacks diverge silently |
| A-06 | HIGH | Architecture | CommonService is a 966-line utility god object |
| A-07 | HIGH | Architecture | Contacts fetches all 10,000 contacts in a loop |
| A-08 | HIGH | Architecture | SocketService stream map is unbounded |
| A-09 | HIGH | Architecture | No feature flag / remote config system |
| A-10 | MEDIUM | Architecture | HtmlSanitizerService re-instantiated on every build |
| A-11 | MEDIUM | Architecture | Notifiers drive navigation via NavigationService |
| A-12 | MEDIUM | Architecture | SharedPreferences + SecureStorage used without contract |
| P-01 | HIGH | Performance | Inbox list is unbounded — all emails in memory |
| P-02 | HIGH | Performance | `ref.watch(inboxProvider)` rebuilds full list on any state change |
| P-03 | HIGH | Performance | HTML sanitizer runs 8 regex chains on every list item build |
| P-04 | HIGH | Performance | BaseAPIService calls getAppVersion() uncached on every request |
| P-05 | MEDIUM | Performance | Search debounce is 1,000 ms (too slow) |
| P-06 | MEDIUM | Performance | TextEditingController re-created on every build |
| P-07 | MEDIUM | Performance | FlatList is an unmaintained package with unknown virtualization |
| P-08 | MEDIUM | Performance | Contact list runs full O(n log n) sort on every mutation |
| ST-01 | CRITICAL | Stability | No global ErrorWidget fallback on web |
| ST-02 | CRITICAL | Stability | 2-second blocking delay in notification handler |
| ST-03 | HIGH | Stability | All local notifications use ID 0 — overwrite each other |
| ST-04 | HIGH | Stability | Notification path parsing silently swallows format errors |
| ST-05 | HIGH | Stability | ContactListNotifier has duplicate storage instances |
| ST-06 | HIGH | Stability | Passkey check in redirect can throw and be silently swallowed |
| ST-07 | MEDIUM | Stability | Toast system uses static OverlayEntry; only one toast at a time |
| ST-08 | MEDIUM | Stability | App resume does not refresh inbox — misses emails on reconnect |
| SC-01 | CRITICAL | Scalability | All emails accumulate in memory — no eviction |
| SC-02 | CRITICAL | Scalability | Contacts fetches all pages on every login |
| SC-03 | HIGH | Scalability | No attachment streaming or progress feedback |
| SC-04 | HIGH | Scalability | Single notification channel for all types |
| SC-05 | HIGH | Scalability | AppCache query params have no TTL |
| CQ-01 | HIGH | Code Quality | buildEmailHtml injects script into sanitized content |
| CQ-02 | HIGH | Code Quality | Large commented-out dead code in critical paths |
| CQ-03 | HIGH | Code Quality | Notifier drives navigation via GoRouter push |
| CQ-04 | MEDIUM | Code Quality | Inconsistent const usage on inner widgets |
| CQ-05 | MEDIUM | Code Quality | SentEmailList duplicates EmailList (588 lines vs 339 lines) |
| CQ-06 | MEDIUM | Code Quality | Contact search filter logic duplicated in three methods |
| CQ-07 | MEDIUM | Code Quality | Zero widget/integration tests |
| CQ-08 | MEDIUM | Code Quality | env defaults to 'stage' — silent misconfiguration risk |
| CQ-09 | MEDIUM | Code Quality | _RedirectState is module-level mutable global |
| CQ-10 | MEDIUM | Code Quality | descope SDK is pre-1.0, not pinned to exact version |
| CQ-11 | MEDIUM | Code Quality | flat_list is unmaintained |
| CQ-12 | MEDIUM | Code Quality | Deprecated routes accumulating |

---

## Recommended Fix Priority Order

### Sprint 1 (Blockers before scale)
1. **SC-01** — Add inbox list sliding window / discard old pages
2. **SC-02** — Server-side contact search; stop fetching all pages
3. **P-01** — Switch `FlatList` to `ListView.builder` with `itemExtent`
4. **ST-01** — Add `ErrorWidget.builder` fallback on web
5. **ST-03** — Fix notification ID (use emailId hash)

### Sprint 2 (Architecture debt)
6. **A-01** — Begin InboxNotifier extraction (socket, selection as first sub-notifiers)
7. **A-02** — Add `apiServiceProvider`; migrate 5–10 highest-traffic call-sites
8. **P-02** — Add `.select()` to inbox layout widgets
9. **P-03** — Pre-process stripped HTML in notifier when items load
10. **P-04** — Cache appVersion in BaseAPIService

### Sprint 3 (Quality baseline)
11. **CQ-05** — Merge EmailList / SentEmailList
12. **CQ-07** — Add widget tests for skeleton loader, OTP form, inbox loading state
13. **A-05** — Merge the two HTTP stacks
14. **CQ-08** — Fix env defaultValue or add compile-time assertion
15. **P-05** — Reduce search debounce to 300 ms
