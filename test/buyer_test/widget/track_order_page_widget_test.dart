import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/widgets/app_google_map_view.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import '../../mock_firebase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('AppGoogleMapView Full Screen Widget Tests', () {
    testWidgets('renders fullscreen button with Exit Full Screen when isFullScreen is true', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                storeName: 'Test Store',
                isFullScreen: true,
                showControls: true,
                onToggleFullScreen: () {
                  toggleCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fullScreenBtn = find.byTooltip('Exit Full Screen');
      expect(fullScreenBtn, findsOneWidget);

      await tester.tap(fullScreenBtn);
      await tester.pump();
      expect(toggleCalled, isTrue);
    });

    testWidgets('renders fullscreen button with Full Screen tooltip when isFullScreen is false', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 370,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                storeName: 'Test Store',
                isFullScreen: false,
                showControls: true,
                onToggleFullScreen: () {
                  toggleCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fullScreenBtn = find.byTooltip('Full Screen');
      expect(fullScreenBtn, findsOneWidget);

      await tester.tap(fullScreenBtn);
      await tester.pump();
      expect(toggleCalled, isTrue);
    });
  });

  group('TrackOrderPageUI Widget Tests', () {
    testWidgets('renders TrackOrderPageUI successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<IOrderRepository>.value(
              value: MockOrderRepository(),
            ),
            RepositoryProvider<IAuthService>.value(value: MockAuthService()),
            RepositoryProvider<IUserProfileRepository>.value(
              value: MockUserProfileRepository(),
            ),
          ],
          child: const MaterialApp(home: TrackOrderPageUI(orderId: 'FG125678')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TrackOrderPageUI), findsOneWidget);
    });
  });
}
