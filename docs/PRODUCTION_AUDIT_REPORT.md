# OptMsg Production Readiness Audit Report (Review 20)

**Date:** 2026-03-29
**Branch:** `optmsgApp-v1.0.7.ryan.uxui.test`
**Flutter SDK:** >=3.41.4 | **Dart SDK:** >=3.11.0
**Stack:** Flutter · Riverpod 3.3.1 · GoRouter 17.1.0 · Descope 0.10.0 · Stripe (server-side redirect) · Firebase (Analytics, Crashlytics, FCM, Performance) · Socket.IO

> **Review 20** is a comprehensive audit following the UX/UI modernization, Descope SDK upgrade, auth overhaul, M3 bottom nav, consolidated AppBar, multi-select, tags sidebar, and Move action. Auth/session management is now solid. UX/UI is dramatically improved. Security and performance remain the primary areas needing work.

---

## Overall Production Readiness

| Domain | Score | Status |
|--------|------:|--------|
| Authentication & Session | 9.0/10 | All 14 notifiers `_disposed`-guarded. Descope 0.10.0. SessionRefreshMutex, centralized 401 handler, exponential backoff recovery, passkey 5-min timeout. |
| Security & Privacy | 5.5/10 | JWT in compose URL, keystore+Firebase in git, no cert pinning, regex HTML sanitizer, ~84 bare debugPrint in release, Firebase Analytics sends user ID. |
| Stripe / Payments | 7.0/10 | Server-side checkout (no client keys). Cancel uses GET. No subscription status enum. No customer portal. |
| State Management | 9.5/10 | All 14 notifiers verified. `mounted` guards verified. `printLog` guarded. HTML body cached. |
| Platform Compliance | 7.0/10 | Many R18 items resolved. Remaining: keystore in git, debugPasskeyInfo in prod, Firebase configs tracked, missing viewport tag. |
| UX / UI | 7.5/10 | M3 bottom nav, consolidated shell AppBar (26→1), multi-select everywhere, tags sidebar, Move action, light/dark theme system. |
| Architecture & Performance | 6.0/10 | InboxNotifier 2377 lines, ArchiveNotifier 3205 lines, 55+ unguarded ref.watch(), unbounded list, ~84 bare debugPrint. |
| Toast Notifications | 7.5/10 | See `docs/TOAST_NOTIFICATIONS.md`. |
| **Release Readiness** | **CONDITIONAL** | **4 CRITICAL issues remain. Auth is solid. UX is production-grade. Fix CRITs + top performance items.** |

---

## Table of Contents

1. [Critical Issues](#1-critical-issues--must-fix-before-release)
2. [High Issues](#2-high-issues)
3. [Medium Issues](#3-medium-issues)
4. [Low Issues](#4-low-issues)
5. [Top 20 Priority Fixes](#5-top-20-priority-fixes)
6. [Platform Release Checklists](#6-platform-release-checklists)
7. [Architecture Extensibility Roadmap](#7-architecture-extensibility-roadmap)
8. [Security & Privacy Exception Register](#8-security--privacy-exception-register)
9. [Summary Scorecard](#9-summary-scorecard)
10. [Performance Deep-Dive](#10-performance-deep-dive)

---

## 1. Critical Issues — Must Fix Before Release

### C-SEC-01: JWT Leaked in Compose URL Query String
**File:** `lib/screens/compose/web_compose.dart:1038–1064`
`validateUrl()` appends the Descope session JWT as `?token=<jwt>&tokentype=descope` to the compose URL on **both web and mobile**. The JWT lands in browser history, server logs, Referer headers, and proxy logs. Session hijacking risk (CWE-598).
**Fix:** Mobile: remove token from URL, use HTTP headers only. Web: use a server-issued one-time token or `postMessage` bridge.

### C-SEC-02: Keystore + Plaintext Credentials in Git
**Files:** `android/key/optmsg.jks`, `android/key/credentials`, `android/gradle.properties:12–14`
Release keystore (binary), password (`123456`), key alias, and Apple cert password (`yogi@gupta`) are all tracked by git.
**Fix:** `git rm --cached` all 3 files. Rotate keystore with strong password. Store in CI secrets only.

### C-SEC-03: Firebase Config Files + `firebase_options.dart` Tracked by Git
**Files:** 3× `google-services.json`, 3× `GoogleService-Info.plist`, `lib/firebase_options.dart`
`.gitignore` lines 144 and 146 are **commented out** (`#`). Firebase API keys for all 3 environments exposed.
**Fix:** Uncomment `.gitignore` lines. `git rm --cached` all 7 files. Regenerate keys via Firebase console.

### C-ARCH-01: Inbox Email List Grows Unboundedly in Memory
**File:** `lib/screens/email/inbox_riverpod/inbox_notifier.dart:861`
Pages append via `[...s.items, ...newItems]` with no eviction. 10K emails = 50–200 MB. OOM on low-end Android.
**Fix:** Sliding-window pagination — keep 3–5 pages, re-fetch on scroll-back.

---

### Resolved CRITICALs from Prior Reviews

| ID | Resolution |
|----|-----------|
| ~~C-AUTH-01~~ | `SessionRefreshMutex.isLoggedOut = false` added in `userLogin()` |
| ~~C-AUTH-02~~ | Diagnostic toast removed from passkey enrollment |
| ~~C-PLAT-01~~ | Namespace changed to `com.optmsg.mail`; `MainActivity.kt` package updated |
| ~~C-STATE-01~~ | `EmailDetailNotifier._disposed` properly reset in `build()` |
| ~~C-STATE-02~~ | `mounted` guards added in `tag_email_list.dart` |
| ~~C-UX-01~~ | M3 `NavigationBar` implemented in `app_navigation_bar.dart` (73 lines) |
| ~~C-UX-02~~ | Compose accessible via shell AppBar action on mobile |

---

## 2. High Issues

### Security

| ID | File | Issue |
|----|------|-------|
| H-SEC-01 | `descope_api_service.dart:22` | Cert pinning SHA-1 list empty. Descope SDK internal client cannot be pinned (vendor limitation). |
| H-SEC-02 | `Info.plist:150,173` | `UIFileSharingEnabled=true` + `LSSupportsOpeningDocumentsInPlace=true` expose Documents dir via iTunes/Files. |
| H-SEC-03 | `firebase_options.dart:50,60,68` | Firebase API keys hardcoded in tracked source file (distinct from google-services.json). |
| ~~H-SEC-04~~ | `socket_service.dart:96,106` | ~~Raw socket error payload sent to Crashlytics without sanitization.~~ **FIXED R20** — `_sanitizeForLog()` redacts JWTs and truncates to 200 chars before Crashlytics logging. |
| ~~H-SEC-05~~ | `app_config.dart:4` | ~~`env = 'stag'` hardcoded. Production build without `--dart-define=ENV=prod` silently uses staging.~~ **FIXED R20** — `env` now reads from `String.fromEnvironment('ENV', defaultValue: 'prod')`. Builds without `--dart-define` default to production. |
| ~~H-SEC-06~~ | `html_sanitizer_service.dart:80–105` | ~~Regex-based sanitizer. Missing SVG, MathML, `srcdoc` patterns. Known bypass vectors.~~ **FIXED R20** — Added `<svg>` (content + self-closing), `<math>` (content + self-closing), and `srcdoc` attribute stripping to sanitization pipeline. |

### Stripe

| ID | File | Issue |
|----|------|-------|
| H-STRIPE-01 | `subscription_notifier.dart:65` | `cancelMembership()` uses HTTP GET for destructive action. Should be POST. |
| ~~H-STRIPE-02~~ | `profile_model.dart:64` | ~~No subscription status enum beyond binary `isSubscribed`. Lapsed paid accounts get no recovery prompt.~~ **FIXED R20** — Added `SubscriptionStatus` enum (`lib/model/subscription_status.dart`) with `active`, `freeActive`, `freeExpired`, `lapsed`, `none` states derived from existing fields. `LoginModel.User.subscriptionStatus` getter + `SubscriptionNotifier.subscriptionStatus`. `isLapsed` helper enables recovery prompts. 15 unit tests. |

### Platform

| ID | File | Issue |
|----|------|-------|
| H-PLAT-01 | `MainActivity.kt:41–111` | `debugPasskeyInfo()` logs SHA-256 fingerprints on every `onCreate` in all flavors including production. |
| ~~H-PLAT-02~~ | `AndroidManifest.xml:11–12` | ~~`FOREGROUND_SERVICE_DATA_SYNC` declared with no `<service>` element. API 34+ crash risk.~~ **FIXED R20** — Removed orphaned `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_DATA_SYNC` permissions. No code, Kotlin class, or plugin uses foreground services. |

### Performance

| ID | File | Issue |
|----|------|-------|
| H-PERF-01 | 6 files (see [Perf Deep-Dive](#10-performance-deep-dive)) | `ref.watch()` without `.select()` on 45+-field state objects. Full list rebuild on any state change. |
| ~~H-PERF-02~~ | `email_list.dart:293` + 2 more | ~~`htmlReplaceString()` runs 10+ regex passes per row per rebuild. Not cached.~~ **FIXED R20** — Static LRU cache (200 entries, quarter-eviction) inside `HtmlSanitizerService`. All 3 call sites benefit with zero caller changes. Cache cleared on logout. |
| ~~H-PERF-03~~ | `notification_service.dart:140` | ~~`Future.delayed(Duration(seconds: 2))` before notification navigation. Unconditional.~~ **FIXED R20** — Replaced with `_waitForAuthReady()` that polls `authProvider.isInitialized` every 100ms (3s max). Instant when app is warm. |
| H-PERF-04 | `native_app_html_view_native.dart:266` | 3 timed retries (300ms, 1s, 2.5s) for WebView height — 3.8s of potential reflows. |

### Architecture

| ID | File | Issue |
|----|------|-------|
| H-ARCH-01 | `inbox_notifier.dart` | 2377-line god notifier with 10 responsibilities. See `docs/REFACTOR.md` P1-1. |
| H-ARCH-02 | `archive_list_notifier.dart` | 3205-line god notifier. Same pattern. |

---

## 3. Medium Issues

### Security

| ID | File | Issue |
|----|------|-------|
| M-SEC-01 | `view_email.dart:1609–1616` + 83 more | ~84 bare `debugPrint` calls active in release builds. Includes signed S3 URLs and API payloads. |
| M-SEC-02 | `platform_secure_storage_web.dart:71` | Bare `print()` logs decryption failure with key name in release web builds. |
| M-SEC-03 | `auth_notifier.dart:106–107` | Raw user ID sent to Firebase Analytics + Crashlytics without consent dialog. |

### Platform

| ID | File | Issue |
|----|------|-------|
| M-PLAT-01 | `Info.plist` | `UISupportedInterfaceOrientations` (iPhone) key missing — only iPad variant present. |
| M-PLAT-02 | `web/index.html` | No `<meta name="viewport">` tag. Mobile web renders at desktop width. |
| M-PLAT-03 | `web/index.html:19` | CSP `frame-src` includes `http://localhost:3000` — dev leftover. |
| M-PLAT-04 | `web/index.html:14` | CSP `script-src` missing `https://js.stripe.com`. |
| M-PLAT-05 | `web/index.html:23` | Meta description is internal developer notes, not marketing copy. |
| M-PLAT-06 | `web/manifest.json:9` | `orientation: portrait-primary` blocks desktop PWA landscape. |

### Stripe

| ID | File | Issue |
|----|------|-------|
| M-STRIPE-01 | `payment_method_notifier.dart:151` | 30s add-card timeout clears spinner silently with no user message. |
| M-STRIPE-02 | `stripe_url_validator.dart:16` | Validator allows app's own API domain as "valid Stripe URL". |

### UX

| ID | Screen | Issue |
|----|--------|-------|
| ~~M-UX-01~~ | `app_navigation_bar.dart:24` | ~~Bottom nav defaults to index 0 (Inbox highlighted) on unmatched routes like /settings.~~ **FIXED R20** — Icon color now uses `hasMatch && selectedIndex == N` so no tab highlights on unmatched routes. |
| ~~M-UX-02~~ | `shell_layout.dart:518` | ~~`toolbarHeight: isMobile ? 48 : 48` — both branches identical. Dead conditional.~~ **FIXED R20** — Replaced with plain `toolbarHeight: 48`. |
| M-UX-03 | Auth screens | No progress indicator across multi-step signup flow. |
| M-UX-04 | Email list | Timestamps always show full date, never relative ("5 min ago"). |
| ~~M-UX-05~~ | Settings | ~~No dark mode toggle despite full dark color system in `AppColorsExtension`.~~ **FIXED** — `_ThemeModeSelector` (system/light/dark segmented control) added to mobile, tablet, and desktop settings layouts. Persisted via `themeModePref` in secure storage + AppCache. |
| M-UX-06 | OTP | No OTP expiry countdown displayed. |
| M-UX-07 | `descope_error_mapper.dart` | Only 4 Descope error codes mapped. Rate-limit, passkey errors show generic message. |

### Performance

| ID | File | Issue |
|----|------|-------|
| ~~M-PERF-01~~ | `archive_responsive.dart:415` | ~~`ref.listen` without `.select()` in `build()` — fires on every state mutation.~~ **FIXED R20** — Added `.select((s) => (s.selectedEmailIds.isNotEmpty, s.showCheckboxes))` so listener only fires when relevant fields change. |
| M-PERF-02 | `view_email.dart:2486` | `getUserData()` reads from SecureStorage instead of in-memory `authProvider.userData`. |
| ~~M-PERF-03~~ | `native_app_html_view_native.dart:57–134` | ~~HTML sanitization runs synchronously on main thread. 50–200ms for large emails.~~ **FIXED (PC-04)** — `_builtHtml ??=` cache already ensures sanitization runs once per widget lifecycle. |

---

## 4. Low Issues

| ID | Category | File | Issue |
|----|----------|------|-------|
| ~~L-01~~ | Platform | `pubspec.yaml:21` | ~~Version `1.0.6+35` but branch is `1.0.7`.~~ **FIXED** — Version now `1.0.7+1`, matches branch. |
| L-02 | Platform | `web/manifest.json:3` | `start_url: "."` should be `"/"`. |
| L-03 | Platform | `styles.dart:82–83` | `radiusL` and `radiusXL` both `8.0` — identical, misleading. |
| L-04 | UX | global | Only ~20 `Semantics` uses across entire codebase. Accessibility very sparse. |
| L-05 | UX | `styles.dart:117` | `appBarGradient` hardcoded light colors — dark mode AppBar may appear flat. |
| L-06 | UX | `select_plan.dart:143` | "Step 3/4" hardcoded instead of parameterized. |
| L-07 | Security | `platform_secure_storage_web.dart:36–53` | Silent plaintext fallback on non-HTTPS origins. |
| ~~L-08~~ | Security | `auth_notifier.dart:106` | ~~`Crashlytics.setUserIdentifier()` missing `!kIsWeb` guard.~~ **FIXED R20** — Added `if (!kIsWeb)` guard on both set and clear paths. |
| ~~L-09~~ | State | `view_email.dart:683` | ~~`addPostFrameCallback` → `setAppBarConfig` → parent rebuild loop risk.~~ **FIXED R20** — `_lastAppBarConfigKey` dedup guard skips redundant `setAppBarConfig` calls, breaking the rebuild loop. |
| L-10 | Platform | `web/manifest.json:5` | Description still "A new Flutter project." |

---

## 5. Top 20 Priority Fixes

| # | ID | Fix | Impact | Effort |
|---|-----|-----|--------|--------|
| 1 | C-SEC-02 | `git rm --cached` keystore + credentials. Rotate keystore. | Signing identity protection | 1 hr |
| 2 | C-SEC-03 | `git rm --cached` 7 Firebase files. Uncomment `.gitignore`. | Credential exposure | 30 min |
| 3 | C-SEC-01 | Remove JWT from compose URL — use headers (mobile) / OTT (web) | Session hijacking prevention | Medium |
| 4 | H-PERF-01 | Add `.select()` to 6 provider watch sites | Eliminates scroll jank | 2 hrs |
| ~~5~~ | ~~H-PERF-02~~ | ~~Memoize `htmlReplaceString()` per email ID~~ | ~~List render perf~~ | **DONE** |
| ~~6~~ | ~~H-PERF-03~~ | ~~Replace 2s notification delay with auth-ready poll~~ | ~~Faster notification tap~~ | **DONE** |
| 7 | H-PLAT-01 | Remove `debugPasskeyInfo()` from MainActivity.kt | Info leak in logcat | 5 min |
| 8 | H-SEC-05 | Drive `env` from `--dart-define`, not hardcoded | Prevent staging-in-prod | 15 min |
| 9 | M-PLAT-02 | Add viewport meta tag to `web/index.html` | Mobile web usable | 1 min |
| 10 | M-SEC-01 | Wrap ~84 bare `debugPrint` in `if (kDebugMode)` | Stop release logging | 1 hr |
| 11 | H-STRIPE-01 | Change cancel subscription from GET to POST | REST/idempotency | 2 min |
| 12 | H-SEC-02 | Set `UIFileSharingEnabled=false` or move attachments | Privacy | 5 min |
| ~~13~~ | ~~H-PLAT-02~~ | ~~Verify merged manifest has `foregroundServiceType`~~ | ~~API 34+ crash prevention~~ | **DONE** |
| 14 | M-PLAT-03 | Remove `http://localhost:3000` from CSP | Security | 1 min |
| 15 | M-PERF-02 | Replace secure storage read with `authProvider.userData` | Faster email open | 5 min |
| ~~16~~ | ~~H-SEC-06~~ | ~~Add SVG, MathML, srcdoc to HTML sanitizer regex~~ | ~~XSS gap~~ | **DONE** |
| ~~17~~ | ~~M-UX-01~~ | ~~Fix bottom nav highlighting on unmatched routes~~ | ~~Nav clarity~~ | **DONE** |
| 18 | M-PLAT-05 | Replace dev-note meta description with marketing copy | SEO/sharing | 5 min |
| 19 | C-ARCH-01 | Sliding-window pagination for inbox | OOM prevention | Large |
| ~~20~~ | ~~H-SEC-04~~ | ~~Sanitize socket error data before Crashlytics log~~ | ~~Data minimization~~ | **DONE** |

---

## 6. Platform Release Checklists

### iOS
- [ ] Set `UIFileSharingEnabled=false` or scope to non-sensitive directory
- [ ] Add `NSURLIsExcludedFromBackupKey` to attachment directory
- [ ] Add explicit `UISupportedInterfaceOrientations` for iPhone
- [ ] Verify Apple has granted `com.apple.developer.mail-client` entitlement
- [ ] `git rm --cached` all `GoogleService-Info.plist` files
- [ ] Verify `aps-environment = production` in release entitlements
- [ ] Bump version to match branch (1.0.7)

### Android
- [ ] `git rm --cached android/key/optmsg.jks android/key/credentials android/gradle.properties`
- [ ] Rotate keystore with strong password
- [ ] Remove `debugPasskeyInfo()` from MainActivity.kt
- [x] ~~Verify merged manifest has `foregroundServiceType` for FOREGROUND_SERVICE~~ **FIXED R20** — orphaned permissions removed entirely
- [ ] `git rm --cached` all `google-services.json` files
- [ ] Bump version + build number in `pubspec.yaml`
- [ ] Drive `env` from `--dart-define=ENV=prod`

### Web
- [ ] Add `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- [ ] Remove `http://localhost:3000` from CSP `frame-src`
- [ ] Add `https://js.stripe.com` to CSP `script-src`
- [ ] Replace meta description with marketing copy
- [ ] Change manifest `orientation` to `any`
- [ ] Update manifest description
- [ ] Uncomment `*google-services.json` and `*firebase_options.dart` in `.gitignore`

---

## 7. Architecture Extensibility Roadmap

See `docs/REFACTOR.md` for the detailed refactoring roadmap with 4 priority tiers. Top 5 changes:

1. **Add `.select()` to provider watches** (P0-1) — eliminates 55+ unnecessary rebuilds
2. **Split InboxNotifier** (2377 lines → orchestrator + 8 services) (P1-1)
3. **Split ArchiveNotifier** (3205 lines → same pattern) (P1-2)
4. **Extract common EmailListItemWidget** (P1-4) — ~1000 lines reduction
5. **Consolidate HTTP stacks** (ApiService + BaseAPIService → 1) (P1-3)

---

## 8. Security & Privacy Exception Register

| # | Exception | Risk | Mitigation | Remediation |
|---|-----------|------|------------|-------------|
| 1 | Firebase Analytics receives raw user ID | HIGH | None | Pre-launch: hash user ID or add consent dialog |
| 2 | Web CSP requires `unsafe-eval` | MED | `object-src 'none'`, `base-uri 'self'` | Flutter upstream nonce-based CSP |
| 3 | No certificate pinning | HIGH | Standard CA validation | Post-launch Sprint 1: public key pinning |
| 4 | Regex HTML sanitizer has bypass vectors | HIGH | 14 regex rules cover common vectors | Post-launch Sprint 2: DOM parser |
| 5 | Web secure storage: AES-GCM encryption | MED | WebCrypto AES-GCM-256 | Accepted for cross-tab Descope sessions |
| 6 | Attachments persist unencrypted on device | MED | Downloaded to temp directory | Post-launch: cleanup on dismiss + exclude from iCloud |
| 7 | Excel preview loads JS from CDN without SRI | MED | cdnjs.cloudflare.com (trusted) | Bundle xlsx.js as local asset |

---

## 9. Summary Scorecard

### Issues by Severity x Category

| Category | CRIT | HIGH | MED | LOW | Total |
|----------|------|------|-----|-----|-------|
| Security | 3 | 6 | 3 | 2 | 14 |
| Stripe | 0 | 2 | 2 | 0 | 4 |
| Platform | 0 | 2 | 6 | 3 | 11 |
| State/Perf | 1 | 4 | 3 | 1 | 9 |
| Architecture | 0 | 2 | 0 | 0 | 2 |
| UX/UI | 0 | 0 | 7 | 4 | 11 |
| **Total** | **4** | **16** | **21** | **10** | **51** |

### Trend

| Review | Total | CRIT | HIGH | MED | LOW | Notes |
|--------|-------|------|------|-----|-----|-------|
| R1 | 78 | 12 | 22 | 28 | 16 | Initial audit |
| R9 | 55 | 3 | 14 | 22 | 16 | Loading architecture fixed |
| R12 | 43 | 2 | 8 | 18 | 15 | `ref.mounted` eliminated |
| R17 | 33 | 2 | 1 | 14 | 16 | Auth solid, 27 fixes in one cycle |
| R18 | 164 | 11 | 46 | 61 | 46 | First comprehensive 8-domain audit |
| **R20** | **51** | **4** | **16** | **21** | **10** | **Post-UX overhaul. Auth 9.0. State 9.5.** |

**Key improvement R18→R20:**
- CRITs: 11 → 4 (7 resolved — C-AUTH-01/02, C-PLAT-01, C-STATE-01/02, C-UX-01/02)
- State Management: 27 issues → 0 (all 14 notifiers verified)
- Auth: 16 issues → 0 critical, architecture rated 9.0/10
- UX: 41 issues → 11 (M3 nav, shell AppBar, multi-select, tags, move)
- Total: 164 → 51 (−69% reduction)

---

## 10. Performance Deep-Dive

### User-Reported Symptoms → Root Causes

| Symptom | Root Cause | Fix ID |
|---------|-----------|--------|
| Slow email loading | Double `email/detail` fetch (Phase 2 TODO logged) | H-PERF-05 |
| Email not fully rendering | WebView height retries (300ms, 1s, 2.5s) | H-PERF-04 |
| Scroll jank | `ref.watch()` without `.select()` on 45+-field state | H-PERF-01 |
| Sluggish screen transitions | Full layout rebuild on any state mutation | H-PERF-01 |
| Slow notification tap | Unconditional 2-second delay | H-PERF-03 |

### Quick Wins (Low Risk, High Impact)

1. **H-PERF-03** — Replace 2s notification delay with auth-ready poll (30 min)
2. **M-PERF-02** — Use `authProvider.userData` instead of SecureStorage read in `view_email.dart` (5 min)
3. **H-PERF-01** — Add `.select()` to 6 highest-impact provider watch sites (2 hrs)
4. **H-PERF-02** — Memoize `htmlReplaceString()` per email ID in 3 list files (30 min)

### Full Performance Issue List

| ID | File | Line | Symptom | Severity |
|----|------|------|---------|----------|
| H-PERF-01 | 6 files | various | Full-state watch → unnecessary rebuilds | HIGH |
| H-PERF-02 | `email_list.dart` + 2 | 293 | Regex per row per rebuild | HIGH |
| H-PERF-03 | `notification_service.dart` | 140 | 2s delay on notification tap | HIGH |
| H-PERF-04 | `native_app_html_view_native.dart` | 266 | 3.8s of height reflows | HIGH |
| H-PERF-05 | `email_detail_notifier.dart` + `view_email.dart` | 57/193 | Double email/detail API fetch | MED |
| ~~M-PERF-01~~ | `archive_responsive.dart` | 415 | ~~`ref.listen` without `.select()` in build~~ **FIXED** | ~~MED~~ |
| M-PERF-02 | `view_email.dart` | 2486 | SecureStorage read delays socket init | MED |
| ~~M-PERF-03~~ | `native_app_html_view_native.dart` | 57 | ~~Sync HTML sanitization on main thread~~ **FIXED (PC-04)** | ~~MED~~ |
| L-PERF-01 | `view_email.dart` | 683 | AppBar config push → rebuild loop risk | LOW |
| L-PERF-02 | `inbox_notifier.dart` | 861 | Unbounded list growth (= C-ARCH-01) | HIGH |

---

## Appendix: Resolved from Prior Reviews

All items below were confirmed FIXED in R20 and are no longer tracked:

- C-AUTH-01: SessionRefreshMutex.isLoggedOut reset on OTP login
- C-AUTH-02: Diagnostic toast removed from passkey enrollment
- C-PLAT-01: Namespace changed to com.optmsg.mail
- C-STATE-01: EmailDetailNotifier._disposed reset in build()
- C-STATE-02: tag_email_list.dart mounted guards added
- C-UX-01: M3 NavigationBar implemented (was commented out)
- C-UX-02: Compose accessible via shell AppBar action
- All H-STATE-01 through H-STATE-09: _disposed guards on all 14 notifiers
- H-PERF-03 (R18): HTML sanitization cached via `_builtHtml ??=`
- All OTP navigation patterns: pushReplacement for signup, go for login
- `printLog` globally guarded by `kDebugMode` in logger.dart
- Dual URL system consolidated (end_point.dart → app_config.dart)
- FCM onTokenRefresh updates server
- Router redirect uses AppCache (not SharedPreferences)
- `ref.mounted` eliminated (0 instances, was 51)
- Freezed direct mutations eliminated (0 `.isRead =` assignments)

---

*Report generated by Claude Code — Review 20. See also: `docs/REFACTOR.md` and `docs/TOAST_NOTIFICATIONS.md`.*
