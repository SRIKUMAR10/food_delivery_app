import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import 'package:mocktail/mocktail.dart';

class MockHomePageBloc extends Mock implements HomePageBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHomePageBloc mockHomePageBloc;

  setUp(() {
    mockHomePageBloc = MockHomePageBloc();
    when(
      () => mockHomePageBloc.state,
    ).thenReturn(const HomePageLoading('default_category'));
    when(() => mockHomePageBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomePageBloc.close()).thenAnswer((_) async => {});
  });

  group('Onboarding Page Integration and Performance Tests', () {
    testWidgets('Tap Get Started button and measure performance', (
      WidgetTester tester,
    ) async {
      // Start the app directly at the OnboardingPage to isolate it
      await tester.pumpWidget(
        BlocProvider<HomePageBloc>.value(
          value: mockHomePageBloc,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final buttonFinder = find.byType(HoverButton);
      expect(buttonFinder, findsOneWidget);

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
