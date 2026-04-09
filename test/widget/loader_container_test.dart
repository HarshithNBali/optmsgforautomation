import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/widgets/load_container/load_container.dart';
import 'package:optmsg/widgets/load_container/loader_provider.dart';

void main() {
  group('LoaderContainer', () {
    testWidgets('should render child content', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoaderContainer(
              child: Text('Hello'),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('should not show spinner initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoaderContainer(
              child: Text('Content'),
            ),
          ),
        ),
      );

      // No spinner visible initially (loaderProvider defaults to false)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('loaderProvider', () {
    test('should default to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(loaderProvider), false);
    });

    test('set(true) should update to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(loaderProvider.notifier).set(true);
      expect(container.read(loaderProvider), true);
    });

    test('set(false) should update to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(loaderProvider.notifier).set(true);
      container.read(loaderProvider.notifier).set(false);
      expect(container.read(loaderProvider), false);
    });
  });
}
