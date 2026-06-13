import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Seller Bloc Architecture/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_UI.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SellerForgotPasswordScreenUI(),
    );
  }

  group('SellerForgotPasswordScreenUI Widget Tests', () {
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
  });
}
