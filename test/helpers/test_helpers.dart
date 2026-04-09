/// Shared test utilities for the OptMsg test suite.
///
/// Import this file in every test to get access to common setup/teardown
/// helpers, pump utilities, and assertion extensions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override, ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns a [ThemeData] with [AppColorsExtension.light] registered.
/// Use in widget tests that render widgets depending on `context.appColors`.
ThemeData testThemeData() => ThemeData(
      extensions: const [AppColorsExtension.light],
    );

/// Initialises [SharedPreferences] with empty values for test environments
/// where notifiers call `SharedPreferences.getInstance()` during init.
void initMockSharedPreferences([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
}

/// Wraps [widget] in a [MaterialApp] inside a [ProviderScope] with optional
/// [overrides]. Use for widget tests that need navigation, themes, or
/// Riverpod providers.
Widget makeTestableWidget(
  Widget widget, {
  List<Override> overrides = const [],
  NavigatorObserver? navigatorObserver,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: testThemeData(),
      home: widget,
      navigatorObservers:
          navigatorObserver != null ? [navigatorObserver] : const [],
    ),
  );
}

/// Wraps [widget] in a [Scaffold] → [MaterialApp] → [ProviderScope].
/// Use when the widget under test needs a Scaffold ancestor (e.g. for
/// SnackBars, Drawers, etc.).
Widget makeScaffoldTestableWidget(
  Widget widget, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: testThemeData(),
      home: Scaffold(body: widget),
    ),
  );
}

/// Creates a [ProviderContainer] with the given [overrides] and registers
/// an automatic dispose via [addTearDown].
ProviderContainer createContainer({
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    overrides: overrides,
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}

/// Pumps the widget tree and waits for all scheduled microtasks and timers
/// to complete, with a configurable [timeout].
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Extension on [WidgetTester] for common pump patterns.
extension WidgetTesterX on WidgetTester {
  /// Pumps the widget tree then lets all microtasks run (one event loop turn).
  Future<void> pumpAndWaitMicrotasks() async {
    await pump();
    await pump(Duration.zero);
  }

  /// Sets the logical screen size for responsive layout testing.
  /// Remember to call [resetScreenSize] in tearDown.
  void setScreenSize({double width = 400, double height = 800}) {
    view.physicalSize = Size(width, height);
    view.devicePixelRatio = 1.0;
  }

  /// Resets the screen size to defaults after a responsive test.
  void resetScreenSize() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  }
}

/// Convenience matcher: the widget tree contains a widget of type [T].
Matcher findsWidgetOfType<T>() => findsWidgets;

/// Waits for a provider's state to satisfy [predicate], polling every [interval].
/// Throws after [timeout] if condition is never met.
Future<void> waitForProviderState<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
  bool Function(T) predicate, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final stopwatch = Stopwatch()..start();
  while (!predicate(container.read(provider))) {
    if (stopwatch.elapsed > timeout) {
      throw TestTimeoutException(
        'Provider state did not match predicate within $timeout',
      );
    }
    await Future.delayed(interval);
  }
}

class TestTimeoutException implements Exception {
  final String message;
  TestTimeoutException(this.message);
  @override
  String toString() => 'TestTimeoutException: $message';
}
