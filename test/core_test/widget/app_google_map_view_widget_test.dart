import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/widgets/app_google_map_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppGoogleMapView Widget Tests', () {
    testWidgets('Renders AppGoogleMapView with basic setup without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGoogleMapView(
              driverLocation: LatLng(13.0827, 80.2707),
              storeLocation: LatLng(13.0850, 80.2750),
              customerLocation: LatLng(13.0900, 80.2800),
              showControls: true,
              showProgressCard: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AppGoogleMapView), findsOneWidget);
    });

    testWidgets('Renders dark mode and controls safely',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGoogleMapView(
              driverLocation: LatLng(13.0827, 80.2707),
              isDarkMode: true,
              showControls: true,
              isFullScreen: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AppGoogleMapView), findsOneWidget);
    });
  });
}
