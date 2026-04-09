# Branch Changes Summary

> **Branch:** `optmsg_1.0.7_27feb`
> **Diffed against:** `optmsg_1.0.7_27feb` (uncommitted working-tree changes)
> **Prepared by:** Claude Code
> **Date:** 2026-03-09
> **Reviewer note:** This branch is a comprehensive upgrade of the OptMsg Flutter app covering GoRouter migration, Riverpod modernization, security hardening (Descope session management, JWT handling, biometric lock), responsive UI overhaul, and stability fixes. Net result: +10,211 / -41,648 lines across 316 files — a significant reduction in code size due to dead code removal and directory consolidation.

---

## 1. Navigation: GoRouter Migration

### What was replaced
- All imperative `Navigator.push()` / `Navigator.pop()` / `Navigator.pushReplacement()` patterns removed from the router layer
- Hardcoded route path strings (e.g. `inboxPath`, `contactPath`, `settingsPath`) in `StringConstant` replaced with `AppRoutes.*` constants
- Manual auth checks before navigation replaced with declarative redirect guards

### New GoRouter structure

**Route definitions (`app_router.dart`):**
- Root `/` renders an empty `Scaffold` — safety fallback during the `!isInitialized` window
- All protected routes live inside a single `ShellRoute` that renders `ShellLayout` (sidebar + bottom nav)
- Auth-flow routes (`/login`, `/signup`, `/enter-otp`, `/setup-profile`, `/add-passkey`) are top-level `GoRoute`s outside the shell
- Nested routes: `/settings` has sub-routes `profile`, `account`, `account/subscription/detail`
- Compose, reply, forward pass JWT via `extra` map — no longer embedded in URL query strings
- Catch-all `/:module/:slug` for static pages with `allowedModules` whitelist (`help`, `signup`)

**Auth redirect guard (`app_router.dart`):**
- `_RiverpodRefreshListenable` subscribes to `authProvider` and triggers GoRouter re-evaluation on auth state change
- Guard checks `isInitialized` first (prevents flash-of-login on cold start)
- Fast path: `!isAuthenticated && !isPublicRoute` returns `/login` immediately — no async storage reads
- Public route matching uses segment-based comparison to prevent `/enter-otp` matching `/enter-otp-profile`
- Redirect-loop protection: `guardedRedirect()` tracks consecutive redirects within 3-second window; breaks after 5+
- Stripe web redirect: `_stripeParamsConsumed` flag prevents `Uri.base` from re-triggering `/processing-payment`
- Passkey guard checks `userData['webauthn']` and `hasPasskeyEnrolled` storage flag

**Route helper classes:**
- `AppRoutes` (`app_routes.dart`) — declarative string constants + parameterized path builders (`emailDetailPath(int)`, `replyPath(int)`, `tagEmailsPath(int)`, etc.)
- `AppNavigator` (`navigation_helper.dart`) — static facade with ~25 shortcut methods (`goToInbox()`, `goToCompose()`, `goToSettings()`, etc.) + `setAuthenticated()` / `logout()` helpers
- `NavigationContext` extension on `BuildContext` — `goTo()`, `pushTo()`, `replaceTo()`, `goBack()`, `canGoBack`
- `route_extras.dart` (new) — `safeExtras()`, `extraString()`, `extraBool()`, `extraTyped<T>()` for type-safe `goState.extra` access
- `route_observer_service.dart` (rewritten) — `trackRouteChanges(GoRouter)` persists last route to `SharedPreferences`, logs screen views to Firebase Analytics + Crashlytics

**Responsive route wrappers (`responsive_route_wrappers.dart`):**
- ~25 `Responsive*Wrapper` widgets (one per route destination)
- Each checks `AppBreakpoints.isMobileLayout()` — desktop/tablet wraps content in `Inbox(...)` shell; mobile returns bare screen
- Uses `ValueKey` for widget identity to prevent unnecessary rebuilds

### Files changed
| File | Change |
|------|--------|
| `lib/router/app_router.dart` | Modified (664 lines) |
| `lib/router/app_routes.dart` | Modified (42 lines) |
| `lib/router/navigation_helper.dart` | Modified (108 lines) |
| `lib/router/responsive_route_wrappers.dart` | Modified (309 lines) |
| `lib/router/route_observer_service.dart` | Modified (125 lines) |
| `lib/router/route_extras.dart` | **Added** |
| `lib/widgets/shell_layout.dart` | Modified (167 lines) |
| `lib/widgets/drawer.dart` | Modified (87 lines) |
| `lib/widgets/side_menu.dart` | Modified (56 lines) |
| `lib/widgets/bottom_nav_action.dart` | Modified (69 lines) |
| `lib/screens/dashboard/bottom_navigation_bar.dart` | Modified |
| `lib/constant/string_constant.dart` | Modified — removed hardcoded path constants |

---

## 2. State Management: Riverpod Migration

### Provider package removals
- All `StateNotifierProvider` declarations converted to `NotifierProvider` (modern Riverpod)
- Import changed from `flutter_riverpod/legacy.dart` to `flutter_riverpod/flutter_riverpod.dart`
- No `ChangeNotifier` migrations — the only `ChangeNotifier` (`_RiverpodRefreshListenable`) is a GoRouter adapter, not state management

### Directory rename: `riverprod` → `riverpod`
9 feature module directories deleted and recreated with corrected spelling:

| Deleted (`*_riverprod/`) | Added (`*_riverpod/`) |
|---|---|
| `lib/screens/contacts/add_contact_riverprod/` | `lib/screens/contacts/add_contact_riverpod/` |
| `lib/screens/contacts/contacts_riverprod/` | `lib/screens/contacts/contacts_riverpod/` |
| `lib/screens/contacts/edit_contact_riverprod/` | `lib/screens/contacts/edit_contact_riverpod/` |
| `lib/screens/contacts/view_contact_riverprod/` | `lib/screens/contacts/view_contact_riverpod/` |
| `lib/screens/email/archive_riverprod/` | `lib/screens/email/archive_riverpod/` |
| `lib/screens/email/draft_riverprod/` | `lib/screens/email/draft_riverpod/` |
| `lib/screens/email/inbox_riverprod/` | `lib/screens/email/inbox_riverpod/` |
| `lib/screens/notifications/notification_riverprod/` | `lib/screens/notifications/notification_riverpod/` |
| `lib/screens/tags/tag_riverprod/` | `lib/screens/tags/tag_riverpod/` |

Plus 3 settings directories (`account`, `profile`, `setting`) and `helpCenter`.

### Notifier class pattern change
Old (`StateNotifier`):
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) { _initialize(); }
}
```
New (`Notifier`):
```dart
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.onDispose(() { _disposed = true; });
    Future.microtask(_initialize);
    return AuthState.initial();
  }
}
```
Key differences: `build()` replaces constructor, `ref.onDispose()` replaces `dispose()` override, `_disposed` flag guards all async continuations, `Future.microtask()` for initialization.

### Key provider conversions
| Provider | Old | New |
|---|---|---|
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>((ref) => ...)` | `NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new)` |
| `bottomNavProvider` | `StateNotifierProvider` | `NotifierProvider` |
| `passkeyProvider` | `StateNotifierProvider` | `NotifierProvider` |
| `webEnterOtpProvider` | `StateNotifierProvider.autoDispose` | `NotifierProvider` |
| `helpCenterProvider` | `StateNotifierProvider` | `NotifierProvider.autoDispose` |
| `checkoutProvider` | `StateNotifierProvider` | `NotifierProvider.autoDispose` |
| `paymentMethodProvider` | `StateNotifierProvider` | `NotifierProvider.autoDispose` |
| `staticPagesProvider` | `StateNotifierProvider` | `NotifierProvider` |
| `updateProvider` | `NotifierProvider(() => ...)` | `NotifierProvider(UpdateNotifier.new)` |

### New state classes with Freezed
- `UpdateState` — manual `copyWith` → `@freezed abstract class`
- `CountState` — updated to Freezed 3.x `abstract class` syntax
- New `.freezed.dart` files: `update_provider`, `payment_method_state`, `checkout_state`, `subscription_state`, `web_enter_otp_state`

### Tags provider consolidated
- Deleted standalone `lib/services/tags_state.dart` + `.freezed.dart`
- New home: `lib/screens/tags/tag_riverpod/tags_notifier.dart` + `tags_state.dart`
- `lib/services/tags_provider.dart` now a barrel file re-exporting from `tag_riverpod`

### BottomNavNotifier refactor
- Removed inline socket listeners (`_setupListeners`, `unReadSub`, `notifySub`) — centralized to `SocketService` → `countProvider`
- Added `syncFromRoute(String path)` to sync bottom nav index from GoRouter path

### Package import casing
- All `import 'package:OptMsg/...'` changed to `import 'package:optmsg/...'` (lowercase)

### Selective rebuilds
- `ref.watch(authProvider.select((s) => s.isAuthenticated))` in `ResponsivePlansWrapper` — only rebuilds on auth change, not every state mutation

### Dart 3 syntax
- `(_, __)` callback parameters → `(_, _)` (wildcard syntax)

### Files changed
All `*_riverprod/` files (deleted) + all `*_riverpod/` files (added) — ~120 files total. Plus modified: `auth_notifier.dart`, `bottom_nav_provider.dart`, `tags_provider.dart`, `count_notifier.dart`, `update_provider.dart`, `passkey_notifier.dart`, `help_center_notifier.dart`, `static_pages_notifier.dart`, all subscription notifiers/states, and ~30 screen files converted to `ConsumerWidget`/`ConsumerStatefulWidget`.

---

## 3. Adaptive & Responsive UI

### Breakpoint system
- `AppBreakpoints` (`lib/common/responsive/breakpoints.dart`) rewritten
- Android tablet detection now uses `shortestSide` from `PlatformDispatcher` instead of cached flag — correctly distinguishes phones in landscape from physical tablets
- `isDesktopLayout()` respects physical tablet detection (F-01) — iPad Pro 12.9" in portrait no longer returns `true` for desktop
- Breakpoints: Mobile <600, Tablet 600-1023, Desktop ≥1024, LargeDesktop ≥1440

### New responsive helpers
- Static methods: `isLandscape()`, `isNativeTabletLandscape()`, `isKeyboardVisible()`, `keyboardHeight()`
- Context extensions: `context.isMobile`, `context.isTablet`, `context.isDesktop`, `context.isLandscape`, `context.isKeyboardVisible`

### Widgets made adaptive
- 41 widget files updated in `lib/widgets/` (+1,064 / -863 lines)
- All `AdaptiveService.isDesktopLayout/isTabletLayout` calls replaced with `AppBreakpoints.*`
- `AdaptiveService` (`lib/services/adaptive_service.dart`) marked deprecated
- `CommonService` overlay positioning switched to `AppBreakpoints`
- `EmailSenderService` replaced `MediaQuery.of(context).size.width > 600` with `AppBreakpoints.isMobileLayout(context)`

### ShellLayout sidebar
- Desktop and tablet now have separate static caches (`_desktopExpanded`, `_tabletExpanded`) with different defaults
- Toggle works for both desktop and tablet (was `null` for tablet before)

### Orientation handling
- Tablet landscape detection uses consistent `!kIsWeb && isTablet && MediaQuery.orientation == Orientation.landscape` pattern
- Responsive route wrappers handle orientation-aware layout selection

### Files changed
| File | Summary |
|------|---------|
| `lib/common/responsive/breakpoints.dart` | Tablet detection rewrite, new helpers |
| `lib/common/responsive/responsive.dart` | Minor update |
| `lib/common/responsive/responsive_layout_builder.dart` | Added context extensions |
| `lib/services/adaptive_service.dart` | Deprecated |
| `lib/router/responsive_route_wrappers.dart` | ~25 responsive wrapper widgets |
| `lib/widgets/shell_layout.dart` | Sidebar split, socket listener removal |
| `lib/constant/styles.dart` | Full restructure (sections, new tokens) |
| 41 files in `lib/widgets/` | `AdaptiveService` → `AppBreakpoints` |

---

## 4. Security

### 4a. Descope Authentication

**Token usage fix (critical):**
- `refreshable_api.dart`: Changed from sending `refreshJwt` to `sessionJwt` in the `authorization` header — previously the long-lived refresh token was sent on every API call
- `api_service.dart`: Builds per-request headers with `sessionJwt`; removed fallback path that read `refreshJwt` from storage

**Manual JWT storage removed:**
- All manual writes of `sessionJwt`/`refreshJwt` to `SecureStorageService` removed from `auth_notifier.dart`
- Descope SDK's `manageSession()` now handles persistence exclusively
- `clearAllData()` still deletes these keys for stale-value cleanup

**Session refresh on startup:**
- `main.dart`: After `Descope.sessionManager.loadSession()`, calls `refreshSessionIfNeeded()` with 10-second timeout
- If refresh fails, session is cleared — prevents first API call from hitting 401

**Session revocation on logout:**
- `auth_notifier.dart` `logout()`: Calls `Descope.auth.revokeSessions(RevokeType.currentSession, refreshJwt)` with 5-second timeout — prevents refresh token reuse

**Stale session fix (C-11):**
- `Descope.sessionManager.clearSession()` now called at top of `userVerify()` — fixes 500 errors from stale JWT on login

**Initialization uses Descope as source of truth:**
- `_initialize()` checks `Descope.sessionManager.session` directly instead of reading `isAuthenticated` from secure storage
- Validates refresh token is not expired and `userData` exists
- If session JWT expired but refresh token valid, attempts refresh

**DescopeApiService migrated to Dio:**
- `descope_api_service.dart`: Replaced raw `http` with `Dio`, including certificate pinning infrastructure
- Authorization header now uses `sessionJwt` (was `refreshJwt`)
- Session refresh routed through `SessionRefreshMutex`

**Auth state error typing:**
- `AuthState.error()` now accepts `AuthErrorType` enum (descopeError, subscriptionInvalid, invalidCredentials, network, generic)

**Files changed:** `auth_notifier.dart`, `refreshable_api.dart`, `api_service.dart`, `descope_api_service.dart`, `main.dart`, `auth_state.dart`, `auth_state.freezed.dart`

### 4b. Biometric Authentication

**BiometricService API update:**
- `AuthenticationOptions` changed: `useErrorDialogs: true, stickyAuth: true` → `persistAcrossBackgrounding: true` (local_auth API change)

**Privacy screen (iOS native):**
- `AppDelegate.swift`: New `privacyView` overlay system — when `privacyEnabled` is true, `applicationWillResignActive` adds a brand-blue overlay to prevent content from appearing in the iOS app switcher
- Controlled via Flutter method channel `com.optmsg.mail/privacy` with `setPrivacyScreenEnabled` method

**Biometric lock overhaul (`main.dart`):**
- Grace period changed from 5 seconds to `Duration.zero` (instant lock)
- Privacy screen shows on `AppLifecycleState.inactive` (earlier than `paused`) — prevents content flash in app switcher
- Lock only triggers when `_isBiometricEnabled` is true
- Cold-start biometric lock: `_loadBiometricSettingAndColdStartLock()` runs at `initState`
- Failed biometric shows retry dialog ("Try Again" / "Log Out") instead of immediate logout
- Auth state read from `providerContainer.read(authProvider)` instead of secure storage (avoids race during logout)

**Files changed:** `biometric_service.dart`, `main.dart`, `ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist`

### 4c. General Security Improvements

**New session management architecture:**
- `SessionRefreshMutex` (new: `lib/services/session_refresh_mutex.dart`) — process-wide mutex ensuring only one Descope JWT refresh runs at a time; uses `Completer<void>` pattern; has `isLoggedOut` and `passkeyFlowInProgress` flags
- `SessionExpiryManager` (new: `lib/services/session_expiry_manager.dart`) — centralizes 401-handling that was duplicated in `ApiService` and `BaseAPIService`; idempotent `handleExpiry()` with `_isHandling` guard; no more UI from network layer
- 30-second `Timer.periodic` in `_MyAppState` keeps JWT fresh; stopped on background, restarted on resume

**New security utilities:**
- `secure_print_helper.dart` (new) — opens print-preview via `InAppWebView` with JWT in HTTP headers, not URL
- `secure_url_helper.dart` (new) — `stripTokenFromUri()`/`stripTokenFromUrl()` removes `token`/`tokentype` query params; `getSessionToken()` centralized accessor
- `stripe_url_validator.dart` (new) — validates payment URLs are HTTPS and point to `*.stripe.com` or the app's API host

**Platform-conditional secure storage:**
- `lib/services/storage/` (new directory) — `PlatformSecureStorage` interface with mobile (`FlutterSecureStorage` with iOS -25308 handling) and web (`sessionStorage` with `optmsg_secure_` prefix) implementations
- Web uses `sessionStorage` not `localStorage` — data clears when tab closes, preventing persistent XSS token theft

**Token-in-URL patterns removed:**
- Old `?token=$token&tokentype=descope` query params replaced with header-based auth throughout
- `fetchJsonDataUrl()` has URL allowlist restricting to `*.optmsg.com`, `*.amazonaws.com`, `*.descope.com`

**HTTP security:**
- All HTTP calls now have 30-second timeouts (previously unbounded)
- `ApiService._createSecureClient()` rejects bad certificates via `badCertificateCallback`
- `authorization` header no longer set as empty string in defaults — only added when JWT exists

**iOS App Transport Security:**
- `NSAllowsArbitraryLoads` changed from `true` to `false` — enforces HTTPS only

**Android:**
- `READ_EXTERNAL_STORAGE` limited to `maxSdkVersion="32"`, `WRITE_EXTERNAL_STORAGE` to `maxSdkVersion="28"` (scoped storage)
- Added `READ_MEDIA_VISUAL_USER_SELECTED` (API 34+ partial access)
- Removed `requestLegacyExternalStorage="true"`
- Added `dataExtractionRules` (replaces `fullBackupContent`)
- `flutter_deeplinking_enabled` changed to `true`

**Email HTML sanitizer hardening:**
- Strips `<script>`, `<iframe>`, `<object>`, `<embed>`, `<applet>`, `<form>`, `<base>` tags
- Removes event handler attributes (`onclick`, `onerror`, etc.)
- Neutralizes `javascript:`/`vbscript:`/`data:` URIs
- Removes CSS `expression()` patterns

**Web CSP:**
- `web/index.html`: Added `Content-Security-Policy` meta tag with explicit `connect-src`, `script-src`, `frame-src`, `object-src 'none'`, `base-uri 'self'`, `form-action 'self'`

**Removed:**
- `breach_notifier.dart` and `check_breach_mails.dart` deleted (removed HIBP breach check feature and its API key reference)

**Files changed:** `session_refresh_mutex.dart` (new), `session_expiry_manager.dart` (new), `analytics_service.dart` (new), `secure_print_helper.dart` (new), `secure_url_helper.dart` (new), `stripe_url_validator.dart` (new), `storage/` directory (new, 3 files), `base_api_service.dart`, `api_service.dart`, `storage_service.dart`, `AndroidManifest.xml`, `Info.plist`, `AppDelegate.swift`, `web/index.html`, `mail_html_view.dart`

---

## 5. Performance

- **Selective Riverpod rebuilds:** `ref.watch(authProvider.select((s) => s.isAuthenticated))` in subscription wrappers — only rebuilds when auth changes, not on every state mutation
- **Session refresh timeout:** `refreshSessionIfNeeded()` has 10-second timeout (L-19) preventing hung app boot
- **Email sender iterative loop:** `displayAddEmailModal` in `EmailSenderService` converted from recursive to iterative — eliminates stack overflow risk with many emails
- **Email HTML rendering:** Inline `<script>` strips `width`/`height` attributes from tables/images at DOM load; CSS viewport changed from `initial-scale=0.5` to `1.0` with `box-sizing: border-box`; regex patterns compiled as static `final` fields
- **Provider disposal:** `ref.onDispose()` in all notifiers' `build()` sets `_disposed = true` and cancels timers — prevents work after teardown
- **Socket listener centralization:** Removed per-widget socket subscriptions from `ShellLayout`, `SideMenu`, `BottomNavNotifier` — centralized to `SocketService` → `countProvider` (reduces duplicate event handlers)

### Files changed
`email_sender_service.dart`, `mail_html_view.dart`, `auth_notifier.dart`, `bottom_nav_provider.dart`, `shell_layout.dart`, `side_menu.dart`, `responsive_route_wrappers.dart`

---

## 6. Stability

### Error handling
- `main()` wrapped in `runZonedGuarded()` for unhandled async errors
- `PlatformDispatcher.onError` changed from `fatal: true` to `fatal: false` (prevents app termination on uncaught errors)
- Firebase init tracks `firebaseReady` flag; Crashlytics only enabled when Firebase initialized + release mode + non-web
- Router redirect wrapped in try/catch — returns `null` on transient storage I/O failures
- `AppBadgePlus.updateBadge()` wrapped in try/catch in 3 places
- `formatPhoneNumber()` handles short numbers (`digits.length < 6`) instead of throwing substring range errors
- `checkHtmlData()` fixed: was calling `data.replaceAll` instead of `tempMessage.replaceAll` for second replacement

### Null safety / disposed-guard fixes
- `_disposed` flag checked after every `await` in `AuthNotifier._initialize()`, `userVerify()`, and passkey flows
- `CommonService.showOverlayToast()`: added `finalOverlayState.mounted` check before overlay insert
- Notification service reads auth state from Riverpod instead of stale secure storage

### dispose/cancel fixes
- `_MyAppState.dispose()`: now disposes `_sessionRefreshTimer`, `_isPrivacyVisible`, `routerRefreshListenable` (C-08), `appRouter`
- `SocketService.disconnect()`: sets `_isDisposed = true`, nulls `_socket`, closes all stream controllers; `initSocket()` cleans up before reinitializing
- `NotificationService`: stores `_onMessageSub`, `_onMessageOpenedAppSub`, `_tokenRefreshSub` as fields; cancels before re-subscribing (prevents duplicate listeners)
- Splash screen: removed fixed timer; uses `providerContainer.listen(authProvider)` to remove only when `isInitialized` becomes true

### Race condition fixes
- Socket reconnect/connect uses fresh JWT from `Descope.sessionManager.session?.sessionJwt` instead of stale closure token
- ACK callbacks guarded with `if (_isDisposed) return`
- Socket service adds `reconnectIfNeeded()` called on app resume
- FCM token: no longer stores placeholder `'1234'` on failure
- Token refresh subscription listens to `FirebaseMessaging.instance.onTokenRefresh` and persists new tokens

### Platform-specific fixes
- **iOS:** Local notification init sets `requestAlertPermission`/`requestBadgePermission`/`requestSoundPermission` to `false` (avoids duplicate permission prompts)
- **iOS:** `flutter_local_notifications` API updated to named parameters
- **iOS:** `AppDelegate.swift` migrated to `FlutterImplicitEngineDelegate` pattern; scene-based `keyRootViewController()`; QuickLook preview tried before "Open In" menu; `pendingFileResult` pattern prevents premature temp-file cleanup
- **Android:** Notification permission checks `sdkInt >= 33` explicitly instead of unreliable `Permission.notification.isDenied`
- **Android:** `enableOnBackInvokedCallback="true"` (predictive back gesture)

### Files changed
`main.dart`, `auth_notifier.dart`, `socket_service.dart`, `notification_service.dart`, `common_service.dart`, `mail_html_view.dart`, `AppDelegate.swift`, `AndroidManifest.xml`, `Info.plist`

---

## 7. Cleanup & Improvements

### Dependency changes (pubspec.yaml)
- **Package renamed:** `OptMsg` → `optmsg` (all imports updated)
- **SDK constraint raised:** `>=3.2.3 <4.0.0` → `>=3.11.0 <4.0.0`; Flutter `>=3.41.2`
- **Version bumped:** `1.0.3+1` → `1.0.6`
- **Major upgrades:** `descope` 0.9.12→0.9.18, `flutter_riverpod` 3.0.3→3.2.1, `go_router` 14.6.2→17.1.0, `freezed_annotation` 2.4.1→3.0.0, `freezed` 2.4.5→3.2.5, `flutter_secure_storage` 9.0.0→10.0.0, `flutter_local_notifications` 19.3.0→21.0.0, Firebase suite bumped to latest, `intl` 0.19.0→0.20.1, `permission_handler` 11.3.1→12.0.1
- **Removed:** `get_ip_address`, `dart_rss`, `internet_connection_checker_plus`
- **Added:** `firebase_performance`, `mime`, `mockito` (dev), `youtube_player_iframe`
- **Fonts:** Added `Figtree` (headings), `NotoSans` (body); `Manrope` switched from static to variable font
- **Lints:** `flutter_lints` 4.0.0→6.0.0; `deprecated_member_use: ignore` commented out

### Dead code removal
- Deleted `breach_notifier.dart` and `check_breach_mails.dart` (HIBP breach check feature)
- Deleted standalone `tags_state.dart` + `.freezed.dart` from services (consolidated to `tag_riverpod/`)
- Deleted `subscription_provider.dart` (absorbed into subscription notifier)
- Removed root-level analysis report files: `analysis_report.txt`, `final_analysis_report.txt`, `new_analysis_report.txt`, `file_by_file_fix_plan.md`
- Removed `checkIp()` method (used deleted `get_ip_address` package)
- Removed string constants: `allSent`, `allTrash`, `allArchive`, `addToContact`, duplicate `faqPageKey`, all hardcoded path constants

### Code style
- `styles.dart` fully restructured: organized into sections (font weights, spacing, border radius, font sizes, colors/brand/semantic/status, type scale for Figtree/NotoSans, legacy aliases)
- Added: `appBarGradient`, `primaryDark`, `primaryVariant`, `onPrimary`, `overlayDark`/`overlayLight`
- `string_constant.dart`: long string literals reformatted, apostrophe encoding fixed
- Return types added where previously implicit dynamic (e.g. `extensionTypesIcon()` → `SvgPicture`, `getFileName()` → `String`)
- Library directive modernized: `library responsive;` → `library;`

### Web cleanup
- `web/index.html`: Removed duplicate viewport meta tag, removed deprecated `serviceWorkerVersion` script, simplified Firebase service worker registration, removed jQuery-dependent Flutter initialization

### Firebase changes
- `GoogleService-Info.plist` (dev/stage/prod): Minor config updates
- `firebase_analytics_collection_enabled` changed from `false` to `true` (Android)
- `FirebaseAppDelegateProxyEnabled` changed from `false` to `true` (iOS)
- Crashlytics and Analytics integration throughout session management

---

## 8. Files Changed — Full Reference

### Added Files (new)

| File Path | Category | Summary |
|-----------|----------|---------|
| `lib/router/route_extras.dart` | Navigation | Type-safe GoRouter extras accessors |
| `lib/common/utilites/secure_print_helper.dart` | Security | Print preview via InAppWebView with JWT in headers |
| `lib/common/utilites/secure_url_helper.dart` | Security | Strip tokens from URLs, centralized JWT accessor |
| `lib/common/utilites/stripe_url_validator.dart` | Security | Validates Stripe payment URLs |
| `lib/screens/auth/login_post_processor.dart` | Security | Post-login processing logic |
| `lib/services/analytics_service.dart` | Cleanup | Firebase Analytics event logging |
| `lib/services/session_expiry_manager.dart` | Security | Centralized idempotent 401 handler |
| `lib/services/session_refresh_mutex.dart` | Security | Process-wide JWT refresh mutex |
| `lib/services/storage/platform_secure_storage.dart` | Security | Platform storage interface |
| `lib/services/storage/platform_secure_storage_stub.dart` | Security | Mobile FlutterSecureStorage impl |
| `lib/services/storage/platform_secure_storage_web.dart` | Security | Web sessionStorage impl |
| `lib/services/update_provider.freezed.dart` | State | Generated Freezed code |
| `lib/widgets/load_container/delayed_loading_overlay.dart` | UI | Delayed loading indicator |
| `android/app/src/main/res/xml/data_extraction_rules.xml` | Security | Android backup rules |
| `assets/fonts/Figtree-VariableFont_wght.ttf` | UI | New heading font |
| `assets/fonts/Manrope-VariableFont_wght.ttf` | UI | Variable font replacement |
| `assets/fonts/NotoSans-VariableFont_wdth,wght.ttf` | UI | New body font |
| `ios/Runner/Assets.xcassets/AppIcon-prod.appiconset/*` | Cleanup | Production app icons |
| `lib/screens/auth/web/enterOtp/web_enter_otp_state.freezed.dart` | State | Generated Freezed code |
| `lib/screens/subscription/change_payment/payment_method_state.freezed.dart` | State | Generated Freezed code |
| `lib/screens/subscription/checkout/checkout_state.freezed.dart` | State | Generated Freezed code |
| `lib/screens/subscription/subscription_details/subscription_state.freezed.dart` | State | Generated Freezed code |

### Added Directories (riverprod → riverpod rename, ~100 files)

| Directory | Category | Files |
|-----------|----------|-------|
| `lib/screens/contacts/add_contact_riverpod/` | State | 7 files |
| `lib/screens/contacts/contacts_riverpod/` | State | 7 files |
| `lib/screens/contacts/edit_contact_riverpod/` | State | 7 files |
| `lib/screens/contacts/view_contact_riverpod/` | State | 7 files |
| `lib/screens/email/archive_riverpod/` | State | 14 files |
| `lib/screens/email/draft_riverpod/` | State | 10 files |
| `lib/screens/email/inbox_riverpod/` | State | 16 files |
| `lib/screens/notifications/notification_riverpod/` | State | 4 files |
| `lib/screens/settings/account_riverpod/` | State | 8 files |
| `lib/screens/settings/profile_riverpod/` | State | 8 files |
| `lib/screens/settings/setting_riverpod/` | State | 8 files |
| `lib/screens/tags/tag_riverpod/` | State | 8 files |
| `lib/screens/helpCenter/help_center_riverpod.dart` | State | 1 file |

### Modified Files

| File Path | Category | Summary |
|-----------|----------|---------|
| `.gitignore` | Cleanup | Updated ignore patterns |
| `android/app/src/main/AndroidManifest.xml` | Security | Scoped storage, predictive back, deep linking |
| `android/build.gradle` | Cleanup | Build config updates |
| `ios/Flutter/AppFrameworkInfo.plist` | Cleanup | Framework version update |
| `ios/Podfile` | Cleanup | Pod config changes |
| `ios/Runner.xcodeproj/project.pbxproj` | Cleanup | Xcode project structure |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/*.xcscheme` | Cleanup | Build scheme updates |
| `ios/Runner/AppDelegate.swift` | Security | Privacy screen, scene lifecycle, file preview |
| `ios/Runner/Firebase/*/GoogleService-Info.plist` | Cleanup | Firebase config updates |
| `ios/Runner/Info.plist` | Security | ATS enforcement, scene manifest |
| `ios/Runner/RunnerRelease.entitlements` | Cleanup | Entitlements update |
| `lib/common/app_manger/app_cache.dart` | Navigation | Cache for nav state + query params |
| `lib/common/responsive/breakpoints.dart` | UI | Tablet detection rewrite, new helpers |
| `lib/common/responsive/responsive.dart` | UI | Minor responsive update |
| `lib/common/responsive/responsive_layout_builder.dart` | UI | Context extensions added |
| `lib/constant/string_constant.dart` | Cleanup | Removed path constants, text fixes |
| `lib/constant/styles.dart` | UI | Full restructure, new design tokens |
| `lib/main.dart` | Stability | Zone guard, session timer, biometric lock, splash fix |
| `lib/model/auth/auth_state.dart` | State | AuthErrorType enum, typed errors |
| `lib/model/auth/auth_state.freezed.dart` | State | Regenerated |
| `lib/model/auth/enter_otp_state.dart` | State | Minor update |
| `lib/model/auth/enter_otp_state.freezed.dart` | State | Regenerated |
| `lib/model/auth/passkey_state.dart` | State | Minor update |
| `lib/model/auth/passkey_state.freezed.dart` | State | Regenerated |
| `lib/model/base_response/request_error.dart` | Cleanup | Type fix |
| `lib/model/base_response/request_response.dart` | Cleanup | Type fix |
| `lib/model/contact_list_model.dart` | Cleanup | Type fix |
| `lib/model/inbox_list_model.dart` | Cleanup | Removed unused field |
| `lib/model/notification_list_model.dart` | Cleanup | Added fields |
| `lib/model/request_add_contact_modal.dart` | Cleanup | Type fix |
| `lib/model/sent_list_model.dart` | Cleanup | Added fields |
| `lib/model/view_email_model.dart` | Cleanup | Model updates |
| `lib/repositories/account/account_api.dart` | Security | Header/auth changes |
| `lib/repositories/auth/auth_api.dart` | Security | Header/auth changes |
| `lib/repositories/base/base_api_service.dart` | Security | SessionExpiryManager, static dialog guard |
| `lib/repositories/base/refreshable_api.dart` | Security | sessionJwt instead of refreshJwt |
| `lib/repositories/contact/contact_api.dart` | Security | Header changes |
| `lib/repositories/contact/contact_repository.dart` | Cleanup | Refactored |
| `lib/repositories/draft/draft_repository.dart` | Cleanup | Refactored |
| `lib/repositories/email/archive_api.dart` | Security | Header changes |
| `lib/repositories/email/draft_api.dart` | Security | Header changes |
| `lib/repositories/email/inbox_api.dart` | Security | Header changes, 401 suppression |
| `lib/repositories/end_point/end_point.dart` | Security | Compile-time endpoint resolution |
| `lib/repositories/inbox/email_detail_repository.dart` | Cleanup | Refactored |
| `lib/repositories/inbox/inbox_repository.dart` | Cleanup | Refactored |
| `lib/repositories/notification/notification_api.dart` | Security | Header changes |
| `lib/repositories/setting/setting_api.dart` | Security | Header changes |
| `lib/repositories/tags/tag_api.dart` | Security | Header changes |
| `lib/router/app_router.dart` | Navigation | Full rewrite — redirect guard, ShellRoute |
| `lib/router/app_routes.dart` | Navigation | Constants + path builders |
| `lib/router/navigation_helper.dart` | Navigation | AppNavigator facade |
| `lib/router/responsive_route_wrappers.dart` | Navigation/UI | ~25 responsive wrappers |
| `lib/router/route_observer_service.dart` | Navigation | Route persistence + analytics |
| `lib/screens/auth/auth_riverpod/auth_notifier.dart` | State/Security | Notifier migration, session mgmt |
| `lib/screens/auth/createAccount/*.dart` (4 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/enterOtp/*.dart` (7 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/forgotUserName/*.dart` (2 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/login/*.dart` (4 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/passKey/add_pass_key.dart` | State/Security | Passkey flow updates |
| `lib/screens/auth/passKey/passkey_notifier.dart` | State | Notifier migration |
| `lib/screens/auth/setupProfile/*.dart` (4 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/userNameSuccess/*.dart` (5 files) | State | ConsumerWidget conversion |
| `lib/screens/auth/web/*.dart` (5 files) | State/Security | Web auth flow updates |
| `lib/screens/compose/web_compose.dart` | Navigation | GoRouter extras, JWT handling |
| `lib/screens/dashboard/bottom_nav_provider.dart` | State | Notifier migration, syncFromRoute |
| `lib/screens/dashboard/bottom_nav_state.dart` | State | Minor update |
| `lib/screens/dashboard/bottom_nav_state.freezed.dart` | State | Regenerated |
| `lib/screens/dashboard/bottom_navigation_bar.dart` | Navigation | GoRouter integration |
| `lib/screens/helpCenter/help_center_notifier.dart` | State | Notifier migration |
| `lib/screens/helpCenter/help_center_state.dart` | State | Minor update |
| `lib/screens/helpCenter/help_center_state.freezed.dart` | State | Regenerated |
| `lib/screens/inbox/attachment_preview_screen.dart` | UI | Responsive updates |
| `lib/screens/inbox/custom_file_downloader_manager.dart` | Cleanup | Minor fix |
| `lib/screens/inbox/inbox.dart` | Navigation | GoRouter integration |
| `lib/screens/inbox/mail_html_view.dart` | Security/Performance | HTML sanitizer + rendering |
| `lib/screens/inbox/view_inbox.dart` | UI | Major responsive refactor |
| `lib/screens/inbox/widget/*.dart` (3 files) | UI | Responsive updates |
| `lib/screens/no_internet_screen.dart` | Navigation | GoRouter integration |
| `lib/screens/staticPages/*.dart` (3 files) | State/Navigation | Notifier migration, GoRouter |
| `lib/screens/subscription/**/*.dart` (14 files) | State | Notifier migration, Freezed states |
| `lib/screens/tags/tag_email_list.dart` | Navigation | GoRouter integration |
| `lib/services/adaptive_service.dart` | UI | Deprecated |
| `lib/services/api_service.dart` | Security | SessionRefreshMutex, timeouts |
| `lib/services/biometric_service.dart` | Security | API update |
| `lib/services/common_service.dart` | UI/Stability | AppBreakpoints, overlay mount check |
| `lib/services/count_notifier.dart` | State | Freezed 3.x syntax |
| `lib/services/count_notifier.freezed.dart` | State | Regenerated |
| `lib/services/descope_api_service.dart` | Security | Dio migration, sessionJwt |
| `lib/services/email_sender_service.dart` | Performance | Iterative loop, AppBreakpoints |
| `lib/services/floating_action_button_location.dart` | Cleanup | Minor fix |
| `lib/services/global_variable_state.dart` | State | Minor update |
| `lib/services/global_variable_state.freezed.dart` | State | Regenerated |
| `lib/services/notification_service.dart` | Stability | Subscription tracking, race fixes |
| `lib/services/socket_service.dart` | Stability | Disposed guard, fresh JWT, cleanup |
| `lib/services/storage_service.dart` | Security | Platform storage, expanded clear |
| `lib/services/tags_provider.dart` | State | Barrel re-export |
| `lib/services/update_provider.dart` | State | Freezed conversion |
| `lib/services/web_file_picker_service.dart` | Cleanup | Refactored |
| `lib/services/web_utils_web.dart` | Cleanup | Minor fix |
| `lib/webPackerHandler/*.dart` (4 files) | Security | Stripe URL validation |
| `lib/widgets/*.dart` (41 files) | UI | AppBreakpoints migration |
| `pubspec.yaml` | Cleanup | Renamed, version bump, dep upgrades |
| `test/auth_notifier_test.dart` | Cleanup | Updated for new notifier API |
| `web/index.html` | Security | CSP, cleanup |

### Deleted Files

| File Path | Category | Summary |
|-----------|----------|---------|
| `.claude/settings.local.json` | Cleanup | Local settings removed |
| `analysis_report.txt` | Cleanup | Root-level report removed |
| `assets/fonts/Manrope-Regular.ttf` | Cleanup | Replaced with variable font |
| `file_by_file_fix_plan.md` | Cleanup | Moved to docs/ |
| `final_analysis_report.txt` | Cleanup | Root-level report removed |
| `new_analysis_report.txt` | Cleanup | Root-level report removed |
| `lib/screens/auth/breach_notifier.dart` | Cleanup | HIBP feature removed |
| `lib/screens/auth/check_breach_mails.dart` | Cleanup | HIBP feature removed |
| `lib/screens/helpCenter/help_center_riverprod.dart` | State | Typo rename |
| `lib/screens/subscription/subscription_riverpod/subscription_provider.dart` | State | Absorbed into notifier |
| `lib/services/tags_state.dart` | State | Consolidated to tag_riverpod/ |
| `lib/services/tags_state.freezed.dart` | State | Consolidated to tag_riverpod/ |
| All `*_riverprod/` directories (~105 files) | State | Replaced by `*_riverpod/` |

---

## 9. Review Notes for Team

### Breaking changes
- **Package name:** `OptMsg` → `optmsg` — all imports must use lowercase. Any external tooling or CI scripts referencing the old name will break
- **SDK floor raised:** Dart ≥3.11.0, Flutter ≥3.41.2 — all dev machines and CI must be on these versions
- **Freezed 3.x:** All `@freezed` classes use `abstract class ... with _$...` syntax. Generated files must be regenerated with `build_runner`
- **GoRouter 17.x:** Any remaining `Navigator.push/pop` calls in feature code must be migrated to `context.go()`/`AppNavigator.*`
- **flutter_secure_storage 10.x:** API changes may affect any custom storage code

### Security-sensitive areas needing extra scrutiny
- 🚨 **Certificate pinning not active:** `DescopeApiService` has pinning infrastructure but `_descopePinnedSha1` is empty — TODO to populate it
- 🚨 **`*.amazonaws.com` in URL allowlist:** `fetchJsonDataUrl()` allows any `*.amazonaws.com` host — consider restricting to specific S3 buckets
- ⚠️ **405 handling inconsistency:** `ApiService` only triggers session expiry on 401; `BaseAPIService` handles both 401 and 405. Could cause different behavior depending on code path
- ⚠️ **Web CSP requires `unsafe-inline`/`unsafe-eval`** — inherent Flutter web limitation (C-01 in Riverpod audit)

### Areas requiring QA testing
- **Biometric lock:** Grace period changed to instant; privacy screen timing changed to `inactive` state; retry dialog replaces immediate logout — test on iOS (FaceID/TouchID) and Android (fingerprint)
- **Descope session lifecycle:** Login → use app → background → foreground → verify JWT refresh works; Logout → login again → verify no stale session; Let JWT expire → verify silent refresh or graceful redirect
- **Passkey enrollment:** Test passkey guard redirect after signup, after login for users with/without passkeys enrolled
- **Stripe payment flow:** Web redirect handling with `_stripeParamsConsumed` flag; validate `stripe_url_validator.dart` doesn't block legitimate checkout URLs
- **Responsive layouts:** Test on physical iPad (portrait vs landscape), Android tablet, phone in landscape, web at various widths. The tablet detection rewrite (shortestSide-based) is a behavioral change

### Future work: Re-enable CSP for web
- **Priority:** Medium — security hardening
- **Problem:** `flutter_inappwebview` on Flutter web loads remote HTML as `data:text/html` URIs inside sandboxed iframes. This breaks relative script paths (jQuery, Summernote, Bootstrap) in the compose page, and inherits the parent CSP which blocks them further.
- **Current state:** CSP meta tag removed from `web/index.html` to unblock compose. Matches the pre-refactor branch (`optmsg_1.0.7_27feb`) which had no CSP.
- **Solution:** Replace `InAppWebView` with `HtmlElementView` + native `IFrameElement` on web (`kIsWeb`). Rewrite the Flutter↔compose JS bridge to use `window.postMessage()` instead of `evaluateJavascript()` / `addJavaScriptHandler()`. This requires changes to both the Flutter app and the server-side compose HTML. Once done, re-add CSP to `web/index.html`.
- **Files affected:** `lib/screens/compose/web_compose.dart`, `web/index.html`, server-side compose endpoint HTML

### Known issues from audit reports (not yet fixed)
- **C-01 (Production Audit):** `SubscriptionNotifier.makePayment()` has no timeout — spinner persists if socket event never arrives
- **C-02 (Production Audit):** Contact upload endpoints use placeholder hostnames (`dev-upload.example.com`)
- **C-05 (Riverpod Audit):** Passkey enrollment interrupted by concurrent 401 — `SessionExpiryManager.handleExpiry()` doesn't check `passkeyFlowInProgress`
- **C-12 (Riverpod Audit):** `plan_list_model.dart:81` maps `type` to `json['title']` instead of `json['type']` — corrupts plan filtering
- **H-03 (Riverpod Audit):** OTP resend sets `unauthenticated` instead of `awaitingOtp`
- See `docs/PRODUCTION_AUDIT_REPORT.md` and `docs/RIVERPOD_AUDIT_REPORT.md` for complete issue inventories

### Migration patterns the team should understand
1. **Notifier pattern:** All notifiers use `build()` + `ref.onDispose()` + `_disposed` flag. Every `await` must check `_disposed` before mutating state
2. **GoRouter redirect:** Auth state changes trigger `_RiverpodRefreshListenable` → GoRouter re-evaluates redirect. No manual navigation on login/logout
3. **Responsive wrappers:** Every route has a `Responsive*Wrapper` that decides mobile vs desktop shell. New routes must add a wrapper
4. **SessionRefreshMutex:** All JWT refresh paths go through `guardedRefreshIfNeeded()`. Adding a new API service? Route its refresh through the mutex
5. **Safe extras:** Use `safeExtras()` + `extraString()`/`extraBool()`/`extraTyped<T>()` for all `goState.extra` access — never cast directly
