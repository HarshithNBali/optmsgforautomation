# AppBar State Management Audit & Stale Config Investigation

## Context
The centralized ShellLayout AppBar (introduced after v1.0.5) uses a push-based config model: screens call `ShellLayout.of(context)?.setAppBarConfig(config)` to tell the shell what to display. When switching screens, stale configs from the previous screen can persist, showing wrong actions, titles, or search bars. Additionally, the documentation table uses ambiguous symbols and is missing several screens/states.

## Part 1: Root Cause — Stale AppBar Config

### The Problem
In v1.0.5, each screen had its own `Scaffold` + `GradientAppBar`. State was local — disposing a screen disposed its AppBar. No cross-screen bleed was possible.

In the refactored ShellLayout, there is ONE persistent `AppBar` and screens **push** config into it. The shell relies on two mechanisms to reset:

1. **`didUpdateWidget`** — resets config when `matchedLocation` changes (go() routes)
2. **`build()` pop detection** — detects `canPop` transition true→false and resets (push route pops)

### Why It Breaks — 5 Identified Stale State Vectors

#### Vector 1: Screen `initState` fires AFTER `didUpdateWidget`
When navigating from Screen A to Screen B via `go()`:
1. `didUpdateWidget` fires → sets route-derived config (correct)
2. Screen A disposes (no cleanup of AppBar)
3. Screen B `initState` fires → `addPostFrameCallback` pushes B's config
4. **But**: Screen A's `ref.listenManual` callbacks may still fire between steps 1-3, re-pushing A's config

**Affected**: All screens with `ref.listenManual` for selection mode (inbox, archive, draft, contacts, tags, notifications)

#### Vector 2: `setAppBarConfig` merges title but replaces everything else — except it doesn't clear callbacks
When a screen sets `showSearch: true, onSearch: callback` and then the user navigates away, the next screen's `_configForRoute()` returns `showSearch: true` for that route, but `onSearch` is null (route-derived configs never have callbacks). The search icon appears but **tapping it opens a search bar with no callback** — typing does nothing.

#### Vector 3: Pop detection in `build()` is one frame late
The pop detection (line 583-595) runs inside `build()` and schedules a `postFrameCallback`. After popping a push route, there's **one frame** where the stale config from the push route is still visible.

#### Vector 4: Sidebar navigation resets config but screen listener re-pushes it
In the sidebar `onItemSelected` callback, the config is reset to the new route. But if the OLD screen's `ref.listenManual` fires in between (e.g., selection state cleanup), the OLD screen's config overwrites the sidebar's reset.

#### Vector 5: `_screenOverrideTitle` not cleared on push-route pop
`_screenOverrideTitle` is set when a screen pushes a title (line 136). It's cleared in `didUpdateWidget` (line 201) when `matchedLocation` changes. But push routes **don't change `matchedLocation`** — so popping a push route never clears `_screenOverrideTitle`. The `build()` pop handler resets the config, but `_screenOverrideTitle` remains true, blocking the `titleStale` guard from fixing subsequent title drift.

---

## Part 2: Documentation Table — Updated & Corrected

### Symbol legend (replaces ambiguous `[≡]`):
- `☰` = hamburger/drawer (leading)
- `←` = back arrow (leading)
- `[🔍]` = search toggle icon
- `[🔔]` = notification bell
- `[filter]` = filter icon (svgFilter) — opens unread/tags/contact-type overlay
- `[+Add]` = add button (TextButton.icon or FAB)

### Corrections to current doc table:
- `/inbox` does NOT have `[+Add]` — doc was correct, audit was wrong
- `[≡]` should be `[filter]` everywhere for clarity
- `/tags` (list) is missing entirely
- Selection mode states not documented
- `/notifications` selection mode not documented
- `/settings/profile` edit mode not documented

---

## Part 3: v1.0.5 (afc2dc2) vs Current — Side-by-Side Comparison

### Architecture Change
| Aspect | v1.0.5 (afc2dc2) | Current (refactored) |
|--------|-------------------|---------------------|
| AppBar ownership | Each screen owns its Scaffold + GradientAppBar | Single ShellLayout owns AppBar; screens push config |
| State isolation | Fully isolated — dispose cleans up | Shared — stale config can bleed across screens |
| AppBar widget | `GradientAppBar` (custom PreferredSizeWidget) | Material `AppBar` with gradient `flexibleSpace` |
| Navigation | `Navigator.push()` / `Navigator.pop()` | GoRouter `go()` / `push()` / `pop()` |
| Router | Simple flat router (`router.dart`) | ShellRoute with nested GoRouter (`app_router.dart`) |
| Sidebar | Inside `Inbox` widget as nested navigator | Separate `SideMenu` in ShellLayout |

### Per-Screen AppBar Comparison

#### Inbox
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading (normal) | Menu icon → `Navigator.push(MyDrawer())` | Hamburger → `openDrawer()` | Drawer mechanism changed |
| Title | "Inbox" | "Inbox" | Same |
| Search | Toggle via IconButton, inline in AppBar | Toggle via IconButton, slides below AppBar | UX changed — search now below |
| Notification bell | IconButton → `Navigator.push(NotificationList())` | IconButton → `context.push('/notifications')` | Navigation mechanism changed |
| Filter | IconButton (svgFilter) → toggle overlay | IconButton (svgFilter) via `filterWidget` slot | Same behavior, different plumbing |
| Selection back | InkWell (svgLeftArrow) | IconButton (svgLeftArrow) *(just fixed)* | Touch target improved |
| Selection actions | IconButtons: SelectAll, Add, Delete, Archive, Tags, More | IconButtons: OptIn, Delete, Archive, More | **Tags action removed** from selection; OptIn replaces Add |
| FAB | Not present | Compose FAB | **NEW** |

#### Drafts
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading (normal) | Menu icon | Hamburger | Same concept |
| Title | "Drafts" | "Drafts" | Same |
| Search | Toggle IconButton, inline | Toggle IconButton, below AppBar | UX changed |
| Selection actions | IconButtons: SelectAll, Delete | IconButton: Delete | Same (only delete) |
| FAB | Not present | Compose FAB | **NEW** |

#### Archive/Sent/Trash (was `common_email_list.dart`)
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Implementation | Single `common_email_list.dart` | `archive_responsive.dart` (shared for archive/sent/trash) | Renamed + restructured |
| Leading | Menu icon | Hamburger | Same concept |
| Title | Dynamic (Archive/Sent/Trash) | Dynamic (Archive/Sent/Trash) | Same |
| Search | Toggle IconButton, inline | Toggle IconButton, below AppBar | UX changed |
| Filter | IconButton toggle overlay | IconButton via filterWidget slot | Same behavior |
| Selection actions | IconButtons: SelectAll, Add, Delete, Archive, Move, Tags, More | IconButtons: OptIn, Delete, Archive (sent only), More | **Simplified** — Move/Tags removed from AppBar |
| FAB | Not present | Compose FAB | **NEW** |

#### Contacts
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Menu/Back (context-dependent) | Hamburger (standard) | Simplified |
| Title | "Contacts" | "Contacts" | Same |
| Add button | InkWell "+Add" in actions | TextButton.icon "+Add" (tablet/desktop) or FAB (mobile) | Touch target fixed; mobile uses FAB |
| Search | Always-on bar at bottom of AppBar | Toggle below AppBar (currently closed by default) | **UX changed** — search no longer always visible |
| Selection mode | Not in v1.0.5 | Multi-select with delete | **NEW** |
| Notification bell | Via drawer/InkWell | IconButton in AppBar | **NEW in AppBar** |
| Filter | Not in v1.0.5 | Filter widget (OptIn/All contacts) | **NEW** |

#### Tags List
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow (`Navigator.pop`) | Hamburger (top-level go route now) | **Changed** — was push, now go() |
| Title | "Tags" | "Tags" | Same |
| Add button | InkWell "+Add" in actions | IconButton "+Add" | Touch target fixed |
| Selection mode | Not in v1.0.5 | Multi-select with delete | **NEW** |
| Notification bell | Not present | IconButton in AppBar | **NEW** |

#### Tag Email List
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow | Back arrow (derived from non-top-level route) | Same |
| Title | Tag name | Tag name (pushed by screen) | Same |
| Selection back | InkWell | IconButton *(just fixed)* | Touch target improved |
| Selection actions | IconButtons: SelectAll, Delete | IconButtons: OptIn, Delete, Archive, More | **Expanded** — more actions added |

#### Notifications
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow (`Navigator.pop`) | Back arrow (push route) | Same concept |
| Title | "Notifications" | "Notifications" | Same |
| Actions | None | None (normal) / Delete+Mark (selection) | **NEW** selection mode |

#### Settings
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow → push MyDrawer | Hamburger (top-level) | **Changed** — now top-level go() route |
| Title | "Settings" | "Settings" | Same |
| Actions | None | Notification bell | **NEW** |

#### View Email
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow | Back arrow (push route) | Same |
| Title | (varies by email type) | (varies by email type) | Same |
| Actions | Reply, Forward, More menu, etc. (full actions) | OptIn, Delete, More (mobile); none (desktop — in content area) | **Simplified** for mobile; desktop moved to content |
| Reply FAB | Not present | Reply FAB (mobile) | **NEW** |

#### Compose
| Feature | v1.0.5 | Current | Change |
|---------|--------|---------|--------|
| Leading | Back arrow | Back arrow (push route) | Same |
| Title | "New Message" | "New Message" (mobile) / empty (desktop) | Desktop drops title |
| Actions | Attach + Send | Attach + Send (mobile) / none (desktop) | Desktop moved to content |

---

## Part 4: Implementation Plan

### Step 1: Fix `_screenOverrideTitle` on push-route pop (Vector 5)
**File**: `lib/widgets/shell_layout.dart` — `build()` method, line ~585-595

Add `_screenOverrideTitle = false;` inside the `pushPopped` handler:
```dart
if (titleStale || pushPopped) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() {
        _screenOverrideTitle = false;  // ADD THIS LINE
        _appBarConfig = _configForRoute(widget.state.matchedLocation, uri: widget.state.uri);
        _mobileSearchOpen = false;
        _searchController.clear();
      });
    }
  });
}
```

### Step 2: Guard `setAppBarConfig` against stale screen pushes (Vectors 1 & 4)
**File**: `lib/widgets/shell_layout.dart` — `setAppBarConfig()` method, line ~132

Add a timestamp/generation counter so that route-derived configs from `didUpdateWidget` take priority over late-arriving screen pushes:

```dart
int _configGeneration = 0;  // Incremented in didUpdateWidget and pushPopped handler

void setAppBarConfig(AppBarConfig config) {
  if (!mounted) return;
  // ... existing logic
}
```

And in `didUpdateWidget`:
```dart
_configGeneration++;
```

Then in `setAppBarConfig`, screens will pass the generation they captured in `initState`. If it's stale, skip the push.

**Simpler alternative**: Just add `_mobileSearchOpen = false;` in the `didUpdateWidget` reset (already done) and rely on the existing `_screenOverrideTitle` guard once Vector 5 is fixed. The timing issue is narrow enough that fixing Vector 5 + the existing `mounted` guards should cover it.

**Decision**: Use the simpler approach first — fix Vector 5 and observe. If stale state persists, add generation counter in a follow-up.

### Step 3: Update documentation table in `shell_layout.dart`
**File**: `lib/widgets/shell_layout.dart` — lines 11-56

Replace the existing doc block with corrected version:
- Replace `[≡]` with `[filter]` everywhere
- Add `/tags` top-level route
- Add selection mode documentation section
- Add notification selection mode
- Add profile edit mode variant
- Fix subscription/change title
- Retain all FAB documentation
- Add `/contacts` search-open-by-default note
- Add clear symbol legend at the top

### Step 4: Auto-open search on `/contacts` route (new feature)
**Goal**: When navigating to the contacts list, the search input should always be expanded by default, since users typically search before scrolling.

**Approach**: Add `searchOpenByDefault` flag to `AppBarConfig`, and have ShellLayout auto-expand the search bar when this flag is set.

**File**: `lib/services/app_bar_config_state.dart`
- Add `final bool searchOpenByDefault;` field (default `false`)
- Add to constructor and `copyWith`

**File**: `lib/widgets/shell_layout.dart` — `setAppBarConfig()` method
- When receiving a config with `searchOpenByDefault: true`, set `_mobileSearchOpen = true` and request focus on the search field

**File**: `lib/screens/contacts/contacts_riverpod/contact_list_riverpod.dart` — `_pushAppBarConfig()`
- Add `searchOpenByDefault: true` to the normal-mode AppBarConfig push:
```dart
ShellLayout.of(context)?.setAppBarConfig(
  AppBarConfig(
    showSearch: true,
    searchOpenByDefault: true,  // ADD
    onSearch: _onSearch,
    ...
  ),
);
```

**Behavior**:
- On mobile: search bar slides open automatically when contacts screen appears
- On desktop/tablet: search is already always visible in the AppBar (no change needed — desktop search is handled differently)
- When user closes search manually (taps X), it stays closed until next navigation to contacts

### Step 5: Ensure search field gets focus when auto-opened
**File**: `lib/widgets/shell_layout.dart` — `setAppBarConfig()` method

After setting `_mobileSearchOpen = true`, request focus:
```dart
if (config.searchOpenByDefault && !_mobileSearchOpen) {
  _mobileSearchOpen = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _searchFocusNode.requestFocus();
  });
}
```

### Step 6: Create AppBar regression tests
**Files**: `test/regression/appbar_state_regression_test.dart`, `test/regression/appbar_test_helpers.dart`

Follow the existing regression test pattern from `gl_106_regression_test.dart` — source-level pattern verification that catches regressions if code changes revert a fix.

#### Test helper: `test/regression/appbar_test_helpers.dart`
Extend the existing `gl_106_test_helpers.dart` pattern with AppBar-specific utilities:
- `extractAppBarConfig(String source, String methodName)` — extracts `AppBarConfig(...)` constructor calls within a method
- `extractSetAppBarConfigCalls(String source)` — finds all `setAppBarConfig` calls
- `verifyIconButtonNotInkWell(String source, String widgetName)` — confirms actions use IconButton not InkWell
- Reuse `readSourceFile`, `sourceContains`, `sourceLinesContaining` from existing helpers

#### Test file: `test/regression/appbar_state_regression_test.dart`
Organized by category:

**Group 1: Touch Target Tests — all AppBar action buttons must use IconButton**
For each screen with selection mode actions, verify no `InkWell` wrapping SVG icons in `_buildSelectionActionsWidgets` or `_buildSelectionLeadingWidget`:
- `inbox_responsive.dart` — selection back arrow + 4 action buttons
- `archive_responsive.dart` — selection back arrow + 4 action buttons
- `draft_responsive.dart` — selection back arrow + delete button
- `contact_list_riverpod.dart` — selection back arrow
- `tags_list_riverpod.dart` — selection back arrow + delete button
- `tag_email_list.dart` — selection back arrow + action helper function
- `notification_responsive.dart` — selection back arrow + 2 action buttons
- `shell_layout.dart` — "Add" button must use TextButton.icon not InkWell

**Group 2: AppBar Config Completeness — every screen that pushes config must include required fields**
For each screen:
- Inbox: must push `showSearch: true`, `onSearch`, `filterWidget`
- Archive: must push `showSearch: true`, `onSearch`, `filterWidget`
- Drafts: must push `showSearch: true`, `onSearch`
- Contacts: must push `showSearch: true`, `searchOpenByDefault: true`, `onSearch`, `filterWidget`
- Tags list: must push `showAddButton: true`, `onAdd`
- Notifications: must push `title: 'Notifications'` (or non-empty title for mobile)
- View email: must push `customActions` (on mobile)
- View contact: must push `title` with contact name
- Compose: must push `customActions` on mobile

**Group 3: Stale State Guards — shell_layout must properly reset config**
- `_screenOverrideTitle` must be set to `false` in the `pushPopped` handler
- `didUpdateWidget` must reset `_screenOverrideTitle = false` when route changes
- `_configForRoute` must NOT include callbacks (`onSearch`, `onAdd`, `filterWidget` must be null/default)
- `setAppBarConfig` must check `mounted` before `setState`
- Pop detection must clear `_mobileSearchOpen` and call `_searchController.clear()`

**Group 4: Documentation Integrity — doc table matches `_configForRoute`**
- Every route in `_configForRoute`'s switch statement must appear in the doc comment
- Every route in the doc comment must appear in `_configForRoute`
- `searchRoutes` array must match the routes documented as having `[🔍]`

**Group 5: Contacts Search Auto-Open**
- `contact_list_riverpod.dart` `_pushAppBarConfig` must include `searchOpenByDefault: true`
- `app_bar_config_state.dart` must define `searchOpenByDefault` field
- `shell_layout.dart` `setAppBarConfig` must handle `searchOpenByDefault` flag

**Group 6: AppBarConfig model completeness**
- `AppBarConfig` must have `copyWith` that covers all fields
- `AppBarConfig` constructor must have `searchOpenByDefault` with default `false`

Run with: `flutter test test/regression/appbar_state_regression_test.dart`

## Files to Modify
1. `lib/widgets/shell_layout.dart` — Fix Vector 5, update doc table, handle `searchOpenByDefault`
2. `lib/services/app_bar_config_state.dart` — Add `searchOpenByDefault` field
3. `lib/screens/contacts/contacts_riverpod/contact_list_riverpod.dart` — Set `searchOpenByDefault: true`

## Files to Create
4. `test/regression/appbar_state_regression_test.dart` — AppBar state regression tests
5. `test/regression/appbar_test_helpers.dart` — AppBar test utilities

## Verification
1. `flutter analyze` — must pass with zero issues
2. `flutter test test/regression/appbar_state_regression_test.dart` — all tests pass
3. `flutter test test/regression/` — existing GL 1.0.6 tests still pass
4. Manual test scenarios:
   - Navigate Inbox → Contacts → Tags → Settings rapidly — AppBar should update instantly with no stale state
   - Open a push route (email detail, notifications) → pop back — AppBar should restore correctly with correct title
   - Enter selection mode → navigate away via sidebar → AppBar should reset to normal
   - Enter selection mode → pop back to list → AppBar should restore list config
   - Navigate to `/contacts` — search bar should auto-expand and be focused
   - Close search on contacts → navigate away → navigate back → search should auto-open again
   - On Android: verify all AppBar actions respond on first tap
