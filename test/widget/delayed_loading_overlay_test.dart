import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart';

void main() {
  group('DelayedLoadingOverlay', () {
    testWidgets('should render child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(LoaderIndicator), findsNothing);
    });

    testWidgets('should not show spinner immediately when loading',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoaderIndicator), findsNothing);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should show spinner after delay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: true,
              delay: Duration(milliseconds: 100),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoaderIndicator), findsNothing);

      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(LoaderIndicator), findsOneWidget);
    });

    testWidgets('should hide spinner when loading becomes false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: true,
              delay: Duration(milliseconds: 50),
              child: Text('Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LoaderIndicator), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: false,
              delay: Duration(milliseconds: 50),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoaderIndicator), findsNothing);
    });

    testWidgets('should cancel timer if loading stops before delay',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: true,
              delay: Duration(milliseconds: 200),
              child: Text('Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DelayedLoadingOverlay(
              isLoading: false,
              delay: Duration(milliseconds: 200),
              child: Text('Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoaderIndicator), findsNothing);
    });
  });
}
