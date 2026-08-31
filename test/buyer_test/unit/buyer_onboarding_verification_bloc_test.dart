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

    when(() => mockUser.uid).thenReturn('test_buyer_123');
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  group('BuyerOnboardingVerificationBloc Tests', () {
    test('initial state has personalDetails step and initial status', () {
      final bloc = BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      );
      expect(bloc.state.currentStep, equals(BuyerVerificationStep.personalDetails));
      expect(bloc.state.status, equals(BuyerVerificationStatus.initial));
      bloc.close();
    });

    test('prefills initial parameters passed via constructor', () {
      final bloc = BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
        initialFullName: 'Priya Sundaram',
        initialEmail: 'priya@example.com',
        initialPhone: '+919876543210',
        initialIsPhoneVerified: true,
      );
      expect(bloc.state.fullName, equals('Priya Sundaram'));
      expect(bloc.state.email, equals('priya@example.com'));
      expect(bloc.state.phone, equals('+919876543210'));
      expect(bloc.state.isPhoneVerified, isTrue);
      bloc.close();
    });

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'handles BuyerVerificationPrefillRequested event correctly',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      act: (bloc) => bloc.add(const BuyerVerificationPrefillRequested(
        fullName: 'Karthik Raja',
        email: 'karthik@example.com',
        phone: '+919988776655',
        isPhoneVerified: true,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.fullName, 'fullName', 'Karthik Raja')
            .having((s) => s.email, 'email', 'karthik@example.com')
            .having((s) => s.phone, 'phone', '+919988776655')
            .having((s) => s.isPhoneVerified, 'isPhoneVerified', true),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'emits updated step when BuyerVerificationStepChanged is added',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      act: (bloc) => bloc.add(const BuyerVerificationStepChanged(
        BuyerVerificationStep.contactVerification,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>().having(
          (s) => s.currentStep,
          'currentStep',
          BuyerVerificationStep.contactVerification,
        ),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'transitions from personalDetails to contactVerification upon valid BuyerPersonalDetailsUpdated',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      act: (bloc) => bloc.add(const BuyerPersonalDetailsUpdated(
        fullName: 'Rahul Sharma',
        displayName: 'Rahul',
        bio: 'Loves Spicy Biryani',
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.fullName, 'fullName', 'Rahul Sharma')
            .having((s) => s.currentStep, 'currentStep',
                BuyerVerificationStep.contactVerification)
            .having((s) => s.status, 'status', BuyerVerificationStatus.inProgress),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'fails personal details update when full name is empty',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      act: (bloc) => bloc.add(const BuyerPersonalDetailsUpdated(
        fullName: '',
        displayName: '',
        bio: '',
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                'Please enter your full name'),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'handles OTP request correctly',
      build: () {
        when(() => mockRepository.sendPhoneVerificationOtp(
                phone: any(named: 'phone')))
            .thenAnswer((_) async => 'mock_vid_123');
        return BuyerOnboardingVerificationBloc(
          repository: mockRepository,
          auth: mockAuth,
        );
      },
      seed: () => const BuyerOnboardingVerificationState(
        phone: '+919876543210',
        currentStep: BuyerVerificationStep.contactVerification,
      ),
      act: (bloc) => bloc.add(const BuyerSendOtpRequested()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.loading),
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.otpSent)
            .having((s) => s.otpCountdown, 'otpCountdown', 30),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'fails OTP verification when code length is invalid',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        phone: '+919876543210',
        otpCode: '123',
        currentStep: BuyerVerificationStep.contactVerification,
      ),
      act: (bloc) => bloc.add(const BuyerVerifyOtpPressed()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                'Please enter the 6-digit OTP'),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'updates delivery address and transitions to dietaryPreferences step',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.addressSelection,
      ),
      act: (bloc) => bloc.add(const BuyerAddressUpdated(
        formattedAddress: '123 Main Road, Anna Nagar',
        houseFlatNo: 'B-102',
        landmark: 'Near Bus Stop',
        addressTag: 'Home',
        latitude: 13.0827,
        longitude: 80.2707,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.formattedAddress, 'formattedAddress', '123 Main Road, Anna Nagar')
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.dietaryPreferences),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'fails address update when formattedAddress is empty',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.addressSelection,
      ),
      act: (bloc) => bloc.add(const BuyerAddressUpdated(
        formattedAddress: '',
        houseFlatNo: '',
        landmark: '',
        addressTag: 'Home',
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Please specify your delivery address'),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'toggles dietary preferences and spice preference correctly',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      act: (bloc) {
        bloc.add(const BuyerDietaryPreferenceToggled('Vegetarian'));
        bloc.add(const BuyerSpicePreferenceChanged('Spicy'));
      },
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.selectedDietaryTypes, 'selectedDietaryTypes', ['Vegetarian']),
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.spicePreference, 'spicePreference', 'Spicy'),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'completes full verification and saves profile to repository',
      build: () {
        when(() => mockRepository.saveBuyerVerificationProfile(
              userId: any(named: 'userId'),
              state: any(named: 'state'),
            )).thenAnswer((_) async {});
        return BuyerOnboardingVerificationBloc(
          repository: mockRepository,
          auth: mockAuth,
        );
      },
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.completionSuccess,
        fullName: 'Rahul Sharma',
        phone: '+919876543210',
        formattedAddress: 'Anna Nagar, Chennai',
      ),
      act: (bloc) => bloc.add(const BuyerCompleteVerificationSubmitted()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.loading),
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.success)
            .having((s) => s.successMessage, 'successMessage', contains('₹100 Welcome Gift Unlocked')),
      ],
    );
  });
}
