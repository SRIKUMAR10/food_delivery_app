import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

void main() {
  group('DeliveryCompletedPage Widget Tests', () {
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
        MaterialApp(home: DeliveryCompletedPage(orderId: orderId)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('renders header, hero, summary and action cards', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_completed_header')), findsOneWidget);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('#ORD12345'), findsWidgets);

      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);

      expect(
        find.byKey(const Key('dp_completed_summary_card')),
        findsOneWidget,
      );
      expect(find.text('Delivery Summary'), findsOneWidget);
      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('12, Beach Road, Chennai - 600001'), findsOneWidget);
      expect(find.text('32 min'), findsWidgets);
      expect(find.text('Paid Successfully'), findsOneWidget);
      expect(find.text('UPI • Google Pay'), findsOneWidget);

      expect(find.byKey(const Key('dp_completed_rating_card')), findsOneWidget);
      expect(find.text('Excellent (5.0/5)'), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_bottom_bar')), findsOneWidget);
    });

    testWidgets('renders sidebar navigation and promo banner on desktop', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      expect(find.byKey(const Key('dp_completed_sidebar')), findsOneWidget);
      for (final label in [
        'Dashboard',
        'Orders',
        'Earnings',
        'Incentives',
        'History',
        'Wallet',
        'Profile',
        'Settings',
        'Help & Support',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('Great Job!'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_completed_promo_banner')),
        findsOneWidget,
      );
    });

    testWidgets('hides sidebar on mobile viewport', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(390, 844));

      expect(find.byKey(const Key('dp_completed_sidebar')), findsNothing);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_bottom_bar')), findsOneWidget);
    });

    testWidgets('completes the order and shows the completed chip', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      final completeButton = find.byKey(
        const Key('dp_completed_complete_button'),
      );
      expect(completeButton, findsOneWidget);
      await tester.tap(completeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Order Completed'), findsWidgets);
      expect(
        find.byKey(const Key('dp_completed_complete_button')),
        findsNothing,
      );
      expect(find.byKey(const Key('dp_completed_return_home')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rates the customer and uploads proof of delivery', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, size: const Size(1280, 1000));

      await tester.ensureVisible(find.byKey(const Key('dp_completed_star_5')));
      await tester.tap(find.byKey(const Key('dp_completed_star_5')));
      await tester.pump();

      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Thanks for your feedback!'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('dp_completed_upload_proof')),
      );
      await tester.tap(find.byKey(const Key('dp_completed_upload_proof')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Proof uploaded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders skeleton while initial data is loading', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: DeliveryCompletedPage(orderId: '#ORD12345')),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_completed_skeleton')), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
