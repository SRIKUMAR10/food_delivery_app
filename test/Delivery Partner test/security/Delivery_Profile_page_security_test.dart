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
    test('service environment variables expose only safe placeholder keys', () {
      final service = DeliveryProfileService();
      final env = service.getEnvironmentVariables();

      expect(env.length, 4);
      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('UPLOAD_ENDPOINT'), isTrue);
      expect(
        env.keys.any((k) => k.contains('SECRET') && k != 'KEY_SECRET'),
        isFalse,
      );
    });

    test('media validation rejects executable and unsupported files', () {
      final service = DeliveryProfileService();

      expect(service.validateMedia('malware.exe'), isNotNull);
      expect(service.validateMedia('document.sh'), isNotNull);
      expect(service.validateMedia('../../etc/passwd'), isNotNull);
      expect(service.validateMedia(''), isNotNull);
    });

    test('media validation allows safe document extensions only', () {
      final service = DeliveryProfileService();

      expect(service.validateMedia('license.jpg'), isNull);
      expect(service.validateMedia('rc.pdf'), isNull);
      expect(service.validateMedia('pan.webp'), isNull);
    });

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
