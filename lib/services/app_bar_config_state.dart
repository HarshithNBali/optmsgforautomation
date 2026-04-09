import 'package:flutter/widgets.dart';

/// Configuration that each screen pushes to describe what the shell AppBar
/// should display. ShellLayout reads this via [appBarConfigProvider] and
/// renders a single, persistent AppBar with fixed slots.
///
/// Screens only set what's unique to them — everything else (hamburger,
/// back button, logo, notification bell, responsive search presentation)
/// is handled universally by ShellLayout.
@immutable
class AppBarConfig {
  const AppBarConfig({
    this.title = '',
    this.showSearch = false,
    this.searchOpenByDefault = false,
    this.onSearch,
    this.filterWidget,
    this.showAddButton = false,
    this.onAdd,
    this.isSelectionMode = false,
    this.selectionLeading,
    this.selectionActions = const [],
    this.customActions,
    this.hideUpgradeBanner = false,
    this.onBackPressed,
  });

  /// Screen title shown on mobile. Desktop shows the logo instead.
  final String title;

  // ── Search ──────────────────────────────────────────────────────────────
  /// Whether the search bar / icon are visible on this screen.
  final bool showSearch;
  /// When true, the mobile search bar auto-opens on screen entry.
  final bool searchOpenByDefault;
  final ValueChanged<String>? onSearch;

  // ── Filter slot (inbox / archive) ──────────────────────────────────────
  /// Screen-specific filter icons. Null = hidden.
  final Widget? filterWidget;

  // ── Add slot (tags / contacts) ─────────────────────────────────────────
  final bool showAddButton;
  final VoidCallback? onAdd;

  // ── Selection mode (email screens) ─────────────────────────────────────
  final bool isSelectionMode;
  final Widget? selectionLeading;
  final List<Widget> selectionActions;

  // ── Custom actions (detail/push screens) ────────────────────────────────
  /// When non-null, replaces ALL default action slots (notification bell,
  /// search toggle, filter, add) with these custom actions. Use for detail
  /// screens like view email, compose, view contact that have their own
  /// specific action buttons.
  final List<Widget>? customActions;

  // ── Back button intercept ───────────────────────────────────────────────
  /// When non-null, the shell's back button calls this instead of navigating.
  /// Screens set this when an overlay (more menu, tag list) is open so the
  /// first back press closes the overlay and the second navigates away.
  final VoidCallback? onBackPressed;

  // ── Misc ────────────────────────────────────────────────────────────────
  /// Hide the free-trial upgrade banner (subscription screens).
  final bool hideUpgradeBanner;

  AppBarConfig copyWith({
    String? title,
    bool? showSearch,
    bool? searchOpenByDefault,
    ValueChanged<String>? onSearch,
    Widget? filterWidget,
    bool? showAddButton,
    VoidCallback? onAdd,
    bool? isSelectionMode,
    Widget? selectionLeading,
    List<Widget>? selectionActions,
    List<Widget>? customActions,
    bool? hideUpgradeBanner,
    VoidCallback? onBackPressed,
  }) {
    return AppBarConfig(
      title: title ?? this.title,
      showSearch: showSearch ?? this.showSearch,
      searchOpenByDefault: searchOpenByDefault ?? this.searchOpenByDefault,
      onSearch: onSearch ?? this.onSearch,
      filterWidget: filterWidget ?? this.filterWidget,
      showAddButton: showAddButton ?? this.showAddButton,
      onAdd: onAdd ?? this.onAdd,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectionLeading: selectionLeading ?? this.selectionLeading,
      selectionActions: selectionActions ?? this.selectionActions,
      customActions: customActions ?? this.customActions,
      hideUpgradeBanner: hideUpgradeBanner ?? this.hideUpgradeBanner,
      onBackPressed: onBackPressed ?? this.onBackPressed,
    );
  }
}
