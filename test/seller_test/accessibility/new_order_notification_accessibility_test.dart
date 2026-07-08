import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_ui.dart';

void main() {
  testWidgets('New Order Notification accessibility test', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(home: NewOrderNotificationPage(orderId: '1025')),
    );
    await tester.pumpAndSettle();

    // Verify buttons have semantic labels
    expect(
      tester.getSemantics(find.text('Accept Order')),
      matchesSemantics(
        isButton: true,
        hasTapAction: true,
        label: 'Accept Order',
        hasEnabledState: true,
        isEnabled: true,
      ),
    );

    handle.dispose();
  });
}
