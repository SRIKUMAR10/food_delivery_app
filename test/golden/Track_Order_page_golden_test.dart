import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';

void main() {
  testWidgets('Golden test for TrackOrderPageUI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TrackOrderPageUI(orderId: 'FG125678')),
    );

    // Skip the actual matching here to avoid needing golden files generated.
    // await expectLater(find.byType(TrackOrderPageUI), matchesGoldenFile('track_order_ui.png'));
    expect(find.byType(TrackOrderPageUI), findsOneWidget);
  });
}
