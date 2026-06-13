import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Buyer Bloc Architecture/ForgotPasswordPage/ForgotPasswordPage_UI.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ForgotPasswordScreenUI(),
    );
  }

  group('ForgotPasswordScreenUI Widget Tests', () {
    testWidgets('renders mobile layout and required form fields', (tester) async {
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

    testWidgets('shows loading indicator when form is submitted', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.pump();

      // Tap Submit
      await tester.tap(find.text('Submit'));
      await tester.pump(); // Starts loading

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish loading and wait for snackbar
      
      // Verify Snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Password reset link sent to'), findsOneWidget);
    });
  });
}
