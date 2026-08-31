import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';

class MockBuyerVerificationRepository extends Mock
    implements IBuyerOnboardingVerificationRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBuyerVerificationRepository mockRepository;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(const BuyerOnboardingVerificationState());
  });

  setUp(() {
    mockRepository = MockBuyerVerificationRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('test_integration_user');
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockRepository.saveBuyerVerificationProfile(
          userId: any(named: 'userId'),
          state: any(named: 'state'),
        )).thenAnswer((_) async {});
  });

  testWidgets('Integration Flow: Step 1 through Step 2 transition', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'Anand Kumar',
          initialEmail: 'anand@example.com',
          initialPhone: '+919876543210',
          initialIsPhoneVerified: true,
        ),
      ),
    );

    await tester.pump();

    // Step 1 check
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('👤 Personal Identity & Avatar'), findsOneWidget);

    // Proceed to Step 2
    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Step 2 check
    expect(find.text('Step 2 of 6'), findsOneWidget);
    expect(find.text('Phone Number Verified ✅'), findsOneWidget);
  });
}
