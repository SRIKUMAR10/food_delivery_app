import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_LoginScreen/Seller_LoginScreen_UI.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  late MockSellerRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: SellerLoginScreenUI(repository: mockRepository));
  }

  group('SellerLoginScreenUI Widget Tests', () {
    testWidgets('renders mobile layout and required form fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('LogIn'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget); // Button
      expect(find.text('SignUp'), findsOneWidget);
    });

    testWidgets('renders web layout and required form fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('LogIn'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
