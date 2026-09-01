import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_repository.dart';

class MockDeliveryOnboardingVerificationRepository extends Mock
    implements DeliveryOnboardingVerificationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(Uint8List(0));
  });

  late MockDeliveryOnboardingVerificationRepository mockRepository;
  late DeliveryOnboardingVerificationBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryOnboardingVerificationRepository();
    when(() => mockRepository.currentUserId).thenReturn('test_partner_123');
    when(() => mockRepository.saveDraftState(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.saveDocumentUrl(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.uploadDocumentBytes(any(), any(), any(), any()))
        .thenAnswer((_) async => 'https://storage.googleapis.com/test_doc.jpg');
    when(() => mockRepository.waitForCurrentUser(timeout: any(named: 'timeout')))
        .thenAnswer((_) async => null);
    when(() => mockRepository.watchPartnerProfile(any()))
        .thenAnswer((_) => Stream.value(<String, dynamic>{}));
    bloc = DeliveryOnboardingVerificationBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryOnboardingVerificationBloc Unit Tests', () {
    test('initial state has correct default values', () {
      expect(bloc.state.currentStep, DeliveryVerificationStep.personalDetails);
      expect(bloc.state.status, DeliveryVerificationStatus.initial);
      expect(bloc.state.vehicleType, 'Motorcycle');
      expect(bloc.state.payoutFrequency, 'Daily');
      expect(bloc.state.city, 'Chennai');
    });

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated step on DeliveryVerificationStepChanged',
      build: () => bloc,
      act: (b) => b.add(const DeliveryVerificationStepChanged(
          DeliveryVerificationStep.vehicleAndLicense)),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.currentStep, 'currentStep',
                DeliveryVerificationStep.vehicleAndLicense)
            .having((s) => s.status, 'status',
                DeliveryVerificationStatus.inProgress),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated personal details on DeliveryPersonalDetailsChanged',
      build: () => bloc,
      act: (b) => b.add(const DeliveryPersonalDetailsChanged(
        fullName: 'Rahul Kumar',
        displayName: 'Rahul K',
        dob: '15/08/1996',
        gender: 'Male',
        bloodGroup: 'O+',
        emergencyContactName: 'Suresh',
        emergencyContactPhone: '9876543210',
        bio: 'Experienced delivery rider',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.fullName, 'fullName', 'Rahul Kumar')
            .having((s) => s.displayName, 'displayName', 'Rahul K')
            .having((s) => s.bloodGroup, 'bloodGroup', 'O+')
            .having((s) => s.emergencyContactPhone, 'emergencyContactPhone',
                '9876543210'),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated vehicle details on DeliveryVehicleDetailsChanged',
      build: () => bloc,
      act: (b) => b.add(const DeliveryVehicleDetailsChanged(
        vehicleType: 'Electric Vehicle',
        vehicleNumber: 'TN-01-EV-9999',
        vehicleModel: 'Ather 450X',
        drivingLicenseNumber: 'TN0120190001234',
        dlExpiryDate: '31/12/2030',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.vehicleType, 'vehicleType', 'Electric Vehicle')
            .having((s) => s.vehicleNumber, 'vehicleNumber', 'TN-01-EV-9999')
            .having((s) => s.vehicleModel, 'vehicleModel', 'Ather 450X')
            .having((s) => s.drivingLicenseNumber, 'drivingLicenseNumber',
                'TN0120190001234'),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated bank details on DeliveryBankDetailsChanged',
      build: () => bloc,
      act: (b) => b.add(const DeliveryBankDetailsChanged(
        bankAccountNumber: '123456789012',
        confirmAccountNumber: '123456789012',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        accountHolderName: 'Rahul Kumar',
        upiId: 'rahul@okaxis',
        payoutFrequency: 'Daily',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.bankAccountNumber, 'bankAccountNumber',
                '123456789012')
            .having((s) => s.ifscCode, 'ifscCode', 'SBIN0001234')
            .having((s) => s.upiId, 'upiId', 'rahul@okaxis')
            .having((s) => s.isStep5Valid, 'isStep5Valid', true),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated zone and GPS address on DeliveryZonePreferencesChanged',
      build: () => bloc,
      act: (b) => b.add(const DeliveryZonePreferencesChanged(
        city: 'Chennai',
        operatingZone: 'Anna Nagar Zone',
        preferredShift: 'Morning',
        workType: 'Full-Time',
        deliveryRadiusKm: 12.0,
        formattedAddress: 'Anna Nagar West, Chennai, Tamil Nadu',
        houseFlatNo: 'Plot 42',
        landmark: 'Near Roundtana',
        latitude: 13.0850,
        longitude: 80.2100,
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.city, 'city', 'Chennai')
            .having((s) => s.operatingZone, 'operatingZone', 'Anna Nagar Zone')
            .having((s) => s.formattedAddress, 'formattedAddress',
                'Anna Nagar West, Chennai, Tamil Nadu')
            .having((s) => s.latitude, 'latitude', 13.0850)
            .having((s) => s.longitude, 'longitude', 80.2100)
            .having((s) => s.isStep6Valid, 'isStep6Valid', true),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'fetches profile from Firestore/Auth and pre-fills full name and partner details',
      build: () {
        when(() => mockRepository.fetchPartnerProfile('test_partner_123'))
            .thenAnswer((_) async => {
                  'name': 'arun',
                  'displayName': 'arun',
                  'phone': '9876543210',
                  'email': 'arun@example.com',
                  'city': 'Chennai',
                });
        return bloc;
      },
      act: (b) => b.add(const DeliveryVerificationAutoFetchRequested()),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.isDataFetched, 'isDataFetched', true)
            .having((s) => s.fullName, 'fullName', 'arun')
            .having((s) => s.displayName, 'displayName', 'arun')
            .having((s) => s.phone, 'phone', '9876543210')
            .having((s) => s.email, 'email', 'arun@example.com'),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits updated profile on DeliveryVerificationProfileStreamUpdated',
      build: () => bloc,
      act: (b) => b.add(const DeliveryVerificationProfileStreamUpdated({
        'name': 'Kavitha Devi',
        'displayName': 'Kavitha',
        'phone': '9876543210',
        'city': 'Coimbatore',
        'zone': 'RS Puram',
      })),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.fullName, 'fullName', 'Kavitha Devi')
            .having((s) => s.displayName, 'displayName', 'Kavitha')
            .having((s) => s.city, 'city', 'Coimbatore')
            .having((s) => s.operatingZone, 'operatingZone', 'RS Puram'),
      ],
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'uploads avatar to storage and persists URL on DeliveryAvatarPicked',
      build: () => bloc,
      act: (b) => b.add(DeliveryAvatarPicked(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'my_selfie.jpg',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.localAvatarBytes, 'localAvatarBytes', isNotNull)
            .having((s) => s.avatarFileName, 'avatarFileName', 'my_selfie.jpg')
            .having((s) => s.isUploadingAvatar, 'isUploadingAvatar', true),
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.avatarUrl, 'avatarUrl', 'https://storage.googleapis.com/test_doc.jpg')
            .having((s) => s.isUploadingAvatar, 'isUploadingAvatar', false),
      ],
      verify: (_) {
        verify(() => mockRepository.uploadDocumentBytes(
              'test_partner_123',
              'avatars',
              'my_selfie.jpg',
              any(),
            )).called(1);
        verify(() => mockRepository.saveDocumentUrl(
              'test_partner_123',
              'avatarUrl',
              'https://storage.googleapis.com/test_doc.jpg',
            )).called(1);
      },
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'uploads driving license to storage and persists URL on DeliveryDlDocumentPicked',
      build: () => bloc,
      act: (b) => b.add(DeliveryDlDocumentPicked(
        isFront: true,
        bytes: Uint8List.fromList([4, 5, 6]),
        fileName: 'dl_front.jpg',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.dlFrontBytes, 'dlFrontBytes', isNotNull),
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.dlFrontUrl, 'dlFrontUrl', 'https://storage.googleapis.com/test_doc.jpg'),
      ],
      verify: (_) {
        verify(() => mockRepository.uploadDocumentBytes(
              'test_partner_123',
              'driving_license',
              'dl_front.jpg',
              any(),
            )).called(1);
        verify(() => mockRepository.saveDocumentUrl(
              'test_partner_123',
              'dlFrontUrl',
              'https://storage.googleapis.com/test_doc.jpg',
            )).called(1);
      },
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'uploads Aadhaar and PAN to storage and persists URL on DeliveryKycDocumentPicked',
      build: () => bloc,
      act: (b) => b.add(DeliveryKycDocumentPicked(
        docType: 'aadhaar',
        isFront: true,
        bytes: Uint8List.fromList([7, 8, 9]),
        fileName: 'aadhaar_front.jpg',
      )),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.aadhaarFrontBytes, 'aadhaarFrontBytes', isNotNull),
        isA<DeliveryOnboardingVerificationState>()
            .having((s) => s.aadhaarFrontUrl, 'aadhaarFrontUrl', 'https://storage.googleapis.com/test_doc.jpg'),
      ],
      verify: (_) {
        verify(() => mockRepository.uploadDocumentBytes(
              'test_partner_123',
              'government_id',
              'aadhaar_front.jpg',
              any(),
            )).called(1);
        verify(() => mockRepository.saveDocumentUrl(
              'test_partner_123',
              'aadhaarFrontUrl',
              'https://storage.googleapis.com/test_doc.jpg',
            )).called(1);
      },
    );

    blocTest<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      'emits success on DeliverySubmitVerificationApplication',
      build: () {
        when(() => mockRepository.submitFullKycApplication(
              any(),
              any(),
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) => b.add(const DeliverySubmitVerificationApplication()),
      expect: () => [
        isA<DeliveryOnboardingVerificationState>().having(
            (s) => s.status, 'status', DeliveryVerificationStatus.uploadingFiles),
        isA<DeliveryOnboardingVerificationState>().having(
            (s) => s.status, 'status', DeliveryVerificationStatus.success),
      ],
    );
  });
}
