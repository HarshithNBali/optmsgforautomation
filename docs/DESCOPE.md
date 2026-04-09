# Descope Authentication & Session Management

Developer reference for the OptMsg app's authentication architecture. This document covers the complete auth flow, session token lifecycle, refresh mechanisms, concurrency guards, and how they intersect with other app-level systems (biometrics, connectivity, sockets, privacy overlay).

---

## Table of Contents

1. [Auth Architecture Overview](#1-auth-architecture-overview)
2. [Session Lifecycle](#2-session-lifecycle)
3. [Token Refresh Flow](#3-token-refresh-flow)
4. [401 Recovery Flow](#4-401-recovery-flow)
5. [HTTP Service Layers](#5-http-service-layers)
6. [Socket Authentication](#6-socket-authentication)
7. [App Lifecycle & Session](#7-app-lifecycle--session)
8. [Intersections with Adjacent Systems](#8-intersections-with-adjacent-systems) — Biometric, Connectivity, Passkey, Privacy
9. [Login & Logout Flows](#9-login--logout-flows)
10. [Concurrency Guards](#10-concurrency-guards)
11. [Troubleshooting Guide](#11-troubleshooting-guide)
12. [Logout Rules — When to Log Out](#12-logout-rules--when-to-log-out)
13. [Descope SDK Internals (v0.9.18)](#13-descope-sdk-internals-v0918)
14. [Storage Architecture & Logout Lifecycle](#14-storage-architecture--logout-lifecycle) — AppCache, SecureStorage, Platform Storage, Logout Sequence, Re-Login Restoration

---

## 1. Auth Architecture Overview

### Provider: Descope

- **SDK**: `descope` Flutter package
- **Project setup**: `Descope.setup(projectId)` in `main.dart` before `runApp()`
- **Session manager**: `Descope.sessionManager` — handles token storage, refresh, and persistence

### Two-Token System

| Token | TTL | Purpose | Storage |
|-------|-----|---------|---------|
| **Session JWT** | 10 minutes | Authenticates every API request and socket connection | In-memory + Keychain (iOS) / EncryptedSharedPreferences (Android) |
| **Refresh Token** | 4 weeks | Obtains new session JWTs when they expire | Same secure storage |

### Key Design Principle

**Token refresh is invisible to the user.** Users should never see error toasts, loading states, or "session expired" messages unless the 4-week refresh token has genuinely expired or the backend has revoked their session.

### Key Files

| File | Role |
|------|------|
| `lib/main.dart` | App entry, Descope init, lifecycle observer, session refresh timer |
| `lib/screens/auth/auth_riverpod/auth_notifier.dart` | `AuthNotifier` — login, logout, auth state |
| `lib/services/session_refresh_mutex.dart` | Serializes concurrent JWT refreshes |
| `lib/services/session_expiry_manager.dart` | Handles 401 recovery (silent refresh or terminal logout) |
| `lib/services/api_service.dart` | HTTP client with pre-request refresh + retry-on-401 |
| `lib/repositories/base/base_api_service.dart` | Base HTTP client with pre-request refresh + retry-on-401 |
| `lib/repositories/base/refreshable_api.dart` | Extension of BaseAPIService with additional pre-refresh |
| `lib/services/socket_service.dart` | Socket.IO with token refresh on "Invalid Token" |

---

## 2. Session Lifecycle

### Cold Start (App Launch)

```
main() entry
  |
  v
Descope.setup(projectId)                    // Initialize SDK
  |
  v
Descope.sessionManager.loadSession()        // Load tokens from secure storage
  |
  v
refreshSessionIfNeeded()                    // Refresh JWT if expired (15s timeout)
  |                                         // No-op if JWT has >60s remaining
  v
AuthNotifier._initialize()                  // Read session + userData
  |                                         // If valid: set authenticated
  |                                         // If expired/missing: set unauthenticated
  v
GoRouter redirect guard                     // Checks isInitialized, then isAuthenticated
  |                                         // Routes to /login or /inbox
  v
_startSessionRefreshTimer()                 // 30-second periodic refresh (foreground only)
```

### Normal Operation (JWT Expiry)

```
API request initiated
  |
  v
guardedRefreshIfNeeded()                    // Pre-request: refresh if JWT near expiry
  |                                         // No-op if JWT has >60s remaining
  v
Request sent with fresh JWT
  |
  v
Server returns 200                          // Happy path - no user interruption
```

### JWT Expired in Transit (Race Condition)

```
API request initiated
  |
  v
guardedRefreshIfNeeded()                    // JWT had >60s, but expires during flight
  |
  v
Request sent with now-stale JWT
  |
  v
Server returns 401 "Invalid Token"
  |
  v
SessionExpiryManager.handleExpiry()         // Silent recovery attempt
  |
  v
refreshSessionIfNeeded() succeeds           // Refresh token still valid
  |
  v
Retry original request with fresh JWT       // Automatic, invisible to caller
  |
  v
Server returns 200                          // User sees successful result
```

### Terminal: Refresh Token Expired

```
Any refresh attempt
  |
  v
Refresh token is expired (>4 weeks) OR Descope server rejects (DescopeException)
  |
  v
Toast: "Session expired. Please log in again."
  |
  v
setAuthenticated(false) -> GoRouter -> /login
  |
  v
clearAllData() (secure storage wipe)
```

---

## 3. Token Refresh Flow

### All Refresh Entry Points

There are 6 code paths that can trigger a token refresh. All are serialized through `SessionRefreshMutex.guardedRefreshIfNeeded()`:

| # | Trigger | File | When |
|---|---------|------|------|
| ~~1~~ | ~~**Cold start**~~ | ~~`main.dart`~~ | **CS-1: Removed** — was redundant with entry point #3 in `_initialize()`. `loadSession()` in `main()` is sufficient. |
| 2 | **30-second timer** | `main.dart:754` | Every 30s while app is in foreground |
| 3 | **App resume** | `main.dart:864` | When app returns from background/tab switch |
| 4 | **Pre-request (ApiService)** | `api_service.dart:175` | Before every HTTP request via `_buildPerRequestHeaders()` |
| 5 | **Pre-request (BaseAPIService)** | `base_api_service.dart:72` | Before every HTTP request via `make()` |
| 6 | **Socket retry** | `socket_service.dart:219` | When server rejects socket login with "Invalid Token" |

> **Note (CS-1):** Entry point #1 was removed because `AuthNotifier._initialize()` already checks `sessionToken.isExpired` and calls `refreshSessionIfNeeded()`. The cold-start refresh in `main()` added up to 15s of blocking before `runApp()` when the JWT was expired. Pre-request refresh in `ApiService` is the safety net for any remaining staleness.

### SessionRefreshMutex — Serialization

**File**: `lib/services/session_refresh_mutex.dart`

All 6 paths call `SessionRefreshMutex.guardedRefreshIfNeeded()`, which uses a static `Completer<void>` to ensure only ONE refresh runs at a time:

```
Call 1 arrives -> starts refresh, creates Completer
Call 2 arrives -> sees Completer exists, awaits same Future
Call 3 arrives -> sees Completer exists, awaits same Future
Refresh completes -> all 3 callers resolve simultaneously
```

This prevents:
- Multiple concurrent Descope API calls (wasteful)
- iOS Keychain locking errors from concurrent secure storage access
- Race conditions between timer, lifecycle, and API-triggered refreshes

### refreshSessionIfNeeded() Behavior

The Descope SDK's `refreshSessionIfNeeded()`:
- **No-op** if the session JWT has more than ~60 seconds remaining
- **Refreshes** by calling Descope servers with the refresh token if JWT is near expiry
- **Updates** in-memory session + persists to secure storage on success
- **Throws `DescopeException`** if the server rejects the refresh (token revoked)
- **Throws network errors** (SocketException, TimeoutException) if server unreachable

---

## 4. 401 Recovery Flow

**File**: `lib/services/session_expiry_manager.dart`

When an API call returns 401/405, both `ApiService` and `BaseAPIService` delegate to `SessionExpiryManager.handleExpiry()`:

```
handleExpiry() called
  |
  +-- passkeyFlowInProgress? -> return false (don't interfere with WebAuthn)
  +-- isLoggedOut? -> return false (already logging out)
  +-- _expiryCompleter exists? -> await and return same result (concurrent 401s)
  |
  v
Attempt silent recovery:
  |
  +-- In-memory session null? -> loadSession() from secure storage
  |
  +-- Refresh token still valid?
  |     |
  |     +-- refreshSessionIfNeeded() succeeds -> return true (RECOVERED)
  |     +-- DescopeException -> TERMINAL (server rejected)
  |     +-- Network error -> return true (transient, retry later)
  |
  v
TERMINAL: refresh token expired or no session
  |
  v
Toast "Session expired. Please log in again."
SessionRefreshMutex.isLoggedOut = true
clearSession() + setAuthenticated(false) + clearAllData()
return false
```

### Return Values

- **`true`** = session recovered, caller should **retry the original request**
- **`false`** = terminal, caller should **return error to UI** (user is being redirected to login)

### HTTP 200 With `success:false` Auth Errors (ST-race fix)

Some backend endpoints return HTTP 200 with `{"success": false, "message": "Invalid Token"}` instead of a proper HTTP 401. This bypasses the standard status-code 401 check and propagates the raw auth message directly to the UI.

**Detection**: Both `ApiService._handleResponse()` and `BaseAPIService.make()` check for `success:false` responses containing auth-related keywords:
```dart
if (decoded['success'] == false) {
  final msg = (decoded['message'] ?? '').toString().toLowerCase();
  if (msg.contains('invalid token') || msg.contains('unauthorized') ||
      msg.contains('authentication failed') || msg.contains('token expired')) {
    // Treat the same as a genuine HTTP 401 — trigger recovery + retry
  }
}
```

**Why this matters**: Without this detection, the "Invalid Token" message would surface as a visible error toast to the user when they return from background, even though the session is recoverable.

---

## 5. HTTP Service Layers

### ApiService (`lib/services/api_service.dart`)

Used by most feature notifiers for standard API calls.

**Request flow**:
```
get()/post()/put()
  |
  v
_withAuthRetry() wrapper          // Catches 401, recovers, retries once
  |
  v
_safeRequest()                    // Catches SocketException -> NoInternetException
  |
  v
_buildHeaders()
  -> _buildPerRequestHeaders()
    -> _guardedRefreshIfNeeded()  // Pre-request token refresh (may be no-op if session null)
    -> ST-race null-session check (see below)
    -> Read fresh JWT from Descope.sessionManager.session?.sessionJwt
  |
  v
HTTP request (with 30s timeout)
  |
  v
_handleResponse()                 // Decode JSON, check status codes
  |                               // Also detects HTTP 200 success:false "Invalid Token"
  v
If 401/405 or success:false auth message: _withAuthRetry catches it
  -> _handleExpiredSession() -> SessionExpiryManager.handleExpiry()
  -> If recovered (true): retry the entire request (fresh headers + JWT)
  -> If terminal (false): return error response to caller
```

**Key**: The `_withAuthRetry()` wrapper makes 401 recovery + retry transparent to callers. Callers never see auth-related errors.

### BaseAPIService (`lib/repositories/base/base_api_service.dart`)

Used by `RefreshableService` and direct subclasses.

**Request flow**:
```
make(type, endpoint, ...)
  |
  v
NetworkService.hasInternet()      // DNS lookup to google.com (non-web only)
  |
  v
guardedRefreshIfNeeded()          // Pre-request token refresh (may be no-op if session null)
  |
  v
ST-race null-session check        // If session still null, loadSession() + refresh again
  |                               // (handles race between _refreshSessionOnResume() and API calls)
  v
Inject fresh JWT into headers     // authorization + tokentype headers
  |
  v
HTTP request (with 30s timeout)
  |
  v
If 401/405 and !isRetry:
  -> _handleSessionExpiry() -> SessionExpiryManager.handleExpiry()
  -> If recovered: retry via make(..., isRetry: true) with fresh JWT
  -> If terminal: return RequestResponse(error: ...)
If HTTP 200 with success:false + auth message and !isRetry:
  -> same recovery path as 401
```

**`isRetry` guard**: Prevents infinite retry loops. The retry call sets `isRetry: true`, so if the retry also gets a 401, it returns the error instead of retrying again.

### RefreshableService (`lib/repositories/base/refreshable_api.dart`)

Extends `BaseAPIService`. Adds its own pre-request refresh and JWT header injection before calling `make()`.

```
makeRefreshable(type, endpoint, ...)
  |
  v
guardedRefreshIfNeeded()          // Pre-refresh (RefreshableService's own)
  |
  v
Build headers with fresh JWT
  |
  v
make(type, endpoint, headers: allHeaders)  // Delegates to BaseAPIService
  |                                         // BaseAPIService also pre-refreshes
  |                                         // (idempotent via Completer)
  v
...same flow as BaseAPIService
```

The double-refresh is harmless — `guardedRefreshIfNeeded()` is idempotent via its Completer pattern.

---

## 6. Socket Authentication

**File**: `lib/services/socket_service.dart`

### Connection Flow

```
initSocket(url, token, userId)
  |
  v
socket.io connect (WebSocket transport)
  |
  v
onConnect -> emit 'login' with fresh JWT from Descope.sessionManager
  |
  v
Server ACK:
  +-- success -> emit 'unReadCount', 'notificationExists'
  +-- "Invalid Token" -> _refreshAndRetryLogin()
```

### Token Refresh on Socket

`_refreshAndRetryLogin()` (lines 215-232):
1. Guard: skip if `_isRetryingAuth` (prevents re-entrant loops) or `isLoggedOut`
2. Call `SessionRefreshMutex.guardedRefreshIfNeeded()`
3. Re-emit `login` with fresh JWT
4. Does NOT force logout on failure — lets existing API/timer flows handle it

### Socket Events That Use Auth

- `onConnect` — sends fresh JWT
- `onReconnect` — sends fresh JWT (from `Descope.sessionManager`, not stale closure)
- `connect_error` — triggers `_refreshAndRetryLogin()`
- Login ACK with "Invalid Token" — triggers `_refreshAndRetryLogin()`

### Reconnect on Resume

`SocketService().reconnectIfNeeded()` is called AFTER `_refreshSessionOnResume()` completes in `main.dart`. This ordering ensures the socket uses a fresh JWT, not one that expired while backgrounded.

---

## 7. App Lifecycle & Session

**File**: `lib/main.dart`, class `_MyAppState` with `WidgetsBindingObserver`

### Lifecycle State Transitions

| State | What Happens | Session Refresh |
|-------|-------------|----------------|
| `inactive` | App loses focus (notification shade, app switcher) | No change |
| `hidden` | Web tab loses focus | **Stop** refresh timer |
| `paused` | App truly backgrounded | **Stop** refresh timer, record `_backgroundedAt` |
| `resumed` | App returns to foreground | **Start** timer, refresh JWT, reconnect socket |

### Resume Flow (Detailed)

```
AppLifecycleState.resumed
  |
  v
_startSessionRefreshTimer()                 // Restart 30s periodic timer
  |
  v
[Mobile only] 100ms delay                  // CS-5: Reduced from 300ms
  |
  v
_refreshSessionOnResume()                   // Proactive JWT refresh
  |
  +-- Session null? -> loadSession() from secure storage
  |     +-- Load failed? -> Treat as transient (Keychain error), skip logout
  |     +-- Load succeeded, still null? -> Genuine no-session, logout
  |     +-- Load succeeded, session found? -> Restart timer, continue
  |
  +-- Not authenticated? -> Skip (router already going to /login)
  |
  +-- guardedRefreshIfNeeded()
  |     +-- Success -> JWT refreshed, continue
  |     +-- DescopeException or refresh token expired -> Terminal logout
  |     +-- Network error -> Skip logout (transient), next timer tick retries
  |
  v
SocketService().reconnectIfNeeded()         // AFTER JWT refresh (M-12)
  |
  v
[Mobile only] _checkAndLockIfNeeded()       // Biometric lock if applicable
```

### ST-race: Resume API Call Race Condition

**Problem**: `_refreshSessionOnResume()` and API calls from the UI fire concurrently on app resume. When the in-memory Descope session is null (Android memory pressure cleared it, or after a cold start variant), `guardedRefreshIfNeeded()` is a **no-op** — `refreshSessionIfNeeded()` returns immediately if `_session == null` in the Descope SDK without throwing. The API call then proceeds with no JWT header, and some backend endpoints return HTTP 200 with `{"success": false, "message": "Invalid Token"}` rather than HTTP 401.

**Symptoms** (all appearing together after 10+ minute idle):
- "Invalid Token" toast on the contacts or any other screen
- "Internet disconnected" banner fired by the catch-all network error handler
- Screen content shows "No contacts found" / blank

**Fix**:
1. Both `ApiService._guardedRefreshIfNeeded()` and `BaseAPIService.make()` check whether the session is still null after `guardedRefreshIfNeeded()` completes. If so, they call `loadSession()` + `guardedRefreshIfNeeded()` once more before injecting the JWT.
2. Both HTTP layers detect `success:false` + auth-related message in HTTP 200 responses and treat them as 401s (triggers the full recovery + retry path).
3. Feature notifiers (e.g. `contact_list_notifier.dart`) check for null data before dereferencing, and only show "No Internet" for actual `NoInternetException` — not for every caught exception.

**Timing diagram**:
```
App resume
  |
  +---> _refreshSessionOnResume()                (async, takes time)
  |         -> loadSession() from Keychain       (may take 50–500ms)
  |         -> guardedRefreshIfNeeded()
  |
  +---> UI rebuild fires API calls               (concurrent, immediately)
            -> guardedRefreshIfNeeded()
               -> _session == null -> NO-OP      (no exception)
            -> ⚠️ JWT still null in memory
            -> request sent with no auth header
            -> backend returns success:false "Invalid Token"

With fix:
  +---> UI rebuild fires API calls
            -> guardedRefreshIfNeeded() -> no-op
            -> session still null?
               -> loadSession() + guardedRefreshIfNeeded() again
               -> JWT now fresh in memory
            -> request sent with valid JWT -> success ✅
```

### 30-Second Refresh Timer

- **Started**: When auth state becomes `authenticated`, or on resume
- **Stopped**: When app pauses/hides, or auth state becomes `unauthenticated`
- **Action**: Calls `SessionRefreshMutex.guardedRefreshIfNeeded()` every 30 seconds
- **Terminal handling**: If refresh token expires or Descope rejects, logs out (deferred if biometric dialog is active)

---

## 8. Intersections with Adjacent Systems

### 8.1 Biometric (Face/Touch ID)

**Files**: `lib/services/biometric_service.dart`, `lib/services/action_biometric_guard.dart`, `lib/main.dart`

**Relationship**: Biometric lock/unlock is completely separate from token refresh. It uses `local_auth` (hardware biometric APIs), not HTTP calls.

#### Biometric State Machine

```
User backgrounds app (paused)
  |
  v
_wentToPaused = true, _backgroundedAt = DateTime.now()
_isPrivacyVisible = true (Flutter overlay)
_setNativePrivacyScreen(true) (iOS/Android native)
If _isBiometricEnabled: _isLocked = true
  |
  v
User returns to foreground (resumed)
  |
  v
_refreshSessionOnResume() runs FIRST        // JWT refresh before biometric
  |
  v
SocketService().reconnectIfNeeded()         // Socket uses fresh JWT
  |
  v
_checkAndLockIfNeeded()                     // THEN biometric check
  |
  +-- _unlockInProgress? → skip (prevents re-entrant triggers)
  +-- Just authenticated (<5s ago)? → skip, clear overlays
  +-- Not authenticated? → skip, clear overlays
  +-- isBiometricEnable != 'true' in storage? → skip, clear overlays
  +-- No _backgroundedAt recorded? → skip (was rotation, not real background)
  +-- Within grace period? → skip, clear overlays
  |
  v (biometric lock needed)
_isLocked = true, _isPrivacyVisible = true
  |
  v
_triggerBiometricUnlock()
  |
  +-- BiometricService().authenticate() succeeds
  |   → _isLocked = false, _isPrivacyVisible = false
  |   → ActionBiometricGuard.markAuthenticated() (resets action-level timer)
  |
  +-- First attempt fails → _showRetryDialog()
  |   +-- "Try Again" → second attempt (iOS offers passcode fallback)
  |   +-- "Log Out" → _performLockLogout() → AuthNotifier.logout()
  |
  +-- Second attempt fails → _performLockLogout()
```

#### Cold-Start Biometric Lock

On cold start, the biometric lock is handled by `_loadBiometricSettingAndColdStartLock()` (called from `initState()`, async but not awaited). This runs concurrently with `AuthNotifier._initialize()` which restores the authenticated state from storage.

**Two race conditions fixed by `_coldStartLockPending`:**

**Race 1 — `resumed` lifecycle event:** iOS fires `inactive` → `resumed` on cold start in milliseconds — before `_loadBiometricSettingAndColdStartLock()` can complete its 3 async platform-channel calls. The `resumed` handler's else-branch (rotation/notification shade path) saw `_isLocked = false` and called `_dismissPrivacyOverlay()`, bypassing the biometric entirely. Fix: guard that dismiss with `!_coldStartLockPending`.

**Race 2 — auth listener:** `AuthNotifier._initialize()` completes faster (1 async hop — session already in memory from `main()`) than the cold-start lock (3 async hops). When it sets `AuthState.authenticated()`, the `ref.listen(authProvider)` callback in `build()` saw a not-authenticated → authenticated transition and dismissed the overlay. Fix: guard that dismiss with `!_coldStartLockPending`.

**`_coldStartLockPending` flag** gates both racing dismissals until the cold-start lock decision is made:

```
App cold start (main.dart)
  |
  v
main(): Descope.setup() → loadSession() → refreshSessionIfNeeded() → runApp()
  |
  v
_MyAppState.initState()
  |
  ├── _isPrivacyVisible = true (default on mobile — splash covers first frame)
  ├── _coldStartLockPending = true (gates auth listener + resumed handler)
  └── _loadBiometricSettingAndColdStartLock() [async, not awaited]
        |
        v
      Read 'isBiometricEnable' from SecureStorage
        |
        +-- false → _coldStartLockPending = false, dismiss overlay
        |
        +-- true →
              Load Descope session (if not in memory)
              Read 'isAuthenticated' from SecureStorage
              Check Descope.sessionManager.session != null
                |
                +-- not authenticated or no session → _coldStartLockPending = false, dismiss
                |
                +-- both true →
                      _isLocked = true, _isPrivacyVisible = true
                      _waitForNavigatorAndUnlock() → _triggerBiometricUnlock()
                      _triggerBiometricUnlock() sets _unlockInProgress = true
                        then _coldStartLockPending = false (handoff)

CONCURRENT (Race 1): iOS lifecycle fires inactive → resumed
  → resumed else-branch checks: if (!_isLocked.value && !_coldStartLockPending)
  → _coldStartLockPending = true → overlay NOT dismissed ✓

CONCURRENT (Race 2): AuthNotifier._initialize() (microtask from build())
  → Reads session (sync) + userData (1 async hop)
  → Sets AuthState.authenticated()
  → ref.listen fires in _MyAppState.build()
  → Guarded by: if (!_unlockInProgress && !_coldStartLockPending) ✓
```

**Key invariant:** On the lock path, at least one of `_coldStartLockPending` or `_unlockInProgress` is always `true` until the biometric prompt resolves, so neither the lifecycle handler nor the auth listener can prematurely dismiss the overlay.

#### Session Refresh Deferral During Biometric

| Guard | Where Checked | Effect |
|-------|---------------|--------|
| `_coldStartLockPending` | `ref.listen(authProvider)` in `build()` + `didChangeAppLifecycleState` resumed else-branch | Prevents two racing dismissals from bypassing the cold-start biometric lock: (1) the auth listener firing when `_initialize()` restores authenticated state, and (2) the `resumed` lifecycle event firing before `_loadBiometricSettingAndColdStartLock()` completes. Handed off to `_unlockInProgress` once `_triggerBiometricUnlock()` fires. |
| `biometricPending` | `_refreshSessionOnResume()` lines 818-819 | If biometric check is about to fire, defers terminal logout so user sees the biometric prompt first — the next API call after unlock discovers the session issue |
| `_unlockInProgress` | `_startSessionRefreshTimer()` line 788, `_refreshSessionOnResume()` lines 841, 886 | Defers terminal logout while the system biometric dialog is active — prevents logging out while Face/Touch ID is displayed |
| `passkeyFlowInProgress` | `SessionRefreshMutex` line 36, `SessionExpiryManager` line 43 | Skips refresh/recovery entirely during WebAuthn ceremony — refreshing JWT breaks the challenge-JWT binding |
| Just-authenticated grace | `_checkAndLockIfNeeded()` line 471-482 | Skips biometric if login completed <5s ago — passkey/biometric system dialogs cause paused→resumed lifecycle churn that would otherwise trigger a spurious lock |

#### Storage Reads During Biometric Check

| Key Read | File:Line | Purpose |
|----------|-----------|---------|
| `isBiometricEnable` | `main.dart:_checkAndLockIfNeeded()` line 495 | Fresh read from `SecureStorageService` (not cache) to determine whether to lock |
| `authProvider.isAuthenticated` | `main.dart:_checkAndLockIfNeeded()` line 486 | From Riverpod state (in-memory) — if false, dismiss overlays immediately |

**Key rule**: Token refresh never triggers biometric. Biometric never triggers token refresh. They coexist via deferral guards. The biometric `isBiometricEnable` flag is read from secure storage (not AppCache) so it's always authoritative even after the in-memory cache is cleared during logout.

### 8.2 Connectivity Monitoring ("Internet disconnected")

**Files**: `lib/services/common_service.dart`, `lib/common/utilites/network_service.dart`, `lib/main.dart`

#### Detection Mechanisms

| # | Mechanism | File | Platform | When |
|---|-----------|------|----------|------|
| 1 | `Connectivity().onConnectivityChanged` stream | `main.dart:monitorInternetConnection()` | Mobile only | Real-time OS connectivity events |
| 2 | `NetworkService.hasInternet()` DNS lookup | `base_api_service.dart:53` | Mobile only | Pre-request check before every `BaseAPIService.make()` call |

**Web has no connectivity monitoring** — the `Connectivity` plugin and DNS lookup are skipped on web (`kIsWeb` guards). Web relies on HTTP request failures to surface network issues.

#### "Internet Disconnected" Banner — Full Flow

```
Connectivity().onConnectivityChanged fires ConnectivityResult.none
  |
  v
2-second delay timer starts (main.dart:1001)    // Debounce: avoids flash on brief handoff
  |
  v
Timer fires → CommonService.showConnectivityBanner()
  |
  +-- SessionRefreshMutex.isRefreshing == true?
  |   → SUPPRESS banner (false positive: auth issue, not network issue)
  |   → Return without showing anything
  |
  +-- isRefreshing == false → Show persistent red "Internet disconnected" banner
  |   → _isOffline = true (static flag)
  |   → Banner stays visible across navigation (overlay-based, not widget-based)
  |   → User can dismiss via close icon (but _isOffline stays true)
  |
  v
Connectivity restores (non-none result)
  |
  v
Cancel the 2-second timer (if still pending)
CommonService.hideConnectivityBanner()
  → _isOffline = false
  → Remove overlay
  |
  v
Auto-retry: after 1s delay, call inboxProvider.notifier.getAllEmails('')
  → Re-fetches inbox data with (presumably) fresh connectivity
```

#### Toast Suppression Layers

There are **3 layers** of toast suppression that prevent confusing duplicate messages:

| Layer | Check | File:Line | What It Suppresses |
|-------|-------|-----------|-------------------|
| **1. Logout suppression** | `SessionRefreshMutex.isLoggedOut && type == 'error'` | `common_service.dart:animatedToast()` | ALL error toasts during logout — `SessionExpiryManager` already showed "Session expired" |
| **2. "No internet" redirect** | `message.toLowerCase().contains('no internet')` | `common_service.dart:animatedToast()` | Redirects to persistent banner system instead of showing a dismissable toast |
| **3. Refresh-in-flight suppression** | `SessionRefreshMutex.isRefreshing` | `common_service.dart:showConnectivityBanner()` | Prevents false "Internet disconnected" banner when a JWT refresh is in progress |

#### `NoInternetException` — How API-Level Connectivity Errors Flow

```
ApiService._safeRequest() catches SocketException/TimeoutException
  → throws NoInternetException(noInternet)     // noInternet = "No internet connection"
  |
  v
Caller (notifier) catches NoInternetException
  → CommonService.animatedToast(error.message, 'error')
  → animatedToast detects "no internet" text → showConnectivityBanner()
  → Banner shown instead of toast (if not already showing + not mid-refresh)
```

```
BaseAPIService.make() calls NetworkService.hasInternet() BEFORE request
  → DNS lookup to google.com (3-second timeout)
  → If fails: returns RequestResponse with error "No internet connection"
  → Caller shows toast → redirected to banner system by animatedToast()
```

#### When the Banner Legitimately Shows

- Airplane mode on
- WiFi disconnected with no cellular fallback
- DNS resolution to google.com genuinely fails (not during JWT refresh)
- Prolonged network outage (>2 seconds after `ConnectivityResult.none`)

#### When the Banner Should NOT Show (Guarded Against)

- During JWT token refresh (`isRefreshing` guard)
- Brief WiFi→cellular handoff (<2 seconds, debounce timer cancels)
- After logout started (`isLoggedOut` suppresses error toasts globally)

### 8.3 Passkey Enrollment

**File**: `lib/screens/auth/passkey/passkey_notifier.dart`

**The conflict**: WebAuthn (passkeys) requires the JWT used at `/start` to match the one at `/finish`. If a background timer refreshes the JWT between these two calls, the server rejects the finish with a cryptographic mismatch.

**The guard**: `SessionRefreshMutex.passkeyFlowInProgress` is set to `true` before passkey `/start` and `false` after `/finish`. While set:
- `guardedRefreshIfNeeded()` returns immediately (no refresh)
- `SessionExpiryManager.handleExpiry()` returns `false` immediately (no recovery attempt)

### 8.4 Privacy Overlay

**File**: `lib/main.dart`

The privacy overlay (splash screen shown on app switcher/background) interacts with the resume flow:

```
paused -> Show privacy overlay + native privacy flag
  |
resumed -> _refreshSessionOnResume() FIRST
  |        Then check biometric lock
  |        Only dismiss privacy overlay after biometric succeeds (or not needed)
```

The privacy overlay has no direct interaction with token refresh. It's purely a visual guard during lifecycle transitions.

---

## 9. Login & Logout Flows

### Login Flow

```
LoginScreen -> userVerify(email/phone)
  |
  v
Descope.sessionManager.clearSession()      // Clear any stale session from prior login
  |
  v
API: user/verify                            // Backend checks user exists
  |
  v
EnterOtpScreen -> verifyDescopeOtp(code)
  |
  v
Descope.otp.verify(method, loginId, code)   // Returns DescopeSession
  |
  v
Descope.sessionManager.manageSession()      // Persist session to secure storage
  |
  v
API: user/login                             // Backend creates/validates user record
  |
  v
setAuthenticated(true, userData)            // AuthState -> authenticated
  |                                         // GoRouter -> /inbox
  v
_startSessionRefreshTimer()                 // Begin 30-second refresh cycle
SocketService().initSocket()                // Connect with fresh JWT
```

### Logout Flow

**Critical ordering**: `setAuthenticated(false)` FIRST, then background cleanup.

```
performLogout() (in SettingsNotifier)
  |
  v
SessionRefreshMutex.isLoggedOut = true      // Block all future refreshes
  |
  v
setAuthenticated(false)                     // Immediate: GoRouter -> /login
  |
  v
[Background Future]:
  logoutAccount()                           // API call to backend
  clearSession()                            // Wipe secure storage
    -> Does NOT call setAuthenticated(false) (prevents mid-login reset)
    -> Resets inbox/archive/draft/tags providers
    -> AppCache().clear()
    -> SocketService().disconnect()
```

### Why `clearSession()` Does NOT Call `setAuthenticated(false)`

`clearSession()` is also called during login flows (to clear stale state). If it called `setAuthenticated(false)`, it would redirect to /login mid-login, breaking the flow. The `setAuthenticated(false)` call is explicit in `performLogout()` only.

### `isLoggedOut` Flag

- Set to `true` at the start of logout
- Checked by `guardedRefreshIfNeeded()` — skips refresh (prevents restoring a cleared session)
- Checked by `SessionExpiryManager.handleExpiry()` — skips recovery (prevents duplicate toasts)
- Reset to `false` on next successful login (in `setAuthenticated(true)`)

---

## 10. Concurrency Guards

### SessionRefreshMutex

**File**: `lib/services/session_refresh_mutex.dart`

| Flag | Type | Purpose |
|------|------|---------|
| `_refreshCompleter` | `Completer<void>?` | Ensures only one `refreshSessionIfNeeded()` call runs at a time. Concurrent callers await the same Future. |
| `isLoggedOut` | `bool` | Blocks all refresh attempts during/after logout. Prevents restoring a cleared session. |
| `passkeyFlowInProgress` | `bool` | Blocks refresh during WebAuthn ceremony. Preserves challenge-JWT binding. |
| `isRefreshing` | `bool` | Indicates a refresh is in-flight. Used to suppress false "Internet disconnected" banners. |

### SessionExpiryManager

**File**: `lib/services/session_expiry_manager.dart`

| Flag | Type | Purpose |
|------|------|---------|
| `_expiryCompleter` | `Completer<bool>?` | Ensures only one 401 recovery flow runs at a time. Concurrent 401 handlers await the same Future. Returns `true` (recovered) or `false` (terminal). |

### How They Prevent Race Conditions

**Scenario**: Two API calls both get 401 at the same time.
```
Call A gets 401 -> handleExpiry() -> creates _expiryCompleter, starts recovery
Call B gets 401 -> handleExpiry() -> sees _expiryCompleter, awaits same Future
Recovery succeeds -> both get true -> both retry with fresh JWT
```

**Scenario**: Timer refresh and API pre-request refresh happen simultaneously.
```
Timer calls guardedRefreshIfNeeded() -> creates _refreshCompleter
API call's _buildPerRequestHeaders() calls guardedRefreshIfNeeded() -> awaits same Future
Refresh completes -> both continue with fresh JWT
```

**Scenario**: Logout starts while refresh is in-flight.
```
Refresh is running (Completer active)
performLogout() sets isLoggedOut = true
Refresh completes -> checks isLoggedOut -> clears the session that was just refreshed
API calls see isLoggedOut -> skip refresh, return immediately
```

---

## 11. Troubleshooting Guide

### Symptom: User sees "Session expired" toast unexpectedly

**Possible causes**:
1. Refresh token genuinely expired (>4 weeks since last login)
2. Backend revoked the session (check server-side Descope console)
3. `DescopeException` from server during refresh attempt

**Where to look**:
- `[SessionExpiryManager] Descope rejected refresh` in debug logs
- `[SessionTimer] Terminal but biometric in progress` — timer detected terminal state
- Check `Descope.sessionManager.session?.refreshToken.isExpired` value

### Symptom: "Internet disconnected" banner appears when internet is fine

**Possible causes**:
1. DNS lookup to google.com timed out (3s timeout in `NetworkService.hasInternet()`)
2. WiFi->cellular handoff caused brief `ConnectivityResult.none`
3. Banner appeared during token refresh (should be suppressed by `isRefreshing` guard)
4. **(ST-race)** A feature notifier's `catch` block called `animatedToast("No Internet", ...)` for a non-network exception (e.g. null dereference from `data!` when the API returned an error). The "No Internet" keyword routes to `showConnectivityBanner()` regardless of actual connectivity. Fixed in `contact_list_notifier.dart` — catch block now only shows the "No Internet" toast for actual `NoInternetException`.

**Where to look**:
- `[SessionRefreshMutex] isRefreshing` state during the event
- `monitorInternetConnection()` in `main.dart` — 2-second delay before showing banner
- `CommonService.showConnectivityBanner()` — check if `isRefreshing` guard fired
- Feature notifier `catch` blocks — ensure they test `e is NoInternetException` before showing "No Internet"

### Symptom: API call fails silently (no error, no data)

**Possible causes**:
1. 401 recovery succeeded but retry also failed (non-auth error)
2. `NoInternetException` caught and suppressed (toast suppression for connectivity banner)

**Where to look**:
- Feature notifier's error handling — check if it suppresses empty messages
- `inbox_notifier.dart` has special suppression for `noInternet` messages

### Symptom: App logs out on resume from background

**Possible causes**:
1. In-memory session was null (Android memory pressure cleared Descope SDK state)
2. `loadSession()` from secure storage also returned null (tokens wiped)
3. iOS Keychain temporarily unavailable (treated as transient since RC-4 fix)

**Where to look**:
- `[Session] loadSession() threw on resume` — Keychain read error (transient, no logout)
- `[Session] No session but biometric pending` — deferred logout for biometric flow
- `_refreshSessionOnResume()` in `main.dart`

### Symptom: Passkey enrollment fails

**Possible causes**:
1. JWT was refreshed between `/start` and `/finish` — `passkeyFlowInProgress` guard was not set
2. Session expired during the WebAuthn ceremony

**Where to look**:
- `passkey_notifier.dart` — verify `SessionRefreshMutex.passkeyFlowInProgress = true` before `/start`
- Check that the guard is set in both `enrollPasskey()` and `signInWithPasskey()`

### Symptom: Socket shows "Invalid Token" repeatedly

**Possible causes**:
1. JWT expired while app was backgrounded, socket reconnects with stale token
2. `_refreshAndRetryLogin()` failed (network error during refresh)

**Where to look**:
- Socket ACK handler at `emitEventWithAck('login', ...)` — checks for "Invalid Token" in response
- `_refreshAndRetryLogin()` — should refresh JWT and re-emit login
- Verify `SocketService().reconnectIfNeeded()` is called AFTER `_refreshSessionOnResume()`

### Symptom: "Invalid Token" toast on Contacts, Inbox, or other screens after 10+ minute idle

**This is the ST-race condition.** The in-memory Descope session was null when the API call fired (either Android cleared it under memory pressure, or there was a race between `_refreshSessionOnResume().loadSession()` and the API call on resume). `guardedRefreshIfNeeded()` was a no-op, the request went without a JWT header, and the backend returned `success:false, message:"Invalid Token"` in a HTTP 200 response.

**Expected behavior** (with fix): The null-session recovery in `ApiService._guardedRefreshIfNeeded()` and `BaseAPIService.make()` loads the session from storage and refreshes the JWT before any request is sent. The "Invalid Token" in HTTP 200 detection triggers the standard retry path. The user sees no error.

**Diagnostic logs to check**:
- `[Session] loadSession() threw on resume` — Keychain momentarily unavailable
- `[SessionRefreshMutex] Session refresh failed:` — network error during refresh on resume
- Absence of `[SessionExpiryManager] Recovery succeeded` — refresh didn't fire before the API call

---

## 12. Logout Rules — When to Log Out

The app must ONLY force-logout a user when one of these conditions is met:

| Condition | Evidence | Code Path |
|-----------|----------|-----------|
| Refresh token expired | `session.refreshToken.isExpired == true` | All terminal paths |
| Descope server rejection | `catch (e) where e is DescopeException` | All terminal paths |
| Session genuinely absent | `loadSession()` succeeded AND `session == null` | `_refreshSessionOnResume()` |
| User manually logs out | Settings → Log Out | `AuthNotifier.logout()` |

The app must **NEVER** force-logout on:

- Transient network errors (timeout, SocketException, WiFi→cellular handoff)
- iOS Keychain temporarily unavailable (`-25308` or read failure on resume)
- Android in-memory session cleared by OS memory pressure (reload from storage first)
- Web IndexedDB/WebCrypto temporary failure
- Any non-`DescopeException` error from `refreshSessionIfNeeded()`

---

## 13. Descope SDK Internals (v0.9.18)

### SDK Source References

The Descope Flutter SDK (v0.9.18) manages tokens through three core classes:

| Class | File (in package) | Role |
|-------|-------------------|------|
| `DescopeSessionManager` | `lib/src/session/manager.dart` | Manages active session, coordinates storage and lifecycle |
| `SessionStorage` | `lib/src/session/storage.dart` | Persists session to platform-specific secure storage |
| `SessionLifecycle` | `lib/src/session/lifecycle.dart` | Determines when to refresh, calls Descope auth API |

### Token Persistence Model

Both JWTs are stored as a **single JSON blob** keyed by the Descope `projectId`:

```json
{
  "sessionJwt": "<10-minute JWT>",
  "refreshJwt": "<4-week JWT>",
  "user": { "userId": "...", "loginIds": [...], ... }
}
```

**Platform-specific storage backends:**

| Platform | Backend | Key | Encryption |
|----------|---------|-----|------------|
| iOS | Keychain (via MethodChannel `descope_flutter/methods`) | `projectId` | Hardware-backed |
| Android | Keystore (via MethodChannel `descope_flutter/methods`) | `projectId` | Hardware-backed |
| Web | `window.localStorage[projectId]` | `projectId` | **None** (plaintext in localStorage) |

**Important:** The Descope SDK's storage is **completely separate** from the app's `SecureStorageService`. The app's `clearAllData()` does NOT touch the Descope SDK's storage key. Only `Descope.sessionManager.clearSession()` removes the SDK's data.

### Token Lifecycle — What Happens When

| Operation | Session JWT (10 min) | Refresh JWT (4 weeks) | Storage Write? |
|-----------|---------------------|----------------------|---------------|
| `manageSession(session)` | Set from auth response | Set from auth response | YES — full blob saved |
| `loadSession()` | Loaded from storage | Loaded from storage | NO — read only |
| `refreshSessionIfNeeded()` | Replaced with new JWT | Kept (unless server rotates) | YES — if tokens changed (dedup via `_lastValue` check) |
| `clearSession()` | Set to null | Set to null | YES — blob removed |
| JWT expires naturally | Still in storage (NOT deleted) | Still in storage (NOT deleted) | NO — expiry is checked in code, not enforced by storage |

**Key insight: Tokens are never auto-deleted by expiration.** An expired JWT stays in secure storage indefinitely until either:

1. `refreshSessionIfNeeded()` overwrites it with a fresh one
2. `clearSession()` explicitly removes it
3. The OS wipes the keychain/storage (app uninstall, factory reset)

### refreshSessionIfNeeded() — Detailed Flow

```
refreshSessionIfNeeded() called (manager.dart:151)
  |
  v
Is _session null? → YES → return (no-op)
  |
  NO
  v
shouldRefresh(session)? (lifecycle.dart:57)
  → Checks: DateTime.now() + 60 seconds > session.sessionToken.expiresAt
  → If session has >60s remaining → return (no-op, nothing saved)
  |
  YES (JWT expiring within 60s or already expired)
  v
Descope.auth.refreshSession(session.refreshJwt) (lifecycle.dart:49)
  → HTTP POST to Descope servers with the refresh JWT
  → Server validates refresh token
  |
  +-- Success: returns RefreshResponse with new session JWT
  |   |         (and optionally new refresh JWT if server rotates it)
  |   v
  |   session.updateTokens(response) (session.dart:108-111)
  |     → _sessionToken = response.sessionToken  (always replaced)
  |     → _refreshToken = response.refreshToken ?? _refreshToken  (kept if not rotated)
  |   v
  |   storage.saveSession(session) (manager.dart:155)
  |     → Only writes if tokens actually changed (storage.dart:51 dedup)
  |     → Saves full {sessionJwt, refreshJwt, user} blob to platform storage
  |
  +-- DescopeException: server rejected refresh (token revoked, expired server-side)
  |   → Throws DescopeException — caller must handle (TERMINAL)
  |
  +-- Network error: SocketException, TimeoutException
      → Throws error — caller should NOT treat as terminal
```

### SDK Timer — NOT IMPLEMENTED (v0.9.18)

```dart
// In lifecycle.dart lines 65-71:
void startTimer() {
  // TODO: not implemented yet
}
void stopTimer() {
  // TODO: not implemented yet
}
```

The SDK's built-in periodic refresh timer is **unimplemented** as of v0.9.18. This is why the app provides its own 30-second timer in `main.dart:_startSessionRefreshTimer()`. Without the app's timer, the SDK would never proactively refresh — it only refreshes when `refreshSessionIfNeeded()` is explicitly called by app code.

**When upgrading the Descope SDK:** Check if `startTimer()`/`stopTimer()` have been implemented. If so, the app's 30-second timer may conflict with the SDK's timer (double refresh attempts). Test carefully and consider removing the app's timer if the SDK handles it.

---

## 14. Storage Architecture & Logout Lifecycle

### Storage Separation Summary

| Storage | Manager | Keys | Cleared By |
|---------|---------|------|-----------|
| Descope SDK (Keychain/Keystore/localStorage) | `DescopeSessionManager` | Single key = `projectId` | `clearSession()` only |
| App Secure Storage (Keychain/EncryptedSharedPrefs/encrypted localStorage) | `SecureStorageService` | `userData`, `isAuthenticated`, `isBiometricEnable`, etc. | `clearAllData()` or `clearAllAppStorage()` |
| App SharedPreferences | `SecureStorageService._prefs` | `upgradePopupShownAfterLogin`, `isPasskeyPageOpenStatus`, etc. | `clearAllPrefs()` |
| App In-Memory Cache | `AppCache()` singleton | `_isCheckout`, `_subscriptionPage`, `_signupInProgress`, etc. | `AppCache().clear()` |

### AppCache — In-Memory Redirect Cache

**File**: `lib/common/app_manger/app_cache.dart`

AppCache is a singleton that holds redirect-critical values in memory so GoRouter's `_asyncRedirect()` can make routing decisions without async I/O on every navigation.

#### AppCache Fields and Their Impact on Routing

| Field | Type | Default After `clear()` | Read By | Impact If Stale |
|-------|------|------------------------|---------|----------------|
| `_isCheckout` | `String?` | `null` | `app_router.dart:151` | Stale `'true'` → redirects to checkout instead of inbox after re-login |
| `_subscriptionPage` | `String` | `''` | `app_router.dart` (subscription routing) | Stale value → redirects to wrong plan page |
| `_signupInProgress` | `String` | `''` | `app_router.dart` (signup flow) | Stale `'true'` → traps user in signup flow after re-login |
| `_hasPasskeyEnrolled` | `bool` | `false` | `login_post_processor.dart:35` | Stale `true` → skips passkey enrollment prompt (harmless) |
| `_hasCompletedOnboarding` | `bool` | `false` | `app_router.dart` | Stale `true` → skips onboarding (harmless) |
| `_isPasskeyPageOpen` | `bool` | `false` | `app_router.dart` | Stale `true` → shows passkey page inappropriately |
| `_mailto` | `String?` | `null` | `app_router.dart:267` | Stale value → opens compose for wrong recipient |
| `_queryParms` | `Map?` | `null` | `app_router.dart:194` | Stale value → processes a payment signal from prior session |
| `_tabName` | `String` | `''` | Navigation drawer | Stale value → highlights wrong tab (cosmetic only) |
| `_lastNavigation` | `String` | `''` | Navigation helpers | Stale value → incorrect back navigation (cosmetic) |

#### AppCache Lifecycle

```
App cold start (main.dart)
  |
  v
AppCache().loadRedirectCache()               // Batch-loads from SecureStorageService
  → Reads: isCheckout, subscriptionPage, signupInProgress,
  →        hasPasskeyEnrolled, hasCompletedOnboarding, mailto
  → Writes to in-memory fields
  → Called ONCE before GoRouter is created (main.dart:184)
  |
  v
GoRouter redirect reads AppCache synchronously (no I/O per navigation)
  |
  v
Screens update AppCache inline when writing to storage:
  → storage.writeData('isCheckout', 'true');
  → AppCache().setIsCheckout('true');       // Keep in-memory + storage in sync
  |
  v
Logout (manual or forced):
  → AppCache().clear()                       // Reset all in-memory fields
  → clearAllData()                           // Delete from storage (background)
  |
  v
Re-login:
  → loadRedirectCache() is NOT called again  // Only runs at app init
  → Screens set values as needed (e.g., select_plan sets subscriptionPage)
  → AppCache starts with cleared defaults — correct for a fresh session
```

**Critical rule**: `AppCache().clear()` MUST be called in ALL logout paths (manual and forced). Without it, stale redirect state from the previous session bleeds into the next login and causes wrong-screen redirects.

### App Secure Storage — Keys Deleted During `clearAllData()`

**File**: `lib/services/storage_service.dart`

The following keys are deleted sequentially during `clearAllData()`:

| Key | Content | Why Cleared |
|-----|---------|------------|
| `userData` | User profile JSON blob | Session-specific |
| `isAuthenticated` | `'true'` / `'false'` | Session-specific |
| `isBiometricEnable` | `'true'` / `'false'` | Session-specific (per-user setting) |
| `userProfileData` | Extended profile data | Session-specific |
| `selected_plan` | Plan selection state | Session-specific |
| `updatePopUpDismiss` | UI dismissal flag | Session-specific |
| `isContactAlreadySync` | Contact sync flag | Session-specific |
| `loginId` | User identifier | Session-specific |
| `sessionJwt` | Legacy (now managed by Descope SDK) | Cleanup only |
| `refreshJwt` | Legacy (now managed by Descope SDK) | Cleanup only |
| `payment_data` | Subscription cache | Session-specific |
| `hasPasskeyEnrolled` | Passkey enrollment flag | Session-specific (different users have different passkeys) |
| `signupInProgress` | Signup flow state | Session-specific |
| `isCheckout` | Checkout state | Session-specific |
| `subscriptionPage` | Subscription routing | Session-specific |

After the key-by-key deletion, `clearAllPrefs()` wipes all SharedPreferences.

### Keys Intentionally NOT Cleared During Logout

| Key | Content | Why Preserved |
|-----|---------|--------------|
| `readingPaneEnabled` | `'true'` / `'false'` | Device-level preference — not tied to any user account |
| `deviceToken` | FCM push notification token | Device-specific — written once during `_MyAppState.initState()`, not re-written on re-login because `MyApp` stays mounted across logout/login |

### Platform-Specific Secure Storage Behavior

| Platform | Implementation | Encryption | Retry Logic | Known Issues |
|----------|---------------|-----------|-------------|-------------|
| **iOS** | `FlutterSecureStorage` → Keychain | Hardware-backed | 3 attempts for `-25308` errors (200ms, 400ms backoff) | Keychain locked during cold start before first unlock |
| **Android** | `FlutterSecureStorage` → EncryptedSharedPreferences | Hardware-backed | None (no Keychain equivalent issue) | In-memory session can be cleared by OS memory pressure (file picker, camera) |
| **Web** | Custom `_WebSecureStorage` → `localStorage` | AES-GCM-256 via WebCrypto API | Key stored in IndexedDB (non-extractable) | If IndexedDB key is lost, encrypted data becomes unreadable — returns null without deleting entry (RC-9 fix) |

### Web Encryption Details

**File**: `lib/services/storage/platform_secure_storage_web.dart`

```
Write: plaintext → WebCryptoHelper.encrypt() → AES-GCM-256 ciphertext → localStorage['optmsg_enc_' + key]
Read:  localStorage['optmsg_enc_' + key] → WebCryptoHelper.decrypt() → plaintext
       OR: localStorage['optmsg_secure_' + key] (legacy plaintext) → auto-migrate to encrypted
```

- **Encryption key**: AES-GCM-256 key stored in IndexedDB with `non-extractable` flag
- **Legacy migration**: Old plaintext `optmsg_secure_*` keys auto-migrate to encrypted `optmsg_enc_*` on first read
- **Fallback**: If WebCrypto unavailable (insecure context, private browsing), stores plaintext under legacy prefix
- **Decryption failure**: Returns null and preserves the entry (does NOT delete) — recovery re-fetches from backend

### What Gets Cleared During Each Type of Logout

| Storage Layer | Manual Logout (`AuthNotifier.logout()`) | Forced Logout (`SessionExpiryManager` / timer / resume) |
|---|---|---|
| Descope SDK tokens | `clearSession()` | `clearSession()` |
| App secure storage (13 keys) | `clearAllData()` (background) | `clearAllData()` |
| SharedPreferences | `clearAllPrefs()` + specific keys | `clearAllPrefs()` (via clearAllData) |
| AppCache (in-memory) | `AppCache().clear()` | `AppCache().clear()` |
| Socket connection | `disconnect()` | Not explicitly disconnected |
| Firebase user | `_clearFirebaseUser()` | Not cleared |
| `SessionRefreshMutex.isLoggedOut` | Set to `true` | Set to `true` |

### What Survives Logout (by design)

- `readingPaneEnabled` — device-level user preference
- `deviceToken` — FCM push notification token (device-specific, not session-specific)
- `hasRunBefore` — SharedPreferences key used for reinstall detection (cleared by `clearAllPrefs()` but re-set on next launch)
- Descope SDK storage format/config (unrelated to session data)

### Forced Logout — Complete Sequence

```
TERMINAL CONDITION DETECTED (refresh token expired / DescopeException / null session)
  |
  v
1. CommonService.animatedToast('Session expired. Please log in again.', 'error')
   → Toast fires BEFORE isLoggedOut is set (so it's not suppressed by RC-5)
  |
  v
2. SessionRefreshMutex.isLoggedOut = true
   → Blocks all future guardedRefreshIfNeeded() calls
   → Causes all subsequent error toasts to be suppressed (RC-5)
   → Prevents SessionExpiryManager.handleExpiry() re-entry (RC-2)
  |
  v
3. Descope.sessionManager.clearSession()
   → Removes SDK's {sessionJwt, refreshJwt, user} blob from Keychain/storage
   → Sets in-memory _session = null
  |
  v
4. AppCache().clear()
   → Resets all in-memory redirect flags to defaults
   → Prevents stale routing on next login (RC-6)
  |
  v
5. providerContainer.read(authProvider.notifier).setAuthenticated(false)
   → AuthState → unauthenticated
   → GoRouter redirect fires → navigates to /login
   → Still-mounted screens may fire error handlers, but RC-5 suppresses toasts
  |
  v
6. SecureStorageService().clearAllData() (background, unawaited)
   → Deletes 13 secure storage keys sequentially
   → Clears all SharedPreferences
   → deviceToken and readingPaneEnabled are preserved
```

### Re-Login After Forced Logout — State Restoration

| State | When Restored | By What Code | AppCache Updated? |
|-------|-------------|-------------|-------------------|
| Descope JWTs | OTP verify or passkey sign-in | `manageSession(session)` | N/A (SDK storage) |
| `userData` | `userLogin()` success | `writeObjectData('userData', ...)` | No (not in AppCache) |
| `isAuthenticated` | `userLogin()` success | `writeData('isAuthenticated', 'true')` | No (not in AppCache) |
| `isBiometricEnable` | `userLogin()` success | `writeData('isBiometricEnable', ...)` | No (not in AppCache) |
| `hasPasskeyEnrolled` | `userVerify()` (from backend) | `writeData(...)` + `AppCache().setHasPasskeyEnrolled()` | **Yes** |
| `isLoggedOut` | `setAuthenticated(true)` | `isLoggedOut = false` | N/A (static flag) |
| `deviceToken` | Survives logout | Already in storage from `initState()` | No (not in AppCache) |
| `signupInProgress` | Signup flow screens | Screen-specific `writeData()` + `AppCache().setSignupInProgress()` | **Yes** (when screen mounts) |
| `subscriptionPage` | Plan selection screen | `select_plan.dart:247` + `AppCache().setSubscriptionPage()` | **Yes** (when screen mounts) |
| `isCheckout` | Checkout screen | `checkout_notifier.dart:105` + `AppCache().setIsCheckout()` | **Yes** (when screen mounts) |

**Note**: `loadRedirectCache()` is NOT called again on re-login — it only runs during `main()`. After re-login, AppCache starts with cleared defaults (from `AppCache().clear()`). Screens populate their values when they mount. This is correct behavior because a new session starts fresh.

---

## Descope Best Practices Followed

1. **Pre-request refresh**: `refreshSessionIfNeeded()` called before every API request (Descope docs: "call before making requests")
2. **Retry-on-401**: Automatic recovery + retry when session JWT expires in transit
3. **Transparent management**: Token refresh is invisible to UI callers — no error toasts for recoverable auth issues
4. **Serialized refresh**: Single Completer ensures only one refresh runs at a time
5. **Graceful degradation**: Transient network errors during refresh don't trigger logout — next timer tick retries
6. **Secure storage**: Keychain (iOS) and EncryptedSharedPreferences (Android) via Descope SDK defaults
7. **Null-session recovery on API calls**: Both HTTP layers detect a null in-memory session after `guardedRefreshIfNeeded()` and perform a `loadSession()` + re-refresh before sending the request — guards against the resume race condition where Android clears the in-memory session under memory pressure
8. **HTTP 200 auth-error detection**: Both HTTP layers check for `success:false` + auth-related messages in HTTP 200 responses and route them through the standard 401 recovery path — guards against backends that return "Invalid Token" in a 200 body

Sources:
- [Descope Mobile SDK Session Management](https://docs.descope.com/authorization/session-management/session-validation/mobile)
- [Descope Session Management Overview](https://docs.descope.com/authorization/session-management)
- [Descope Flutter SDK (pub.dev)](https://pub.dev/packages/descope)

---

## 15. Audit Changelog (2026-03-27)

Fixes for production issues: slow cold-start, "invalid session" blank screens, and Android black screens.

### Cold-Start & Resume Performance

| ID | Fix | Impact |
|----|-----|--------|
| CS-1 | Removed redundant `refreshSessionIfNeeded()` from `main()` — `_initialize()` handles it | Saves up to 15s on cold start |
| CS-2 | Reduced exponential backoff for missing userData from `[1,2,4,8]s` to `[200,500,1000,2000]ms` | Reduces worst-case splash from ~30s to ~4s |
| CS-3 | Made Firebase Analytics init non-blocking (`unawaited`) | Saves up to 10s on slow Android |
| CS-4 | Parallelized `AppCache.loadRedirectCache()` via `Future.wait()` | Saves 300-600ms on iOS |
| CS-5 | Reduced resume delay from 300ms to 100ms | Faster resume |
| CS-6 | Deferred `AppBreakpoints.initializeDeviceInfo()` (no longer blocks `runApp()`) | Saves 100-200ms |

### Blank Screen & Session Expiry Races

| ID | Fix | Impact |
|----|-----|--------|
| BS-1 | `errorBuilder` now shows spinner + retry (was blank `Scaffold`) | Eliminates stuck blank screen |
| BS-2 | Added `isLoggedOut` guards to timer and resume logout paths | Prevents duplicate `setAuthenticated(false)` |
| BS-3 | Timer terminal handling routes through `SessionExpiryManager.handleExpiry()` | Atomic cleanup via Completer |
| BS-4 | Resume terminal handling routes through `SessionExpiryManager.handleExpiry()` | Same — prevents concurrent cleanup races |
| BS-5 | `'/'` route shows spinner instead of blank `Scaffold` | Visual feedback during slow auth init |

### Android-Specific

| ID | Fix | Impact |
|----|-----|--------|
| AN-1 | `_hideNativePrivacyOverlay()` now awaited with 500ms timeout + 1 retry | Fixes native overlay stuck → black screen |
| AN-3 | Removed redundant `loadSession()` in biometric cold-start | Session already in memory from `main()` |
| AN-4 | `FLAG_SECURE` only set inside `isAuth + hasSession` check | Prevents interference with Credential Manager |
| AN-5 | Connectivity-restore inbox refresh guarded by `isRefreshing` check | Prevents cascading API calls on resume |

### Web Storage (Planned — Descope 0.10.0 Upgrade)

The Descope SDK v0.10.0 changes web session storage from `localStorage` to `sessionStorage`. When upgrading, the app will override this to keep `localStorage` for session persistence across tab closes. Future TODO: implement trusted-device checkbox in login flow to use `localStorage` (trusted) vs `sessionStorage` (untrusted), leveraging Descope's "Remember me" project setting.
