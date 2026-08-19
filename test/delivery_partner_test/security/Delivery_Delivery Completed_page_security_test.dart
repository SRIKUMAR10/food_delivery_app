import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

class MockDeliveryCompletedService extends Mock
    implements DeliveryCompletedServiceBase {}

const mockModel = DeliveryCompletedModel(
  orderId: '#ORD12345',
  walletBalance: 2450.00,
  partnerName: 'Ravi Kumar',
  partnerVehicleNo: 'TN 01 AB 1234',
  customerName: 'Arun Kumar',
  deliveryAddress: '12, Beach Road, Chennai - 600001',
  timeTaken: '32 min',
  distanceCovered: 5.6,
  paymentStatus: 'Paid Successfully',
  paymentMethod: 'UPI • Google Pay',
  customerRating: 5.0,
  deliveryEarnings: 120.00,
  completedAt: 'Today, 4:15 PM',
);

void main() {
  late MockDeliveryCompletedRepository mockRepository;
  late MockDeliveryCompletedService mockService;

  setUp(() {
    mockRepository = MockDeliveryCompletedRepository();
    mockService = MockDeliveryCompletedService();
    registerFallbackValue('#ORD12345');
  });

  group('DeliveryCompletedPage Security Tests', () {
    test('service payload exposes only safe placeholder data', () async {
      final service = DeliveryCompletedService();
      final data = await service.fetchCompletedOrderData('#ORD12345');
      final raw = data.toString();

      expect(
        raw.contains(
          RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
        ),
        isFalse,
      );
    });

    test('service payload does not contain connection secrets', () async {
      final service = DeliveryCompletedService();
      final data = await service.fetchCompletedOrderData('#ORD12345');

      for (final key in data.keys) {
        expect(key.toLowerCase().contains('password'), isFalse);
        expect(key.toLowerCase().contains('token'), isFalse);
      }
    });

    test('environment variables avoid sensitive key names', () {
      final service = DeliveryCompletedService();
      final env = service.getEnvironmentVariables();

      for (final key in env.keys) {
        expect(key.toLowerCase().contains('secret'), isFalse);
        expect(key.toLowerCase().contains('apikey'), isFalse);
        expect(key.toLowerCase().contains('token'), isFalse);
      }
    });

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'sanitizes fetch exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.fetchCompletedOrderDetails(any()),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const FetchCompletedOrderDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        ),
        isA<DeliveryCompletedPageState>()
            .having((s) => s.status, 'status', DeliveryCompletedStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              isNot(contains('Exception: ')),
            ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'sanitizes complete order exception messages for display',
      build: () {
        when(
          () => mockRepository.completeOrder(any()),
        ).thenThrow(Exception('Disk full'));
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (b) => b.add(const CompleteOrderSubmittedEvent('#ORD12345')),
      expect: () => [
        isA<DeliveryCompletedPageState>().having(
          (s) => s.status,
          'status',
          DeliveryCompletedStatus.loading,
        ),
        isA<DeliveryCompletedPageState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Disk full',
        ),
      ],
    );

    test('validateMedia rejects files that could hide malicious content', () {
      final service = DeliveryCompletedService();

      expect(
        service.validateMedia('proof.html'),
        'Unsupported file type: .html',
      );
      expect(
        service.validateMedia('script.exe'),
        'Unsupported file type: .exe',
      );
      expect(
        service.validateMedia('payload.bin'),
        'Unsupported file type: .bin',
      );
    });
  });
}
