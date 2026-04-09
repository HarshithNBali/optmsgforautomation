ticket optmsg-109

Push Notification Fixes — Walkthrough
flutter analyze → ✅ No issues found

Web Fixes
W-1 · Service Worker API Updated
firebase-messaging-sw.js

Firebase JS SDK v10+ removed setBackgroundMessageHandler(). Replaced with the current API:

diff
- messaging.setBackgroundMessageHandler(function(payload) { ... });
+ messaging.onBackgroundMessage(function(payload) { ... });
W-2 · Service Worker Registration Race
index.html

Moved SW registration before flutter_bootstrap.js defer so the SW begins installing before Flutter initialises Firebase and calls getToken().

diff
- <script src="flutter_bootstrap.js" defer></script>
  <!-- Firebase Service Worker Registration -->
  <script defer>...</script>
+ <script src="flutter_bootstrap.js" defer></script>
W-3 · getToken() Called Before SW is Active
notification_service.dart

Added _waitForServiceWorkerReady() — a 1.5 s belt-and-suspenders guard that closes the installing → activated window on first page load. Called in _saveFcmToken() before getToken() on web.

Also wired in VAPID key support via --dart-define=VAPID_KEY=...:

dart
const vapidKey = String.fromEnvironment('VAPID_KEY', defaultValue: 'YOUR_STAGING_VAPID_KEY_HERE');
await firebaseMessaging.getToken(vapidKey: kIsWeb ? vapidKey : null);
IMPORTANT

Set the VAPID key via --dart-define=VAPID_KEY=<base64-key> (from Firebase Console → Project Settings → Cloud Messaging → Web Push certificates). Without it, getToken() may return null in some browsers.

W-4 · WebCrypto Decrypt Bug (All Decryption Always Failed)
web_crypto_helper.dart

Root cause: Uint8List.sublistView(combined, _ivLength).buffer.toJS returns the full parent ArrayBuffer (IV + ciphertext), not just the ciphertext slice. AES-GCM then tried to decrypt [IV||ciphertext] as the ciphertext → auth tag mismatch every time.

diff
- .decrypt(algorithm, key, ciphertext.buffer.toJS)
+ .decrypt(algorithm, key, ciphertext.toJS)
.toJS on a Uint8List produces a JS Uint8Array that carries the correct byteOffset/byteLength of the view. This was a Day 1 bug that silently broke all FCM token reads from secure storage.

W-5 · Stale Encrypted Entry Blocks Plaintext Fallback
platform_secure_storage_web.dart
 — write()

When IndexedDB was unavailable, write() fell back to plaintext — but left the stale optmsg_enc_<key> entry intact. The next read() found the encrypted entry first, failed to decrypt it, and returned null without ever reaching the plaintext.

dart
} catch (_) {
  // W-5: remove stale encrypted entry so read() can reach the plaintext fallback
  web.window.localStorage.removeItem('$_encPrefix$key');
  web.window.localStorage.setItem('$_legacyPrefix$key', value);
}
W-6 · read() Returned null on Decrypt Failure
platform_secure_storage_web.dart
 — read()

The decryption catch block had an early return null that prevented execution from falling through to the legacy plaintext prefix check. Removed it — now execution continues to the optmsg_secure_<key> check after logging the failure.

W-7 · Firebase Project Mismatch
firebase-config.js
 · 
firebase_options.dart

Created web/firebase-config.js (gitignored, replaced by CI/CD) defaulting to optmsg-staging.

Made DefaultFirebaseOptions.web a dynamic getter instead of a const:

dart
static FirebaseOptions get web {
  const env = String.fromEnvironment('ENV', defaultValue: 'stag');
  if (env == 'prod') return const FirebaseOptions(/* opt-msg-app */ ...);
  return const FirebaseOptions(/* optmsg-staging */ ...);
}
ENV	Firebase project	Backend	firebase-config.js
stag (default)	optmsg-staging (sender: 1004260439071)	staging-api.optmsg.com	staging config
prod	opt-msg-app (sender: 403388879371)	api.optmsg.com	prod config
IMPORTANT

You still need to replace the appId placeholder in the staging config with the real staging Web App ID from Firebase Console. The appId for production is already correct.

iOS Fixes
I-1 · Missing UIBackgroundModes
Info.plist

Added required background modes so iOS wakes the app for silent push:

xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
I-2 · Duplicate Permission Prompt
AppDelegate.swift

Removed the native UNUserNotificationCenter.requestAuthorization() call. The Flutter Firebase Messaging SDK (firebaseMessaging.requestPermission() in Dart) is now the sole owner of the permission dialog. iOS users will now see exactly one prompt on first launch.

Run Commands
bash
# Staging (web) — covers all local dev
flutter run -d chrome --web-port=5001 --dart-define=ENV=stag --dart-define=VAPID_KEY=<your-staging-vapid-key>
# Production (web)
flutter run -d chrome --dart-define=ENV=prod --dart-define=VAPID_KEY=<your-prod-vapid-key>



ticket-46 

Walkthrough - Removing Empty Reading Pane (Ensuring 2-Pane UI)
I have updated the application to ensure that when an email or contact list is empty, the reading pane is completely hidden. This prevents the UI from showing a blank 3rd pane and instead presents a clean 2-pane layout (Navigation Sidebar + Full-width Content List).

Changes Made
1. Inbox Module
Desktop/Tablet Layout: Updated inbox_desktop_layout.dart and inbox_tablet_layout.dart to hide the split-pane view if state.items.isEmpty.
Reading Pane Widget: Reverted the placeholder logic in reading_pane_widget.dart as the parent layout now manages visibility.
2. Drafts Module
Desktop Layout: Updated draft_desktop_layout.dart to hide the reading pane when the drafts list is empty.
Reading Pane Widget: Updated draft_reading_pane_widget.dart to return a blank surface, ensuring no placeholder icons appear if the widget is temporarily rendered during transitions.
3. Archive, Sent, and Trash Modules
Responsive Wrapper: Updated archive_responsive.dart to calculate shouldShowReadingPane based on whether state.items is non-empty. This automatically propagates the 2-pane layout to the Archive, Sent, and Trash modules on both Desktop and Tablet.
4. Contacts Module
Web Layout: Updated web_read_pane.dart to hide the right-hand flex column if the contact list is empty and no contact is currently selected.
Verification Results
Layout Behavior
State	Active Panes	Result
List Empty	Sidebar + Full-width List	✅ 2 Panes
List with Items	Sidebar + List + Reading Pane	✅ 3 Panes
NOTE

This change fulfills the requirement to "show only 2 pane not 3" when no data is present, matching the visual layout preferred for empty states.

inbox_desktop_layout.dart
 
archive_responsive.dart
 
web_read_pane.dart



ticket optmsg-187

# Subscription Widget Changes

## `_ChangeSubscriptionOrCancelButtonRiverpod` — Show "Change Subscription" for Paid Users

**File:** `lib/screens/subscription/subscription_riverpod/subscription_riverpod.dart`

### What Changed

Previously, the `_ChangeSubscriptionOrCancelButtonRiverpodState` widget only showed the **"Change Subscription"** button for free users, and only the **"Cancel Membership"** button for paid users.

**After this change**, paid users now see **both** buttons:
1. **Change Subscription** — gradient button navigating to `AppRoutes.changeSubscription`
2. **Cancel Membership** — outlined button that shows a confirmation dialog before cancelling

### Before

| User Type  | Buttons Shown               |
|------------|-----------------------------|
| Free User  | Change Subscription         |
| Paid User  | Cancel Membership           |

### After

| User Type  | Buttons Shown                                   |
|------------|-------------------------------------------------|
| Free User  | Change Subscription                             |
| Paid User  | Change Subscription + Cancel Membership         |

### Technical Details

- Extracted `_buildChangeSubscriptionButton(BuildContext context)` helper method
- Extracted `_buildCancelMembershipButton(BuildContext context)` helper method
- For paid users, both buttons are rendered inside a `Wrap` widget (spacing: 8) so they flow naturally on all screen sizes — side-by-side on desktop, stacked on mobile




ticket 63

Throttle Email View Height Updates
Address the "A problem repeatedly occurred" crash on Safari (iOS/macOS) when zooming into emails. This crash is caused by a feedback loop where zooming triggers frequent ResizeObserver events in the iframe, which then trigger frequent setState calls in Flutter, leading to a rendering process crash.

Proposed Changes
Core Logic
[MODIFY] 
native_app_html_view_web.dart
Implement a throttle mechanism for _deferHeightUpdate.
Only trigger setState if the height difference is significant (> 4 pixels).
Add a minimum interval (e.g., 150ms) between consecutive setState calls during active layout changes.
Verification Plan
Manual Verification
Deploy to staging and test on an iPhone/iPad using Safari.
Navigate to an email with complex HTML content.
Perform rapid pinch-zoom gestures.
Verify that the page no longer crashes with "A problem repeatedly occurred".
Verify that the email content eventually settles to the correct height after zooming stops.

ticket 51

Contact Navigation & UI Fixes Summary
This document summarizes the changes made to resolve navigation issues and improve the user interface for the contact details and edit screens on both Web/Desktop and Mobile platforms.

Key Changes
1. Navigation & Data Integrity
Model Conversion: Updated ResponsiveViewContactriverpodWrapper in lib/router/responsive_route_wrappers.dart to automatically convert contact data from a Map (JSON) to a Contacts model. This prevents NoSuchMethodError crashes when navigating back from the edit screen on Web.
Defensive ID Access: Improved property access in ViewContactriverpod and its layouts to safely extract the contact ID, ensuring robustness across different entry points.
2. AppBar & Back Button UI
Unified Back Button Logic: Refactored ShellLayout in lib/widgets/shell_layout.dart to ensure a consistent navigation experience.
Search Bar Refinement: Updated the shell's logic to hide the global search bar on contact detail/edit pages.
Code Change: ShellLayout Navigation Refinement
dart
// lib/widgets/shell_layout.dart
// Navigation leading logic (Line 441 approx)
} else if (showSidebar) {
  // Restore Logo/Hamburger on Desktop
  leading = SizedBox(
    width: sidebarWidth,
    child: isCollapsed
        ? Center(child: IconButton(icon: const Icon(Icons.menu), ...))
        : Row(children: [
            IconButton(icon: const Icon(Icons.menu), ...),
            SvgPicture.asset(svgWebLogo, ...),
          ]),
  );
} else if (canPop) {
  // Mobile/Push back button
  leading = IconButton(icon: SvgPicture.asset(svgArrowBack), ...);
}
// Title area logic (Line 486 approx)
} else if (!isMobile && (!isTopLevel || goCanPop)) {
  // Add back button before Title on Desktop
  title = Row(children: [
    IconButton(icon: SvgPicture.asset(svgArrowBack), ...),
    Text(config.title),
  ]);
}
3. Navigation & Data Integrity
Model Conversion: Added automatic Map to Contacts conversion in lib/router/responsive_route_wrappers.dart.
Code Change: Router Wrapper Model Safety
dart
// lib/router/responsive_route_wrappers.dart
// Ensure we have a proper model, as GoRouter 'extra' can sometimes be a Map on Web.
final Contacts effectiveContact = contact is Map<String, dynamic>
    ? Contacts.fromJson(contact)
    : contact as Contacts;
3. Component UI Refinement
Actions Visibility: Fixed logic in ViewContactriverpod and its layouts to ensure "Edit" and "Delete" buttons are visible in full-page mode on Desktop, regardless of the reading pane state.
Mobile Alignment: Removed the redundant "Add" button from the Desktop contact details view to match the cleaner Mobile design.
Files Modified
Component	File Path
Shell	
shell_layout.dart
Router	
responsive_route_wrappers.dart
Router	
app_router.dart
Contacts	
view_contact_riverpod.dart
Layouts	
view_contact_desktop_layout.dart
Layouts	
view_contact_tablet_layout.dart



ticket 225,224,228

Networking & Performance Optimizations Walkthrough
I have implemented the requested Networking and Performance optimizations. Below is a summary of the changes.

1. Networking - Singleton Pattern
The ApiService has been refactored to use a Singleton pattern via a factory constructor. This ensures that the 30+ places in the app currently calling ApiService() will now share a single instance, reusing the same http.Client and security configuration.

dart
// lib/services/api_service.dart
factory ApiService({String? baseUrl}) {
  _instance ??= ApiService._internal(baseUrl: baseUrl);
  return _instance!;
}
2. Performance - Background JSON Parsing
JSON parsing has been moved to a background isolate using the compute function in both ApiService and BaseAPIService. This prevents the UI thread from freezing ("jank") when parsing large email payloads or contact lists.

dart
// lib/repositories/base/base_api_service.dart
final decoded = await compute(_parseJson, response.body);
3. Networking - Timeout & Cancellation
I added CancelToken and flexible timeout support to all core networking methods.

Timeouts: Methods now accept a timeout parameter (defaults to 30s, customizable up to 60s+).
Cancellation: Callers can pass a CancelToken and call .cancel() to abort long-running requests or ignore their results if the user navigates away.
dart
// Example usage:
final token = CancelToken();
apiService.get('/path', cancelToken: token);
token.cancel(); // Request will be ignored/aborted where possible
Files Modified
api_service.dart
base_api_service.dart
refreshable_api.dart
Verification
Added debug logs to ApiService to confirm single-time initialization.
Verified that makeRefreshable and make signatures remain compatible with existing repository implementations.