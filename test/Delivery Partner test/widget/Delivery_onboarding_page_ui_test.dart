import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';

class MockDeliveryOnboardingPageBloc
    extends Mock
    implements DeliveryOnboardingPageBloc {}

void main() {
  late MockDeliveryOnboardingPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryOnboardingInitEvent());
    registerFallbackValue(const DeliveryOnboardingGetStartedClickedEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryOnboardingPageBloc();
    when(() => mockBloc.stream).thenAnswer(
      (_) => Stream.value(
        const DeliveryOnboardingPageState(
          status: DeliveryOnboardingStatus.loaded,
          features: [
            OnboardingFeatureItem(
              title: 'Fast Delivery',
              description: 'Optimized routes to save time.',
              iconKey: 'fast_delivery',
            ),
          ],
          partnerStats: [
            PartnerStatItem(
              value: '10K+',
              label: 'Active Partners',
              iconKey: 'partners',
            ),
          ],
        ),
      ),
    );
    when(() => mockBloc.state).thenReturn(
      const DeliveryOnboardingPageState(
        status: DeliveryOnboardingStatus.loaded,
        features: [
          OnboardingFeatureItem(
            title: 'Fast Delivery',
            description: 'Optimized routes to save time.',
            iconKey: 'fast_delivery',
          ),
        ],
        partnerStats: [
          PartnerStatItem(
            value: '10K+',
            label: 'Active Partners',
            iconKey: 'partners',
          ),
        ],
      ),
    );
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<DeliveryOnboardingPageBloc>.value(
        value: mockBloc,
        child: const DeliveryOnboardingPageUI(),
      ),
    );
  }

  group('DeliveryOnboardingPageUI Widget Tests', () {
    testWidgets('renders DeliverGo title, tagline, and Get Started button',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('DeliverGo'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Fast Delivery'), findsOneWidget);
    });

    testWidgets('triggers GetStartedClickedEvent on Get Started button tap',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 1000));

      final btn = find.text('Get Started');
      await tester.tap(btn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => mockBloc.add(const DeliveryOnboardingGetStartedClickedEvent()))
          .called(1);
    });
  });
}
