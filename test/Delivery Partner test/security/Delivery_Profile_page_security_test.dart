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

void main() {
  late MockDeliveryProfileRepository mockRepository;
  late MockDeliveryProfileService mockService;

  setUp(() {
    mockRepository = MockDeliveryProfileRepository();
    mockService = MockDeliveryProfileService();
    registerFallbackValue(const DeliveryProfileState());
  });

  group('DeliveryProfilePage Security Tests', () {
    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'sanitizes exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.fetchProfile(),
        ).thenThrow(Exception('Internal server token mismatch'));
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
          errorMessage: 'Internal server token mismatch',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'save error message is sanitized for display',
      build: () {
        when(
          () => mockRepository.saveProfile(any()),
        ).thenThrow(Exception('Disk full'));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () =>
          const DeliveryProfileState(status: DeliveryProfileStatus.loaded),
      act: (b) => b.add(const DeliveryProfileSaveEvent()),
      expect: () => [
        const DeliveryProfileState(
          status: DeliveryProfileStatus.loaded,
          saveStatus: DeliveryProfileSaveStatus.saving,
        ),
        const DeliveryProfileState(
          status: DeliveryProfileStatus.loaded,
          saveStatus: DeliveryProfileSaveStatus.failed,
          errorMessage: 'Disk full',
        ),
      ],
    );
  });
}
