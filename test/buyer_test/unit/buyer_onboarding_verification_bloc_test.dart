import 'dart:typed_data';
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
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepository = MockBuyerVerificationRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('test_buyer_123');
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockRepository.saveStep3Address(
          userId: any(named: 'userId'),
          formattedAddress: any(named: 'formattedAddress'),
          houseFlatNo: any(named: 'houseFlatNo'),
          landmark: any(named: 'landmark'),
          addressTag: any(named: 'addressTag'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async {});
    when(() => mockRepository.getCurrentUserVerificationData(any()))
        .thenAnswer((_) async => {});
  });

  group('BuyerOnboardingVerificationBloc Tests', () {
    test('initial state has personalDetails step and initial status with permissions enabled by default', () {
      final bloc = BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      );
      expect(bloc.state.currentStep, equals(BuyerVerificationStep.personalDetails));
      expect(bloc.state.status, equals(BuyerVerificationStatus.initial));
      expect(bloc.state.locationPermissionGranted, isTrue);
      expect(bloc.state.pushNotificationsGranted, isTrue);
      expect(bloc.state.cameraPermissionGranted, isTrue);
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
      'auto-fetches existing profile with address details and populates state in real-time',
      build: () {
        when(() => mockRepository.getCurrentUserVerificationData('test_buyer_123'))
            .thenAnswer((_) async => {
                  'fullName': 'Srikumar Developer',
                  'email': 'sri@example.com',
                  'phone': '+919876543210',
                  'address': 'No 45, Gandhi Road, Chennai',
                  'houseFlatNo': 'Flat 4B',
                  'landmark': 'Opposite Post Office',
                  'selectedAddressType': 'Work',
                  'latitude': 13.0827,
                  'longitude': 80.2707,
                });
        return BuyerOnboardingVerificationBloc(
          repository: mockRepository,
          auth: mockAuth,
        );
      },
      act: (bloc) => bloc.add(const BuyerVerificationAutoFetchRequested()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.fullName, 'fullName', 'Srikumar Developer')
            .having((s) => s.formattedAddress, 'formattedAddress', 'No 45, Gandhi Road, Chennai')
            .having((s) => s.houseFlatNo, 'houseFlatNo', 'Flat 4B')
            .having((s) => s.landmark, 'landmark', 'Opposite Post Office')
            .having((s) => s.addressTag, 'addressTag', 'Work')
            .having((s) => s.latitude, 'latitude', 13.0827)
            .having((s) => s.longitude, 'longitude', 80.2707),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'updates delivery address, calls saveStep3Address in real-time, and transitions to paymentSetup step',
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
      verify: (_) {
        verify(() => mockRepository.saveStep3Address(
              userId: 'test_buyer_123',
              formattedAddress: '123 Main Road, Anna Nagar',
              houseFlatNo: 'B-102',
              landmark: 'Near Bus Stop',
              addressTag: 'Home',
              latitude: 13.0827,
              longitude: 80.2707,
            )).called(1);
      },
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.formattedAddress, 'formattedAddress', '123 Main Road, Anna Nagar')
            .having((s) => s.houseFlatNo, 'houseFlatNo', 'B-102')
            .having((s) => s.landmark, 'landmark', 'Near Bus Stop')
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.paymentSetup),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'toggles address tag and stays on addressSelection step without transitioning',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.addressSelection,
        addressTag: 'Home',
      ),
      act: (bloc) => bloc.add(const BuyerAddressTagChanged('Work')),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.addressTag, 'addressTag', 'Work')
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.addressSelection),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'updates address and coordinates via BuyerAddressLocationSelected without step change',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.addressSelection,
      ),
      act: (bloc) => bloc.add(const BuyerAddressLocationSelected(
        formattedAddress: 'Indira Nagar, Bengaluru',
        latitude: 12.9784,
        longitude: 77.6408,
        houseFlatNo: 'Flat 302',
        landmark: 'Near Metro',
        addressTag: 'Work',
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.formattedAddress, 'formattedAddress', 'Indira Nagar, Bengaluru')
            .having((s) => s.latitude, 'latitude', 12.9784)
            .having((s) => s.longitude, 'longitude', 77.6408)
            .having((s) => s.houseFlatNo, 'houseFlatNo', 'Flat 302')
            .having((s) => s.landmark, 'landmark', 'Near Metro')
            .having((s) => s.addressTag, 'addressTag', 'Work')
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.addressSelection),
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
      'updates payment method in real-time without advancing step',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.paymentSetup,
        preferredPaymentMethod: 'UPI (GPay / PhonePe / Paytm)',
      ),
      act: (bloc) => bloc.add(const BuyerPaymentMethodChanged('Credit / Debit Cards')),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.preferredPaymentMethod, 'preferredPaymentMethod', 'Credit / Debit Cards')
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.paymentSetup),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'toggles buyer wallet in real-time without advancing step',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.paymentSetup,
        activateBuyerWallet: true,
      ),
      act: (bloc) => bloc.add(const BuyerWalletToggled(false)),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.activateBuyerWallet, 'activateBuyerWallet', isFalse)
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.paymentSetup),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'toggles individual permission in real-time without advancing step',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.permissionsSetup,
        locationPermissionGranted: false,
      ),
      act: (bloc) => bloc.add(const BuyerSinglePermissionToggled(
        permissionType: 'location',
        isGranted: true,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.locationPermissionGranted, 'locationPermissionGranted', isTrue)
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.permissionsSetup),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'selects payment preference and transitions to permissionsSetup step',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.paymentSetup,
      ),
      act: (bloc) => bloc.add(const BuyerPaymentPreferenceSelected(
        paymentMethod: 'UPI',
        defaultUpiId: 'buyer@okaxis',
        activateBuyerWallet: true,
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.preferredPaymentMethod, 'preferredPaymentMethod', 'UPI')
            .having((s) => s.defaultUpiId, 'defaultUpiId', 'buyer@okaxis')
            .having((s) => s.activateBuyerWallet, 'activateBuyerWallet', isTrue)
            .having((s) => s.currentStep, 'currentStep', BuyerVerificationStep.permissionsSetup),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'handles BuyerAvatarPickRequested with direct bytes and updates avatarUrl',
      build: () {
        when(() => mockRepository.uploadProfileAvatar(
              userId: any(named: 'userId'),
              imageBytes: any(named: 'imageBytes'),
              fileName: any(named: 'fileName'),
              contentType: any(named: 'contentType'),
            )).thenAnswer((_) async => 'https://storage.googleapis.com/test_avatar.jpg');
        return BuyerOnboardingVerificationBloc(
          repository: mockRepository,
          auth: mockAuth,
        );
      },
      act: (bloc) => bloc.add(BuyerAvatarPickRequested(
        directBytes: Uint8List.fromList([1, 2, 3, 4]),
        fileName: 'avatar.jpg',
      )),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.isUploadingAvatar, 'isUploadingAvatar', isTrue)
            .having((s) => s.localAvatarBytes, 'localAvatarBytes', isNotNull),
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.isUploadingAvatar, 'isUploadingAvatar', isFalse)
            .having((s) => s.avatarUrl, 'avatarUrl', 'https://storage.googleapis.com/test_avatar.jpg')
            .having((s) => s.successMessage, 'successMessage', contains('Profile photo updated')),
      ],
    );

    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'handles BuyerAvatarRemoved by clearing avatarUrl and local bytes',
      build: () => BuyerOnboardingVerificationBloc(
        repository: mockRepository,
        auth: mockAuth,
      ),
      seed: () => const BuyerOnboardingVerificationState(
        avatarUrl: 'https://storage.googleapis.com/old_avatar.jpg',
      ),
      act: (bloc) => bloc.add(const BuyerAvatarRemoved()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.avatarUrl, 'avatarUrl', isNull)
            .having((s) => s.localAvatarBytes, 'localAvatarBytes', isNull)
            .having((s) => s.successMessage, 'successMessage', contains('Profile photo removed')),
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
