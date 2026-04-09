# OptMsg Refactoring Roadmap

**Date:** 2026-03-29
**Branch:** `optmsgApp-v1.0.7.ryan.uxui.test`
**Companion:** `docs/PRODUCTION_AUDIT_REPORT.md` (Review 20)

> Prioritized by risk (regression probability), impact (perf/lines saved), and deduplication.
> These are structural improvements only — no functional changes to the app.

---

## Priority Legend
| Priority | Risk | Effort | Description |
|----------|------|--------|-------------|
| P0 | Low | 2-4 hrs | Mechanical, no behavior change |
| P1 | Medium | 1-2 days | Architectural, new module boundaries |
| P2 | Low | 0.5-1 day | Extraction refactors |
| P3 | Low | 2-4 hrs | Cleanup, polish |

---

## P0 — High Impact, Low Risk

### P0-1: Add `.select()` to Provider Watches

**Problem:** ~55 `ref.watch()` calls subscribe to entire Freezed state objects (30-45+ fields each). Any field change rebuilds the watching widget — including ephemeral flags like `isComposeHovered`, `emailListPaneWidth`, `showMenuOptions`.

**User impact:** Scroll jank, sluggish transitions between states.

**Affected files (highest impact):**
| File | Line | Provider | Fields used | Total fields |
|------|------|----------|-------------|-------------|
| `email_list_pane.dart` | 26 | inboxProvider | 13 | 45+ |
| `mobile_inbox_layout_widget.dart` | 20 | inboxProvider | 13 | 45+ |
| `inbox_mobile_layout.dart` | 94 | inboxProvider | 14 | 45+ |
| `inbox_responsive.dart` | 817 | inboxProvider | 8 | 45+ |
| `archive_responsive.dart` | 395 | archiveProvider | 12 | 40+ |
| `draft_responsive.dart` | 213 | draftProvider | 8 | 30+ |

**Approach:**
1. For each widget, identify which state fields the `build()` method reads
2. Replace `ref.watch(provider)` with `ref.watch(provider.select((s) => (field1: s.field1, ...)))`
3. For widgets reading many fields, use a Dart record type

**Example:**
```dart
// Before:
final state = ref.watch(inboxProvider); // rebuilds on ANY of 45+ fields

// After:
final items = ref.watch(inboxProvider.select((s) => s.items));
final isLoading = ref.watch(inboxProvider.select((s) => s.isLoading));
```

**Verification:** Scroll email list while toggling filters/overlays — list should NOT visibly rebuild.

---

### P0-2: Memoize `htmlReplaceString()` in Email List Rows

**Problem:** `HtmlSanitizerService().htmlReplaceString()` runs 10+ regex passes on every email row on every list rebuild. With 20-30 visible items, that's 200-300 regex operations per frame.

**Files:** `email_list.dart:293`, `sent_email_list.dart:439`, `draft_email_list.dart:247`

**Fix:** Cache per email ID:
```dart
final Map<int, String> _previewCache = {};
String _getPreview(Emails item) => _previewCache[item.emailId] ??=
    HtmlSanitizerService().htmlReplaceString(item.email.messageText ?? '');
```

---

## P1 — High Impact, Medium Risk

### P1-1: Split InboxNotifier (2377 lines → ~400 orchestrator + services)

**Current responsibilities (identified by method grouping):**
1. Email list CRUD — fetch, paginate, refresh, search (~400 lines)
2. Socket event routing — newMessage, trashMessage, readReceipt debouncing (~200 lines)
3. Selection management — toggle, selectAll, clear (~150 lines)
4. Undo management — undoBuffer, undoIds, restore (~100 lines)
5. Tag management — showTagDialog, addTags, removeTags (~200 lines)
6. Filter/overlay state — showFilter, showTagList, showMoveOverlay (~150 lines)
7. Reading pane — selectedEmailIdForReadingPane, refresh key (~200 lines)
8. Contact sync + opt-in — pendingOptInEmail, syncContacts (~150 lines)
9. Bulk email actions — archive, trash, markRead, move (~300 lines)
10. Bootstrap + lifecycle — init, dispose, _isBootstrapping (~200 lines)

**Proposed decomposition:**
```
InboxNotifier (orchestrator, ~400 lines)
├── EmailListService (fetch/paginate/search/refresh)
├── SocketEventRouter (socket handlers + debounce)
├── SelectionManager (toggle/selectAll/clear)
├── UndoManager (buffer/restore)
├── TagManager (add/remove/dialog state)
├── OverlayStateNotifier (filter/tag/move/menu — shared P2-1)
├── ReadingPaneManager (selection + refresh key)
└── BulkActionService (archive/trash/markRead/move)
```

Each becomes a separate Riverpod provider that InboxNotifier composes via `ref.watch()` / `ref.read()`.

**Risk:** Method signatures at the notifier level stay the same (delegates down). Widget `ref.watch()` targets change.

---

### P1-2: Split ArchiveNotifier (3205 lines → same pattern)

Mirror P1-1 decomposition. Archive has additional sent/trash/spam folder handling.

---

### P1-3: Consolidate HTTP Stacks

**Current:** Two parallel HTTP layers with duplicate header assembly, 401 retry, Firebase tracing:
- `ApiService` (388 lines) — used by 27 files, 57 call sites via `ApiService()`
- `BaseAPIService` (270 lines) — used by 10 repository subclasses

**Proposed:** Keep `BaseAPIService` as the single HTTP layer (has connection pooling, modern architecture). Create `ApiServiceProvider` Riverpod provider. Migrate 57 direct `ApiService()` call sites over 2-3 sprints.

---

### P1-4: Extract Common Email List Item Widget

**Problem:** 4 email list files have substantial duplication in row layout:
| File | Lines | Purpose |
|------|-------|---------|
| `email_list.dart` | 369 | Inbox rows |
| `sent_email_list.dart` | 615 | Sent rows |
| `draft_email_list.dart` | 299 | Draft rows |
| `tag_email_list.dart` | 621 | Tag-filtered rows |
| **Total** | **1904** | |

**Shared elements:** Sender display, subject/preview, date, tag chips, read/unread state, selection checkbox, swipe gestures.

**Proposed:** `EmailListItemWidget` with variant enum (inbox/archive/draft/sent/tag) for folder-specific behavior. **Estimated reduction: ~800-1000 lines.**

---

## P2 — Medium Impact, Low Risk

### P2-1: Extract Shared OverlayStateNotifier

Both InboxNotifier and ArchiveNotifier manage identical overlay fields: `showFilter`, `showTagList`, `showMoveOverlay`, `showMenuOptions`, `showTagDialog`. Extract into a shared `OverlayStateNotifier`.

### P2-2: Extract Sidebar from Shell Layout

`shell_layout.dart` (657 lines) contains ~250 lines of sidebar logic (prefs, toggle, rendering). Extract into `SidebarWidget` to reduce shell to ~400 lines.

### P2-3: Consolidate Responsive Layout Files

9 layout files (2954 lines) across inbox/archive/draft × mobile/tablet/desktop have shared patterns (overlay management, state watchers, appBar config). Extract common `EmailListLayout` base widget with hooks for folder-specific behavior.

---

## P3 — Polish

### P3-1: Remove Dead Code
- Commented-out blocks in `archive_list_notifier.dart`, `contact_list_notifier.dart`
- Leftover backup files (`.orig`, `.bak`)
- Unused imports identified by `flutter analyze`

### P3-2: Migrate Legacy Text Styles
`styles.dart` (759 lines) has ~40 text styles with hardcoded hex colors. Migrate to theme-based `TextTheme` extensions consuming `AppColorsExtension` tokens.

### P3-3: Split CustomDismissible (1273 lines)
Split into `SwipeEngine` (gesture detection, animation, thresholds) + `ActionPanels` (archive/trash/tag panel widgets) + thin `CustomDismissible` wrapper.

---

## Execution Order & Dependencies

```
P0-1 (.select)  ← no deps, do FIRST (immediate perf win)
P0-2 (memoize)  ← no deps, do alongside P0-1
P1-4 (email list widget) ← do before P1-1 (reduces notifier surface area)
P1-1 (split inbox notifier) + P2-1 (overlay extract) ← do together
P1-2 (split archive notifier) ← mirror P1-1
P1-3 (HTTP consolidation) ← independent, parallel
P2-2 (sidebar) ← independent
P2-3 (layout consolidation) ← after P1-4
P3-* ← anytime, independent
```

---

## Estimated Impact

| Refactor | Lines Before | Lines After (est.) | Net Change |
|----------|-------------|-------------------|------------|
| P0-1 | N/A | N/A | Perf only |
| P0-2 | N/A | N/A | Perf only |
| P1-1 | 2,377 | ~400 + ~1,600 services | +maintainability |
| P1-2 | 3,205 | ~400 + ~2,200 services | +maintainability |
| P1-3 | 658 combined | ~350 single | -308 |
| P1-4 | 1,904 | ~900 | **-1,004** |
| P2-1 | embedded | ~150 shared | -200 from notifiers |
| P2-3 | 2,954 | ~1,800 | **-1,154** |
| P3-1 | varies | varies | ~-200 dead code |
| P3-3 | 1,273 | ~1,200 split | reorganization |
| **Total** | | | **~-2,866 lines** |
