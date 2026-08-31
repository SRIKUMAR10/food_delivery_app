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
  late MockDeliveryOnboardingVerificationRepository mockRepository;
  late DeliveryOnboardingVerificationBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryOnboardingVerificationRepository();
    when(() => mockRepository.currentUserId).thenReturn('test_partner_123');
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
