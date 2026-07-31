import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

void main() {
  group('DeliveryPickupConfirmationPageUi Widget Tests', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      Size? size,
      String orderId = '#ORD12345',
    }) async {
      if (size != null) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
      }
      await tester.pumpWidget(
        MaterialApp(home: DeliveryPickupConfirmationPage(orderId: orderId)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('renders header, hero, pickup info and customer cards', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_pickup_header')), findsOneWidget);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('#ORD12345'), findsWidgets);

      expect(find.byKey(const Key('dp_pickup_hero_card')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);

      expect(find.byKey(const Key('dp_pickup_info_card')), findsOneWidget);
      expect(find.text('Pickup Information'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);

      expect(find.byKey(const Key('dp_pickup_customer_card')), findsOneWidget);
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
      expect(find.text('12, Beach Road, Chennai - 600001'), findsOneWidget);
    });

    testWidgets('renders sidebar navigation and promo banner on desktop', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_pickup_sidebar')), findsOneWidget);
      for (final label in [
        'Dashboard',
        'Orders',
        'Earnings',
        'Incentives',
        'History',
        'Wallet',
        'Profile',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('Deliver More Earn More'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_promo_banner')), findsOneWidget);
    });

    testWidgets('hides sidebar on mobile viewport', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(390, 844));

      expect(find.byKey(const Key('dp_pickup_sidebar')), findsNothing);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.byKey(const Key('dp_pickup_bottom_bar')), findsOneWidget);
    });

    testWidgets('starts delivery and shows delivery started state', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      final startButton = find.byKey(const Key('dp_pickup_start_delivery'));
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders skeleton while initial data is loading', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryPickupConfirmationPage(orderId: '#ORD12345'),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_skeleton')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
