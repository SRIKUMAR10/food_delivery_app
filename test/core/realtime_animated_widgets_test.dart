import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/realtime_animated_widgets.dart';

void main() {
  group('Realtime Animated Widgets Tests', () {
    testWidgets('RealtimeCountSwitcher renders prefix and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealtimeCountSwitcher(value: 42, prefix: '₹'),
          ),
        ),
      );

      expect(find.text('₹42'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealtimeCountSwitcher(value: 50, prefix: '₹'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹50'), findsOneWidget);
    });

    testWidgets('RealtimePulseBadge renders badge label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealtimePulseBadge(label: 'LIVE'),
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('RealtimeHealthBar renders progress bar smoothly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealtimeHealthBar(percentage: 85.0),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('AdaptiveAnimatedCard responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveAnimatedCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });
  });
}
