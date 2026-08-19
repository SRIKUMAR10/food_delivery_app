import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingPageBloc extends Mock implements OnboardingPageBloc {}

void main() {
  group('OnboardingPageView Widget Tests', () {
    late MockOnboardingPageBloc mockBloc;

    setUp(() {
      mockBloc = MockOnboardingPageBloc();
      when(() => mockBloc.state).thenReturn(OnboardingInitial());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<OnboardingPageBloc>.value(
          value: mockBloc,
          child: const OnboardingPageView(),
        ),
      );
    }

    testWidgets('Renders Mobile Layout on small screens', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());

      // Verify Image, Title, and HoverButton exist
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('The Fastest\nFood Delivery'), findsOneWidget);
      expect(find.byType(HoverButton), findsOneWidget);

      // Reset window size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Renders Web Layout on wide screens', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());

      // Verify the Tagline which only exists in wide layout
      expect(find.text('⚡ Express Delivery'), findsOneWidget);
      expect(find.text('The Fastest\nFood Delivery'), findsOneWidget);
      expect(find.byType(HoverButton), findsOneWidget);

      // Reset window size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
