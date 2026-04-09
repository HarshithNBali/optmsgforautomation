# GL 1.0.6 Production Bug Fixes — Gap Analysis & Resolution Tracker

**Branch**: `optmsgApp-v1.0.7.ryan.uxui.test`
**Date**: 2026-03-29
**Source**: QA Report (31 bugs) from `Rel1.0.6_Production_Observations.csv`
**Reference Fix Branch**: `fix/stripe-web-routing-and-safari-passkeys`
**Merged Branch Audit**: `optmsg-v1.0.7.merged` (24 verified, 1 partial, 2 not fixed, 4 unconfirmed)

---

## Architecture Note

This branch uses `NotifierProvider` + `SessionRefreshMutex`. The fix branch used `StateNotifierProvider` + `TokenRefreshCoordinator`. Direct cherry-pick is not viable — all fixes must be manually adapted.

---

## Master Status Table

| Bug | Priority | Summary | Status on This Branch | Phase | Action |
|-----|----------|---------|----------------------|-------|--------|
| 1 | P0 | Passkey enrollment broken — Reader signup (Safari) | CODE OK — NEEDS MANUAL QA | 3 | SessionRefreshMutex + onDispose cleanup in place; test Safari iPhone reader signup |
| 2 | P0 | Passkey enrollment broken — Paid signup (Safari) | CODE OK — NEEDS MANUAL QA | 3 | Same as Bug 1; additionally test post-Stripe redirect passkey flow |
| 3 | P0 | Enable passkey in login goes to inbox | CODE OK — NEEDS MANUAL QA | 3 | LoginPostProcessor checks isSupported() + enrollment fresh each login; verify on Safari |
| 4 | P1 | Trash doesn't auto-refresh on socket new message | FIXED | 2 | Removed `_eventStreams.clear()` from `initSocket()`; removed `_refreshAndRetryLogin()` from connect_error handler |
| 5 | P1 | Contact detail shows stale data after edit | FIXED | 1 | Added `ref.invalidate(viewContactProvider)` after successful save |
| 6 | P1 | Compose page refresh — "Something went wrong" | CODE OK — NEEDS MANUAL QA | 3 | `!isInitialized` null-return in router prevents premature redirect; verify web refresh |
| 7 | P2 | No notification popup — profile edit (iOS native) | ALREADY RESOLVED | - | Permissions requested via Firebase Messaging separately |
| 8 | P2 | No notification popup — new message (iOS native) | ALREADY RESOLVED | - | Same as Bug 7 |
| 9 | P2 | Settings page icons misaligned | VERIFIED FIXED | 3 | Confirmed via manual QA — UX/UI modernization resolved alignment |
| 10 | P2 | Account page icons misaligned | VERIFIED FIXED | 3 | Confirmed via manual QA — same as Bug 9 |
| 11 | P2 | Archive/trash sidebar counts incorrect | FIXED | 5 | Added `unReadCount` socket event to `markSelectedAsUnread()` in archive_list_notifier |
| 12 | P2 | Help Center back button broken after refresh | VERIFIED FIXED | 5 | Confirmed via manual QA — router `!isInitialized` guard resolved |
| 13 | P1 | New card not shown without manual refresh (Safari) | FIXED | 4 | Pre-open popup synchronously via `preOpenTab()`; `addNewCard` navigates pending tab |
| 14 | P1 | Face/Touch ID not triggering on iOS app switch | FIXED | 4 | Removed `persistAcrossBackgrounding: true`; default `false` prevents iOS caching |
| 15 | P2 | Save with empty First Name allowed | ALREADY RESOLVED | - | DateFormat matches stored format (`MMMM dd, yyyy`) |
| 16 | P1 | Reading pane resets to ON after refresh | NEEDS BACKEND | 5 | Requires `POST /user/toggle-reading-pane` endpoint |
| 17 | P2 | Trash list auto-refreshes on back (loses scroll) | FIXED — NEEDS MANUAL QA | 5 | Removed unconditional `refresh()` from `_updateBadgeFromSocket`; added `PageStorageKey` to ListView |
| 18 | P0 | Blank black/blue screen when deleting in trash | FIXED | 1 | Added `backgroundColor: Theme.of(context).scaffoldBackgroundColor` to Scaffold |
| 19 | P1 | File size shows wrong unit (167KB → 163MB) | DEFERRED — BACKEND | 1 | App sends bytes correctly; backend must align storage/return values |
| 20 | P2 | White screen on browser back from Stripe | FIXED — NEEDS MANUAL QA | 5 | New-tab Stripe checkout via `openStripeCheckout()` + localStorage fallback + stale flag cleanup |
| 21 | P1 | Existing tags not shown with checkbox in popup | VERIFIED FIXED | 3 | Confirmed via manual QA — initState assignment works correctly |
| 22 | P1 | "Add to existing" in opt-in shows nothing | ALREADY RESOLVED | - | `skip_all` handled correctly |
| 23 | P0 | Reply/Reply-All/Forward not working | ALREADY RESOLVED | - | SecureStorageService is singleton via factory |
| 24 | P1 | Tags not applied to multi-selected (non-inbox) | ALREADY RESOLVED | - | RequestType enum lowercase + consistent |
| 25 | P1 | Tags can't be removed from message list | ALREADY RESOLVED | - | Same as Bug 24 |
| 26 | P2 | Sidebar counts disappear after web refresh | VERIFIED FIXED | 5 | Confirmed via manual QA — router `!isInitialized` guard resolved |
| 27 | P1 | Web app freezes after backgrounding | FIXED | 2 | Added `kIsWeb` branch with `http.head()` in `NetworkService.hasInternet()` |
| 28 | P1 | "Something went wrong" on 3-dots in archive/trash | VERIFIED FIXED | 3 | Confirmed via manual QA — redesigned 3-dots menu resolved the issue |
| 29 | P2 | "Move to sent" via archive swipe not working | FIXED | 5 | Swipe 'Sent' mapped to `isSent` instead of `isArchive` in custom_dismissible.dart |
| 30 | P2 | Move sent → archive returns HTTP 500 | ALREADY RESOLVED | - | RequestType enum consistent |
| 31 | P2 | Search bar auto-opens after inbox refresh | FIXED | 1 | Removed initState listener; icon derived from controller text in build() |

---

## Phase 1 — Low-Risk Standalone Fixes

### Bug 18 — Blank Screen When Deleting in Trash (P0)
- **Status**: NOT FIXED
- **Root Cause**: `Scaffold` in `custom_dismissible.dart:617` has no `backgroundColor`. During list rebuild after delete, the raw dark Scaffold background flashes for 1-2 frames.
- **Fix**: Add `backgroundColor: Colors.white` (or theme background) to the Scaffold.
- **File**: `lib/widgets/custom_dismissible.dart:617`
- **Test Platforms**: iPhone web, iPhone native, Android web, Android native
- **Regression Test**: `test/regression/gl_106_regression_test.dart` — verify Scaffold has backgroundColor

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

### Bug 19 — File Size Shows Wrong Unit (P1)
- **Status**: APP CODE CORRECT — NEEDS BACKEND FIX
- **Root Cause**: `web_compose.dart` correctly sends raw bytes as `'size': fileLength`. The display formatter `CommonService().formatFileSize(int bytes)` (common_service.dart:614) correctly converts bytes → KB/MB. The bug is on the **backend**: the server likely interprets the `size` field as KB (legacy expectation from the old app) and stores/returns an inflated value. When the client calls `formatFileSize()` on the server-returned value, 167KB appears as 163MB.
- **App Fix**: None needed — sending raw bytes and displaying with `formatFileSize(bytes)` is the correct architecture.
- **Backend Fix Required**:
  1. Update API to store `size` as raw bytes (stop any KB→bytes multiplication)
  2. Database migration: `UPDATE attachments SET size = size * 1024 WHERE size < [threshold]` to convert existing KB values to bytes (or the inverse if the server is multiplying)
  3. Document that `size` field is in bytes
- **File**: `lib/screens/compose/web_compose.dart` — lines 1262, 1273, 1352, 1363 (all correct, sending bytes)
- **Display**: `lib/screens/inbox/view_email.dart:3339` calls `formatFileSize(attachment.size)` (correct, expects bytes)
- **Formatters**: `common_service.dart:614` `formatFileSize(int bytes)` and `:630` `composeFormatFileSize(int sizeInBytes)` — both correctly handle bytes
- **Test Platforms**: All platforms — verify after backend migration
- **Blocked By**: Backend API + database migration

**Resolution**: [ ] Fixed | [x] Deferred — Waiting on Backend
**Notes**: App sends raw bytes, formatters expect bytes. Backend needs to align.

---

### Bug 31 — Search Bar Auto-Opens After Inbox Refresh (P2)
- **Status**: NOT FIXED
- **Root Cause**: `search_bar.dart:31` adds `widget.controller?.addListener(_syncIcon)` in `initState()`. On web refresh, controller may retain previous text, causing `_syncIcon` to fire and render the search bar in expanded/active state.
- **Fix**: Remove `addListener(_syncIcon)` from `initState()`, remove `_syncIcon()` method, remove `dispose()` cleanup. The icon state should be derived from controller text directly in `build()`.
- **File**: `lib/widgets/search_bar.dart:29-45`
- **Test Platforms**: iPhone web, Android web, large-web
- **Regression Test**: Verify no controller listener in initState

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

### Bug 5 — Contact Detail Shows Stale Data After Edit (P1)
- **Status**: NOT FIXED
- **Root Cause**: After `edit_contact_notifier.dart` saves a contact successfully, it does not invalidate `viewContactProvider`. The view screen reuses cached state instead of fetching fresh data.
- **Fix**: Add `ref.invalidate(viewContactProvider)` after successful save in `updateContact()`.
- **File**: `lib/screens/contacts/edit_contact_riverpod/edit_contact_notifier.dart`
- **Test Platforms**: iPhone web (primary), all platforms
- **Regression Test**: Verify invalidation call exists after save

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

## Phase 2 — Socket & Network Fixes

### Bug 4 — Trash Doesn't Auto-Refresh on Socket New Message (P1)
- **Status**: NOT FIXED
- **Root Cause**: `socket_service.dart:39` calls `_eventStreams.clear()` inside `initSocket()` on reconnect. This closes all StreamControllers, orphaning active subscriptions in notifiers (inbox, archive, trash). Socket events are silently dropped after reconnect.
- **Fix**: Remove the `_eventStreams.clear()` block (lines 36-39) from `initSocket()`. Keep socket disposal (lines 33-35) but let stream controllers persist across reconnects.
- **Also**: Remove `_refreshAndRetryLogin()` method and its `connect_error` handler call — the retry-login pattern causes unwanted auth state churn.
- **File**: `lib/services/socket_service.dart:31-39` (clear block), `:93-100` (connect_error handler), `:215-232` (_refreshAndRetryLogin)
- **Test Platforms**: All platforms — test trash, inbox, archive receive socket events after reconnect
- **Regression Test**: Verify `_eventStreams.clear()` is not called in `initSocket()`

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

### Bug 27 — Web App Freezes After Backgrounding (P1)
- **Status**: NOT FIXED (shares root cause with Bug 4)
- **Root Cause**: `network_service.dart:34` uses `InternetAddress.lookup('google.com')` which is not available in web browsers — throws an exception. `hasInternet()` returns `false`, causing all API calls to return early. Combined with Bug 4's socket stream clearing, the web UI appears completely frozen after tab resume.
- **Fix**: Add a web-specific reachability check using `http.head()` instead of DNS lookup when `kIsWeb` is true.
- **File**: `lib/common/utilites/network_service.dart`
- **Dependency**: Also fix Bug 4 (socket streams) for full resolution
- **Test Platforms**: iPhone web, Android web, large-web — background tab for 30+ seconds, then return
- **Regression Test**: Verify web path uses HTTP head, not DNS lookup

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

## Phase 3 — Verification Pass

### Bugs 1 & 2 — Passkey Enrollment Not Working at Signup (P0)
- **Status**: NEEDS VERIFICATION
- **Context**: On the fix branch, the root cause was:
  1. Provider was `NotifierProvider` (not autoDispose) — stale `isEnabled = true`
  2. After Stripe redirect, `session.refreshJwt` was stale/null — passkey.add() failed
  3. `SessionRefreshMutex.passkeyFlowInProgress` could get stuck after exception
  4. `_handleNavigation()` read null `widget.pageKey` post-Stripe redirect
- **Current Branch**: Uses `NotifierProvider` (same as buggy version). Has `SessionRefreshMutex.passkeyFlowInProgress` with cleanup in `onDispose`. Has `_initCompleter` to prevent concurrent init. No explicit session recovery/retry loop.
- **Verification Steps**:
  1. Test on iPhone Safari: Reader signup → Enable Passkey → should prompt for passkey (not skip to Congrats)
  2. Test on iPhone Safari: Paid signup → Stripe payment → Enable Passkey → should work without "something went wrong"
  3. If either fails, port the session recovery + retry logic from the fix branch, adapted for `NotifierProvider` + `SessionRefreshMutex`
- **Files**: `lib/screens/auth/passKey/passkey_notifier.dart`, `lib/screens/auth/passKey/add_pass_key.dart`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 3 — Enable Passkey in Login Goes Directly to Inbox (P0)
- **Status**: NEEDS VERIFICATION
- **Context**: The merged branch audit says NOT FIXED. On the fix branch, the root cause was stale `AppCache().hasPasskeyEnrolled` flag from a previous session.
- **Current Branch**: Uses `LoginPostProcessor.goToAddPassKeyIfNeeded()` which checks:
  1. `authState.userData?['user']?['webauthn'] == true` → skip (already enrolled)
  2. `SecureStorageService().readData('hasPasskeyEnrolled') == 'true'` → skip
  3. `Descope.passkey.isSupported()` → if not supported, skip
  4. Both conditions met → navigate to AddPassKey
- **Key Question**: Does the secure storage `hasPasskeyEnrolled` flag persist incorrectly from a previous session? If `clearSession()` doesn't clear this flag, it would cause the bug.
- **Verification Steps**:
  1. Login → OTP → click "Enable Passkey" → should show passkey dialog, NOT go to inbox
  2. If it goes to inbox, check whether `hasPasskeyEnrolled` is being cleared on logout
- **Files**: `lib/screens/auth/login_post_processor.dart`, `lib/screens/auth/enterOtp/otp_screen.dart`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 6 — Compose Page Refresh Shows "Something Went Wrong" (P1)
- **Status**: NEEDS VERIFICATION
- **Context**: On the fix branch, the fix was to add `if (!isInitialized) return AppRoutes.splash;` as first redirect check.
- **Current Branch**: `app_router.dart:141` has `if (!isInitialized) return null;` — returns null (no redirect) instead of redirecting to splash. This prevents premature redirect to `/login` but doesn't show a splash screen during init.
- **Verification Steps**:
  1. Login → navigate to Inbox → refresh page → should NOT show "Something went wrong"
  2. Test on Archive, Sent, Trash, Compose pages too
  3. If the null-return approach works, no splash screen is needed
- **Files**: `lib/router/app_router.dart:141`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bugs 9 & 10 — Settings & Account Page Icons Misaligned (P2)
- **Status**: NEEDS VERIFICATION
- **Context**: The fix branch removed `AnimatedContainer` route indicator, `Semantics` wrapper, and changed `ColorFilter.mode(...)` to `color:` directly on SVG.
- **Current Branch**: Still has `AnimatedContainer` + `Semantics` + `ColorFilter.mode(...)` in `drawer_item.dart`. However, this branch has extensive UX/UI modernization that may have resolved the visual alignment independently.
- **Verification Steps**:
  1. Open Settings page — check icon/text alignment across all rows
  2. Open Account page — same check
  3. Test on all screen sizes (mobile, tablet, desktop)
  4. If misaligned, apply the fix: remove AnimatedContainer, remove Semantics, use `color:` on SVG
- **Files**: `lib/widgets/drawer_item.dart`, `lib/screens/settings/settings_mobile_layout.dart`, `lib/screens/settings/account_mobile_layout.dart`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 21 — Existing Tags Not Shown With Checkbox in Popup (P1)
- **Status**: PARTIALLY FIXED
- **Context**: Fix branch wrapped `selectedTagIds` assignment in `setState()` in `initState()`.
- **Current Branch**: `pop_up_modal_tag_list.dart:73-76` assigns `selectedTagIds` directly in `initState()` without `setState()`. However, since `initState()` runs before the first `build()`, the assignment should be available when `build()` runs. The `addPostFrameCallback` at line 80 also calls `widget.callback!(selectedTagIds)` after frame.
- **Verification Steps**:
  1. Login → Sent folder → select a message with multiple tags → click Tags in header
  2. Verify existing tags show checkmarks
  3. If not showing, wrap assignment in `setState()`
- **File**: `lib/widgets/pop_up_modal_tag_list.dart:71-84`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 28 — "Something Went Wrong" on 3-Dots in Archive/Trash Detail (P1)
- **Status**: PARTIALLY FIXED / LIKELY RESOLVED
- **Context**: Fix branch used `List<Widget>.from(actions)` before `.insert()` to avoid mutating an immutable list.
- **Current Branch**: `gradient_appbar.dart` does NOT exist on this branch. The 3-dots menu has been redesigned as part of UX/UI modernization. The `shell_layout.dart` uses actions but constructs lists differently.
- **Verification Steps**:
  1. Open Archive → open a message → click 3-dots in header
  2. Open Trash → same test
  3. Dropdown options should appear without error
- **File**: N/A (redesigned)

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

## Phase 4 — Auth/Safari/Stripe Fixes

### Bug 14 — Face/Touch ID Not Triggering on iOS App Switch (P1)
- **Status**: NOT FIXED
- **Root Cause**: `biometric_service.dart:44` uses `persistAcrossBackgrounding: true` which causes iOS to cache the biometric result. Subsequent calls in the same session return cached `true` without prompting.
- **Current Branch Impact**: The branch has a sophisticated biometric lock system with `_justAuthenticatedAt` (5s grace), `_permissionDialogStartedAt` (30s grace), and `_isBiometricEnabled` cache. The `persistAcrossBackgrounding: true` is the core issue — removing it won't break the grace period system since that's handled independently in `_checkAndLockIfNeeded()`.
- **Fix**:
  1. `biometric_service.dart`: Remove `persistAcrossBackgrounding: true`, add `options: const AuthenticationOptions(useErrorDialogs: true, stickyAuth: true)`
  2. Verify `_checkAndLockIfNeeded()` in main.dart still works correctly (it should — it reads biometric setting from storage, not from the cached result)
- **Files**: `lib/services/biometric_service.dart:42-44`
- **Test Platforms**: iOS native only
- **Test Steps**: Enable biometric → switch to another app → wait 5 seconds → return → should prompt for biometric

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

### Bug 13 — New Card Not Shown Without Manual Refresh — Safari (P1)
- **Status**: NOT FIXED
- **Root Cause**: Safari blocks `window.open()` calls that don't originate from a direct user gesture synchronously. `payment_method_notifier.dart` opens the Stripe popup after async operations (URL fetch), so Safari blocks it. The `_addCardTimeout` timer fallback leaves user with spinner.
- **Fix**:
  1. Open a blank popup synchronously in the button's `onPressed` handler (before any async)
  2. After async URL fetch completes, navigate the pre-opened popup to the Stripe URL
  3. Remove `_addCardTimeout` timer
- **Files**:
  - `lib/screens/subscription/change_payment/payment_method_notifier.dart` — rework `addCard()` flow
  - `lib/webPackerHandler/web_check_out.dart` — update `addNewCard()` to accept pre-opened window
- **Test Platforms**: Safari iOS, Safari macOS (popup timing is fragile)
- **Note**: `web_check_out.dart` already has a `preOpenTab()` method — investigate if it can be leveraged

**Resolution**: [ ] Fixed | [ ] Not Applicable | [ ] Deferred
**Notes**:

---

## Phase 5 — Investigation & Backend

### Bug 12 — Help Center Back Button Broken After Refresh (P2)
- **Status**: LIKELY AUTO-RESOLVED
- **Context**: Fix branch changed `HelpCenterNotifier` from `autoDispose` to non-autoDispose, and relied on the splash guard fix.
- **Current Branch**: `help_center_notifier.dart:5-6` uses `NotifierProvider.autoDispose` — the autoDispose pattern. This means the notifier disposes and rebuilds on deep navigation, potentially losing state.
- **Dependency**: This is likely resolved if Bug 6 (router splash guard / `!isInitialized` null-return) works correctly. Verify Bug 6 first.
- **If Still Broken**: Change from `NotifierProvider.autoDispose` to `NotifierProvider` (remove `.autoDispose`).
- **File**: `lib/screens/helpCenter/help_center_notifier.dart:5-6`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 26 — Sidebar Counts Disappear After Web Refresh (P2)
- **Status**: LIKELY AUTO-RESOLVED
- **Context**: Shares root cause with Bug 6 — no splash guard means sidebar count provider rebuilds before auth is restored.
- **Dependency**: Re-test after Bug 6 verification. If `!isInitialized` null-return prevents premature redirect, sidebar counts should survive refresh.
- **If Still Broken**: Need dedicated investigation of `count_notifier.dart` initialization timing.
- **File**: `lib/services/count_notifier.dart`

**Resolution**: [ ] Verified Working | [ ] Needs Fix | [ ] Deferred
**Notes**:

---

### Bug 17 — Trash List Auto-Refreshes on Back (Loses Scroll) (P2)
- **Status**: FIXED — NEEDS MANUAL QA
- **Root Cause**: `_updateBadgeFromSocket()` in `archive_list_notifier.dart:384-388` unconditionally called `refresh()` on every socket `unReadCount` response. When the user viewed a message (triggering read status updates), socket events fired → `refresh()` → full list reload → scroll position lost. The inbox notifier's version of this method does NOT call `refresh()` — the archive version was the outlier.
- **Fix Applied**:
  1. Removed `refresh()` from `_updateBadgeFromSocket()` — now only updates native app badge, matching inbox notifier pattern. Sidebar counts are updated centrally by `SocketService._updateCountNotifier()`.
  2. Added `PageStorageKey<String>('dismissible_${widget.emailType}')` to `ListView.builder` in `custom_dismissible.dart` as a safety net for scroll preservation across widget rebuilds. Moved `_listKey` (GlobalKey) to a `KeyedSubtree` wrapper to preserve drag-to-select `findRenderObject()` functionality.
- **Files Modified**: `lib/screens/email/archive_riverpod/archive_list_notifier.dart`, `lib/widgets/custom_dismissible.dart`
- **Manual QA Required**:
  1. Open Trash → scroll to ~70th message → tap to open → press back → verify scroll position preserved
  2. Repeat for Archive, Sent, Inbox lists
  3. Bug 11 regression: In archive, select messages → mark as unread → verify sidebar counts still update
  4. Pull-to-refresh still works in all folders
  5. Native iOS/Android: verify app badge updates after read/unread operations
  6. Web/desktop: drag-to-select multiple messages — should still work
  7. Multi-device: change from another device → verify list updates on manual refresh (not automatically — expected)

**Resolution**: [ ] Verified Working via Manual QA | [ ] Needs Further Fix
**Notes**:

---

### Bug 11 — Archive/Trash Sidebar Counts Incorrect (P2)
- **Status**: FIXED
- **Root Cause**: `markSelectedAsUnread()` in `archive_list_notifier.dart:2508-2510` called `updateInboxEmailStatus('isRead', ...)` which updated local state but did NOT emit the `unReadCount` socket event. Sidebar counts never received updated values. `markSelectedAsRead()` DID emit the event (lines 2592-2600) — only the unread path was missing.
- **Fix Applied**: Added `unReadCount` socket event emission after `updateInboxEmailStatus()` call in `markSelectedAsUnread()`, matching the pattern used in `markSelectedAsRead()`.
- **File Modified**: `lib/screens/email/archive_riverpod/archive_list_notifier.dart`

**Resolution**: [x] Fixed
**Notes**: Orange dot visibility (`email_list.dart:164-179`) depends on `isRead` flag in local state — this updates correctly. The sidebar count issue was the missing socket event.

---

### Bug 16 — Reading Pane Resets to ON After Refresh (P1)
- **Status**: NEEDS BACKEND ENDPOINT
- **Root Cause**: `toggleReadingPane()` in `settings_notifier.dart:214-231` writes only to `SecureStorageService` (local). On web refresh, `userData['user']['isReadingPane']` from the backend (default `true`) overwrites the local preference.
- **Current Branch**: Has a TODO comment (lines 208-212) acknowledging the need for a backend API endpoint.
- **Action Required**:
  1. **Backend team**: Create `POST /user/toggle-reading-pane` endpoint that persists the preference
  2. **Frontend**: Update `toggleReadingPane()` to call the API, then update local storage
  3. **Frontend**: Update `getUserData()` to read `isReadingPane` from user data response
- **File**: `lib/screens/settings/setting_riverpod/settings_notifier.dart:208-231`
- **Blocked By**: Backend endpoint creation

**Resolution**: [ ] Fixed | [ ] Deferred — Waiting on Backend
**Notes**:

---

### Bug 20 — White Screen on Browser Back from Stripe (P2)
- **Status**: FIXED — NEEDS MANUAL QA
- **Root Cause**: `loadRedirectCache()` in `app_cache.dart` read `isCheckout` from SecureStorage (sessionStorage on web) only. After cross-origin navigation to Stripe, sessionStorage is cleared. On browser back, `isCheckout` was null, the router recovery guard failed, and the user hit the unauthenticated guard → white screen.
- **Fix Applied** (two layers):
  1. **localStorage fallback** (`app_cache.dart`): `loadRedirectCache()` now falls back to SharedPreferences (localStorage) on web when sessionStorage is cleared. Mirrors the pattern already used in `ProcessingPaymentScreen`.
  2. **Stale flag cleanup** (`auth_notifier.dart`): Clears `isCheckout` from all storage layers when a subscribed user logs in, preventing false recovery triggers on subsequent sessions.
  3. **New-tab Stripe checkout** (architecture improvement): Added `openStripeCheckout()` method that opens Stripe in a new browser tab via `preOpenTab()` (same Safari-safe pattern as Bug 13). The Flutter app stays loaded, the socket-based payment confirmation (`checkout_notifier.dart:151-200`) becomes the primary path on web. Falls back to same-tab navigation if popup is blocked.
- **Files Modified**: `lib/common/app_manger/app_cache.dart`, `lib/screens/auth/auth_riverpod/auth_notifier.dart`, `lib/webPackerHandler/base_check_out.dart`, `lib/webPackerHandler/web_check_out.dart`, `lib/webPackerHandler/mobile_check_out.dart`, `lib/screens/subscription/checkout/check_out.dart`, `lib/screens/subscription/checkout/checkout_notifier.dart`
- **Manual QA Required**:
  1. Start paid signup → Pay Now → Stripe opens in new tab → complete payment → original tab shows success
  2. Safari iOS: same flow — verify popup opens (not blocked)
  3. Safari macOS: same flow
  4. Popup blocked scenario: disable popups in browser → Pay Now → should fall back to same-tab → browser back → should recover to checkout (not white screen)
  5. Complete payment → log out → log back in → should NOT trigger recovery flow
  6. Native iOS/Android: verify no change in behavior

**Resolution**: [ ] Verified Working via Manual QA | [ ] Needs Further Fix

#### Recommended Architecture Improvement — New-Tab Stripe Checkout

**Problem with current same-tab approach**: `window.location.href = stripeUrl` fully unloads the Flutter app. All in-memory state, socket connections, and timers are destroyed. The entire recovery infrastructure (localStorage fallbacks, ProcessingPaymentScreen, router guards, Safari ITP recovery) exists solely to recover from this self-inflicted state loss.

**The socket-based confirmation path already exists** (`checkout_notifier.dart:151-200`) and works perfectly on native apps. On web, it's killed when the app unloads.

**Recommended change**: Open Stripe Checkout in a **new browser tab** instead of same-tab navigation.

##### Frontend Changes

1. **`checkout_notifier.dart` `makePayment()`** (line 346):
   - Replace `CheckOutImp().navigateToUrl(url!)` with `CheckOutImp().preOpenTab()` (called synchronously in the button handler, just like Bug 13) + navigate the pre-opened tab to the Stripe URL
   - Remove all localStorage persistence code (lines 331-344) — no longer needed
   - Remove `_paymentTimeout` 5-minute fallback timer — socket handles it
   - The existing `paymentStatus` socket listener (line 151-200) becomes the **primary** confirmation path on web too
   - Add a polling fallback: if socket disconnects during payment, poll `verifyPayment()` every 30s

2. **`web_check_out.dart`**:
   - Add `openStripeCheckout(String url)` method that navigates the pre-opened tab to the Stripe URL (same pattern as `addNewCard` after Bug 13 fix)
   - Keep `closeWebWindow()` to close the Stripe tab after socket confirmation

3. **`checkout_screen.dart` / checkout button handler**:
   - Call `CheckOutImp().preOpenTab()` synchronously in `onPressed` before calling `notifier.makePayment()` (same Safari popup-blocker pattern as Bug 13)

4. **Remove or simplify `ProcessingPaymentScreen`**:
   - Still needed for the Stripe success/failure redirect URL (the tab that Stripe redirects to)
   - Simplify to just show "Payment confirmed, you can close this tab" message
   - OR: Configure Stripe success URL to a static HTML page hosted on your domain that says "Payment complete — return to the app"

5. **Remove `app_router.dart` Stripe recovery guards** (lines 155-227):
   - The synchronous Stripe param check (line 472-491) is still needed for the redirect tab
   - The Safari ITP recovery path and `isCheckout` localStorage checks become unnecessary

##### Backend Changes

1. **Configure Stripe Checkout success/cancel URLs**:
   - Success URL: `https://yourapp.com/payment-complete?session_id={CHECKOUT_SESSION_ID}` (a simple static page, not the Flutter app)
   - Cancel URL: `https://yourapp.com/payment-cancelled` (same — simple static page)
   - These pages tell the user to return to the app tab

2. **Optional but recommended — `GET /plan/payment-status`**:
   - Endpoint that accepts `session_id` and returns payment status from Stripe API
   - Frontend can poll this as a fallback if socket drops
   - More reliable than inferring payment from `user/get-profile` `isSubscribed` flag

##### Security Improvements

| Current | Proposed |
|---------|----------|
| `success=true` in URL params (client-trusting) | Socket event + server-side `verifyPayment()` (server-trusting) |
| localStorage `isCheckout` flag can be spoofed | No client-side flags needed — socket is authoritative |
| Multiple storage layers for one flag | Single in-memory socket state |
| ProcessingPaymentScreen trusts `recovered=true` param | No recovery needed — app never unloads |
| 5-minute blind timeout | Active polling with exponential backoff |

##### Why This Is Better

- **App never unloads** — no state loss, no storage recovery, no browser-back issues
- **Server-authoritative** — payment confirmed via socket + backend API, not URL params
- **Simpler code** — removes ~200 lines of recovery logic across 4 files
- **Safari-safe** — `preOpenTab()` pattern already proven with Bug 13
- **Native parity** — web and native use identical confirmation path (socket)
- **Browser back works** — user is still on the checkout screen, can see progress

##### Migration Path

1. Implement new-tab flow behind a feature flag (`useNewTabCheckout`)
2. Test thoroughly on Safari iOS, Safari macOS, Chrome, Firefox
3. Keep same-tab flow as fallback for popup-blocked scenarios
4. Once validated, remove same-tab path and recovery infrastructure

---

### Bug 29 — "Move to Sent" From Archive Via Swipe Not Working (P2)
- **Status**: FIXED
- **Root Cause**: `custom_dismissible.dart` line 464 had `status == 'Sent' ? 'isArchive' : 'is$status'` — the "Sent" swipe action was incorrectly mapped to `isArchive` instead of `isSent`. Same bug in the `dispose()` fallback at line 510.
- **Fix Applied**: Changed both occurrences to `status == 'Sent' ? 'isSent' : 'is$status'`.
- **File Modified**: `lib/widgets/custom_dismissible.dart`

**Resolution**: [x] Fixed
**Notes**:

---

## Already Resolved — No Action Needed

### Bug 7 & 8 — iOS Push Notifications Not Working (P2)
- **Confirmed**: `notification_service.dart:107-109` sets `requestAlertPermission/Badge/Sound: false` intentionally. Permissions are requested separately via `_requestPermissions()` using Firebase Messaging (line 96). `onBackgroundMessage` is registered in `main()` at line 99 before `runApp()`.
- **Why resolved**: The permission delegation approach avoids duplicate prompts while still granting notification permissions through Firebase Messaging's own request flow.

### Bug 15 — Contact Edit Allows Saving With Empty Mandatory Fields (P2)
- **Confirmed**: `form_validation.dart:76` uses `DateFormat('MMMM dd, yyyy')` and `profile_notifier.dart:283` outputs `DateFormat('MMMM dd, yyyy')` — formats match. The validation chain runs completely, catching empty First Name.

### Bug 22 — "Add to Existing" in Opt-in Shows Nothing (P1)
- **Confirmed**: `email_sender_service.dart:110-113` properly handles `skip_all` result with early return and `triggerEmail()` call. The recursive loop pattern is correct.

### Bug 23 — Reply/Reply-All/Forward Not Working (P0)
- **Confirmed**: `email_sender_service.dart:16` creates `final _storage = SecureStorageService()`. `SecureStorageService` uses a factory constructor (singleton pattern) — all instances share the same underlying storage, avoiding the web localStorage key prefix mismatch.

### Bugs 24, 25, 30 — RequestType Enum Casing Issues (P1/P2)
- **Confirmed**: `base_api_service.dart:18` defines `enum RequestType { get, post, delete, patch, put }` (lowercase). `tag_api.dart` and `archive_api.dart` both use lowercase consistently. No casing mismatch.

---

## Dependency Map

```
Bug 4 (socket) ──────── required by ─── Bug 27 (web freeze)
Bug 6 (compose refresh) ── likely fixes ── Bug 12 (help center back)
Bug 6 (compose refresh) ── likely fixes ── Bug 26 (sidebar counts refresh)
Bug 24/25/30 (RequestType) ── may fix ──── Bug 29 (archive swipe)
Bug 28 (3-dots crash) ───── may fix ──── Bug 29 (archive swipe)
Bug 14 (biometric) ──────── independent
Bug 13 (Stripe popup) ──── independent
Bug 16 (reading pane) ──── blocked by backend
```

---

## Dev Team TODOs (Backend/Infrastructure)

1. **Backend**: Create `POST /user/toggle-reading-pane` endpoint (Bug 16)
2. **QA**: Manual verification needed for Bugs 1, 2, 3, 6, 9, 10, 21, 28 on Safari iOS + all platforms
3. **QA**: Dedicated investigation for Bugs 11, 17, 20, 29
4. **Infrastructure**: Confirm `.well-known/` passkey AASA files are deployed correctly for Safari enrollment (Bugs 1, 2)
