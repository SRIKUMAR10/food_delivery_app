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

const mockModel = PickupConfirmationModel(
  orderId: '#ORD12345',
  pickupLocationName: 'Green Mart',
  pickupAddress: '24, Anna Salai, Chennai - 600002',
  pickupContactName: 'Priya Sharma',
  pickupContactPhone: '+919876543210',
  pickupInstructions: 'Show the order code at the counter.',
  customerName: 'Mike Johnson',
  customerAddress: '12, Beach Road, Chennai - 600001',
  customerPhone: '+919876543211',
  pickupTime: '12:05 PM',
  paymentType: 'Cash on Delivery',
  orderAmount: 486.50,
  walletBalance: 2450.00,
);

void main() {
  late MockPickupConfirmationRepository mockRepository;
  late MockPickupConfirmationService mockService;

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');
  });

  group('DeliveryPickupConfirmationPageBloc Tests', () {
    test('initial state status is initial', () {
      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state.status, PickupConfirmationStatus.initial);
      expect(bloc.state.model, isNull);
      bloc.close();
    });

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'emits [loading, success] when FetchPickupConfirmationDetailsEvent is added',
      build: () {
        when(
          () => mockRepository.watchPickupConfirmationDetails(any()),
        ).thenAnswer((_) => Stream.value(mockModel));
        when(
          () => mockRepository.fetchPickupConfirmationDetails(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) =>
          bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.loading,
        ),
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.success,
          model: mockModel,
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'emits [loading, error] when fetch fails',
      build: () {
        when(
          () => mockRepository.watchPickupConfirmationDetails(any()),
        ).thenAnswer((_) => Stream.error(Exception('Server unreachable')));
        when(
          () => mockRepository.fetchPickupConfirmationDetails(any()),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) =>
          bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.loading,
        ),
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.error,
          errorMessage: 'Exception: Server unreachable',
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'emits [loading, deliveryStarted] when StartDeliveryEvent is added',
      build: () {
        when(
          () => mockRepository.startDelivery(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const StartDeliveryEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.loading,
          model: mockModel,
        ),
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.deliveryStarted,
          model: mockModel,
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'ignores StartDeliveryEvent when no model is loaded',
      build: () => DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) => bloc.add(const StartDeliveryEvent('#ORD12345')),
      expect: () => <DeliveryPickupConfirmationPageState>[],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'emits [loading, error] when start delivery fails',
      build: () {
        when(
          () => mockRepository.startDelivery(any()),
        ).thenThrow(Exception('Network error'));
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const StartDeliveryEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.loading,
          model: mockModel,
        ),
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.error,
          model: mockModel,
          errorMessage: 'Exception: Network error',
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'emits success with updated model when ArrivedAtStoreEvent is added',
      build: () {
        when(
          () => mockRepository.arrivedAtStore(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.fetchPickupConfirmationDetails(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryPickupConfirmationPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const ArrivedAtStoreEvent('#ORD12345')),
      expect: () => [
        const DeliveryPickupConfirmationPageState(
          status: PickupConfirmationStatus.success,
          model: mockModel,
        ),
      ],
    );

    blocTest<
      DeliveryPickupConfirmationPageBloc,
      DeliveryPickupConfirmationPageState
    >(
      'CallCustomerEvent, OpenWhatsAppEvent and CallStoreEvent do not change state',
      build: () => DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) {
        bloc.add(const CallCustomerEvent('+919876543211'));
        bloc.add(const OpenWhatsAppEvent('+919876543211'));
        bloc.add(const CallStoreEvent('+919876543210'));
      },
      expect: () => <DeliveryPickupConfirmationPageState>[],
    );
  });
}
