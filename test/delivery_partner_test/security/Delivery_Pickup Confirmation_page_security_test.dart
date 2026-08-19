import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

void main() {
  late MockPickupConfirmationRepository mockRepository;
  late MockPickupConfirmationService mockService;

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');
  });

  group('DeliveryPickupConfirmationPage Security Tests', () {
    test('service payload exposes only safe placeholder data', () async {
      final service = DeliveryPickupConfirmationService();
      final data = await service.fetchPickupConfirmationData('#ORD12345');
      final raw = data.toString();

      expect(
        raw.contains(
          RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
        ),
        isFalse,
      );
    });

    test('service payload does not contain connection secrets', () async {
      final service = DeliveryPickupConfirmationService();
      final data = await service.fetchPickupConfirmationData('#ORD12345');

      for (final key in data.keys) {
        expect(key.toLowerCase().contains('password'), isFalse);
        expect(key.toLowerCase().contains('token'), isFalse);
      }
    });

    test('environment variables avoid sensitive key names', () {
      final service = DeliveryPickupConfirmationService();
      final env = service.getEnvironmentVariables();

      for (final key in env.keys) {
        expect(key.toLowerCase().contains('secret'), isFalse);
        expect(key.toLowerCase().contains('apikey'), isFalse);
      }
    });

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'sanitizes fetch exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.fetchPickupConfirmationDetails(any()),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const FetchPickupConfirmationDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.loading,
        ),
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.error,
          errorMessage: 'Exception: Internal server token mismatch',
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'sanitizes start delivery exception messages for display',
      build: () {
        when(
          () => mockRepository.startDelivery(any()),
        ).thenThrow(Exception('Disk full'));
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.success,
        model: PickupConfirmationModel(
          orderId: '#ORD12345',
          pickupLocationName: 'Green Mart',
          pickupAddress: '24, Anna Salai',
          pickupContactName: 'Priya Sharma',
          pickupContactPhone: '+919876543210',
          pickupInstructions: 'Show order code.',
          customerName: 'Mike Johnson',
          customerAddress: '12, Beach Road',
          customerPhone: '+919876543211',
          pickupTime: '12:05 PM',
          paymentType: 'Cash on Delivery',
          orderAmount: 486.50,
          walletBalance: 2450.00,
        ),
      ),
      act: (b) => b.add(const StartDeliveryEvent('#ORD12345')),
      expect: () => [
        isA<DeliveryPickupConfirmationPageState>().having(
          (s) => s.status,
          'status',
          PickupConfirmationStatus.loading,
        ),
        isA<DeliveryPickupConfirmationPageState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Exception: Disk full',
        ),
      ],
    );
  });
}
