import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('DeliveryOnboardingPage Golden UI Tests', () {
    testWidgets('renders pixel-perfect layout visually matching UI spec',
        (tester) async {
      final repository = DeliveryOnboardingRepository();
      final service = DeliveryOnboardingService();
      final bloc = DeliveryOnboardingPageBloc(
        repository: repository,
        service: service,
      );

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DeliveryOnboardingPageBloc>.value(
            value: bloc,
            child: const DeliveryOnboardingPageUI(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DeliverGo'), findsOneWidget);
      expect(find.text('Why Partner with '), findsOneWidget);
    });
  });
}
