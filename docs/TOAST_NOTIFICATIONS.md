# Toast Notifications Audit — OptMsg Flutter App

**Audit Date:** 2026-03-17
**Branch:** `optmsgApp-v1.0.6`
**Auditor:** Claude Code (QA/UX)

---

## 1. Toast System Overview

The app uses **two parallel toast mechanisms** and one **persistent banner**:

| Mechanism | Implementation | Used For |
|-----------|---------------|----------|
| `CommonService.animatedToast()` | Custom `OverlayEntry` with `CustomToast` widget | Primary toast — animated, overlay-based, all screens |
| `CommonService.showToast()` | `Fluttertoast` native package | Legacy fallback — only in a handful of contact screens |
| `CommonService.showConnectivityBanner()` | Persistent `OverlayEntry` (no auto-dismiss) | Connectivity loss only |

**Package:** `fluttertoast: ^9.0.0` (used only by `showToast()`).

### CustomToast (`lib/widgets/toast.dart`)
- Types: `success` (green), `error` (red), `Undo` (blue/info), `warning` (yellow default)
- Note: the string `'info'` is not a named case in the switch — it falls through to the `warning` default, rendered as yellow. Any call passing `'info'` is visually indistinguishable from a warning.
- Auto-dismisses after **3 seconds** via `Timer`.
- Has an **X close button** and an optional **Undo button** (visible only when type is `'Undo'`).
- Displayed at the **bottom center** with `bottom: 20` (fixed) or elevated above nav bar when `checkMainScreen = true`.
- Maximum width: `AppBreakpoints.popupMaxWidth`.
- Message truncated at 1 line (`maxLines: 1`, `TextOverflow.ellipsis`) — long messages are silently cut off.

### animatedToast() Signature
```dart
static void animatedToast(String message, String type, [VoidCallback? undoMethod, bool checkMainScreen = false])
```

### No-internet Guard
Any `animatedToast()` call with a message containing `'no internet'` (case-insensitive via `toLowerCase()`) is silently redirected to `showConnectivityBanner()`. This prevents duplicate toasts for offline errors.

---

## 2. Complete Toast Inventory

### 2.1 Authentication

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| A-01 | `userVerify()` — OTP sent (non-Descope path) | `response['message']` (e.g. "OTP sent to your phone") | success | 3s | No | `auth_notifier.dart:490` |
| A-02 | `userVerify()` — verification failed | `response['message'] ?? 'Verification failed'` | error | 3s | No | `auth_notifier.dart:498` |
| A-03 | `userVerify()` — Descope OTP send error (passkey fallback) | `mapDescopeError(e)` | error | 3s | No | `auth_notifier.dart:482` |
| A-04 | `userLogin()` — subscription invalid | `response['message'] ?? 'Subscription invalid'` | error | 3s | No | `auth_notifier.dart:552` |
| A-05 | `userLogin()` — login failed | `response['message'] ?? 'Login failed'` | error | 3s | No | `auth_notifier.dart:561` |
| A-06 | `userLogin()` — generic exception (non-network) | `e.toString()` | error | 3s | No | `auth_notifier.dart:576` |
| A-07 | `verifyDescopeOtp()` — OTP verify error | `mapDescopeError(e)` or `e.toString()` | error | 3s | No | `auth_notifier.dart:626,629` |
| A-08 | `resendOtp()` — OTP resent successfully | `'Otp sent'` | success | 3s | No | `auth_notifier.dart:678` |
| A-09 | `resendOtp()` — resend failed | `mapDescopeError(e)` or `e.toString()` | error | 3s | No | `auth_notifier.dart:685,687` |
| A-10 | `forgotUserName()` — success | `response['message']` | success | 3s | No | `auth_notifier.dart:820` |
| A-11 | `forgotUserName()` — failed | `response['message']` | error | 3s | No | `auth_notifier.dart:827` |
| A-12 | `forgotUserName()` — exception | `e.toString()` | error | 3s | No | `auth_notifier.dart:836` |
| A-13 | `signUp()` — check-username-mobile failed | `response['message']` | error | 3s | No | `auth_notifier.dart:746` |
| A-14 | `signUp()` — exception | `e.toString()` | error | 3s | No | `auth_notifier.dart:753` |
| A-15 | `setupProfile()` — failed | `response['message']` | error | 3s | No | `auth_notifier.dart:1062` |
| A-16 | `setupProfile()` — exception | `'Something went wrong'` | error | 3s | No | `auth_notifier.dart:1071` |
| A-17 | Passkey sign-in failed **(debug mode only)** | `'Passkey failed: $desc'` | error | 3s | No | `auth_notifier.dart:340,452` |
| A-18 | OTP screen — empty OTP submit | `'Please enter OTP'` | error | 3s | No | `create_account_screen.dart:93,99`; `otp_screen.dart:239` |
| A-19 | Web OTP — OTP resent | `'Otp sent'` | success | 3s | No | `web_enter_otp_notifier.dart:167` |
| A-20 | Web OTP — resend/verify error | `mapDescopeError(e)` | error | 3s | No | `web_enter_otp_notifier.dart` |

### 2.2 Session / Security

| ID | Trigger | Message Text (exact) | Type | Duration | Undo? | File:Line |
|----|---------|----------------------|------|----------|-------|-----------|
| S-01 | Session refresh fails (terminal 401 / refresh token expired) | `'Session expired. Please log in again.'` | error | 3s | No | `session_expiry_manager.dart:103` |
| S-02 | Passkey enrollment — **diagnostic toast left in production** | `'Origin: $origin'` | error | 3s | No | `passkey_notifier.dart:118` |

### 2.3 Connectivity

| ID | Trigger | Message Text (exact) | Type | Duration | Undo? | File:Line |
|----|---------|----------------------|------|----------|-------|-----------|
| C-01 | Network goes offline | `'Internet disconnected'` | error | **Persistent** | No (X to dismiss) | `common_service.dart:249` |
| C-02 | Any `animatedToast()` message containing `'no internet'` | Suppressed → C-01 banner shown instead | — | — | — | `common_service.dart:105` |
| C-03 | Contacts: explicit no-internet check (bypasses guard — mixed case) | `'No Internet'` | error | 3s | No | `contact_list_notifier.dart:154` |

### 2.4 Inbox

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| I-01 | Load inbox failed (non-auth, non-network) | `inboxList.message` | error | 3s | No | `inbox_notifier.dart:822` |
| I-02 | Load inbox — generic exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:905` |
| I-03 | `updateEmailStatus()` — API failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:936` |
| I-04 | `updateEmailStatus()` — exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:967` |
| I-05 | `markSelectedAsRead()` — API failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:997` |
| I-06 | `markSelectedAsRead()` — exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:1021` |
| I-07 | `getAllTags()` — API failed | `tagsList.message` | error | 3s | No | `inbox_notifier.dart:1038` |
| I-08 | `getAllTags()` — exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:1047` |
| I-09 | `addEmailTags()` — API failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:1080` |
| I-10 | `addEmailTags()` — exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:1228` |
| I-11 | `syncContacts()` — success | `resp['message']` | success | 3s | No | `inbox_notifier.dart:1368` |
| I-12 | `syncContacts()` — failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:1370` |
| I-13 | Opt-in check — API failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:1483` |
| I-14 | Opt-in check — exception | `'Error checking email'` | error | 3s | No | `inbox_notifier.dart:1500` |
| I-15 | All opt-in emails already exist | `'Emails are already present in a contact'` | info *(renders as warning yellow)* | 3s | No | `inbox_notifier.dart:1513` |
| I-16 | Move to Archive / Trash (undo window) | `CommonService().undoStatus(status)` → e.g. `"Moving to Archive"`, `"Moving to Trash"`, `"Permanently Delete"` | Undo | 3s | **Yes** | `inbox_notifier.dart:1600` |
| I-17 | `handleMarkUnread()` — API failed | `resp['message']` | error | 3s | No | `inbox_notifier.dart:1653` |
| I-18 | `handleMarkUnread()` — exception | `'Something went wrong'` | error | 3s | No | `inbox_notifier.dart:1658` |
| I-19 | Tag dialog: no email selected | `'Please select Email'` | warning | 3s | No | `inbox_notifier.dart:1930` |
| I-20 | Tag dialog: no tag selected | `'Please select Tag'` | warning | 3s | No | `inbox_notifier.dart:1945` |
| I-21 | Contact permission permanently denied | `'Please enable Contacts permission in App Settings to sync contacts'` | warning | 3s | No | `inbox_notifier.dart:601` |
| I-22 | Contact permission permanently denied (after request) | `'Contacts permission permanently denied. Enable it in App Settings to sync.'` | warning | 3s | No | `inbox_notifier.dart:633` |

### 2.5 Archive / Sent / Trash

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| AR-01 | Load list failed | `resp.data!['message'] ?? 'Something went wrong'` | error | 3s | No | `archive_list_notifier.dart:454` |
| AR-02 | Load list — parse failed | `inboxList.message` | error | 3s | No | `archive_list_notifier.dart:465` |
| AR-03 | Load list — exception | `'Something went wrong'` | error | 3s | No | `archive_list_notifier.dart:512` |
| AR-04 | `updateInboxEmailStatus()` — move target failed | `targetResp['message'] ?? 'Failed to move email'` | error | 3s | No | `archive_list_notifier.dart:762,817,854,1019,1069` |
| AR-05 | `updateInboxEmailStatus()` — API failed | `value.data!['message']` or `resp['message']` | error | 3s | No | `archive_list_notifier.dart:780,835,874,896` |
| AR-06 | `updateInboxEmailStatus()` — exception | `'Something went wrong'` | error | 3s | No | `archive_list_notifier.dart:902` |
| AR-07 | `updateEmailStatus()` from trash — success | `value.data!['message']` | success | 3s | No | `archive_list_notifier.dart:974` |
| AR-08 | `updateEmailStatus()` from trash — failed | `value.data!['message']` | error | 3s | No | `archive_list_notifier.dart:983` |
| AR-09 | `updateEmailStatus()` from archive — success | `value.data!['message']` | success | 3s | No | `archive_list_notifier.dart:1036` |
| AR-10 | `updateEmailStatus()` from archive — failed | `value.data!['message']` | error | 3s | No | `archive_list_notifier.dart:1045` |
| AR-11 | `updateEmailStatus()` from sent — success | `resp['message']` | success | 3s | No | `archive_list_notifier.dart:1092,1113` |
| AR-12 | `updateEmailStatus()` from sent — failed | `resp['message']` | error | 3s | No | `archive_list_notifier.dart:1096,1116` |
| AR-13 | `updateEmailStatus()` — exception | `'Something went wrong'` | error | 3s | No | `archive_list_notifier.dart:1122` |
| AR-14 | `getAllTags()` — failed | `parsedTagsList.message` | error | 3s | No | `archive_list_notifier.dart:1180` |
| AR-15 | `addEmailTags()` — failed | `resp['message']` | error | 3s | No | `archive_list_notifier.dart:1207` |
| AR-16 | Tag dialog: no email/tag selected | `'Please select Email & Tag'`, `'Please select Email'`, `'Please select Tag'` | warning | 3s | No | `archive_list_notifier.dart:1362,1371,1380` |
| AR-17 | Free user tries to compose from Archive | `'Sending is Unavailable in the Free Plan.'` | warning | 3s | No | `archive_list_notifier.dart:1416,1457` |
| AR-18 | No tags available | `'No Tags Found'` | warning | 3s | No | `archive_list_notifier.dart:218` |
| AR-19 | Move to Archive/Trash with Undo (from detail) | `CommonService().undoStatus(status)` | Undo | 3s | **Yes** | `archive_list_notifier.dart:2017` |
| AR-20 | `updateInboxEmailStatus()` read-mark — failed | `resp['message']` | error | 3s | No | `archive_list_notifier.dart:2409` |
| AR-21 | `updateInboxEmailStatus()` read-mark — exception | `'Something went wrong'` | error | 3s | No | `archive_list_notifier.dart:2413` |
| AR-22 | Opt-in all emails already exist | `'Emails are already present in a contact'` | info *(renders as warning yellow)* | 3s | No | `archive_list_notifier.dart:2695` |
| AR-23 | Opt-in — API failed | `resp['message']` | error | 3s | No | `archive_list_notifier.dart:2763` |
| AR-24 | Opt-in — exception | `'Error checking email'` | error | 3s | No | `archive_list_notifier.dart:2767` |

### 2.6 Compose

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| CO-01 | No content to save as draft | `'Please add at least one of: recipient, subject, body, or attachment to save as draft'` | error | 3s | No | `web_compose.dart:628` |
| CO-02 | Attachment exceeds 25 MB | `'File size cannot exceed 25 MB'` | error | 3s | No | `web_compose.dart:1188,1221` |
| CO-03 | Attachment type/upload error | Dynamic message from attachment API | error | 3s | No | `web_compose.dart:1194,1211,1227` |
| CO-04 | Attachment general upload error | Dynamic message | error | 3s | No | `web_compose.dart:1241,1247` |
| CO-05 | No valid file data provided | `'No valid file data provided'` | error | 3s | No | `web_compose.dart:1271` |
| CO-06 | S3 signed-URL error | `signedUrlModel.message` | error | 3s | No | `web_compose.dart:1274` |
| CO-07 | Free user tries to compose | `'Sending is Unavailable in the Free Plan.'` | warning | 3s | No | `web_compose.dart:1277,1510` |
| CO-08 | No recipient entered on send | `'Please enter recipient email id'` | error | 3s | No | `web_compose.dart:1545` |
| CO-09 | Email sent successfully | `'Email sent'` | success | 3s | No | `web_compose.dart:1600,1603` |
| CO-10 | Email send failed (socket ack != 'yes') | `catchError` → `'Something went wrong'` | error | 3s | No | `web_compose.dart:1620` |
| CO-11 | Check-email API failed during send | `resp['message']` | error | 3s | No | `web_compose.dart:1716` |
| CO-12 | Error checking email during send | `'Error checking email'` | error | 3s | No | `web_compose.dart:1726` |
| CO-13 | Draft saved (auto-save / manual save) | `'Draft saved'` | success | 3s | No | `web_compose.dart:1801,1865,1909,1911` |
| CO-14 | Message deleted (discard draft) | `'Message Deleted'` | success | 3s | No | `web_compose.dart:1839,1841` |
| CO-15 | Delete draft from send flow — success | `resp['message']` | success | 3s | No | `web_compose.dart:1942` |
| CO-16 | Delete draft from send flow — failed | `resp['message']` or `'Failed to delete draft'` | error | 3s | No | `web_compose.dart:1946,1952` |

### 2.7 View Email (Reading Pane)

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| VE-01 | Mark as read — API failed | `resp['message']` | error | 3s | No | `view_email.dart:375` |
| VE-02 | No tags available | `'No Tags Found'` | warning | 3s | No | `view_email.dart:390,1173` |
| VE-03 | Opt-in — email data not loaded | `'Email data not loaded'` | error | 3s | No | `view_email.dart:412` |
| VE-04 | Attachment open — MethodChannel missing (iOS) | `'File preview unavailable'` | error | 3s | No | `view_email.dart:1624` |
| VE-05 | Attachment open — PlatformException (iOS) | `'Cannot open this file type'` | error | 3s | No | `view_email.dart:1632,1640` |
| VE-06 | Attachment open — OpenFilex failed (Android) | `'Cannot open this file type'` | error | 3s | No | `view_email.dart:1672` |
| VE-07 | Attachment download failed | `'Failed to download file'` | error | 3s | No | `view_email.dart:1692` |
| VE-08 | Attachment — generic exception | `catchError` → `'Something went wrong'` | error | 3s | No | `view_email.dart:1700` |
| VE-09 | Download all attachments (zip) — no attachments | `'No valid attachments to download'` | error | 3s | No | `view_email.dart:1835` |
| VE-10 | Download all attachments (zip) — API failed | `zipData['message'] ?? 'Failed to create zip'` | error | 3s | No | `view_email.dart:1868` |
| VE-11 | Download all attachments (zip) — exception | `catchError` → `'Something went wrong'` | error | 3s | No | `view_email.dart:1874` |
| VE-12 | Load email detail — API error | `emailData?.message ?? 'Unknown error'` | error | 3s | No | `view_email.dart:2226` |
| VE-13 | Load email detail — exception | `'Error loading details'` | error | 3s | No | `view_email.dart:2244` |
| VE-14 | Add/delete tags — failed | `resp['message']` | error | 3s | No | `view_email.dart:2343,2416` |
| VE-15 | Copy email address | `'Successfully copied'` | success | 3s | No | `view_email.dart:2548,2711` |
| VE-16 | Move to Archive/Trash with Undo | `CommonService().undoStatus(status)` | Undo | 3s | **Yes** | `view_email.dart:3044` |
| VE-17 | File not previewable on web | `'Open not available for this file type. Download to open.'` | info *(renders as warning yellow)* | 3s | No | `view_email.dart:3172` |

### 2.8 Attachment Preview Screen

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| AP-01 | File saved successfully | `"File saved successfully."` | success | 3s | No | `attachment_preview_screen.dart:591` |
| AP-02 | Save failed | `"Error: $e"` | error | 3s | No | `attachment_preview_screen.dart:635` |

### 2.9 Contacts

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| CT-01 | Load contacts failed | `list.message` | error | 3s | No | `contact_list_notifier.dart:118` |
| CT-02 | Load contact detail failed | `'Failed to load contact details'` | error | 3s | No | `contact_list_notifier.dart:422` |
| CT-03 | Opt-in check email — success/fail | `resJson['message']` | success/error | 3s | No | `contact_list_notifier.dart:585,587` |
| CT-04 | Opt-in check — exception | Dynamic | error | 3s | No | `contact_list_notifier.dart:591` |
| CT-05 | Block contact — success/fail | `resJson['message']` | success/error | 3s | No | `contact_list_notifier.dart:625,630` |
| CT-06 | Upload contacts — failed | `'Error uploading contacts'` | error | 3s | No | `contact_list_notifier.dart:671` |
| CT-07 | Add contact — null response data | `'An error occurred while adding the contact'` | error | 3s | No | `add_contact_notifier.dart:107` |
| CT-08 | Add contact — API failed | `response['message']` | error | 3s | No | `add_contact_notifier.dart:117` |
| CT-09 | Add contact — success | `response['message'] ?? 'Contact added successfully'` | success | 3s | No | `add_contact_notifier.dart:141,205` |
| CT-10 | Add contact — catch exception | `'An error occurred while adding the contact'` | error *(via `showToast`)* | 3s | No | `add_contact_notifier.dart:222` |
| CT-11 | Edit contact — failed | `res['message']` | error | 3s | No | `edit_contact_notifier.dart:107,109` |
| CT-12 | Edit contact — success | `res['message']` | success | 3s | No | `edit_contact_notifier.dart:115,117` |
| CT-13 | Delete contact — failed / invalid email | `res['message']` or `'Invalid email'` | error | 3s | No | `edit_contact_notifier.dart:139,143` |
| CT-14 | Delete contact — success | `res['message']` | success | 3s | No | `view_contact_notifier.dart:142` |
| CT-15 | Delete contact — catch | `catchError` → `'Something went wrong'` | error | 3s | No | `view_contact_notifier.dart:149` |
| CT-16 | Block/unblock contact — success | `res['message']` | success | 3s | No | `view_contact_notifier.dart:169` |
| CT-17 | Block/unblock contact — failed | `res['message']` | error | 3s | No | `view_contact_notifier.dart:176` |
| CT-18 | Block/unblock contact — catch | `catchError` | error | 3s | No | `view_contact_notifier.dart:184` |
| CT-19 | Invalid email during edit/add | `'Invalid email'` | error | 3s | No | `view_contact_riverpod.dart:119` |
| CT-20 | Copy email/phone | `'Successfully copied'` | success | 3s | No | `view_contact_riverpod.dart:194,278` |

### 2.10 Tags

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| TG-01 | Load tags failed | `parsed.message` | error | 3s | No | `tags_notifier.dart:151` |
| TG-02 | Add tag — API response | `res.data!['message']` | success/error | 3s | No | `tags_notifier.dart:171` |
| TG-03 | Add tag — exception | `e.toString()` | error | 3s | No | `tags_notifier.dart:183` |
| TG-04 | Edit tag — API response | `res.data!['message']` | success/error | 3s | No | `tags_notifier.dart:197` |
| TG-05 | Edit tag — exception | `e.toString()` | error | 3s | No | `tags_notifier.dart:209` |
| TG-06 | Delete tag — API response | `res.data!['message']` | success/error | 3s | No | `tags_notifier.dart:223` |
| TG-07 | Delete tag — exception | `e.toString()` | error | 3s | No | `tags_notifier.dart:235` |
| TG-08 | Tag email list — load failed | `inboxList!.message` | error | 3s | No | `tag_email_list.dart:282` |
| TG-09 | Tag email list — status update failed | `resp['message']` | error | 3s | No | `tag_email_list.dart:311` |

### 2.11 Settings

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| SE-01 | Toggle notification — success | `resp['message']` | success | 3s | No | `settings_notifier.dart:103` |
| SE-02 | Toggle notification — failed | `resp['message']` | error | 3s | No | `settings_notifier.dart:106` |
| SE-03 | Toggle notification — exception | `catchError` → `'Something went wrong'` | error | 3s | No | `settings_notifier.dart:112` |
| SE-04 | Toggle biometrics — success | `'Biometrics Enabled'` or `'Biometrics Disabled'` | success | 3s | No | `settings_notifier.dart:146` |
| SE-05 | Toggle biometrics — API failed | `'Failed to update biometric setting'` | error | 3s | No | `settings_notifier.dart:152` |
| SE-06 | Toggle sort contacts — success | `'Settings updated'` | success | 3s | No | `settings_notifier.dart:178` |
| SE-07 | Toggle sort contacts — failed | `resp['message'] ?? 'Failed to update setting'` | error | 3s | No | `settings_notifier.dart:181` |
| SE-08 | Toggle sort contacts — exception | `catchError` | error | 3s | No | `settings_notifier.dart:187` |
| SE-09 | Toggle sync contacts — success | `resp['message']` | success | 3s | No | `settings_notifier.dart:241` |
| SE-10 | Toggle sync contacts — failed | `resp['message'] ?? 'Failed to update setting'` | error | 3s | No | `settings_notifier.dart:254` |
| SE-11 | Toggle sync contacts — exception | `catchError` | error | 3s | No | `settings_notifier.dart:260` |
| SE-12 | No subscription data found | `'No subscription data found'` | error | 3s | No | `account_notifier.dart:139` |
| SE-13 | Failed to load subscription | `'Failed to load subscription details'` | error | 3s | No | `account_notifier.dart:142` |

### 2.12 Subscription / Checkout

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| SU-01 | Cancel membership — success | `resp['message']` | success | 3s | No | `subscription_notifier.dart:55` |
| SU-02 | Cancel membership — failed | `resp['message']` | error | 3s | No | `subscription_notifier.dart:57` |
| SU-03 | Cancel membership — network error | `'Network error'` | error | 3s | No | `subscription_notifier.dart:60` |
| SU-04 | Change payment method — update success | `resp['message']` | success | 3s | No | `payment_method_notifier.dart:60` |
| SU-05 | Change payment method — update failed | `resp['message']` | error | 3s | No | `payment_method_notifier.dart:90` |
| SU-06 | Delete card — success | `'Card Deleted'` | success | 3s | No | `payment_method_notifier.dart:107` |
| SU-07 | Delete card — failed | `resp['message']` | error | 3s | No | `payment_method_notifier.dart:111` |
| SU-08 | Set default payment — failed | `resp['message']` | error | 3s | No | `payment_method_notifier.dart:122,155` |
| SU-09 | Payment — generic exception | `'Something went wrong'` | error | 3s | No | `payment_method_notifier.dart:136` |
| SU-10 | Select plan — API failed | `resp['message']` | error | 3s | No | `select_plan.dart:265` |
| SU-11 | Select plan — exception | `catchError` | error | 3s | No | `select_plan.dart:269` |
| SU-12 | Checkout — socket error during payment | `'Connection error. Verifying payment…'` | warning | 3s | No | `checkout_notifier.dart:133` |
| SU-13 | Checkout — payment verify failed | `'Please try again.'` | error | 3s | No | `checkout_notifier.dart:164,193` |
| SU-14 | Checkout — payment socket result not success | `'Something went wrong please try again.'` | error | 3s | No | `checkout_notifier.dart:202` |
| SU-15 | Promo code field empty | `'Enter Promo Code'` | error | 3s | No | `checkout_notifier.dart:212` |
| SU-16 | Promo code invalid format | `'Invalid promo code format'` | error | 3s | No | `checkout_notifier.dart:216` |
| SU-17 | Promo code API failed | `resp['message']` | error | 3s | No | `checkout_notifier.dart:229` |
| SU-18 | Promo code applied | `'Promo code applied'` | success | 3s | No | `checkout_notifier.dart:253` |
| SU-19 | Payment select-plan API failed | `resp['message']` | error | 3s | No | `checkout_notifier.dart:306` |
| SU-20 | Payment — invalid Stripe URL | `'Something went wrong'` | error | 3s | No | `checkout_notifier.dart:314` |
| SU-21 | Payment confirmation timeout | `'Payment confirmation timed out. Please try again.'` | error | 3s | No | `checkout_notifier.dart:361,376` |
| SU-22 | Payment — exception | `'Something went wrong'` | error | 3s | No | `checkout_notifier.dart:398` |
| SU-23 | Payment in progress (at 30s) | `'Still confirming your payment…'` | info *(renders as warning yellow)* | 3s | No | `checkout_notifier.dart:455` |
| SU-24 | Payment in progress (at 120s) | `'This is taking longer than expected. We'll send you an email once confirmed.'` | info *(renders as warning yellow)* | 3s | No | `checkout_notifier.dart:461` |
| SU-25 | Change subscription — failed | `resp['message']` | error | 3s | No | `change_subscription.dart:221` |
| SU-26 | Change subscription — exception | `catchError` | error | 3s | No | `change_subscription.dart:224` |
| SU-27 | Processing payment screen feedback | Dynamic | error | 3s | No | `processing_payment.dart:125` |
| SU-28 | Checkout WebView error | Dynamic | error | 3s | No | `check_out.dart:200` |

### 2.13 Swipe Actions (CustomDismissible)

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| SW-01 | No tags available (swipe tag action) | `"No tags found"` | warning | 3s | No | `custom_dismissible.dart:942` |
| SW-02 | No tag selected (swipe tag action) | `"Please select at least one tag"` | warning | 3s | No | `custom_dismissible.dart:924` |
| SW-03 | Mark as unread (swipe) — API failed | `resp['message']` | error | 3s | No | `custom_dismissible.dart:978` |
| SW-04 | Mark as unread (swipe) — exception | `catchError` | error | 3s | No | `custom_dismissible.dart:981` |

### 2.14 Sent Email List

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| SL-01 | Opt-in from sent list — all exist | Dynamic server message | success | 3s | No | `sent_email_list.dart:570` |
| SL-02 | Opt-in from sent list — failed | `resp['message']` | error | 3s | No | `sent_email_list.dart:579` |
| SL-03 | Opt-in from sent list — exception | `'Error checking email'` | error | 3s | No | `sent_email_list.dart:583` |

### 2.15 Print / File Operations

| ID | Trigger | Message Text (exact) | Type | Duration | Undo? | File:Line |
|----|---------|----------------------|------|----------|-------|-----------|
| PR-01 | Print load failed (native) | `'Failed to load email for printing.'` | error | 3s | No | `secure_print_helper.dart:140` |
| PR-02 | Web print failed | `'Print failed: $e'` | error | 3s | No | `secure_print_web.dart:115` |
| PR-03 | File download — generic exception | `catchError` → `'Something went wrong'` | error | 3s | No | `common_service.dart:572` |

### 2.16 Onboarding

| ID | Trigger | Message Text (exact) | Type | Duration | Undo? | File:Line |
|----|---------|----------------------|------|----------|-------|-----------|
| OB-01 | Onboarding API error (non-network) | `'Something went wrong. Please try again.'` | error | 3s | No | `onboarding.dart:302` |

### 2.17 Notification Service

| ID | Trigger | Message Text (exact) | Type | Duration | Undo? | File:Line |
|----|---------|----------------------|------|----------|-------|-----------|
| NS-01 | Invalid notification tap data | `'Invalid notification data'` | error | 3s | No | `notification_service.dart:147` |
| NS-02 | Notification navigation exception | `'Something went wrong'` | error | 3s | No | `notification_service.dart:165` |

### 2.18 Static Pages

| ID | Trigger | Message Text (exact / source) | Type | Duration | Undo? | File:Line |
|----|---------|-------------------------------|------|----------|-------|-----------|
| SP-01 | Static page load failed | `staticPage.message` | error | 3s | No | `static_pages_notifier.dart:97` |

---

## 3. Missing Toasts (Must Add)

The following user-facing events currently produce **no toast feedback** despite being significant enough to warrant one:

| # | Missing Event | Recommended Message | Type | Priority |
|---|--------------|---------------------|------|----------|
| M-01 | **Email send failed with retry** — CO-10 fires `'Something went wrong'` with no retry affordance | `'Failed to send. Tap to retry.'` with a Retry action | error | CRITICAL |
| M-02 | **Undo-send window** — email send (CO-09) gives no cancellation window before delivery | `'Email sent'` with Undo action for 5–10s window if backend supports delayed delivery | Undo | HIGH |
| M-03 | **Subscription renewed successfully** — no toast after successful auto-renewal or plan-restore | `'Subscription renewed'` | success | HIGH |
| M-04 | **Biometric auth failed — fallback offered** — `authenticateBiometric()` returns `false` silently; the UI may update but there is no user-visible explanation | `'Biometric failed. Please try again or use your PIN.'` | warning | HIGH |
| M-05 | **Account provisioning failed during signup (network)** — `setupProfile()` catch for `NoInternetException` is silent (no toast at all) | `'No connection. Profile setup will complete when reconnected.'` | warning | HIGH |
| M-06 | **New email received (foreground)** — Firebase/FCM notifications are handled natively only; no in-app toast shown when the user is actively using the app | `'New message from {sender}'` (tappable) | info | MEDIUM |
| M-07 | **Bulk action count confirmation** — I-16/AR-19 Undo toasts say "Moving to Archive" but do not confirm how many emails were affected | `'N emails moved to Archive'` (with N > 1 shown) | Undo | MEDIUM |
| M-08 | **Contact sync complete** — sync upload triggers API call but no completion toast; I-11 covers the toggle API, not the upload itself | `'Contacts synced'` | success | MEDIUM |
| M-09 | **Rate limit hit (HTTP 429)** — no specific handling; currently falls through to generic `'Something went wrong'` | `'Too many requests. Please wait a moment.'` | warning | MEDIUM |
| M-10 | **Payment declined (card declined vs. network error)** — SU-14 covers socket failure with generic message, not card decline specifically | `'Payment declined. Please check your card details.'` | error | MEDIUM |
| M-11 | **OTP initial send standardization** — A-01 passes raw `response['message']` from server; if the server returns a non-standard string the success feedback is unpredictable | Standardize to `'OTP sent to your phone'` | success | LOW |
| M-12 | **Draft discarded confirmation** — CO-14 "Message Deleted" fires only on confirmed delete; the `deleteDraft` action sheet option resolves correctly | Verify CO-14 fires reliably across all cancel paths | — | LOW |
| M-13 | **Email marked as spam** — no spam functionality exists yet; when added, requires toast | `'Marked as spam'` with Undo | Undo | FUTURE |

---

## 4. Toasts to Suppress or Demote

| # | Toast ID(s) | Issue | Recommendation |
|---|------------|-------|----------------|
| D-01 | SE-01, SE-04, SE-06, SE-09 | **Confirming obvious toggle actions** — "Biometrics Enabled", "Settings updated", notification/sync-contacts toggle success. The switch state itself reflects the change visually. | Suppress success toasts for toggle switches. Retain all error toasts. |
| D-02 | TG-03, TG-05, TG-07 | **Raw `e.toString()` in tag operation exceptions** — may expose internal error codes, stack trace fragments, or HTTP status strings to users. | Replace with `'Something went wrong'`. |
| D-03 | A-06, A-12, A-14 | **`e.toString()` in auth exception paths** — exposes internal exception details during login/signup. | Map through `mapDescopeError()` or collapse to `'Something went wrong'`. |
| D-04 | AP-02 | **`"Error: $e"`** exposed in attachment preview save. | Replace with `'Save failed. Please try again.'` |
| D-05 | S-02 | **`'Origin: $origin'`** — diagnostic toast left in production at `passkey_notifier.dart:118`. Fires on **every Android passkey enrollment** as a red error toast. The code comment marks it "TEMPORARY DIAGNOSTIC". | **Remove immediately** before the next production release. |
| D-06 | I-15, AR-22, VE-17 | **Type `'info'` falls through to yellow `warning` styling** — misleads users. "Emails are already present in a contact" and "Open not available for this file type" are neutral/informational, not warnings. | Add `'info'` as a named case in `CustomToast` with a neutral blue-grey background, or change these calls to `'success'`. |
| D-07 | SU-23, SU-24 | **Payment in-progress toasts auto-dismiss in 3s** — critical status during a financial transaction. Users switch screens and miss it. | Increase duration to 8–10s or make persistent. SU-24 (2-minute message) is especially important and should persist until dismissed. |
| D-08 | CO-13 | **Draft saved on every auto-save invocation** — if auto-save runs silently in the background multiple times per compose session, users will be repeatedly toasted. | Fire CO-13 only once per compose session (debounce flag), or suppress entirely for background auto-saves. |
| D-09 | I-19/I-20, AR-16, SW-02 | **Duplicate "Please select…" validation toasts** — the same validation message fires from `inbox_notifier`, `archive_list_notifier`, and `custom_dismissible` independently. | Consolidate validation into a single shared utility. |
| D-10 | VE-04, VE-05 | **Two different error messages for the same attachment-open failure scenario on iOS** (`'File preview unavailable'` and `'Cannot open this file type'`). | Standardize to `'Cannot open this file type'` for all three iOS error paths. |
| D-11 | C-03 | **Bypasses the no-internet guard via mixed case** — the guard checks `message.toLowerCase().contains('no internet')`, but `'No Internet'` (mixed case) is passed to `animatedToast()` which then runs the guard and correctly intercepts it. This works today, but is fragile. | Replace with `CommonService.showConnectivityBanner()` directly, or document the case-insensitive contract. |
| D-12 | SE-12, SE-13 | **Subscription detail errors fire as toast with no inline error state** — when the subscription screen opens and data is missing, a toast fires but the visible screen shows no explanation. | Show an inline error message on the screen instead of relying solely on the toast. |
| D-13 | PR-02 | **`'Print failed: $e'`** — raw exception string in web print. | Replace with `'Print failed. Please try again.'` |

---

## 5. Toast UX Recommendations

### 5.1 Accessibility
**Current state: Poor.**

`CustomToast` is a `Material > Container > Row` with no `Semantics` wrapper. Neither TalkBack (Android) nor VoiceOver (iOS) will announce toast messages automatically.

**Recommendations:**
- Wrap `CustomToast` in `Semantics(liveRegion: true, label: message)` so screen readers announce the message on appearance.
- `Fluttertoast` (`showToast()`) has similar gaps; migrating to `animatedToast()` (see §5.6) and adding semantics there resolves both.

### 5.2 Error Toast Duration
**Current state: All toasts auto-dismiss in 3 seconds, including errors.**

3 seconds is insufficient for error messages which are often longer and which users need to read and act upon. This is especially problematic for users with cognitive disabilities and for messages like SU-24 (payment status) or I-22 (contacts permission).

**Recommendation:**
- Error toasts: **5–6 seconds** auto-dismiss.
- Success toasts: 3 seconds (current behavior is acceptable).
- Destructive-action Undo toasts: **5+ seconds** (see §5.4).
- Warning toasts: 4 seconds.
- The duration should be a named constant in `CommonService`, not hardcoded in the `Timer`.

### 5.3 Success Toast Duration
**Current state: 3 seconds — acceptable for most success confirmations.**

Short messages ("Email sent", "Draft saved", "Card Deleted") are readable in 3 seconds. No change required here.

### 5.4 Undo Toast Window
**Current state: 3-second Undo window.**

The undo `Timer` fires the API call at 3 seconds — the same instant the toast auto-dismisses. This creates a race condition where tapping Undo at 2.9s may not reliably cancel the API call. The underlying `_undoTimer` and the toast dismiss timer are effectively the same 3-second value.

**Recommendation:**
- Increase the Undo window to **5 seconds**. Set `_undoTimer` duration to `Duration(seconds: 5)` and align `_toastDismissTimer` to match.
- This matches iOS Mail's undo-send convention and the standard 5s destructive-action pattern.

### 5.5 Positioning

**Current state:**
- `checkMainScreen = true`: bottom elevated above nav bar (platform-aware iOS/Android).
- `checkMainScreen = false` (default): fixed `bottom: 20`.
- Connectivity banner: fixed `bottom: 20`.

**Issues:**
1. **Web (desktop):** Toasts appear at bottom-center. Industry convention for desktop web is **top-right** corner. Bottom-center is appropriate for mobile; on web it competes with the browser status bar and footer content.
2. **Mobile with keyboard open:** `bottom: 20` does not account for `MediaQuery.viewInsets.bottom`. Toasts may be hidden behind the software keyboard during compose.

**Recommendations:**
- Web desktop: Position at `top: 24, right: 24` with `maxWidth: 400px` and `left: auto`.
- Mobile (keyboard open): Use `MediaQuery.of(context).viewInsets.bottom + 20` as the bottom offset inside `animatedToast()` when `checkMainScreen = false`.

### 5.6 Theme Consistency

**Current state:**
- `animatedToast()` uses `AppStyles.bgSuccess/bgError/bgWarn` — consistent with design system.
- `showToast()` (Fluttertoast) uses hardcoded `Colors.red` / `Colors.green` — breaks consistency.
- `'info'` type falls through to the `warning` (yellow) case in `CustomToast`.

**Recommendations:**
1. Add `'info'` as a named case in `CustomToast` (neutral blue or blue-grey, e.g. `Color(0xFFE3F2FD)` bg / `Color(0xFF1565C0)` text).
2. Migrate all `showToast()` calls to `animatedToast()`. Affected files:
   - `add_contact_notifier.dart:146,210,222`
   - `edit_contact_notifier.dart:109,117,143`
   - `view_contact_notifier.dart:118,142,149,169,176,184`
3. Remove `fluttertoast` from `pubspec.yaml` once migration is complete.

### 5.7 Toast Queue System

**Current state:** A new `animatedToast()` call immediately removes the previous overlay. If two toasts fire in rapid succession, the first is silently dropped.

**Problem scenarios:**
- Session expiry + inbox reload error fire simultaneously → user sees only one.
- Multiple tag operations in rapid succession → intermediate toasts dropped.

**Recommendation:** Implement a simple FIFO queue with a maximum depth of 3:
```dart
static final Queue<_ToastItem> _queue = Queue();

static void animatedToast(String message, String type, [...]) {
  _queue.add(_ToastItem(message, type, undoMethod, checkMainScreen));
  if (_queue.length == 1) _showNextFromQueue();
}

static void _showNextFromQueue() {
  if (_queue.isEmpty) return;
  final item = _queue.first;
  // ... build overlay ...
  _toastDismissTimer = Timer(duration, () {
    _queue.removeFirst();
    _showNextFromQueue();
  });
}
```

### 5.8 Long Message Truncation

**Current state:** `CustomToast` renders `maxLines: 1` with `TextOverflow.ellipsis`. Several important messages exceed one line and are silently cut off:

- `'Please add at least one of: recipient, subject, body, or attachment to save as draft'` (CO-01) — ~80 chars
- `'Contacts permission permanently denied. Enable it in App Settings to sync.'` (I-22) — ~74 chars
- `'This is taking longer than expected. We'll send you an email once confirmed.'` (SU-24) — ~75 chars
- `'Open not available for this file type. Download to open.'` (VE-17) — ~55 chars

**Recommendation:** Increase `maxLines` to **2** for error and warning toasts. Success toasts can keep `maxLines: 1`.

### 5.9 Critical: Diagnostic Toast in Production

**`S-02` — `passkey_notifier.dart:118`:**
```dart
CommonService.animatedToast('Origin: $origin', 'error');
```
This line is explicitly tagged "TEMPORARY DIAGNOSTIC — remove after Android passkey debugging" in the code comment directly above it. It fires on **every Android passkey enrollment attempt** as a red error toast showing the raw RP origin string to the user. This must be removed before the next production release.

### 5.10 Server Message Pass-Through

Approximately 60% of all toast messages pass raw `response['message']` or `resp['message']` strings from the API without any sanitization. Server messages may:
- Contain technical jargon (e.g. `"Unauthorize Request"`, `"jwt malformed"`, `"Validation error"`)
- Be in a different language or casing than expected
- Include internal error identifiers

**Recommendation:** Introduce a sanitization helper:
```dart
static String _sanitizeMessage(String? msg, String fallback) {
  if (msg == null || msg.trim().isEmpty) return fallback;
  // Suppress known internal patterns
  final lower = msg.toLowerCase();
  if (lower.contains('jwt') || lower.contains('unauthorize') ||
      lower.contains('validation error') || lower.contains('sequelize')) {
    return fallback;
  }
  return msg;
}
```
Apply this to all `animatedToast(response['message'], ...)` call sites.

---

## 6. Summary Statistics

| Category | Approximate Toast Calls |
|----------|------------------------|
| Authentication | 20 |
| Session/Security | 2 |
| Connectivity | 3 |
| Inbox | 22 |
| Archive/Sent/Trash | 24 |
| Compose | 16 |
| View Email | 17 |
| Attachment Preview | 2 |
| Contacts | 20 |
| Tags | 9 |
| Settings | 13 |
| Subscription/Checkout | 28 |
| Swipe (CustomDismissible) | 4 |
| Sent Email List | 3 |
| Print/File | 3 |
| Onboarding | 1 |
| Notification Service | 2 |
| Static Pages | 1 |
| **Total** | **~190** |

| Metric | Count |
|--------|-------|
| Toasts with Undo button | 3 locations |
| Persistent banners | 1 (connectivity) |
| Diagnostic toast in production | **1 (must remove)** |
| Type `'info'` rendered as warning yellow | 5 call sites |
| Raw `e.toString()` exposed to users | 6+ locations |
| `showToast()` (Fluttertoast legacy) calls | ~12 |
| `animatedToast()` calls | ~180 |
| Missing toasts (must add) | 13 identified |
| Toasts to suppress/demote | 13 identified |
