import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_center_state.dart';

final helpCenterProvider =
    NotifierProvider.autoDispose<HelpCenterNotifier, HelpCenterState>(HelpCenterNotifier.new);

class HelpCenterNotifier extends Notifier<HelpCenterState> {
  @override
  HelpCenterState build() {
    return const HelpCenterState();
  }

  /// Initialize help center
  Future<void> init() async {
    try {
      await manageComposeFlag();
    } catch (_) {
      // SharedPreferences failure is non-critical; compose flag may stay stale.
    }
  }

  /// Set compose flag to false when screen loads
  /// This prevents the app from showing the compose page when navigating back
  Future<void> manageComposeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('inCompose', false);
  }

  /// Select FAQ category
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Search help articles
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Toggle FAQ item expansion
  void toggleItem(String itemId) {
    final expanded = List<String>.from(state.expandedItems);
    if (expanded.contains(itemId)) {
      expanded.remove(itemId);
    } else {
      expanded.add(itemId);
    }
    state = state.copyWith(expandedItems: expanded);
  }

  /// Collapse all items
  void collapseAll() {
    state = state.copyWith(expandedItems: []);
  }
}
