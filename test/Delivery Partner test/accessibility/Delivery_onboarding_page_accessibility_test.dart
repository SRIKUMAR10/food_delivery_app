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

  group('DeliveryOnboardingPage Accessibility Tests', () {
    testWidgets('meets screen reader semantic guidelines', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DeliveryOnboardingRepository();
      final service = DeliveryOnboardingService();
      final bloc = DeliveryOnboardingPageBloc(
        repository: repository,
        service: service,
      );

      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DeliveryOnboardingPageBloc>.value(
            value: bloc,
            child: const DeliveryOnboardingPageUI(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.getSemantics(find.text('Get Started')), isNotNull);

      handle.dispose();
    });
  });
}
