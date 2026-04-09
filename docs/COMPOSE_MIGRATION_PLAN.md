# Compose Screen: Backend WebView → Native Flutter Migration

## Context

The compose email screen (`lib/screens/compose/web_compose.dart`, 1926 lines / 70KB) currently loads a **backend-served HTML page** in an `InAppWebView`. The server renders a Summernote (jQuery WYSIWYG) editor at `${defaultBaseUrl}email/compose?pageId=...&token=...`. Flutter acts as a thin shell: handling navigation, file uploads, and socket communication, while the backend owns the actual compose UI, form state, and rich text editing.

This approach has accumulated significant technical debt, cross-platform issues, and **critical reliability gaps** (false success toasts, no send confirmation, no draft recovery on failure). The user wants an analysis of whether to migrate to a native Flutter compose screen — modeled after the `ViewEmail` paradigm that already works well across web, iOS, and Android.

---

## Question 1: Should Compose Move to Frontend?

**Recommendation: Yes — migrate to native Flutter.**

### Why migrate

| Problem | Impact |
|---------|--------|
| **Cross-origin iframe on web breaks validation** — `web_compose.dart:237-248` returns `{ hasContent: true }` for ALL fields on web because CORS prevents querying the iframe. Dirty tracking (`_isDirty`) also doesn't work on web. | Empty drafts can be saved; no client-side validation on web platform |
| **JWT token exposed in URL** — `validateUrl()` at lines 1047-1074 puts the auth token in query params for both web and native. Appears in server logs, browser history, Referer headers. | Security vulnerability |
| **1926-line monolith with `setState`** — All state managed via `setState` with interleaved socket events, upload paths, JS bridge calls, and 6+ inline dialog builders. No Riverpod, no separation of concerns. | Unmaintainable; untestable; inconsistent with rest of codebase |
| **Summernote is legacy jQuery** — Requires a full browser engine to render. Visible load delay (page load + summernote init + focus polling at lines 336-354). | Poor UX; extra ~50-80MB memory for WebView process |
| **Server-side form state** — `addUpdateDraft` socket event sends only `pageId`/`userId`; the server pulls form state from its own session. | Fragile; no offline capability; tight server coupling |
| **No dark mode** — The backend HTML has no dark mode support. ViewEmail injects CSS, but compose doesn't. | Visual inconsistency |
| **No send confirmation** — `triggerEmail()` shows success toast and navigates away without verifying the server actually sent the email. If socket drops, email is lost silently. | Data loss; user thinks email was sent when it wasn't |
| **False draft save success** — `sendEmail('addDraft')` shows "Draft saved" toast even when socket silently drops the event. Draft content is lost forever. | Data loss; false positive UX |
| **Flaky autocomplete** — Recipient autocomplete dropdown frequently drops mid-typing, cancels input, and has intermittent touch responsiveness. Caused by: (a) `setState()` from `msgOptInApp` socket events rebuilding the widget tree mid-typing, (b) explicit `blur()` calls from button taps killing the dropdown, (c) focus polling race condition where `#recipient` is focused before autocomplete plugin initializes, (d) iOS CSS clipping hiding the dropdown. | Broken UX; users cannot reliably enter recipients |

### Why NOT migrate (and mitigations)

| Risk | Mitigation |
|------|------------|
| Flutter rich text editors less mature than Summernote | Use InAppWebView + bundled Quill.js (see Section 5A) — leverages existing InAppWebView dependency with a proven JS editor, no new Flutter dependency needed |
| Backend API changes needed for draft save & send | **Draft save and email send are currently socket-only** (`addUpdateDraft`, `sendMessage`). No REST endpoint accepts email content as JSON. New endpoints needed: `POST/PUT email/draft`, `POST email/send`. Keep socket events running during migration. |
| Autocomplete for TO/CC/BCC currently server-rendered | **Already solved**: `POST contact/listv2` accepts a `search` param and returns contacts with email addresses. `POST contact/check-email` validates individual emails (used by `AddEmailModal`). No new endpoint needed. |

### Existing API inventory (what we already have)

| Endpoint | Method | Status | Usable for native compose? |
|----------|--------|--------|---------------------------|
| `email/drafts-list` | POST | Exists | Yes — fetch draft list |
| `email/delete-drafts` | POST | Exists | Yes — delete drafts |
| `contact/listv2` | POST | Exists | Yes — **autocomplete** (has `search` param) |
| `contact/check-email` | POST | Exists | Yes — validate recipient before send |
| `user/create-singed-url` | POST | Exists | Yes — attachment upload |
| `email/detail` | POST | Exists | Yes — fetch email for reply/forward |
| `email/draft` | POST/PUT | **Phase 0 DONE** | Yes — create/update draft with JSON body |
| `email/send` | POST | **Phase 0 DONE** | Yes — send with server-side contact check, SES retry, `skipContactCheck` flag |
| `email/draft/:id` | GET | **Phase 0 DONE** | Yes — fetch draft for editing (matches `ViewDraftModel`) |

**Phase 0 backend is committed.** Socket events (`addUpdateDraft`, `sendMessage`) remain for WebView backward compat during migration.

---

## Question 2: Height Management & Layout Design

The compose screen has **two variable-height zones**: the header (To/CC/BCC/Subject/Attachments) and the body (rich text editor). Both can grow/shrink.

### Proposed layout architecture

**Mobile (small screens) — single scroll unit, matching ViewEmail pattern:**

```
Scaffold (resizeToAvoidBottomInset: true)
  body: SafeArea
    SingleChildScrollView          // ← header + editor scroll together
      Column
        FromField                  // single row, read-only
        RecipientField (To)        // collapsed: chips + "+N" overflow indicator
        [if expanded] RecipientField (CC)
        [if expanded] RecipientField (BCC)
        SubjectField               // single row
        AttachmentRow              // horizontal scroll, 0-N chips
        Divider
        SizedBox(height: editorHeight)
          InAppWebView (Quill.js)  // scrolling disabled (NeverScrollableScrollPhysics)
          [if reply/forward]
            "--- Original Message ---"
            flutter_widget_from_html  // read-only quoted content
```

The editor's internal scroll is disabled (`NeverScrollableScrollPhysics` equivalent via JS `overflow: hidden`). The editor reports its content height to Flutter via JS bridge (same pattern as `native_app_html_view_native.dart`), and the `SizedBox` expands to fit. The parent `SingleChildScrollView` handles all scrolling — header and body move as one unit, exactly like ViewEmail.

**Desktop/Tablet (reading pane) — split layout:**

```
Scaffold
  body: Column
    ComposeHeaderBar              // fixed: "New Message" title + Save/Delete
    Expanded
      SingleChildScrollView       // still a single scroll unit
        Column
          FromField
          RecipientField (To)     // collapsed: chips + "+N"
          [if expanded] CC/BCC
          SubjectField
          AttachmentRow
          Divider
          SizedBox(height: editorHeight)
            InAppWebView (Quill.js)
```

### Recipient field "+N" overflow indicator

Each `RecipientField` has two modes:

**Collapsed (default):**
- Shows chips in a single `Row` with `overflow: Clip`
- When chips exceed the available width, the last visible position shows a "+N" chip (e.g., "+3")
- Tapping the row or "+N" chip expands to full mode
- Minimizes header height on small screens

**Expanded (on tap):**
- Shows all chips in a `Wrap` layout (multiple lines)
- Shows the text input for adding/editing recipients
- Shows the autocomplete dropdown
- Tapping outside or pressing done collapses back

```dart
// In RecipientField:
if (isCollapsed) {
  return GestureDetector(
    onTap: () => setState(() => isCollapsed = false),
    child: SizedBox(
      height: 40,
      child: Row(
        children: [
          Text('$label: ', style: labelStyle),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              // Measure which chips fit in available width
              // Show those chips + "+N" for the rest
              return _buildCollapsedChips(constraints.maxWidth);
            }),
          ),
        ],
      ),
    ),
  );
} else {
  return Column(
    children: [
      Wrap(children: allChipWidgets),
      RawAutocomplete<String>(...), // input + dropdown
    ],
  );
}
```

### Key design decisions

1. **Single scroll unit on mobile** — Header and body scroll together in one `SingleChildScrollView`, matching the ViewEmail paradigm (`view_email.dart:746`). The editor's height is measured via JS (same `evaluateJavascript` pattern from `native_app_html_view_native.dart`) and set on a `SizedBox`. The editor itself does NOT scroll internally — the parent scroll handles everything. This maximizes reading/writing space on small screens.

2. **Editor height measurement** — The Quill.js editor reports its content height to Flutter via `flutter_inappwebview.callHandler('onHeightChange', height)`. Flutter updates a `ValueNotifier<double>` that drives the `SizedBox`. As the user types and content grows, the SizedBox grows, and the `SingleChildScrollView` accommodates it. Same proven pattern used by `native_app_html_view_native.dart:140-216`.

3. **+N overflow for recipients** — Collapsed recipient rows show visible chips + "+N" indicator. Uses `LayoutBuilder` to measure available width and determine how many chips fit. Tap to expand/edit. This keeps the header compact on small screens while still showing who the email is addressed to.

4. **CC/BCC toggle with `AnimatedSize`** — Smooth expand/collapse. When collapsed, CC/BCC fields are removed from the widget tree entirely.

5. **Reading pane integration** — When compose is embedded in the `Inbox` shell (desktop/tablet), the parent provides width constraints. The compose screen fills whatever space is given.

6. **Keyboard avoidance** — Set `resizeToAvoidBottomInset: true`. The `SingleChildScrollView` auto-scrolls to keep the focused field visible when the keyboard appears. This is standard Flutter behavior that works naturally with native text fields. The header fields are native Flutter widgets, so keyboard avoidance works naturally.

---

## Question 3: Security & Performance Implications

### Security improvements

| Area | Current (WebView) | Proposed (Native) |
|------|-------------------|-------------------|
| **Auth tokens** | JWT in URL query params — visible in logs, browser history, Referer headers | HTTP `Authorization` header only — never in URLs |
| **XSS surface** | Full browser engine rendering server HTML with Summernote; user content rendered as raw HTML | Quill.js Delta document model (structured JSON); HTML only generated at send time via controlled serializer |
| **Cross-origin** | Web iframe requires `allow-scripts` sandbox; CORS prevents validation | Eliminated entirely — no iframe (local asset loaded in InAppWebView) |
| **Process isolation** | WebView runs in separate OS process (good for isolation, bad for control) | Editor still in InAppWebView (isolated), but header fields are native Flutter |
| **Send confirmation** | No verification — success toast shown before server confirms | REST `POST email/send` with HTTP response code verification before showing success |

### Performance improvements

| Area | Current | Proposed |
|------|---------|----------|
| **Memory** | WebView loads entire backend page (Summernote + jQuery + full form HTML) | Local Quill.js (~30KB) in InAppWebView — no server round-trip |
| **Startup** | Server HTML load + Summernote init + JS bridge setup (visible delay, loading overlay needed) | Local asset loads instantly from bundle; native header renders immediately |
| **JS bridge** | 5+ `evaluateJavascript()` calls on page load, each an async IPC round-trip (10-50ms each) | Minimal bridge: only for editor content get/set and dirty tracking |
| **Draft save** | Socket event → server reads WebView session state → persists (multi-hop) | Direct REST POST with JSON body (single HTTP round-trip with 30s timeout) |
| **Rendering** | Double: server HTML → WebView DOM layout → Flutter composites texture | Header: pure Flutter. Editor: local InAppWebView (no network load). |

### Retained security

- Attachment upload flow (signed URL → S3 PUT) is sound and reused unchanged
- `AddEmailModal` contact-check flow before send is preserved

---

## Question 4: UX/UI Consistency Benefits

### Comparison with ViewEmail paradigm

| Aspect | ViewEmail (native) | Current Compose (WebView) | Proposed Compose (native) |
|--------|-------------------|--------------------------|--------------------------|
| **Dark mode** | Flutter `Theme.of(context)` + CSS injection for HTML body | No dark mode at all | Full Flutter theming for header; CSS dark mode for Quill.js editor |
| **Transitions** | GoRouter push animations | Blank white rectangle until `onLoadStop` fires; opacity flip from 0→1 | Instant render — header is native Flutter, editor loads local asset |
| **Loading states** | Shimmer/none (fast) | `ColoredBox` overlay + server spinners hidden by JS injection | None needed (local asset) |
| **Accessibility** | Flutter `Semantics` on all widgets | WebView invisible to Flutter a11y tree; Summernote has poor a11y | Full Flutter semantics on header fields; Quill.js has better a11y than Summernote |
| **Error handling** | `Result<T>` pattern + `CommonService.animatedToast()` | Inconsistent: some toasts, some silent `catch (e) {}` | Consistent `Result<T>` pattern with verified server responses |
| **Responsive** | `ResponsiveLayoutBuilder` with mobile/tablet/desktop callbacks | `ResponsiveWebComposeWrapper` wraps WebView in `Inbox` shell | Same `ResponsiveLayoutBuilder` pattern as ViewEmail |
| **State management** | Riverpod `NotifierProvider` + Freezed | Raw `setState` with 1926 lines of mixed concerns | Riverpod `NotifierProvider` + Freezed |
| **Offline** | Cached via `AppCache` | Impossible (server renders UI) | Autosave to local storage; sync on reconnect |
| **Send reliability** | N/A | No confirmation; false success toasts | REST with timeout + local draft backup on failure |

---

## Question 5: Implementation Plan

### 5A. Rich Text Editor: InAppWebView + Bundled Quill.js

**Recommended approach: Bundle Quill.js as a local asset loaded in InAppWebView.**

This leverages the existing `flutter_inappwebview` dependency (already used throughout the app) and avoids adding a new Flutter package. The key difference from the current approach: the editor HTML is a **local asset** (no server round-trip, no CORS issues, works offline).

**Why InAppWebView + Quill.js over flutter_quill:**

| Factor | InAppWebView + Quill.js | flutter_quill |
|--------|------------------------|---------------|
| **New dependency** | None (InAppWebView already in pubspec) | New package + Delta-to-HTML converter |
| **Editor maturity** | Quill.js: production-proven, 41k GitHub stars | flutter_quill: 2.5k stars, younger ecosystem |
| **HTML round-trip** | Native HTML in/out — no lossy conversion | Delta format requires HTML↔Delta conversion (lossy for complex emails) |
| **Reply/forward emails** | Load original HTML directly into editor | Must convert arbitrary email HTML to Delta (very lossy for marketing emails) |
| **Team familiarity** | Team already manages InAppWebView + JS bridge patterns | New paradigm to learn |
| **Toolbar** | Quill.js built-in toolbar, CSS-customizable | Flutter widget toolbar, Dart-customizable |
| **Dark mode** | CSS injection (same pattern as `native_app_html_view_native.dart`) | Flutter theme integration (better) |
| **Platform behavior** | Consistent across iOS/Android/web (same JS engine) | Consistent (same Dart code) |
| **Height measurement** | Proven pattern exists in `native_app_html_view_native.dart` | Native Flutter layout (simpler) |

**The decisive advantage: HTML round-trip fidelity.** Email is fundamentally an HTML medium. Reply/forward requires loading existing HTML, the user edits it, and the result is sent as HTML. Quill.js works natively with HTML. `flutter_quill` uses Delta format, requiring HTML→Delta on load and Delta→HTML on save — this conversion is lossy for complex email HTML (tables, inline styles, marketing layouts).

**Implementation: `assets/editor/compose_editor.html`**

A self-contained HTML file bundled in the app:
- Loads Quill.js from local bundle (or CDN with local fallback)
- Exposes `getContent()` / `setContent(html)` / `isDirty()` via `window` functions
- Communicates changes to Dart via `flutter_inappwebview.callHandler('onEditorChange')`
- Supports dark mode via CSS variables injected from Flutter
- ~30KB total (Quill.js minified)

### 5B. New file structure

```
lib/screens/compose/
  compose_screen.dart                    # ConsumerStatefulWidget entry point
  compose_riverpod/
    compose_state.dart                   # Freezed immutable state
    compose_state.freezed.dart           # Generated
    compose_notifier.dart                # NotifierProvider business logic
    compose_responsive.dart              # ResponsiveLayoutBuilder switcher
    layouts/
      compose_mobile_layout.dart         # Full-screen compose
      compose_tablet_layout.dart         # In reading pane (landscape)
      compose_desktop_layout.dart        # In reading pane (always)
  widgets/
    compose_action_bar.dart              # Send/Attach buttons (tablet/desktop)
    compose_header_bar.dart              # Title + Delete/Save (tablet/desktop)
    recipient_field.dart                 # Tag-chip email input + autocomplete
    subject_field.dart                   # Standard text field
    from_field.dart                      # Read-only sender display
    attachment_row.dart                  # Horizontal attachment chips
    attachment_chip.dart                 # Single file chip with remove + progress
    compose_editor.dart                  # InAppWebView + Quill.js wrapper
    cc_bcc_toggle.dart                   # Expand/collapse CC/BCC
    compose_confirmation_dialog.dart     # Save/Delete/Discard dialog
    quoted_message_view.dart             # Read-only quoted HTML for reply/forward
  web_compose.dart                       # KEEP: legacy, behind feature flag

assets/editor/
  compose_editor.html                    # Self-contained Quill.js editor
  quill.min.js                           # Quill.js library (local bundle)
  quill.snow.css                         # Quill.js theme
```

### 5C. ComposeState (Freezed)

```dart
@freezed
abstract class ComposeState with _$ComposeState {
  const factory ComposeState({
    @Default(ComposeMode.newMessage) ComposeMode mode,
    int? emailId,                    // for reply/forward/updateDraft
    int? draftId,                    // server-assigned after first save
    @Default([]) List<String> toRecipients,
    @Default([]) List<String> ccRecipients,
    @Default([]) List<String> bccRecipients,
    @Default(false) bool showCcBcc,
    @Default('') String subject,
    @Default('') String bodyHtml,    // HTML from Quill.js editor
    String? quotedHtml,              // original email for reply/forward
    @Default('') String fromEmail,
    @Default('') String fromName,
    @Default([]) List<ComposeAttachment> attachments,
    @Default(0) int totalAttachmentBytes,
    @Default(false) bool isLoading,
    @Default(false) bool isSending,
    @Default(false) bool isSavingDraft,
    @Default(false) bool isDirty,
    @Default(false) bool hasLocalBackup,    // autosave exists
    @Default(SendStatus.idle) SendStatus sendStatus,
    int? sentEmailId,                        // returned by POST email/send on success
    @Default([]) List<String> failedRecipients, // external recipients where SES failed (partial success)
    String? error,
  }) = _ComposeState;
}

enum ComposeMode { newMessage, reply, replyAll, forward, updateDraft }
enum SendStatus { idle, sending, confirming, sent, partialFailure, failed }
```

### 5D. ComposeNotifier pattern

```dart
final composeProvider = NotifierProvider.autoDispose
    .family<ComposeNotifier, ComposeState, ComposeParams>(ComposeNotifier.new);

class ComposeNotifier extends AutoDisposeFamilyNotifier<ComposeState, ComposeParams> {
  bool _disposed = false;
  Timer? _autosaveTimer;

  @override
  ComposeState build(ComposeParams arg) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _autosaveTimer?.cancel();
    });
    Future.microtask(() => _init(arg));
    return const ComposeState(isLoading: true);
  }
}
```

Key methods:
- `_init()` — Load user data, check for local backup, if reply/forward/draft → fetch via `GET email/draft/:id` (new endpoint) or `email/detail` (for reply/forward of sent emails)
- `updateRecipients()`, `updateSubject()`, `updateBody()` — Set fields + mark dirty + trigger autosave timer
- `addAttachment()` — File pick → validate 25MB limit → signed URL → S3 upload → add to state (no `newUpload` socket emit)
- `removeAttachment()` — Remove + update totalBytes
- `_autosaveToLocal()` — Save full draft state to `SecureStorageService` (see 5E)
- `saveDraftToServer()` — `POST email/draft` (new) or `PUT email/draft/:id` (update) with JSON body + 30s timeout. Response `data.draftId` stored in state.
- `send({skipContactCheck})` — `POST email/send` → handle 4 response cases: success (read `data.emailId`), unknownContacts (show opt-in dialog → re-send with `skipContactCheck: true`), failedRecipients (partial success, navigate to Sent), failure (save to drafts)
- `deleteDraft()` — Existing `POST email/delete-drafts`
- `recoverLocalDraft()` — Restore from `SecureStorageService` if local backup exists

### 5E. Autosave & Draft Recovery

**Current problem:** Draft content exists only in the WebView. If the app crashes, network drops, or `addUpdateDraft` socket silently fails, the content is **lost forever** with a false "Draft saved" success toast.

**Solution: Two-tier autosave system.**

#### Tier 1: Local autosave (immediate, offline-safe)

```dart
// In ComposeNotifier:
void _startAutosaveTimer() {
  _autosaveTimer?.cancel();
  _autosaveTimer = Timer(const Duration(seconds: 5), () {
    if (_disposed || !state.isDirty) return;
    _autosaveToLocal();
  });
}

Future<void> _autosaveToLocal() async {
  final backup = {
    'mode': state.mode.name,
    'emailId': state.emailId,
    'draftId': state.draftId,
    'to': state.toRecipients,
    'cc': state.ccRecipients,
    'bcc': state.bccRecipients,
    'subject': state.subject,
    'bodyHtml': state.bodyHtml,
    'quotedHtml': state.quotedHtml,
    'attachments': state.attachments.map((a) => a.toJson()).toList(),
    'savedAt': DateTime.now().toIso8601String(),
  };
  await SecureStorageService().writeObjectData('compose_local_draft', backup);
  state = state.copyWith(hasLocalBackup: true);
}
```

- Triggered: 5 seconds after any content change (debounced)
- Also triggered: on `AppLifecycleState.paused` (app backgrounded) and `dispose()` (navigating away without save)
- Storage: `SecureStorageService` with key `compose_local_draft`
- On compose screen init: check for local backup → offer to restore

#### Tier 2: Server draft save (periodic, with confirmation)

```dart
Future<bool> saveDraftToServer() async {
  state = state.copyWith(isSavingDraft: true);
  try {
    final payload = {
      'to': state.toRecipients,
      'cc': state.ccRecipients,
      'bcc': state.bccRecipients,
      'subject': state.subject,
      'body': state.bodyHtml,
      'attachments': state.attachments.map((a) => {
        'fileName': a.fileName, 'type': a.fileType, 'path': a.serverPath, 'size': a.sizeBytes,
      }).toList(),
      if (state.draftId != null) 'draftId': state.draftId,
    };

    // REST call with 30s timeout (matches ApiService pattern)
    final resp = await ApiService().post('email/draft', payload);

    if (_disposed) return false;

    if (resp['success'] == true) {
      final newDraftId = resp['data']?['draftId'];
      state = state.copyWith(
        draftId: newDraftId ?? state.draftId,
        isSavingDraft: false,
        isDirty: false,
      );
      // Clear local backup after confirmed server save
      await SecureStorageService().deleteData('compose_local_draft');
      return true;
    } else {
      state = state.copyWith(isSavingDraft: false, error: resp['message']);
      return false;
    }
  } catch (e) {
    if (_disposed) return false;
    state = state.copyWith(isSavingDraft: false, error: 'Draft save failed');
    // Local backup still exists — user won't lose content
    return false;
  }
}
```

- Uses REST `POST email/draft` (not socket) — has 30s timeout, returns success/failure
- On failure: toast shows error, **local backup still exists**, user can retry
- On success: clears local backup, updates `draftId` for future updates

#### Recovery flow

When compose screen opens:
1. Check `SecureStorageService().readObjectData('compose_local_draft')`
2. If backup exists and is less than 24 hours old:
   - Show dialog: "You have an unsaved draft from [time]. Restore it?"
   - "Restore" → populate all fields from backup
   - "Discard" → delete backup, start fresh
3. If backup is older than 24 hours, auto-delete it

### 5F. Send Confirmation & Failure Recovery

**Current problem:** `triggerEmail()` in `web_compose.dart:1538-1580` emits a socket `sendMessage` event. The ACK callback checks `data == 'yes'` but has **no timeout**. If socket is disconnected, `emitEventWithAck()` silently returns without emitting (line 141 of `socket_service.dart`). The user sees the loading spinner indefinitely, and the email is lost.

**Solution: REST-based send with explicit confirmation.**

```dart
Future<void> send({bool skipContactCheck = false}) async {
  // 1. Client-side validation (replaces server-side canSend)
  if (state.toRecipients.isEmpty) {
    state = state.copyWith(error: 'Please add at least one recipient');
    return;
  }

  // 2. Save local backup first (insurance)
  await _autosaveToLocal();

  state = state.copyWith(sendStatus: SendStatus.sending);

  // 3. Extract HTML from Quill.js editor
  final bodyHtml = await _getEditorContent();

  // 4. Build payload
  final payload = {
    'to': state.toRecipients,
    'cc': state.ccRecipients,
    'bcc': state.bccRecipients,
    'subject': state.subject,
    'body': bodyHtml,
    'attachments': state.attachments.map((a) => a.toServerJson()).toList(),
    if (state.emailId != null) 'replyToEmailId': state.emailId,
    if (state.draftId != null) 'draftId': state.draftId,
    'type': state.mode.name,
    'skipContactCheck': skipContactCheck,
  };

  // 5. REST send with timeout
  state = state.copyWith(sendStatus: SendStatus.confirming);
  try {
    final resp = await ApiService().post('email/send', payload);
    if (_disposed) return;

    if (resp['success'] == true) {
      // 6. CONFIRMED sent — safe to show success and navigate
      final emailId = resp['data']?['emailId'];
      state = state.copyWith(sendStatus: SendStatus.sent, sentEmailId: emailId);
      await SecureStorageService().deleteData('compose_local_draft');
      CommonService.animatedToast('Email sent', 'success');
      _refreshCounts();

    } else if (resp['data']?['unknownContacts'] != null) {
      // 7. SERVER-SIDE CONTACT CHECK — unknown contacts found
      // Email was NOT sent. Show opt-in dialog, then re-send with skip flag.
      final unknownContacts = List<String>.from(resp['data']['unknownContacts']);
      state = state.copyWith(sendStatus: SendStatus.idle);
      final cancelled = await _showContactOptInFlow(unknownContacts);
      if (cancelled || _disposed) return;
      // Re-send — user resolved contacts or chose to skip
      await send(skipContactCheck: true);

    } else if (resp['data']?['failedRecipients'] != null) {
      // 8. PARTIAL SUCCESS — internal recipients delivered, SES failed for external
      // Do NOT save to drafts — the email exists in Sent folder for internal recipients
      final failed = List<String>.from(resp['data']['failedRecipients']);
      final emailId = resp['data']?['emailId'];
      state = state.copyWith(
        sendStatus: SendStatus.partialFailure,
        sentEmailId: emailId,
        failedRecipients: failed,
      );
      CommonService.animatedToast(
        'Sent, but delivery failed for: ${failed.join(", ")}',
        'warning',
      );

    } else {
      // 9. Server rejected — save to drafts
      state = state.copyWith(
        sendStatus: SendStatus.failed,
        error: resp['message'] ?? 'Failed to send email',
      );
      CommonService.animatedToast(
        resp['message'] ?? 'Failed to send. Your draft has been saved.',
        'error',
      );
      await saveDraftToServer();
    }
  } catch (e) {
    if (_disposed) return;
    // 10. Network/timeout error — save to drafts (server if online, local if offline)
    final draftSaved = await saveDraftToServer();
    if (!draftSaved) await _autosaveToLocal();
    state = state.copyWith(
      sendStatus: SendStatus.failed,
      error: 'Send failed. Message saved to Drafts.',
    );
    CommonService.animatedToast(
      'Message could not be sent. Saved to Drafts.',
      'error',
    );
  }
}
```

**Send failure strategy: No outbox — save to drafts + notify user.**

There is no outbox folder in the UI. The flow is binary:
- **Success** → "Email sent" toast, navigate away, email appears in Sent folder
- **Failure** → Auto-save as draft, show failure notification, user can retry from Drafts

```dart
// In send() — failure handling:
} catch (e) {
  if (_disposed) return;
  // Save to drafts (server if online, local if offline)
  final draftSaved = await saveDraftToServer();
  if (!draftSaved) await _autosaveToLocal();

  state = state.copyWith(
    sendStatus: SendStatus.failed,
    error: 'Send failed. Message saved to Drafts.',
  );
  CommonService.animatedToast(
    'Message could not be sent. Saved to Drafts.',
    'error',
  );
  // Navigate back to drafts after a short delay so user sees the toast
}
```

**Backend retry (server-side, not client-side):** The `POST email/send` endpoint should implement server-side retry logic (e.g., 3 attempts with exponential backoff for SES failures). If all retries fail, the backend returns `{ success: false }` and the client saves to drafts. The client does NOT retry — it trusts the server's final answer.

**Key reliability improvements:**
1. **Local backup before send** — Content is always persisted before attempting send
2. **REST with 30s timeout** — No infinite wait (unlike current socket ACK)
3. **Response verification** — Only shows "sent" toast after server confirms `success: true`
4. **Failure → save to drafts** — If send fails, auto-save as draft (no content loss)
5. **No outbox** — Binary outcome: Sent folder or Drafts folder
6. **SendStatus enum** — UI shows: sending spinner → success toast OR failure toast + saved to drafts

### 5G. Recipient field — fixing the flaky autocomplete

The current autocomplete is server-rendered inside the WebView and has multiple failure modes. The native `RecipientField` widget eliminates all of them:

```dart
// lib/screens/compose/widgets/recipient_field.dart
class RecipientField extends ConsumerStatefulWidget {
  final String label;            // "To", "Cc", "Bcc"
  final List<String> recipients;
  final ValueChanged<List<String>> onChanged;
  final FocusNode focusNode;
  // ...
}
```

**Implementation details:**
- **Chip display:** `textfield_tags` (already in pubspec) — renders entered emails as removable chips
- **Autocomplete dropdown:** Flutter's `RawAutocomplete` widget — renders in an `Overlay` layer, **never clipped** by parent CSS/overflow
- **Search:** Debounced 300ms query to existing `POST contact/listv2` with `search` param
- **Validation:** Email regex on chip add; also accepts comma/semicolon-separated paste
- **State isolation:** `TextEditingController` persists across parent rebuilds — no more lost input from `setState()`. Riverpod state changes in the notifier don't affect the controller.

**How each current bug is fixed:**

| Current bug | Root cause | Native fix |
|-------------|-----------|------------|
| Dropdown drops mid-typing | `setState()` from `msgOptInApp` rebuilds widget tree → WebView re-renders → dropdown lost | `RawAutocomplete` owns its own `Overlay` entry; parent rebuilds don't affect it |
| Input cancelled while typing | WebView `blur()` from button taps (send/attach); focus polling race conditions | Native `FocusNode` — no `blur()` calls; no polling; focus is deterministic |
| Touch/click unresponsive on suggestions | WebView touch passthrough + JS bridge latency for tap events | `InkWell`/`GestureDetector` on native Flutter widgets — instant, reliable |
| iOS dropdown clipping | Backend CSS `overflow`/`box-sizing` hides dropdown in WebView | `Overlay` renders above all other widgets — impossible to clip |
| Autocomplete doesn't activate | Focus set before backend autocomplete plugin initializes | `RawAutocomplete` is ready on first frame — no initialization race |

### 5H. Socket event migration

| Current Socket Event | New Approach |
|---------------------|-------------|
| `canSend` (server validates form) | Client-side validation (we have the form state) |
| `msgOptInApp` (server sends back TO/CC/BCC) | Eliminated — server-side batch contact check in `POST email/send` with `skipContactCheck` flag |
| `sendMessage` (triggers send after AddEmailModal) | Replaced by `POST email/send` REST call with timeout + response verification |
| `addUpdateDraft` (server pulls WebView form state) | Replaced by `POST/PUT email/draft` REST call with JSON body |
| `newUpload` (notify server of S3 upload) | **Eliminated for native compose** — attachment refs (`path`, `type`, `size`, `fileName`) included in draft/send payload. Socket handler stays for WebView backward compat during migration. |
| `unReadCount` (refresh badge counts) | Keep unchanged — server emits `sendEmailCount` after send/save/delete |

### 5I. Backend API (Phase 0 — COMPLETE)

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `email/draft` | POST | Create new draft | `{ success, data: { draftId }, message }` |
| `email/draft/:id` | PUT | Update existing draft | `{ success, message }` |
| `email/draft/:id` | GET | Fetch draft for editing (all fields) | `{ success, data: { to, cc, bcc, subject, body, attachments } }` |
| `email/send` | POST | Send email — **must return success only after email is queued/sent** | `{ success, message }` |

**No new contact endpoint needed** — `POST contact/listv2` with `search` param already provides autocomplete, and `POST contact/check-email` handles recipient validation.

**Payload format for draft save and send:**
```json
{
  "to": ["addr1@example.com"],
  "cc": ["addr2@example.com"],
  "bcc": [],
  "subject": "Subject line",
  "body": "<p>HTML body from Quill.js editor</p>",
  "attachments": [
    { "fileName": "doc.pdf", "type": "application/pdf", "path": "email/abc123.pdf", "size": 1234 }
  ],
  "replyToEmailId": 456,  // only for reply/forward
  "type": "reply"          // compose, reply, replyAll, forward
}
```

**Critical for `POST email/send`:** The backend must not return `success: true` until the email is actually queued for delivery. The current socket approach has no such guarantee — the frontend needs a reliable signal.

#### Data migration analysis: NO migration needed

Existing drafts in the database already store all required fields based on the `ViewDraftModel`:

```
Draft DB record (inferred from ViewDraftModel):
├── id (int)                    — draft ID
├── senderId (int)              — user who created the draft
├── subject (string)            — email subject
├── message (string)            — HTML email body
├── isDeleted (bool)            — soft delete flag
├── created / updated (string)  — timestamps
├── receivers[]                 — related table
│   ├── receiverEmail (string)
│   ├── type (string)           — "to", "cc", "bcc"
│   └── draftId (int)           — FK to draft
├── attachments[]               — related table
│   ├── type, path, size
│   └── draftId (int)           — FK to draft
└── sender{}                    — joined from users table
```

The new REST endpoints will read/write the **same tables** and **same columns** that the socket `addUpdateDraft` handler currently uses. The only difference is the transport: HTTP POST instead of socket event. No schema changes, no data migration, no backfill needed.

Existing drafts will work immediately with the new `GET email/draft/:id` endpoint because the data structure is identical.

#### Frontend model changes required

| Model / File | Change |
|-------------|--------|
| `lib/model/view_draft_model.dart` → `Attachments` class | Add `String? fileName` field (new column added to attachments table by API migration) |
| `ComposeAttachment` (new Freezed class in `compose_state.dart`) | Include `fileName` field — sent in draft/send payloads, returned by `GET draft/:id` |
| `ComposeNotifier.send()` | Use server-side batch contact check (`skipContactCheck` flag) instead of client-side per-recipient loop |
| `ComposeNotifier.send()` | Handle `failedRecipients` partial success — navigate to Sent, do NOT save to drafts |
| `ComposeNotifier.send()` | Read `emailId` from success response `resp['data']['emailId']` |
| `ComposeNotifier.send()` | Handle `unknownContacts` — show `AddEmailModal`, then re-call with `skipContactCheck: true` |
| Socket emissions in compose | Stop emitting `newUpload` — attachment refs included in REST payload |
| All API response parsing | Use `resp['data']` (confirmed: wire format is `data`, not `info`) |

#### Backend implementation plan

The Phase 0 API plan has been finalized separately with full implementation details including:
- `compose.controller.ts`, `compose.service.ts`, `compose.dto.ts` (new files)
- `replyToEmailId` schema migration (additive, nullable)
- `fileName` column added to attachments table
- DB transactions on all multi-table writes
- Server-side SES retry (3 attempts, exponential backoff)
- Server-side batch contact opt-in check with `skipContactCheck` re-send pattern
- Rate limiter on send (5/min)
- Response shapes confirmed: `data` key on wire, `emailId` on success, `unknownContacts`/`failedRecipients` on failure

The following legacy backend prompt is kept for reference:

---

**PROMPT FOR API REPO:**

```
I need to add 4 new REST endpoints for the OptMsg email compose feature. The Flutter
frontend is migrating from a WebView-based compose screen (where the server rendered
the form and pulled form state via socket events) to a native Flutter compose screen
that sends form data via REST.

## Existing infrastructure to reference

The following already exist and should be used as patterns:

1. Socket handler `addUpdateDraft` — currently saves drafts. The new REST endpoints
   should write to the SAME database tables this handler uses (drafts, draft_receivers,
   draft_attachments or whatever the actual table names are).

2. Socket handler `sendMessage` — currently sends emails. The new REST `POST email/send`
   should use the SAME email sending logic (SMTP, queue, etc.) this handler uses.

3. `POST email/drafts-list` — existing endpoint that reads from the drafts table.
   The new `GET email/draft/:id` should read from the same table with the same joins
   (receivers, attachments, sender).

4. `POST email/delete-drafts` — existing endpoint for deleting drafts.

5. Auth middleware — all new endpoints must use the same JWT auth middleware as existing
   endpoints (Descope JWT in Authorization header).

## New endpoints to implement

### 1. POST /api/email/draft — Create a new draft

Request body:
{
  "to": ["recipient1@example.com", "recipient2@example.com"],
  "cc": ["cc1@example.com"],
  "bcc": [],
  "subject": "Email subject line",
  "body": "<p>HTML email body from rich text editor</p>",
  "attachments": [
    {
      "fileName": "document.pdf",
      "type": "application/pdf",
      "path": "email/abc123-document.pdf",
      "size": 12345
    }
  ],
  "replyToEmailId": null,
  "type": "compose"
}

Response (success):
{
  "success": true,
  "data": { "draftId": 789 },
  "message": "Draft saved successfully"
}

Behavior:
- Create a new record in the drafts table with subject, body (as message), senderId from JWT
- Create receiver records for each to/cc/bcc with the appropriate type field
- Create attachment records linked to the draft (path references already-uploaded S3 files)
- Return the new draftId so the client can use PUT for subsequent saves

### 2. PUT /api/email/draft/:id — Update an existing draft

Same request body as POST.

Behavior:
- Verify the draft belongs to the authenticated user (senderId matches JWT user)
- Update subject, body/message, updated timestamp
- Replace receivers: delete existing receivers for this draftId, insert new ones
- Replace attachments: delete existing attachment records for this draftId, insert new ones
  (Note: this only updates DB records — the actual S3 files are managed by the existing
  signed-URL upload flow and should NOT be deleted here)
- Return success/failure

Response:
{
  "success": true,
  "message": "Draft updated successfully"
}

### 3. GET /api/email/draft/:id — Fetch a single draft for editing

Response (should match the existing ViewDraftModel structure the Flutter app expects):
{
  "success": true,
  "data": {
    "email": {
      "id": 789,
      "senderId": 123,
      "subject": "Email subject",
      "message": "<p>HTML body</p>",
      "isDeleted": false,
      "created": "2026-03-31T10:00:00Z",
      "updated": "2026-03-31T10:05:00Z",
      "receivers": [
        {
          "id": 1,
          "draftId": 789,
          "receiverEmail": "recipient@example.com",
          "type": "to",
          "isRead": false,
          "isTrash": false,
          "isArchive": false,
          "isDeleted": false,
          "receiver": { "firstName": "John", "lastName": "Doe" }
        }
      ],
      "attachments": [
        {
          "id": 1,
          "type": "application/pdf",
          "path": "email/abc123-document.pdf",
          "size": 12345
        }
      ],
      "sender": {
        "id": 123,
        "firstName": "Jane",
        "lastName": "Smith",
        "created": "2025-01-01T00:00:00Z"
      }
    }
  },
  "message": ""
}

Behavior:
- Verify the draft belongs to the authenticated user
- Join receivers (with receiver user details if available) and attachments
- Return the full draft data matching ViewDraftModel format

### 4. POST /api/email/send — Send an email

Request body (same structure as draft save):
{
  "to": ["recipient@example.com"],
  "cc": [],
  "bcc": [],
  "subject": "Subject",
  "body": "<p>HTML body</p>",
  "attachments": [
    { "fileName": "doc.pdf", "type": "application/pdf", "path": "email/abc123.pdf", "size": 1234 }
  ],
  "replyToEmailId": 456,
  "type": "reply",
  "draftId": 789
}

Response (success — ONLY return after email is queued for delivery):
{
  "success": true,
  "message": "Email sent successfully"
}

Response (failure):
{
  "success": false,
  "message": "Failed to send email: [specific error]"
}

Behavior:
- CRITICAL: Do NOT return success: true until the email is actually queued/sent.
  The frontend shows success/failure based on this response. False positives cause
  users to lose emails silently. On failure, the client auto-saves the message
  to Drafts — there is NO outbox. Binary outcome: Sent or Drafts.
- Use the same email sending logic as the existing `sendMessage` socket handler
- PRESERVE internal vs. external routing:
    * For each recipient, call chkDomainEmailInfo(email)
    * Internal (OptMsg-to-OptMsg): deliver directly to recipient's inbox in DB
      + emit socket `newMessage` event. No SES needed.
    * External: send via transportEmail() → AWS SES
- Server-side retry: For SES failures, retry up to 3 times with exponential
  backoff BEFORE returning { success: false }. The client does NOT retry.
- If a draftId is provided and send succeeds, delete the draft from the drafts table
- If replyToEmailId is provided, link the sent email as a reply in the email thread
- Create sent-email records so the email appears in the user's Sent folder
- Handle the contact opt-in check: for each recipient, check if they exist in the
  user's contacts. Return a list of unknown contacts in the response so the client
  can prompt the user (or handle this server-side if preferred):
  {
    "success": true,
    "message": "Email sent successfully",
    "data": {
      "unknownContacts": ["new-person@example.com"]
    }
  }

## Internal vs. external message routing

OptMsg has TWO delivery paths. The backend already implements this — the new endpoints must preserve it:

1. **Internal (OptMsg-to-OptMsg):** When the recipient's email domain matches the
   OptMsg domain (checked via `chkDomainEmailInfo()`), the message is delivered
   directly to the recipient's inbox in the database + socket `newMessage` event.
   NO external email service is used.

2. **External (via AWS SES):** When the recipient is NOT an OptMsg user, the message
   is sent via `transportEmail()` which POSTs to AWS SES (`process.env.SES_SEND_URL`).

The `POST email/send` endpoint must use the SAME routing logic that the existing
`sendMessage` socket handler uses — inspect each recipient, route internally or
externally as appropriate.

## Send failure behavior (no outbox)

There is NO outbox folder. The outcome is binary:
- Success: email appears in Sent folder, client shows success toast
- Failure: client auto-saves as draft, shows "Message could not be sent. Saved to Drafts."

The server should retry SES failures internally (3 attempts, exponential backoff)
before returning { success: false }. The client does NOT retry — it trusts the
server's final response.

This matches the Gmail pattern: send succeeds or the message is recoverable.

## Internal message recovery (OptMsg-to-OptMsg)

Internal delivery is a multi-table DB write (emails + emailRecipients +
emailMessages). The critical requirement: these writes MUST be wrapped in a
**database transaction**. If any insert fails, ALL roll back — preventing
partial delivery (e.g., message in Sent but not in recipient's inbox).

**Recovery chain (defense in depth):**

```
Layer 1: DB transaction
  All writes succeed → { success: true } → message delivered
  Any write fails   → rollback ALL → { success: false } → go to Layer 2

Layer 2: Client saves to server drafts
  POST email/draft succeeds → draft in server DB → user retries later from Drafts
  POST email/draft fails    → go to Layer 3

Layer 3: Local autosave (SecureStorageService)
  Always exists (saved before send attempt and every 5 seconds during compose)
  On next app open → "Restore unsaved draft?" → user recovers content
```

**Result: internal messages are NEVER lost.** The worst case is the message
ends up back in Drafts (server or local) for the user to retry. No partial
delivery, no silent loss.

**Draft save has the same chain** — Layer 2 (server) fails → Layer 3 (local) catches it.

## Important constraints

1. All endpoints must use the existing auth middleware (Descope JWT)
2. All endpoints must return the standard { success, data?, message } response format
3. No database schema changes — use the existing drafts, receivers, attachments tables
4. Keep the existing socket event handlers (`addUpdateDraft`, `sendMessage`) working
   during the migration period — both old and new code paths should coexist
5. Add appropriate error handling: invalid draftId, draft not owned by user,
   missing required fields (to array for send), etc.
6. Rate limiting on POST /api/email/send to prevent abuse
7. CRITICAL: POST /api/email/send must wrap ALL database writes (emails,
   emailRecipients, emailMessages, sent-folder records) in a SINGLE database
   transaction. If any insert fails, ALL must roll back. This prevents partial
   delivery (e.g., message in Sent folder but NOT in recipient's inbox).
   For mixed internal+external sends (some recipients internal, some SES):
   - Complete all DB writes for internal recipients in the transaction
   - Commit the transaction
   - THEN attempt SES sends for external recipients
   - If SES fails for some external recipients, still return success for the
     internal recipients but include failed external addresses in the response:
     { success: true, data: { failedRecipients: ["ext@gmail.com"] } }
8. POST/PUT /api/email/draft should also use a transaction for the multi-table
   write (draft + receivers + attachments)
```

---

### 5J. Router changes

Update `app_router.dart` to pass `ComposeParams` instead of URL strings:
```dart
GoRoute(
  path: AppRoutes.compose,
  pageBuilder: pushPageBuilder(safeRouteBuilder((context, goState) {
    if (useNativeCompose) {
      return ResponsiveComposeWrapper(
        params: ComposeParams(
          mode: ComposeMode.fromString(extra['type'] ?? 'compose'),
          emailId: extra['emailId'],
          toEmail: extra['to'],
          sourcePage: extra['sourcePage'],
        ),
      );
    }
    return ResponsiveWebComposeWrapper(...); // Legacy
  })),
)
```

### 5K. Draft reading pane migration

Replace `DraftReadingPaneWidget`'s `InAppWebView` with the new `ComposeScreen`:
```dart
ComposeScreen(
  params: ComposeParams(
    mode: ComposeMode.updateDraft,
    emailId: draftId,
  ),
  hideAppBar: true,  // embedded in reading pane
)
```

### 5L. Migration strategy

| Phase | Scope | Dependencies |
|-------|-------|-------------|
| **Phase 0: Backend** | ~~Implement 4 new REST endpoints.~~ **DONE — committed to API repo.** | Complete |
| **Phase 1: Editor asset** | Create `assets/editor/compose_editor.html` with bundled Quill.js. Test loading from InAppWebView on iOS/Android/web. Implement JS bridge: `getContent()`, `setContent()`, `isDirty()`, `onEditorChange`. | None |
| **Phase 2: Build compose** | Create full file structure. Implement `ComposeState`, `ComposeNotifier`, all widgets. Wire autosave, send confirmation, draft recovery. Add feature flag `useNativeCompose`. Update `ResponsiveWebComposeWrapper`. | Phase 0 + 1 |
| **Phase 3: Test** | All compose modes. Attachments on iOS/Android/web. Reading pane. Keyboard. Dark mode. AddEmailModal flow. Draft round-trip. **Autosave recovery. Send failure + retry. Offline compose.** | Phase 2 |
| **Phase 4: Rollout** | Enable for internal team. Monitor error rates, draft save success, send success. | Phase 3 |
| **Phase 5: Cleanup** | Enable for all users. Delete `web_compose.dart`. Remove `ResponsiveWebComposeWrapper`. Deprecate socket events on backend. | Phase 4 stable |

### Critical files to modify

- `lib/screens/compose/web_compose.dart` — 1926-line file being replaced (reference for all current logic)
- `lib/router/responsive_route_wrappers.dart:529-580` — `ResponsiveWebComposeWrapper` → conditional native/legacy
- `lib/router/app_router.dart:830-893` — Compose route builder → pass `ComposeParams`
- `lib/screens/email/draft_riverpod/widget/draft_reading_pane_widget.dart` — Replace WebView with native compose
- `pubspec.yaml` — No new packages needed (InAppWebView already present)
- `assets/editor/` — New directory for bundled Quill.js editor HTML

### Verification plan

1. `flutter analyze` — zero issues
2. Manual test matrix:
   - **Compose modes:** new, reply, replyAll, forward, updateDraft — all pre-fill correctly
   - **Send confirmation:** send → wait for server response → only then show success toast → verify `emailId` returned
   - **Send failure:** disconnect network → send → error toast → draft auto-saved → reconnect → retry from compose screen
   - **Send unknown contacts:** send to new external address → server returns `unknownContacts` → AddEmailModal shown → user resolves → re-send with `skipContactCheck: true` → success
   - **Send partial failure:** send to internal + external → SES fails → `failedRecipients` returned → warning toast → navigate to Sent (don't save to drafts)
   - **Autosave:** type content → force-kill app → reopen → "Restore draft?" dialog → content recovered
   - **Draft save failure:** disconnect network → save draft → error toast → local backup exists → reconnect → save succeeds
   - **False positive eliminated:** no "Draft saved" or "Email sent" toast without server confirmation
   - **Attachments:** add multiple files → verify 25MB limit → remove one → send
   - **Responsive:** mobile (full screen), tablet landscape (reading pane), desktop (reading pane)
   - **Dark mode:** header themed via Flutter, editor themed via CSS injection
   - **Keyboard:** native fields handle keyboard avoidance; editor scrolls within remaining space
   - **Contact check:** send to new email → AddEmailModal appears
   - **Web platform:** no cross-origin issues, local asset loads, validation works, token not in URL
   - **Recipient autocomplete:** type partial name → dropdown appears reliably → tap suggestion → chip added → dropdown does NOT drop mid-typing → works on iOS/Android/web
   - **Recipient paste:** paste "a@b.com, c@d.com" → both added as chips
   - **Offline compose:** airplane mode → compose → autosave locally → reconnect → save to server
