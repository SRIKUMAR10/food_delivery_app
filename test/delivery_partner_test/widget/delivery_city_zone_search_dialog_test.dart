import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/delivery_city_zone_service.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_city_zone_search_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryCityZoneSearchDialog Widget Tests', () {
    testWidgets('renders dialog header, tab bar, and search box',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryCityZoneSearchDialog(
              initialCity: 'Chennai',
              initialZone: 'Central Zone',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Delivery City & Operating Hub'), findsOneWidget);
      expect(find.text('Cities & Hubs'), findsOneWidget);
      expect(find.text('Map Hub Visualizer'), findsOneWidget);
      expect(find.textContaining('Search city'), findsOneWidget);
      expect(find.text('Popular Delivery Hub Cities'), findsOneWidget);
    });

    testWidgets('renders popular city chips and active hubs for Chennai',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryCityZoneSearchDialog(
              initialCity: 'Chennai',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Popular chips
      expect(find.widgetWithText(ChoiceChip, 'Chennai'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Bengaluru'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Coimbatore'), findsOneWidget);

      // Chennai hubs list
      expect(find.text('Central Zone'), findsWidgets);
      expect(find.text('Anna Nagar Zone'), findsOneWidget);
      expect(find.text('T. Nagar & Mylapore Hub'), findsOneWidget);
    });

    testWidgets('switching popular city chips updates hubs list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryCityZoneSearchDialog(
              initialCity: 'Chennai',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Bengaluru chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bengaluru'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Operating Hubs in Bengaluru'), findsOneWidget);
      expect(find.text('Koramangala & HSR Hub'), findsOneWidget);
      expect(find.text('Whitefield IT Hub'), findsOneWidget);
    });

    testWidgets('selecting a hub triggers onSelectionSelected callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      DeliveryCityZoneSelection? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCityZoneSearchDialog(
              initialCity: 'Chennai',
              onSelectionSelected: (sel) {
                selected = sel;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Select Hub' on Anna Nagar Zone
      final selectButton =
          find.widgetWithText(ElevatedButton, 'Select Hub').first;
      await tester.tap(selectButton);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.city, 'Chennai');
    });

    testWidgets(
        'switching to Map Hub Visualizer tab shows map and confirm button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryCityZoneSearchDialog(
              initialCity: 'Chennai',
              initialZone: 'Central Zone',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Map Hub Visualizer tab
      await tester.tap(find.text('Map Hub Visualizer'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Hub & Location'), findsOneWidget);
      expect(find.textContaining('Operating Hub: Chennai'), findsOneWidget);
    });
  });
}
