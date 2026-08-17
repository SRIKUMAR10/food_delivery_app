import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import '../mock_firebase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockAuthService extends Mock implements IAuthService {}

class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Golden test for TrackOrderPageUI', (WidgetTester tester) async {
    await Firebase.initializeApp();
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
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(TrackOrderPageUI), findsOneWidget);
  });
}
