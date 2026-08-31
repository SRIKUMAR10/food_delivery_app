import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_repository.dart';

class MockBuyerVerificationRepository extends Mock
    implements IBuyerOnboardingVerificationRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockBuyerVerificationRepository mockRepository;
  late MockFirebaseAuth mockAuth;

  setUpAll(() {
    registerFallbackValue(const BuyerOnboardingVerificationState());
  });

  setUp(() {
    mockRepository = MockBuyerVerificationRepository();
    mockAuth = MockFirebaseAuth();
  });

  group('Buyer Verification Permission Tests', () {
    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'toggles location, push notifications, and camera permissions properly',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.permissionsSetup,
      ),
      act: (bloc) => bloc.add(const BuyerPermissionsUpdated(
        locationGranted: true,
        notificationsGranted: true,
        cameraGranted: false,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.locationPermissionGranted, 'locationPermissionGranted', isTrue)
            .having((s) => s.pushNotificationsGranted, 'pushNotificationsGranted', isTrue)
            .having((s) => s.cameraPermissionGranted, 'cameraPermissionGranted', isFalse)
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.completionSuccess),
      ],
    );
  });
}
