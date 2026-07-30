import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';

void main() {
  group('DeliveryOnboardingPage Performance Tests', () {
    testWidgets('renders UI within acceptable frame budget without drop frames',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DeliveryOnboardingRepository();
      final service = DeliveryOnboardingService();
      final bloc = DeliveryOnboardingPageBloc(
        repository: repository,
        service: service,
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DeliveryOnboardingPageBloc>.value(
            value: bloc,
            child: const DeliveryOnboardingPageUI(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1000));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });
}
