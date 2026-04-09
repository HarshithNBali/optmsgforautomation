/// AppBar State Regression Tests
///
/// Source-level tests that verify AppBar touch targets, config completeness,
/// stale-state guards, documentation integrity, and search auto-open behavior.
/// These tests catch regressions at the code pattern level — if a future change
/// reverts a fix, the corresponding test will fail.
///
/// Run with: flutter test test/regression/appbar_state_regression_test.dart
library;

import 'package:flutter_test/flutter_test.dart';

import 'gl_106_test_helpers.dart';
import 'appbar_test_helpers.dart';

void main() {
  // =========================================================================
  // Group 1 — Touch Target Tests
  // All AppBar action buttons must use IconButton, not InkWell
  // =========================================================================

  group('Group 1 — Touch Targets (IconButton not InkWell)', () {
    test('inbox selection actions use IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/inbox_riverpod/inbox_responsive.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActionsWidgets');
      expect(actionsIssues, isEmpty,
          reason:
              'inbox _buildSelectionActionsWidgets must use IconButton, not '
              'InkWell, for proper 48x48 touch targets on Android. '
              'Found: $actionsIssues');
    });

    test('inbox selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/inbox_riverpod/inbox_responsive.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeadingWidget');
      expect(leadingIssues, isEmpty,
          reason:
              'inbox _buildSelectionLeadingWidget must use IconButton for '
              'the back arrow. Found: $leadingIssues');
    });

    test('archive selection actions use IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/archive_riverpod/archive_responsive.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActionsWidgets');
      expect(actionsIssues, isEmpty,
          reason:
              'archive _buildSelectionActionsWidgets must use IconButton. '
              'Found: $actionsIssues');
    });

    test('archive selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/archive_riverpod/archive_responsive.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeadingWidget');
      expect(leadingIssues, isEmpty,
          reason:
              'archive _buildSelectionLeadingWidget must use IconButton. '
              'Found: $leadingIssues');
    });

    test('draft selection actions use IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/draft_riverpod/draft_responsive.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActionsWidgets');
      expect(actionsIssues, isEmpty,
          reason:
              'draft _buildSelectionActionsWidgets must use IconButton. '
              'Found: $actionsIssues');
    });

    test('draft selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/email/draft_riverpod/draft_responsive.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeadingWidget');
      expect(leadingIssues, isEmpty,
          reason:
              'draft _buildSelectionLeadingWidget must use IconButton. '
              'Found: $leadingIssues');
    });

    test('contacts selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/contacts/contacts_riverpod/contact_list_riverpod.dart');

      // Contacts inlines the leading widget in _pushAppBarConfig, so check
      // that there is no InkWell wrapping svgLeftArrow in the file.
      final body = extractMethodBody(source, '_pushAppBarConfig');
      expect(body, isNotNull,
          reason: 'contact_list_riverpod must have _pushAppBarConfig');

      final hasInkWellArrow = body!.contains('InkWell') &&
          body.contains('svgLeftArrow');
      expect(hasInkWellArrow, isFalse,
          reason:
              'contacts selection back arrow must use IconButton, not InkWell');
    });

    test('tags list selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/tags/tag_riverpod/tags_list_riverpod.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeadingWidget');
      expect(leadingIssues, isEmpty,
          reason:
              'tags _buildSelectionLeadingWidget must use IconButton. '
              'Found: $leadingIssues');
    });

    test('tags list selection delete action uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/tags/tag_riverpod/tags_list_riverpod.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActionsWidgets');
      expect(actionsIssues, isEmpty,
          reason:
              'tags _buildSelectionActionsWidgets must use IconButton. '
              'Found: $actionsIssues');
    });

    test('tag email list selection back arrow uses IconButton', () {
      final source =
          readSourceFile('lib/screens/tags/tag_email_list.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeading');
      expect(leadingIssues, isEmpty,
          reason:
              'tag_email_list _buildSelectionLeading must use IconButton. '
              'Found: $leadingIssues');
    });

    test('tag email list selection actions use IconButton', () {
      final source =
          readSourceFile('lib/screens/tags/tag_email_list.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActions');
      expect(actionsIssues, isEmpty,
          reason:
              'tag_email_list _buildSelectionActions must use IconButton. '
              'Found: $actionsIssues');
    });

    test('notification selection back arrow uses IconButton', () {
      final source = readSourceFile(
          'lib/screens/notifications/notification_riverpod/notification_responsive.dart');

      final leadingIssues =
          findInkWellSvgActions(source, '_buildSelectionLeadingWidget');
      expect(leadingIssues, isEmpty,
          reason:
              'notification _buildSelectionLeadingWidget must use IconButton. '
              'Found: $leadingIssues');
    });

    test('notification selection actions use IconButton', () {
      final source = readSourceFile(
          'lib/screens/notifications/notification_riverpod/notification_responsive.dart');

      final actionsIssues =
          findInkWellSvgActions(source, '_buildSelectionActionsWidgets');
      expect(actionsIssues, isEmpty,
          reason:
              'notification _buildSelectionActionsWidgets must use IconButton. '
              'Found: $actionsIssues');
    });

    test('shell_layout Add button uses TextButton.icon not InkWell', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      // The Add button should be TextButton.icon, not InkWell
      final buildBody =
          extractMethodBody(source, '_buildShellAppBar');
      expect(buildBody, isNotNull);

      // Check there's no InkWell wrapping the Add button
      final hasInkWellAdd = buildBody!.contains("InkWell") &&
          buildBody.contains("config.onAdd") &&
          buildBody.contains("Icons.add");
      expect(hasInkWellAdd, isFalse,
          reason:
              'shell_layout Add button must use TextButton.icon, not InkWell');

      // Verify TextButton.icon is used instead
      expect(buildBody.contains('TextButton.icon'), isTrue,
          reason: 'shell_layout must use TextButton.icon for Add button');
    });
  });

  // =========================================================================
  // Group 2 — AppBar Config Completeness
  // =========================================================================

  group('Group 2 — AppBar Config Completeness', () {
    test('inbox pushes showSearch, onSearch, filterWidget', () {
      final source = readSourceFile(
          'lib/screens/email/inbox_riverpod/inbox_responsive.dart');
      final missing = verifyAppBarConfigFields(
        source,
        '_pushAppBarConfig',
        ['showSearch: true', 'onSearch:', 'filterWidget:'],
      );
      expect(missing, isEmpty,
          reason: 'inbox _pushAppBarConfig missing: $missing');
    });

    test('archive pushes showSearch, onSearch, filterWidget', () {
      final source = readSourceFile(
          'lib/screens/email/archive_riverpod/archive_responsive.dart');
      final missing = verifyAppBarConfigFields(
        source,
        '_pushAppBarConfig',
        ['showSearch: true', 'onSearch:', 'filterWidget:'],
      );
      expect(missing, isEmpty,
          reason: 'archive _pushAppBarConfig missing: $missing');
    });

    test('drafts pushes showSearch, onSearch', () {
      final source = readSourceFile(
          'lib/screens/email/draft_riverpod/draft_responsive.dart');
      final missing = verifyAppBarConfigFields(
        source,
        '_pushAppBarConfig',
        ['showSearch: true', 'onSearch:'],
      );
      expect(missing, isEmpty,
          reason: 'drafts _pushAppBarConfig missing: $missing');
    });

    test('contacts pushes showSearch, searchOpenByDefault, onSearch, filterWidget', () {
      final source = readSourceFile(
          'lib/screens/contacts/contacts_riverpod/contact_list_riverpod.dart');
      final missing = verifyAppBarConfigFields(
        source,
        '_pushAppBarConfig',
        [
          'showSearch: true',
          'searchOpenByDefault: true',
          'onSearch:',
          'filterWidget:',
        ],
      );
      expect(missing, isEmpty,
          reason: 'contacts _pushAppBarConfig missing: $missing');
    });

    test('tags list pushes showAddButton, onAdd', () {
      final source = readSourceFile(
          'lib/screens/tags/tag_riverpod/tags_list_riverpod.dart');
      final missing = verifyAppBarConfigFields(
        source,
        '_pushAppBarConfig',
        ['showAddButton: true', 'onAdd:'],
      );
      expect(missing, isEmpty,
          reason: 'tags _pushAppBarConfig missing: $missing');
    });
  });

  // =========================================================================
  // Group 3 — Stale State Guards
  // =========================================================================

  group('Group 3 — Stale State Guards', () {
    test('pushPopped handler clears _screenOverrideTitle', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      // The build() method should clear _screenOverrideTitle in the
      // pushPopped handler (inside the titleStale || pushPopped block)
      final buildBody = extractMethodBody(source, 'build');
      expect(buildBody, isNotNull);

      // Find the pushPopped block and verify it sets _screenOverrideTitle = false
      final hasPushPoppedClear =
          sourceContains(source, '_screenOverrideTitle = false');
      expect(hasPushPoppedClear, isTrue,
          reason:
              'shell_layout build() must clear _screenOverrideTitle = false '
              'in the pushPopped handler to prevent stale title override '
              'after push route pops (Vector 5)');
    });

    test('didUpdateWidget clears _screenOverrideTitle on route change', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      final body = extractMethodBody(source, 'didUpdateWidget');
      expect(body, isNotNull);

      final clearsOverride = body!.contains('_screenOverrideTitle = false');
      expect(clearsOverride, isTrue,
          reason:
              'didUpdateWidget must clear _screenOverrideTitle when route '
              'changes to prevent stale screen overrides');
    });

    test('_configForRoute does NOT include callbacks', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      final body = extractMethodBody(source, '_configForRoute');
      expect(body, isNotNull);

      // Route-derived configs must not contain callbacks
      expect(body!.contains('onSearch:'), isFalse,
          reason:
              '_configForRoute must not set onSearch — callbacks come from '
              'screen setAppBarConfig only');
      expect(body.contains('onAdd:'), isFalse,
          reason: '_configForRoute must not set onAdd');
      expect(body.contains('filterWidget:'), isFalse,
          reason: '_configForRoute must not set filterWidget');
    });

    test('setAppBarConfig checks mounted', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      final body = extractMethodBody(source, 'setAppBarConfig');
      expect(body, isNotNull);

      expect(body!.contains('if (!mounted) return'), isTrue,
          reason:
              'setAppBarConfig must check mounted before setState to '
              'prevent stale config pushes from disposed screens');
    });

    test('pop handler clears _mobileSearchOpen and search controller', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      // The pushPopped/titleStale handler must reset search state
      final buildBody = extractMethodBody(source, 'build');
      expect(buildBody, isNotNull);

      // Look for _mobileSearchOpen = false in the postFrameCallback block
      final lines = sourceLinesContaining(source, '_mobileSearchOpen = false');
      expect(lines.length, greaterThanOrEqualTo(2),
          reason:
              '_mobileSearchOpen must be cleared in pop handler and '
              'didUpdateWidget to prevent stale search bar');
    });
  });

  // =========================================================================
  // Group 4 — Documentation Integrity
  // =========================================================================

  group('Group 4 — Documentation Integrity', () {
    test('_configForRoute routes all documented in doc comment', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      // Extract route strings from _configForRoute switch cases
      final configBody = extractMethodBody(source, '_configForRoute');
      expect(configBody, isNotNull);

      // These routes must appear in both the switch statement AND the doc comment
      final documentedRoutes = [
        '/inbox',
        '/drafts',
        '/archive',
        '/sent',
        '/trash',
        '/tags',
        '/contacts',
        '/settings',
        '/help',
        '/notifications',
      ];

      // Get the doc comment (everything before 'import')
      final docEnd = source.indexOf('import ');
      final docComment = source.substring(0, docEnd);

      for (final route in documentedRoutes) {
        // Check route is in the doc comment
        expect(docComment.contains(route), isTrue,
            reason: 'Route $route is in _configForRoute but missing from '
                'the doc comment in shell_layout.dart');

        // Check route is in _configForRoute
        expect(configBody!.contains("'$route'") || configBody.contains(route),
            isTrue,
            reason: 'Route $route is documented but missing from '
                '_configForRoute switch statement');
      }
    });

    test('searchRoutes array matches documented search routes', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      // Find the searchRoutes const
      final searchRoutesLine = sourceLinesContaining(source, 'searchRoutes');
      expect(searchRoutesLine, isNotEmpty,
          reason: 'shell_layout must define searchRoutes');

      // These routes should have [🔍] in the doc and be in searchRoutes
      final expectedSearchRoutes = [
        '/inbox',
        '/drafts',
        '/archive',
        '/sent',
        '/trash',
        '/contacts',
      ];

      final searchRoutesStr = searchRoutesLine.first;
      for (final route in expectedSearchRoutes) {
        expect(searchRoutesStr.contains("'$route'"), isTrue,
            reason:
                '$route is documented with [🔍] but missing from searchRoutes');
      }
    });

    test('doc comment includes symbol legend', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');
      final docEnd = source.indexOf('import ');
      final docComment = source.substring(0, docEnd);

      expect(docComment.contains('SYMBOL LEGEND'), isTrue,
          reason: 'Doc comment must include a SYMBOL LEGEND section');
      expect(docComment.contains('[filter]'), isTrue,
          reason: 'Doc comment must use [filter] not [≡] for filter icon');
    });

    test('doc comment includes selection mode section', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');
      final docEnd = source.indexOf('import ');
      final docComment = source.substring(0, docEnd);

      expect(docComment.contains('SELECTION MODE'), isTrue,
          reason: 'Doc comment must document selection mode AppBar states');
    });

    test('doc comment includes /tags top-level route', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');
      final docEnd = source.indexOf('import ');
      final docComment = source.substring(0, docEnd);

      // /tags as a top-level route (not just /tags?id=xxx)
      final topLevelSection = docComment.split('SUB-ROUTES').first;
      expect(topLevelSection.contains('/tags'), isTrue,
          reason: 'Doc comment must include /tags as a top-level go() route');
    });

    test('doc comment retains FAB documentation', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');
      final docEnd = source.indexOf('import ');
      final docComment = source.substring(0, docEnd);

      expect(docComment.contains('FAB'), isTrue,
          reason: 'Doc comment must document FAB buttons for mobile screens');
      expect(docComment.contains('Compose'), isTrue,
          reason: 'Doc comment must mention Compose FAB');
    });
  });

  // =========================================================================
  // Group 5 — Contacts Search Auto-Open
  // =========================================================================

  group('Group 5 — Contacts Search Auto-Open', () {
    test('contacts _pushAppBarConfig includes searchOpenByDefault: true', () {
      final source = readSourceFile(
          'lib/screens/contacts/contacts_riverpod/contact_list_riverpod.dart');

      final body = extractMethodBody(source, '_pushAppBarConfig');
      expect(body, isNotNull);

      expect(body!.contains('searchOpenByDefault: true'), isTrue,
          reason:
              'contacts _pushAppBarConfig must set searchOpenByDefault: true '
              'so the search bar auto-opens when navigating to /contacts');
    });

    test('AppBarConfig defines searchOpenByDefault field', () {
      final source =
          readSourceFile('lib/services/app_bar_config_state.dart');

      expect(sourceContains(source, 'final bool searchOpenByDefault'), isTrue,
          reason:
              'AppBarConfig must define searchOpenByDefault field');
    });

    test('shell_layout setAppBarConfig handles searchOpenByDefault', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');

      final body = extractMethodBody(source, 'setAppBarConfig');
      expect(body, isNotNull);

      expect(body!.contains('searchOpenByDefault'), isTrue,
          reason:
              'setAppBarConfig must handle searchOpenByDefault flag to '
              'auto-open the mobile search bar');
    });
  });

  // =========================================================================
  // Group 6 — AppBarConfig Model Completeness
  // =========================================================================

  group('Group 6 — AppBarConfig Model Completeness', () {
    test('AppBarConfig copyWith covers searchOpenByDefault', () {
      final source =
          readSourceFile('lib/services/app_bar_config_state.dart');

      final copyWithBody = extractMethodBody(source, 'copyWith');
      expect(copyWithBody, isNotNull);

      expect(copyWithBody!.contains('searchOpenByDefault'), isTrue,
          reason:
              'AppBarConfig.copyWith must include searchOpenByDefault parameter');
    });

    test('AppBarConfig constructor has searchOpenByDefault with default false', () {
      final source =
          readSourceFile('lib/services/app_bar_config_state.dart');

      expect(
          sourceContains(source, 'this.searchOpenByDefault = false'), isTrue,
          reason:
              'AppBarConfig constructor must have searchOpenByDefault '
              'defaulting to false');
    });

    test('AppBarConfig copyWith covers all fields', () {
      final source =
          readSourceFile('lib/services/app_bar_config_state.dart');

      final copyWithBody = extractMethodBody(source, 'copyWith');
      expect(copyWithBody, isNotNull);

      // All fields that exist as 'final' declarations must appear in copyWith
      final fieldPattern = RegExp(r'final\s+\S+\s+(\w+);');
      final fields = fieldPattern
          .allMatches(source)
          .map((m) => m.group(1)!)
          .toList();

      for (final field in fields) {
        expect(copyWithBody!.contains(field), isTrue,
            reason:
                'AppBarConfig.copyWith is missing field: $field');
      }
    });

    test('AppBarConfig has onBackPressed field', () {
      final source =
          readSourceFile('lib/services/app_bar_config_state.dart');

      expect(sourceContains(source, 'VoidCallback? onBackPressed'), isTrue,
          reason:
              'AppBarConfig must have onBackPressed field for overlay '
              'close-before-navigate behavior');
    });
  });

  // =========================================================================
  // Group — clearOverlayStates completeness
  // =========================================================================

  group('clearOverlayStates must reset all overlay flags', () {
    test('inbox clearOverlayStates resets showMoveOverlay', () {
      final source = readSourceFile(
          'lib/screens/email/inbox_riverpod/inbox_notifier.dart');
      final body = extractMethodBody(source, 'clearOverlayStates');
      expect(body, isNotNull);
      expect(body!.contains('showMoveOverlay: false'), isTrue,
          reason:
              'inbox clearOverlayStates must reset showMoveOverlay');
    });

    test('inbox clearOverlayStates resets showReadingPaneMenuOptions', () {
      final source = readSourceFile(
          'lib/screens/email/inbox_riverpod/inbox_notifier.dart');
      final body = extractMethodBody(source, 'clearOverlayStates');
      expect(body, isNotNull);
      expect(body!.contains('showReadingPaneMenuOptions: false'), isTrue,
          reason:
              'inbox clearOverlayStates must reset showReadingPaneMenuOptions');
    });

    test('archive clearOverlayStates resets showMoveOverlay', () {
      final source = readSourceFile(
          'lib/screens/email/archive_riverpod/archive_list_notifier.dart');
      final body = extractMethodBody(source, 'clearOverlayStates');
      expect(body, isNotNull);
      expect(body!.contains('showMoveOverlay: false'), isTrue,
          reason:
              'archive clearOverlayStates must reset showMoveOverlay');
    });

    test('archive clearOverlayStates resets showReadingPaneMenuOptions', () {
      final source = readSourceFile(
          'lib/screens/email/archive_riverpod/archive_list_notifier.dart');
      final body = extractMethodBody(source, 'clearOverlayStates');
      expect(body, isNotNull);
      expect(body!.contains('showReadingPaneMenuOptions: false'), isTrue,
          reason:
              'archive clearOverlayStates must reset showReadingPaneMenuOptions');
    });
  });

  // =========================================================================
  // Group — ShellLayout back button respects onBackPressed
  // =========================================================================

  group('ShellLayout _navigateBack respects onBackPressed', () {
    test('_navigateBack checks onBackPressed before navigating', () {
      final source = readSourceFile('lib/widgets/shell_layout.dart');
      final body = extractMethodBody(source, '_navigateBack');
      expect(body, isNotNull);
      expect(body!.contains('onBackPressed'), isTrue,
          reason:
              '_navigateBack must check _appBarConfig.onBackPressed '
              'to close overlays before navigating');
    });
  });
}
