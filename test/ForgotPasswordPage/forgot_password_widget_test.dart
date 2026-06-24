import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/ForgotPasswordPage/ForgotPasswordPage_UI.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';

import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<UserRepository>.value(
      value: mockUserRepository,
      child: const MaterialApp(home: ForgotPasswordScreenUI()),
    );
  }

  group('ForgotPasswordScreenUI Widget Tests', () {
    testWidgets('renders mobile layout and required form fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Forgot Password'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget); // Button
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders web layout and required form fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Forgot Password'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('shows loading indicator when form is submitted', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.pump();

      // Tap Submit
      await tester.ensureVisible(find.text('Submit'));
      await tester.tap(find.text('Submit'));
      await tester.pump(); // Starts loading

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish loading and wait for snackbar

      // Verify Snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Password reset link sent to'),
        findsOneWidget,
      );
    });
  });
}
