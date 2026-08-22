import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Delivery Onboarding Page Flow Integration Tests', () {
    testWidgets(
      'Full onboarding page flow test from loading to loaded UI interaction',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repository = DeliveryOnboardingRepository();
        final service = DeliveryOnboardingService();
        final bloc = DeliveryOnboardingPageBloc(
          repository: repository,
          service: service,
        );

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/deliveryLogin': (context) =>
                  const Scaffold(body: Center(child: Text('Delivery Login'))),
            },
            home: BlocProvider<DeliveryOnboardingPageBloc>.value(
              value: bloc,
              child: const DeliveryOnboardingPageUI(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Loaded state verified
        expect(find.text('DeliverGo'), findsOneWidget);
        expect(find.text('Fast Delivery'), findsOneWidget);

        // Tap Get Started
        await tester.tap(find.text('Get Started'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(bloc.state.isStarted, isTrue);
        expect(find.text('Delivery Login'), findsOneWidget);
      },
    );
  });
}
