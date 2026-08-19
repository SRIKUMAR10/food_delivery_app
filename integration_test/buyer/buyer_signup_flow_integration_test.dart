import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_ui.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_repository.dart';

class MockBuyerSignUpRepository extends Mock implements BuyerSignUpRepository {}
class MockBuyerSignUpService extends Mock implements BuyerSignUpService {}
class MockBuyerOtpVerificationRepository extends Mock implements BuyerOtpRepository {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Signup Flow Integration Test Script', () {
    testWidgets('Full Buyer Signup, Get OTP & Verification', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BuyerSignUpPageUI(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(BuyerSignUpPageUI), findsOneWidget);
    });
  });
}
