import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';

class MockOrderDetailsRepository extends Mock
    implements DeliveryOrderDetailsRepositoryBase {}

const sampleOrder = OrderModel(
  id: 'ORD12345',
  restaurantName: 'ahbi',
  customerName: 'Arun Kumar',
  pickupAddress: 'ahbi Store, Main Road',
  dropoffAddress: '12, Gandhi Road, Erode, Tamil Nadu',
  earnings: 120,
  distance: 2.4,
  status: 'Pending',
  customerPhone: '+919876543210',
  merchantPhone: '+918888888888',
  orderValue: 620,
  items: [
    OrderItemDetail(id: '1', name: 'Dosa', quantity: 2, price: 80),
  ],
);

const fallbackOrder = OrderModel(
  id: 'ORD99999',
  restaurantName: 'Partner Store',
  customerName: 'Customer',
  pickupAddress: '',
  dropoffAddress: '',
  earnings: 0,
  distance: 0,
  status: 'Pending',
  customerPhone: '',
  merchantPhone: '',
  orderValue: 0,
);

const emptyOrder = OrderModel(
  id: '',
  pickupAddress: '',
  dropoffAddress: '',
  earnings: 0,
  distance: 0,
  status: 'Pending',
  customerPhone: '',
  merchantPhone: '',
  orderValue: 0,
);

void main() {
  group('DeliveryOrderDetailsPageBloc - Lifecycle & Customer Details', () {
    late MockOrderDetailsRepository mockRepository;

    setUp(() {
      mockRepository = MockOrderDetailsRepository();
    });

    test('initial state status is initial', () {
      final bloc = DeliveryOrderDetailsPageBloc(repository: mockRepository);
      expect(bloc.state.status, OrderDetailsStatus.initial);
      expect(bloc.state.order, isNull);
      bloc.close();
    });

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'emits [loading, success] with customer drop details',
      build: () {
        when(() => mockRepository.watchOrderDetails('ORD12345'))
            .thenAnswer((_) => Stream.value(sampleOrder));
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const FetchOrderDetailsEvent('ORD12345')),
      expect: () => [
        const DeliveryOrderDetailsPageState(status: OrderDetailsStatus.loading),
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.status, 'status', OrderDetailsStatus.success)
            .having((s) => s.order?.customerName, 'customerName', 'Arun Kumar')
            .having((s) => s.order?.dropoffAddress, 'dropoffAddress',
                '12, Gandhi Road, Erode, Tamil Nadu')
            .having((s) => s.order?.customerPhone, 'customerPhone',
                '+919876543210')
            .having((s) => s.order?.restaurantName, 'restaurantName', 'ahbi'),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'handles missing customer data with fallback',
      build: () {
        when(() => mockRepository.watchOrderDetails('ORD99999'))
            .thenAnswer((_) => Stream.value(fallbackOrder));
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const FetchOrderDetailsEvent('ORD99999')),
      expect: () => [
        const DeliveryOrderDetailsPageState(status: OrderDetailsStatus.loading),
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.status, 'status', OrderDetailsStatus.success)
            .having((s) => s.order?.customerName, 'customerName', 'Customer')
            .having((s) => s.order?.dropoffAddress, 'dropoffAddress', ''),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'emits [loading, error] when the order does not exist',
      build: () {
        when(() => mockRepository.watchOrderDetails('missing'))
            .thenAnswer((_) => Stream.value(emptyOrder));
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const FetchOrderDetailsEvent('missing')),
      expect: () => [
        const DeliveryOrderDetailsPageState(status: OrderDetailsStatus.loading),
        const DeliveryOrderDetailsPageState(
          status: OrderDetailsStatus.error,
          errorMessage: 'Order not found or could not be loaded.',
        ),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'emits [loading, error] when fetching fails',
      build: () {
        when(() => mockRepository.watchOrderDetails('12345'))
            .thenAnswer((_) => Stream.error(Exception('Network down')));
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const FetchOrderDetailsEvent('12345')),
      expect: () => [
        const DeliveryOrderDetailsPageState(status: OrderDetailsStatus.loading),
        const DeliveryOrderDetailsPageState(
          status: OrderDetailsStatus.error,
          errorMessage: 'Exception: Network down',
        ),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'markGoingToRestaurant updates state status',
      build: () {
        when(() => mockRepository.markGoingToRestaurant('ORD12345'))
            .thenAnswer((_) async => true);
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      seed: () => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: sampleOrder,
      ),
      act: (bloc) => bloc.add(const MarkGoingToRestaurantEvent('ORD12345')),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.order?.pickupStatus, 'pickupStatus', 'GOING_TO_RESTAURANT'),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'markArrivedAtRestaurant updates state status',
      build: () {
        when(() => mockRepository.markArrivedAtRestaurant('ORD12345'))
            .thenAnswer((_) async => true);
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      seed: () => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: sampleOrder,
      ),
      act: (bloc) => bloc.add(const MarkArrivedAtRestaurantEvent('ORD12345')),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.order?.pickupStatus, 'pickupStatus', 'ARRIVED_AT_RESTAURANT'),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'toggle item verification modifies item status in checklist',
      build: () => DeliveryOrderDetailsPageBloc(repository: mockRepository),
      seed: () => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: sampleOrder,
      ),
      act: (bloc) => bloc.add(const ToggleItemVerificationEvent(0)),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.verifiedItemIndices.contains(0), 'contains index 0', isTrue)
            .having((s) => s.order?.items.first.isVerified, 'item verified', isTrue),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'verify OTP success updates otpStatus and order.isOtpVerified',
      build: () {
        when(() => mockRepository.verifyPickupOtp('ORD12345', '1234'))
            .thenAnswer((_) async => true);
        return DeliveryOrderDetailsPageBloc(repository: mockRepository);
      },
      seed: () => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: sampleOrder,
      ),
      act: (bloc) => bloc.add(const VerifyPickupOtpEvent('ORD12345', '1234')),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.otpStatus, 'otpStatus', OtpVerificationStatus.verifying),
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.otpStatus, 'otpStatus', OtpVerificationStatus.success)
            .having((s) => s.order?.isOtpVerified, 'isOtpVerified', isTrue),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'toggle language updates selected language',
      build: () => DeliveryOrderDetailsPageBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ToggleLanguageEvent('ta')),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>()
            .having((s) => s.selectedLanguage, 'selectedLanguage', 'ta'),
      ],
    );
  });
}
