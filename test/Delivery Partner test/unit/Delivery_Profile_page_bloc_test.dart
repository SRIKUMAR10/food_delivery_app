import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';

class MockDeliveryProfileRepository extends Mock
    implements DeliveryProfileRepositoryBase {}

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

DeliveryProfileState defaultLoaded() {
  const base = DeliveryProfileState(
    status: DeliveryProfileStatus.loaded,
    fullName: 'Ravi Kumar',
    phone: '+91 98765 43210',
    email: 'ravi@test.com',
    dob: '15-08-1995',
    address: '123 Main Road, Chennai',
    vehicleType: 'scooter',
    vehicleNumber: 'TN 01 AB 1234',
    licenseNumber: 'TN07 20010012345',
    verificationStatuses: DeliveryProfileRepository.defaultVerificationStatuses,
    documents: DeliveryProfileRepository.defaultDocuments,
  );
  return base.copyWith(
    completionPercentage: 62,
    checklist: DeliveryProfileRepository.buildDefaultChecklist(profile: base),
  );
}

void main() {
  late MockDeliveryProfileRepository mockRepository;
  late MockDeliveryProfileService mockService;

  setUp(() {
    mockRepository = MockDeliveryProfileRepository();
    mockService = MockDeliveryProfileService();
    registerFallbackValue(const DeliveryProfileState());
  });

  group('DeliveryProfileBloc Unit Tests', () {
    test(
      'initial state starts at initial status with default profile data',
      () {
        final bloc = DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
        expect(bloc.state.status, DeliveryProfileStatus.initial);
        expect(bloc.state.fullName, '');
        expect(bloc.state.completionPercentage, 0);
        expect(bloc.state.documents, isEmpty);
        expect(bloc.state.verificationStatuses['phone'], isFalse);
        bloc.close();
      },
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits loading then loaded state on watchProfile stream emissions',
      build: () {
        when(
          () => mockRepository.watchProfile(),
        ).thenAnswer((_) => Stream.value(defaultLoaded()));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileInitEvent()),
      expect: () => [
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
        defaultLoaded(),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits error state when watchProfile errors',
      build: () {
        when(
          () => mockRepository.watchProfile(),
        ).thenAnswer((_) => Stream.error(Exception('Network down')));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileInitEvent()),
      expect: () => [
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
        const DeliveryProfileState(
          status: DeliveryProfileStatus.error,
          errorMessage: 'Network down',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'updates address field and recalculates completion',
      build: () {
        when(() => mockRepository.updateAddress(any())).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileUpdateAddressEvent('New Address 456')),
      expect: () => [
        isA<DeliveryProfileState>()
            .having((s) => s.address, 'address', 'New Address 456')
            .having((s) => s.actionMessage, 'actionMessage', 'Address updated successfully'),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'updates vehicle details and recalculates completion',
      build: () {
        when(() => mockRepository.updateVehicle(
              vehicleType: any(named: 'vehicleType'),
              vehicleNumber: any(named: 'vehicleNumber'),
            )).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileUpdateVehicleEvent(
        vehicleType: 'bike',
        vehicleNumber: 'TN 02 CD 5678',
      )),
      expect: () => [
        isA<DeliveryProfileState>()
            .having((s) => s.vehicleType, 'vehicleType', 'bike')
            .having((s) => s.vehicleNumber, 'vehicleNumber', 'TN 02 CD 5678')
            .having((s) => s.actionMessage, 'actionMessage', 'Vehicle updated successfully'),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'handles password change successfully',
      build: () {
        when(() => mockRepository.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileChangePasswordEvent(
        currentPassword: 'oldPassword123',
        newPassword: 'newPassword123',
      )),
      expect: () => [
        const DeliveryProfileState(isChangingPassword: true),
        const DeliveryProfileState(
          isChangingPassword: false,
          actionMessage: 'Password changed successfully',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'handles deactivation successfully',
      build: () {
        when(() => mockRepository.deactivateAccount()).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileDeactivateAccountEvent()),
      expect: () => [
        const DeliveryProfileState(isDeactivating: true),
        const DeliveryProfileState(
          isDeactivating: false,
          isActive: false,
          actionMessage: 'Account deactivated',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'handles logout successfully',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileLogoutEvent()),
      expect: () => [
        const DeliveryProfileState(isLoggingOut: true),
        const DeliveryProfileState(
          isLoggingOut: false,
          actionMessage: 'Logged out successfully',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'handles locale change successfully',
      build: () => DeliveryProfileBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (b) => b.add(const DeliveryProfileLocaleChangedEvent('ta')),
      expect: () => [
        const DeliveryProfileState(localeCode: 'ta'),
      ],
    );
  });
}
