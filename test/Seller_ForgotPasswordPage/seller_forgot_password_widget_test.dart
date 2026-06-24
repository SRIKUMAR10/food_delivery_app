import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_UI.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: SellerForgotPasswordScreenUI(firebaseAuth: mockFirebaseAuth),
    );
  }

  group('SellerForgotPasswordScreenUI Widget Tests', () {
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
  });
}
