import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_SignUpPage/Seller_SignUpPage_UI.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  late MockSellerRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: SellerSignUpScreenUI(repository: mockRepository));
  }

  group('SellerSignUpScreenUI Widget Tests', () {
    testWidgets('renders mobile layout and required form fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('signup_button')), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders web layout and required form fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('signup_button')), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
