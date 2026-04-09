# OptMsg Flutter App — UI/UX Modernization Plan

> **Living Document** — Updated as sprints are completed. Check `## Progress Tracker` for current status.

---

## Context

OptMsg is a Flutter-based email privacy/security app (iOS, Android, Web) that has Material 3 enabled but significantly underutilizes it. The `ColorScheme.fromSeed()` uses `Colors.white` as the seed — which generates a near-neutral, low-contrast theme — and there is no dark mode. Over 668 hardcoded `Color(0x...)` values are scattered across 112 files instead of using semantic color roles. The typography system is solid (Figtree + NotoSans variable fonts, proper type scale) but 50+ legacy `TextStyle` constants with hardcoded colors prevent theming. Performance is reasonable but email lists use a custom row-widget pattern without `ListView.builder`. Accessibility is minimal: only 2 of 100+ screen files use `Semantics`, no `semanticLabel` on icons, no RTL support, no `TextScaler` handling. This plan delivers maximum visual modernization with minimal structural churn — theme-layer and color-system changes first, then component-level improvements, then structural work.

---

## Executive Summary

The OptMsg Flutter app is well-architected and functionally solid but visually dated due to three compounding issues:
1. `ColorScheme.fromSeed(seedColor: Colors.white)` defeats Material 3's dynamic color system, producing a washed-out palette
2. 668+ hardcoded hex colors prevent dark mode and make brand consistency fragile
3. No `darkTheme` is configured despite the codebase already having dark-mode-aware skeleton loaders and comments anticipating it

The typography system (Figtree + NotoSans variable fonts with a well-defined type scale) is a genuine strength. Navigation and responsive layout are robust. Security is strong at the HTML-rendering layer. Accessibility is the largest gap.

**Top 5 Quick Wins (all complete ✅):**
1. ✅ Fix `ColorScheme.fromSeed(seedColor: AppStyles.primaryColor)` → immediate Material 3 dynamic tinting (S1.1)
2. ✅ `_buildDarkTheme()` implemented, `AppBarTheme` added to both light/dark (S1.2, S3.8) — dark theme commented out pending color migration
3. ✅ Gradient eliminated from AppBar/sidebar/drawer → flat `colorScheme.primary` via `AppBarTheme` (S3.8)
4. ✅ Manrope removed from `pubspec.yaml` (S1.11)
5. ✅ `semanticLabel` added to `Icon` widgets in `SideMenu`, `EmailList`, `WebMenuItems` (S2.1)

**Remaining high-impact items:**
1. Dark mode color migration — sweep remaining hardcoded `Color(0x...)` across 112 files (S3.3)
2. SVG icon colorFilter migration — replace hardcoded `Colors.white` with theme-aware colors in AppBar actions
3. Full-width AppBar in ShellLayout — M3 ideal layout pattern (P3 backlog)

---

## Progress Tracker

| Sprint | Status | Items | Notes |
|--------|--------|-------|-------|
| **Sprint 1 — P0: Theme Foundation** | ✅ Complete | 13 items | main.dart, styles.dart, pubspec.yaml, 8 widget files — `dart analyze`: no issues. **Hotfix 1:** `DecoratedBox` → `Container` in gradient_appbar.dart (zero-size bug). **Hotfix 2:** `darkTheme` commented out pending full color migration. **S1.13 reverted:** native transitions cause distracting header animation — all platforms use `NoAnimationPageTransitionsBuilder`; per-route transitions deferred to P3. |
| **Sprint 2 — P1: Component Polish** | ✅ Complete | 11 items | Widget-level changes |
| **Sprint 3 — P2: Structural** | ✅ Complete | 8 items | S3.1 Semantics, S3.2 ListView.builder, S3.3 Color migration (all 4 phases — 161 colors migrated across 45 files), S3.4 Empty states, S3.5 Responsive typography, S3.6 TextScaler, S3.7 Screenshot prevention (pre-existing native), S3.8 AppBar M3 migration |
| **Sprint Dark Mode — Full Dark Theme** | ✅ Complete | 5 items | DM.1 color migration prerequisite (S3.3 done), DM.2 darkTheme + themeMode active (system default), DM.3 Settings toggle (SegmentedButton: Light/Auto/Dark, persisted via SecureStorage), DM.4 contrast audit + fixes (biometric unlock, privacy screen, dismissible actions, sent badges, web container, account layout), DM.5 toast dark variants (8 new dark-mode status colors in AppStyles) |
| **Sprint Theme Polish** | ✅ Complete | 6 items | TP.1 M3 component themes (inputDecoration, buttons, card, dialog, bottomSheet), TP.2 form field simplification (inherit from theme), TP.3 dark theme redesign (AppBar: elevated surface not brand primary; primary: #B3CCFF for dark surfaces; onPrimary: dark text for accent buttons), TP.4 dark mode consistency (brand surfaces use AppStyles.onPrimary, AppBar uses foregroundColor, SVG fallback fixed), TP.5 border radius standardization (85 raw values → AppStyles constants across 28 files), TP.6 padding/spacing standardization (AppStyles.space* adopted across 50+ files, ~120 non-standard values fixed) |
| **Backlog — P3** | ⬜ Not Started | 7 items | Major refactors |

---

## Detailed Findings

| # | Area | Finding | Recommendation | Priority | Effort | Impact |
|---|------|---------|----------------|----------|--------|--------|
| 1 | Theme | `ColorScheme.fromSeed(seedColor: Colors.white)` — generates near-neutral M3 palette, defeats dynamic tinting | Change seed to `AppStyles.primaryColor` (#2748C3). M3 will derive surface, container, and tonal colors automatically | P0 | 15 min | 🔴 High |
| 2 | Theme | No `darkTheme` or `themeMode` configured | Add `darkTheme` + `ThemeMode.system` to `MaterialApp.router` in `main.dart` | P0 | 1h | 🔴 High |
| 3 | Colors | Brand gradient `0xff2748c3 + 0xff121e57` hardcoded in 6+ files | Replace all occurrences with `AppStyles.appBarGradient` | P0 | 30 min | 🟡 Medium |
| 4 | Colors | Orange button gradient `[Color(0xFFFC976D), Color(0xFFFD5D1A)]` hardcoded in 3 files | Add `static const LinearGradient accentButtonGradient` to `AppStyles` | P0 | 30 min | 🟡 Medium |
| 5 | Colors | 668+ hardcoded `Color(0x...)` literals across 112 files | Replace with `AppStyles.*` constants or `Theme.of(context).colorScheme.*` | P1 | 2–3 days | 🔴 High |
| 6 | Dark Mode | No dark color scheme defined | Design `darkColorScheme` from brand colors. Add to `ThemeData` | P0 | 2h | 🔴 High |
| 7 | Dark Mode | 50+ `TextStyle` constants have hardcoded white/dark colors | Migrate to `colorScheme.onSurface`, `colorScheme.onPrimary`, etc. at call sites | P1 | 2–3 days | 🔴 High |
| 8 | Typography | Manrope font declared in `pubspec.yaml` but never referenced | Remove from `pubspec.yaml` font assets and fonts declaration | P0 | 5 min | 🟢 Low |
| 9 | Typography | `bodyLarge`/`bodyMedium` use default line height | Set `height: 1.5` on body styles for improved email readability | P1 | 20 min | 🟡 Medium |
| 10 | Typography | Legacy font weight aliases confusing | Deprecate legacy aliases; document canonical names (`semiBold`, `bold`) | P2 | 1h | 🟢 Low |
| ♿ 11 | Accessibility | `semanticLabel` not set on any `Icon` widget across 100+ files | Add `semanticLabel` to all `Icon` in `SideMenu`, `GradientAppBar`, `EmailList`, `Drawer` | P1 | 3–4h | 🔴 High |
| ♿ 12 | Accessibility | Only 2 files use `Semantics()` widget | Add `Semantics` to email list items, action buttons, reading pane controls | P1 | 4–6h | 🔴 High |
| ♿ 13 | Accessibility | No `TextScaler` / `textScaleFactor` handling | Wrap fixed-size containers with `MediaQuery.textScalerOf(context)` | P1 | 1 day | 🟡 Medium |
| ♿ 14 | Accessibility | No RTL (`Directionality`) support | Add `Directionality.of(context)` checks in layouts | P3 | 1–2 weeks | 🟡 Medium |
| ♿ 15 | Accessibility | Tooltips only on 4 components; icon-only buttons lack tooltip | Add `Tooltip` wrapper to all `IconButton` / icon-only `GestureDetector` | P1 | 3–4h | 🟡 Medium |
| ♿ 16 | Accessibility | Checkbox in `email_list.dart` uses default 24dp size (below 48dp) | Wrap in `SizedBox(width: 48, height: 48)` | P1 | 1h | 🟡 Medium |
| 🔒 17 | Security | `AutofillHints` not set on any form field | Add `autofillHints` param to `text_form_field.dart` + call sites | P1 | 1h | 🟡 Medium |
| 🔒 18 | Security | No screenshot prevention (FLAG_SECURE) | Add `flutter_windowmanager` for Android FLAG_SECURE on auth + payment screens | P2 | 1 day | 🟡 Medium |
| 19 | Performance | Zero `ListView.builder` usage | Wrap `CustomDismissible` list with `ListView.builder` | P2 | 2–3 days | 🔴 High |
| 20 | Performance | No `RepaintBoundary` around animated list items | Add `RepaintBoundary` around `EmailList` row and reading pane | P1 | 2h | 🟡 Medium |
| 21 | Performance | `cacheWidth`/`cacheHeight` not set on `Image.network` | Add `cacheWidth` to `open_full_screen_image.dart` | P1 | 30 min | 🟢 Low |
| 22 | UX | Page transitions disabled on ALL platforms | Re-enable default transitions for iOS + Android | P1 | 30 min | 🟡 Medium |
| 23 | UX | Empty states use single `NoData` widget with generic text | Create 6 semantic empty state variants | P2 | 1 day | 🟡 Medium |
| 24 | UX | Card/container border radius inconsistent | Standardize: `radiusM: 12` for cards, `radiusS: 8` for chips/fields | P1 | 2–3h | 🟢 Low |
| 25 | UX | ~~Gradient app bar is heavy for email reading context~~ | ✅ **Done (S3.8)** — migrated to flat `AppBarTheme` with `colorScheme.primary` | ~~P2~~ | ~~3–4h~~ | ✅ |
| 26 | UX | Mobile uses drawer at `/menu` route (full-page navigation) | Replace with `Scaffold.drawer` + hamburger | P2 | 1–2 days | 🟡 Medium |
| 27 | UX | Both `fluttertoast` + `toastification` present (duplicate systems) | Consolidate to `toastification`; remove `fluttertoast` | P1 | 3–4h | 🟢 Low |
| 28 | UX | SideMenu has no active route indicator | Highlight active `DrawerItem` for current route | P1 | 2–3h | 🟡 Medium |
| 29 | Perf/UX | ~~`GradientAppBar` not const-optimized~~ | ✅ **Done (S3.8)** — refactored to `OptAppBar`, removed Stack/gradient/IconTheme layers | ~~P1~~ | ~~1–2h~~ | ✅ |
| 30 | Bundle | Manrope variable font asset (~100KB) loaded but unused | Remove from `pubspec.yaml` | P0 | 5 min | 🟢 Low |

---

## Sprint 1 — P0: Theme Foundation

**Goal:** All theme-layer changes. Zero widget tree restructuring. Maximum visual impact.

**Files modified:**
- `lib/main.dart`
- `lib/constant/styles.dart`
- `pubspec.yaml`
- `lib/widgets/gradient_appbar.dart`
- `lib/widgets/gradient_webbar.dart`
- `lib/widgets/gradient_background.dart`
- `lib/widgets/side_menu.dart`
- `lib/widgets/upgrade_plan_popup.dart`
- `lib/widgets/button_form_field.dart`

### Sprint 1 Checklist

> ✅ **All items verified** — `dart analyze`: no issues. Confirmed by code inspection 2026-03-15.

- [x] **S1.1** Fix `ColorScheme.fromSeed` seed → `AppStyles.primaryColor` ✓ `main.dart:1213` `seedColor: AppStyles.primaryColor`
- [x] **S1.2** `_buildDarkTheme()` implemented in `main.dart` ✓ — **intentionally commented out** pending Sprint Dark Mode (all hardcoded colors must be migrated first). Marker: `TODO(dark-mode-sprint)` at `main.dart:1049`
- [x] **S1.3** Dark surface color constants added to `AppStyles` ✓ `styles.dart` — `surfaceDark`, `surfaceContDark`, `surfaceHighDark`, `onSurfaceDark`, `onSurfaceVarDark`
- [x] **S1.4** `accentButtonGradient` + `disabledButtonGradient` added to `AppStyles` ✓ `styles.dart:80,87`
- [x] **S1.5** `gradient_appbar.dart` → `AppStyles.appBarGradient` ✓ *(superseded by S3.8: gradient removed entirely, now uses `AppBarTheme`)*
- [x] **S1.6** `gradient_webbar.dart` → `AppStyles.appBarGradient` ✓ *(superseded by S3.8: file deleted — confirmed unused)*
- [x] **S1.7** `gradient_background.dart` → `AppStyles.appBarGradient` ✓ `gradient_background.dart:24` *(retained for auth screens)*
- [x] **S1.8** `side_menu.dart` → `AppStyles.appBarGradient` ✓ *(superseded by S3.8: now `colorScheme.primary`)*
- [x] **S1.9** `upgrade_plan_popup.dart` → `AppStyles.appBarGradient` + `AppStyles.accentButtonGradient` ✓ *(superseded by S3.8: gradient → `colorScheme.primary`; `accentButtonGradient` retained for orange button)*
- [x] **S1.10** `button_form_field.dart` → `AppStyles.accentButtonGradient` + `AppStyles.disabledButtonGradient` ✓ `button_form_field.dart:36,115`
- [x] **S1.11** Manrope removed from `pubspec.yaml` ✓ (no match on `grep Manrope pubspec.yaml`)
- [x] **S1.12** `height: 1.5` on `bodyLarge`/`bodyMedium`, `height: 1.4` on `bodySmall` ✓ `main.dart:1176,1182,1188`
- [↩️] **S1.13** ~~Native page transitions re-enabled~~ **REVERTED after audit** — `CupertinoPageTransitionsBuilder` / `ZoomPageTransitionsBuilder` animate the full `Scaffold` including `GradientAppBar`, causing distracting header movement on every sidebar tap. Email clients (Gmail, Outlook, Apple Mail) use instant switching for folder/tab nav. All platforms restored to `NoAnimationPageTransitionsBuilder`. Per-route push transitions (email detail, contact detail) moved to **P3 backlog** — requires app bar relocated into `ShellLayout` first.

---

## Sprint 2 — P1: Component Polish

**Goal:** Widget-level changes. No new screens or structural changes.

### Sprint 2 Checklist

- [x] **S2.1** Add `semanticLabel` to all `Icon` in `side_menu.dart`, `gradient_appbar.dart`, `drawer.dart`, `email_list.dart`, `web_menu_items.dart` ✓ — 4 Icons across 3 files (`side_menu.dart:158`, `email_list.dart:141`, `web_menu_items.dart:279,328`); `gradient_appbar.dart` and `drawer.dart` had no bare `Icon` widgets
- [x] **S2.2** Add `Tooltip` to all icon-only `IconButton` widgets in action bars + reading pane ✓ — 13 IconButtons across 6 files (`email_list_pane.dart`, `open_full_screen_image/pdf/webView.dart`, `attachment_preview_screen.dart`, `web_compose.dart`, `view_email.dart`)
- [x] **S2.3** Wrap email list checkboxes in `SizedBox(48, 48)` for 48dp touch target ✓ — `email_list.dart`, `draft_email_list.dart`, `email_list_pane.dart`: expanded from 24×24 to 48×48 with centered icon + circular InkWell splash; removed redundant left padding and 5px spacers to compensate for wider touch area
- [x] **S2.4** Add `autofillHints` param to `text_form_field.dart` + call sites ✓ — optional `Iterable<String>? autofillHints` added to `CustomTextFormField`, `SimpleTextFormField`, `GrayTextFormField`; wired at 24 call sites (login, create account, setup profile, forgot username, add/edit contact across mobile/tablet/desktop layouts)
- [x] **S2.5** Migrate hardcoded colors in `text_form_field.dart`, `button_form_field.dart`, `upgrade_plan_popup.dart` → `colorScheme` ✓ — borders migrated (`outline`/`outlineVariant`/`primary`), button colors migrated (`onPrimary`/`onSurface`); fill colors kept as hardcoded originals because `surface: Colors.white` in theme overrides seed-generated `surfaceContainer*` tokens — fill migration deferred to S3.3 (dark mode sprint). `upgrade_plan_popup.dart` unchanged (white-on-dark-gradient). Rollback reference: `docs/S2_5_COLOR_MIGRATION_ROLLBACK.md`
- [x] **S2.6** Fix `CustomToast` colors for dark mode ✓ — shadow color migrated from `Colors.black26` to `colorScheme.shadow` in `toast.dart`; bg/text pairs are self-contained pastels, no change needed
- [x] **S2.7** Add `RepaintBoundary` around `EmailList` widget and reading pane ✓ — `email_list.dart` (wraps each row's `MouseRegion`), `reading_pane_widget.dart` (wraps `Stack` containing `ViewEmail`)
- [x] **S2.8** Add `cacheWidth`/`cacheHeight` to `open_full_screen_image.dart` ✓ — `LayoutBuilder` + `MediaQuery.devicePixelRatio` compute `memCacheWidth`/`memCacheHeight` for `CachedNetworkImage`
- [x] **S2.9** Consolidate toast systems — remove `fluttertoast`, keep `toastification` ✓ — removed both `fluttertoast` and `toastification` from `pubspec.yaml` (neither was the primary system); migrated 10 `CommonService.showToast()` fallback call sites in contact notifiers to `animatedToast()`; removed `showToast()` method and fluttertoast import from `common_service.dart`; `dismissToast()` simplified to `_removeOverlay()` only
- [x] **S2.10** Standardize border radius → `AppStyles.radiusM` (12dp) for cards ✓ — migrated 8dp (settings/help/overlay cards, search bar, sent email list), 10dp (plan cards, subscription buttons, view_email sheets), and 16dp (compose dialogs, contact popup, tag action sheet, change subscription cards) to `AppStyles.radiusM` across ~20 files; excluded buttons, skeleton loaders, tags/badges, and 30dp dialog shapes
- [x] **S2.11** Add active route indicator to `SideMenu` `DrawerItem` ✓ — `drawer_item.dart`: orange left bar (3px, animated) + bold title when `isActive`, matching desktop sidebar pattern

---

## Sprint 3 — P2: Structural Improvements

**Goal:** New/refactored components. Creates new shared widgets.

### Sprint 3 Checklist

- [x] **S3.1** Add `Semantics` widgets to email list rows, action buttons, reading pane controls ✓ — Phase 1: row-level `Semantics` on `email_list.dart` (sender + subject + read state), `draft_email_list.dart` (subject + checkbox), `sent_email_list.dart` (recipient + subject + checkbox), `tag_email_list.dart` (select-all tooltip); Phase 2: `drawer_item.dart` (title + selected), `web_menu_items.dart` + `MyDrawerSubItem` (title + selected), reading pane overlay backdrops (close menu); action bars already covered by S2.2 tooltips
- [x] **S3.2** `ListView.builder` migration in `CustomDismissible` ✓ — replaced `FlatList` with `RefreshIndicator` + `ListView.builder` for lazy item construction; added `ScrollController` listener for `onEndReached` pagination (triggers at 200px from bottom); empty state handled via conditional before builder; `flat_list` import removed from `custom_dismissible.dart` (package retained in pubspec — still used by 5 other files: notifications, tags layouts)
- [x] **S3.3** Dark mode color migration — sweep remaining hardcoded colors across 112 files ✓ — **All 4 phases complete.** Phase 1: kept `surface: Colors.white` override (email apps need pure white for reading contrast — matches Gmail/Outlook/Apple Mail); updated brand blues (`primaryColor` #243A8F, `primaryDark` #1B2A6B, `primaryVariant` #2F4CC8); fixed contacts reading pane ignoring user's disabled setting. Phase 2 (S3.8): migrated AppBar, sidebar, drawer, and upgrade popup from `appBarGradient` to theme-driven flat colors. Phase 3: migrated ~90 `Colors.white`/`Colors.grey` background/fill/text usages across ~30 files to `colorScheme.*` tokens — form fills (`surfaceContainerHighest`), text on primary (`onPrimary`), body text (`onSurface`), secondary text (`onSurfaceVariant`), selected backgrounds (`primaryContainer`), borders (`outlineVariant`). Phase 4: migrated ~70 remaining `Colors.black`/`Colors.grey` text/icon colors across ~25 files; migrated AppBar SVG `ColorFilter.mode` icons to `appBarTheme.foregroundColor`; migrated skeleton loaders, date pickers, country picker fills. **Total: ~161 hardcoded colors migrated to theme tokens across ~45 files.** Remaining intentional: brand accent colors (orange `0xFFFD5D1A`, link blue `0xFF1C5AD6`, error red `0xFFFF3B30`), image viewer dark bg, overlay/shadow scrims, 81 deprecated `styles.dart` constants (callers should use `AppTypography`), `main.dart` theme definition. `flutter analyze`: 0 issues.
- [x] **S3.4** Empty state system — 6 semantic `EmptyState` widget variants ✓ — replaced `NoData` widget (generic SVG + text) with enum-driven `EmptyState` widget using Material icons (inbox/mail_outline, notifications/notifications_none, tags/label_outline, contacts/person_outline, emailDetail/mail_outline, generic/info_outline); created shared `ReadingPanePlaceholder` widget (.inbox, .draft, .contacts) to standardize reading pane "select an item" placeholders; removed `hasEmails`/`hasContacts` guards from split-view layouts so reading pane stays visible with empty lists (blank right pane); fixed contacts reading pane using stale `n.readingPaneEnabled` notifier field → `s.readingPaneEnabled` state field; deleted `noData.svg`, `svgNoData` constant, and `no_data.dart`; 6 new tests added
- [x] **S3.5** Responsive typography system ✓ — created `AppTypography` class (`lib/constant/app_typography.dart`) with breakpoint-aware font sizing: mobile (<600px), tablet (600–1023px), desktop (≥1024px). Base sizes match Typography Specification (tablet); mobile scales down 1–4px, desktop scales up 2–4px. Uses existing `AppBreakpoints.deviceType(context)` infrastructure. Dual-font system preserved (Figtree for UI chrome, NotoSans for body/reading). Colors intentionally excluded (applied at call site) to stay independent of S3.3 color migration. Legacy compatibility methods map all 33 used `AppStyles.*` TextStyles to responsive equivalents with `@Deprecated` annotations. Static const type scale removed from `styles.dart` (0 uses). All ~189 legacy style usages across ~129 files migrated to `AppTypography.*(context)`.
- [x] **S3.6** `TextScaler` handling — test at 150%/200%, fix truncation ✓ — added `TextScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.5)` in `main.dart` builder to cap text scaling at 1.5x (industry standard for email apps); replaced fixed `itemExtent: 47` in AlphabetScrollView (4 instances across mobile/tablet/web contact layouts) with dynamic `(47 * textScale).clamp(47.0, 70.0)` so rows grow with text scale; migrated ~50+ inline `fontSize:` values across 25+ files to responsive `AppTypography` methods (`titleMedium`, `bodySmall`, `caption`, `timeStamp`, `labelMedium`, etc.)
- [x] **S3.7** Screenshot prevention ✓ — **already implemented natively** (no package needed). Android: `FLAG_SECURE` in `MainActivity.kt` set on `onCreate` + method channel toggle. iOS: `UIView` privacy overlay in `AppDelegate.swift` on `applicationWillResignActive`. Both controlled via `com.optmsg.mail/privacy` method channel from Dart. Integrated with biometric app lock (`local_auth`), 30-second grace window (`ActionBiometricGuard`), cold-start lock. All authenticated screens protected globally — superior to the original per-screen `flutter_windowmanager` recommendation
- [x] **S3.8** AppBar M3 migration — gradient → flat `AppBarTheme` ✓ — **`GradientAppBar` refactored to `OptAppBar`** (`gradient_appbar.dart`). Removed `Stack`, `Container` with gradient `BoxDecoration`, `flexibleSpace`, `IconTheme`/`DefaultTextStyle` color wrappers. Added `AppBarTheme` to both `_buildLightTheme()` (flat `primaryColor` bg, white foreground) and `_buildDarkTheme()` (`surfaceHighDark` bg, `onSurfaceDark` foreground) in `main.dart`. Migrated all 26 call sites from `GradientAppBar(` → `OptAppBar(`. Removed unused `iconColor`, `textColor`, `isCollapsed` params. Flattened sidebar header (`side_menu.dart` → `colorScheme.primary`), drawer header (`drawer.dart` → `colorScheme.primary`), upgrade popup (`upgrade_plan_popup.dart` → `colorScheme.primary`). Deleted unused `gradient_webbar.dart`. Updated `_FreeTrialCenterBanner` to use `colorScheme.onPrimary`. `gradient_background.dart` retained for branded auth screens. `appBarGradient` deprecated in `styles.dart` (only `gradient_background.dart` remains). Responsive logic preserved: sidebar-aware leading hide, search embedding, free trial banner. `flutter analyze`: 0 errors/warnings. **Files modified (30):** `main.dart`, `styles.dart`, `gradient_appbar.dart`, `side_menu.dart`, `drawer.dart`, `upgrade_plan_popup.dart`, + 24 screen/test files. **Step 2 (future):** Move to full-width AppBar in `ShellLayout` — see P3 backlog.

---

## Backlog — P3: Significant Refactors

- [ ] RTL / Directionality support (Arabic, Hebrew, Persian locales)
- [ ] Full Semantics audit and remediation across all 100+ screens
- [x] `Scaffold.drawer` to replace `/menu` full-screen route on mobile ✓ — added `GlobalKey<ScaffoldState>` + `openDrawer()` to `ShellLayout` (mobile wrapper Scaffold); refactored `MyDrawer` from standalone Scaffold page to `Drawer()` widget (removed PopScope, own Scaffold, close button; added SafeArea, simplified header); changed 7 screen hamburger buttons from `context.push(AppRoutes.menu)` → `ShellLayout.of(context)?.openDrawer()`; deleted `/menu` GoRoute from `app_router.dart`; added `drawerTheme` to both light/dark themes. Result: menu slides over content with edge-swipe support, no route added to back stack
- [x] `NavigationBar` (M3) as `BottomNavigationBar` replacement for mobile ✓ — created `AppNavigationBar` (`lib/widgets/app_navigation_bar.dart`) using M3 `NavigationBar` with pill-shaped indicator (3 items: Inbox, Trash, Contacts); centralized in `ShellLayout` mobile Scaffold (removed from 4 individual screen Scaffolds); moved bottom nav state from `screens/dashboard/` → `lib/services/` (freeing dashboard folder for future use); deleted `WebMobileBottomNav`, `MyBottomNavigationBarApp`, and old dashboard state files; updated `ResponsiveInboxWrapper` to return `InboxResponsive` directly; added `NavigationBarThemeData` to both light/dark themes; keyboard auto-hides nav bar via `MediaQuery.viewInsets`
- [x] Adaptive navigation rail pattern for tablet ✓ — **covered by existing collapsible SideMenu** which collapses to 72px icon-only mode on tablet, functionally identical to a `NavigationRail`. No additional widget needed
- [x] `ThemeExtension` for app-specific tokens ✓ — created `AppColorsExtension` (`lib/constant/app_colors_extension.dart`) with 16 tokens: 8 status colors (error/warn/info/success × bg/text), 4 interactive (accent, accentBg, linkBlue, toggleGreen), 2 surface tints (tintOrange, tintSecondary), 2 gradients (accentGradient, disabledGradient). Registered in both light/dark ThemeData. Added `context.appColors` shorthand to `ResponsiveContext`. Migrated ~34 files: eliminated `isDark` brightness checks in toast/dismissible/sent_email_list/notifications; migrated `clickableTextColor` (20 files), gradients (3 files), surface tints (4 files). Deprecated `clickableBgColor`, `toggleBackground`, `lightOrange`, `lightSecondaryColor` in AppStyles
- [x] **Full-width AppBar in ShellLayout** ✓ — created `AppBarConfig` state + `appBarConfigProvider` (Riverpod) for screens to communicate title/actions/search up to ShellLayout. Single persistent AppBar in ShellLayout renders fixed-slot layout: auto leading (hamburger/back via `canPop()`), title (mobile) / logo (desktop), search (inline desktop / toggle+slide mobile), notification bell (universal), filter slot, add slot. Removed Scaffold from all 7 main screens (inbox, archive, draft, tags, contacts, help center, settings) — they now return body content only and push `AppBarConfig`. Removed SideMenu header (hamburger + logo moved to AppBar). Retired `OptAppBar` responsive logic from main screens. Notification bell now visible on all screens. Eliminates nested Scaffolds, enables per-route content transitions (#8). **Files:** `shell_layout.dart` (rewritten), `app_bar_config_provider.dart` + `app_bar_config_state.dart` (new), `side_menu.dart` (header removed), 7 screen files (Scaffold removed)
- [x] **Per-route push transitions** ✓ — created `buildPushTransitionPage()` + `pushPageBuilder()` helper (`lib/router/route_page_transitions.dart`) with platform-aware transitions: `CupertinoPageTransition` (slide from right, 300 ms) on iOS/Android, fade + subtle horizontal slide (200 ms) on web. Applied `pageBuilder: pushPageBuilder(...)` to all 9 hierarchical GoRoutes: email detail (`/{folder}/email`), view/edit/add contact, add existing contact, compose, view email, attachment preview, change subscription. ShellLayout AppBar stays static — only body content animates.
- [ ] **Icon system audit** — app uses two icon systems: ~60 custom SVGs (`assets/svg/`) for app-specific UI (navigation, actions, email) and Material Icons (`Icons.*`) for generic patterns (checkboxes, chevrons, toast status, empty states, hamburger menu). Audit all ~15 Material Icon usages and decide: migrate to custom SVGs for full brand consistency, or standardize which categories use which system. Low priority — current mix is mostly intentional (brand SVGs for app chrome, Material for platform patterns).

---

## Sprint Dark Mode — Full Dark Theme

> ⚠️ **Blocked until Sprint 3 color migration is complete.** `_buildDarkTheme()` is implemented in `main.dart` but commented out. Do NOT enable until all 668 hardcoded `Color(0x...)` literals are replaced with `colorScheme` tokens — enabling it early produces inconsistent visuals (e.g. white text on white backgrounds, black cards).
>
> Enable by uncommenting `darkTheme` + `themeMode` in `main.dart` (search `TODO(dark-mode-sprint)`).

### Sprint Dark Mode Checklist

- [x] **DM.1** Complete Sprint 3 color migration ✓ — S3.3 Phase 1-4 complete: 161 hardcoded colors migrated across 45 files to `colorScheme.*` tokens
- [x] **DM.2** Dark theme + themeMode active ✓ — `darkTheme: _darkTheme` and `themeMode: ThemeMode.system` already enabled in `main.dart:1267-1272`. Dark ColorScheme uses navy surfaces (`surfaceDark` #0E1530, `surfaceContDark` #161E45, `surfaceHighDark` #1C2660) with light text (`onSurfaceDark` #E8ECFF, `onSurfaceVarDark` #B3BBDD)
- [x] **DM.3** Settings toggle ✓ — `_ThemeModeSelector` SegmentedButton (Light/Auto/Dark) already implemented across all 3 responsive settings layouts (mobile/tablet/desktop). Persisted via `SecureStorageService` key `themeModePref`, default `'system'`. Read on startup in `SettingsNotifier._init()`
- [x] **DM.4** Dark mode contrast audit ✓ — fixed 6 contrast issues: biometric unlock button (`Colors.white` → `colorScheme.surface`), privacy screen bg (same), `custom_dismissible.dart` action backgrounds (4 action types now use dark variants), `sent_email_list.dart` community badge (`lightOrange` → theme-aware orange), `web_container.dart` overlay (white → `outlineVariant`), `account_mobile_layout.dart` bg (hardcoded grey → `surfaceContainerHighest`). Verified attachment_preview_screen white70 on black scaffold is correct (high contrast). All deprecated `AppStyles` TextStyles already migrated to `AppTypography` at call sites
- [x] **DM.5** CustomToast dark variants ✓ — added 8 dark-mode status colors to `AppStyles` (`bgErrorDark` #3D1519, `textErrorDark` #FFB4AB, `bgWarnDark` #3D3012, `textWarnDark` #E8D48B, `bgInfoDark` #0E2D3D, `textInfoDark` #90CAE0, `bgSuccessDark` #1A3318, `textSuccessDark` #A8D89A). `CustomToast.build()` now checks `Theme.of(context).brightness` to select light/dark palette

### Strategy
- `ColorScheme.fromSeed()` for both light and dark, seeded from brand primary (`#243A8F`)
- Light: `Brightness.light` — keeps current white backgrounds; `AppBarTheme` uses flat `primaryColor` (S3.8 ✓)
- Dark: `Brightness.dark` — deep navy surfaces (matches brand `primaryDark`); `AppBarTheme` uses `surfaceHighDark` with `onSurfaceDark` foreground (S3.8 ✓)
- `ThemeMode.system` by default; user toggle exposed in Settings
- AppBar, sidebar header, drawer header, and upgrade popup are now theme-driven (S3.8 ✓) — will auto-switch when dark theme is enabled

### Dark Surface Colors (already added to `AppStyles`)
```
surfaceDark      = #0E1530  Deepest navy (scaffold background)
surfaceContDark  = #161E45  Card surfaces
surfaceHighDark  = #1C2660  Elevated cards
onSurfaceDark    = #E8ECFF  Primary text on dark
onSurfaceVarDark = #B3BBDD  Secondary text on dark
```

### Hardcoded Color Migration Checklist (prerequisite for DM.2)
- [x] `gradient_appbar.dart` — brand gradient removed entirely (S3.8); now uses `AppBarTheme` from `ThemeData`
- [x] `gradient_webbar.dart` — **deleted** (S3.8, confirmed unused)
- [x] `gradient_background.dart` — brand gradient retained for auth screens (acceptable — one-time render)
- [x] `side_menu.dart` — gradient → `Theme.of(context).colorScheme.primary` (S3.8)
- [x] `drawer.dart` — gradient → `Theme.of(context).colorScheme.primary` (S3.8)
- [x] `upgrade_plan_popup.dart` — gradient → `Theme.of(context).colorScheme.primary` (S3.8); orange button gradient kept (`accentButtonGradient`)
- [x] `button_form_field.dart` — orange + disabled → `AppStyles.*`
- [ ] `text_form_field.dart` (lines 208, 220, 288, 292) — border/fill → `colorScheme.outline`, `colorScheme.surfaceContainerHighest`
- [ ] `TextStyle(color: Color(0xFFFFFFFF))` in `styles.dart` → `colorScheme.onPrimary` at call sites
- [ ] `TextStyle(color: Color(0xFF001625))` in `styles.dart` → `colorScheme.onSurface` at call sites
- [ ] `TextStyle(color: Color(0xFF747474))` in `styles.dart` → `colorScheme.onSurfaceVariant` at call sites
- [ ] `tags_desktop_layout.dart:63` → `AppStyles.clickableTextColor`
- [ ] SVG icons in AppBar actions — replace hardcoded `Colors.white` colorFilter with `Theme.of(context).appBarTheme.foregroundColor` (or replace SVGs with Material Icons where equivalent exists)
- [ ] All remaining 112 files — replace `Color(0x...)` literals with named `AppStyles.*` constants

---

## Typography Specification

### Fonts: Keep Figtree + NotoSans (Already Optimal)
- **Figtree** (variable wght 300–800): UI chrome, headings, labels. Clean at 12–17sp.
- **NotoSans** (variable wdth+wght): Body, email content. 1,000+ language coverage — best for multilingual email.
- **NotoColorEmoji**: Emoji fallback.
- ~~**Manrope**~~: Removed (unused, ~100KB bundle waste).
- **Future (P1):** Add `JetBrains Mono` for code blocks in email content.

### Type Scale
| Role | Family | Size | Weight | Height | Notes |
|------|--------|------|--------|--------|-------|
| displayLarge | Figtree | 40 | w800 | — | Plan prices, hero numbers |
| displayMedium | Figtree | 32 | w700 | — | |
| displaySmall | Figtree | 28 | w700 | — | |
| headlineLarge | Figtree | 27 | w700 | — | Screen titles |
| headlineMedium | Figtree | 22 | w700 | — | Card headings |
| headlineSmall | Figtree | 18 | w600 | — | Section headers |
| titleLarge | Figtree | 20 | w600 | — | App bar, panel headings |
| titleMedium | Figtree | 17 | w600 | — | List titles, form labels |
| titleSmall | Figtree | 15 | w600 | — | Secondary labels |
| **bodyLarge** | NotoSans | 17 | w400 | **1.5** | Email previews, long-form |
| **bodyMedium** | NotoSans | 15 | w400 | **1.5** | Standard body text |
| bodySmall | NotoSans | 13 | w400 | 1.4 | Timestamps, metadata |
| labelLarge | Figtree | 17 | w500 | — | Buttons |
| labelMedium | Figtree | 15 | w500 | — | Tabs, secondary buttons |
| labelSmall | Figtree | 12 | w500 | — | Chips, badges |

**Key change:** `height: 1.5` on body styles improves email readability (was system default ~1.2).

---

## Verification Checklist

- [ ] iOS Simulator → System Settings → Dark Mode toggle → all screens adapt
- [ ] AppBar uses `AppBarTheme` colors in both light and dark mode (flat `primaryColor` light, `surfaceHighDark` dark)
- [ ] Sidebar header color matches AppBar color at horizontal seam (both light and dark)
- [ ] Skeleton loader correct in dark mode (already theme-aware)
- [ ] `CustomToast` error/success visible in dark mode
- [ ] Free trial banner renders correctly in AppBar actions area (desktop: text + button, tablet: compact button, mobile: small button)
- [ ] Selection-mode AppBars in inbox/archive/draft work correctly with theme colors
- [ ] Text Size 200% → no truncation in inbox, email detail, settings
- [ ] VoiceOver/TalkBack → email rows announce sender + subject + date
- [ ] 60fps on email list scroll (after `RepaintBoundary`)
- [ ] iOS login with 1Password → autofill suggestion bar appears
- [ ] `flutter analyze` — zero errors/warnings
