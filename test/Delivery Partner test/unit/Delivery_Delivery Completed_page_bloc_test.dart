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
    when(() => mockService.validateMedia(any())).thenReturn(null);
  });

  group('DeliveryCompletedBloc Tests', () {
    test('initial state status is initial', () {
      final bloc = DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state.status, DeliveryCompletedStatus.initial);
      expect(bloc.state.model, isNull);
      expect(bloc.state.proofUploadStatus, DeliveryProofUploadStatus.idle);
      bloc.close();
    });

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'emits [loading, success] when FetchCompletedOrderDetailsEvent is added',
      build: () {
        when(
          () => mockRepository.watchCompletedOrder(any()),
        ).thenAnswer((_) => Stream.value(mockModel));
        when(
          () => mockRepository.fetchCompletedOrderDetails(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) =>
          bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'emits [loading, error] when fetching completed details fails',
      build: () {
        when(
          () => mockRepository.watchCompletedOrder(any()),
        ).thenAnswer((_) => Stream.error(Exception('Server unreachable')));
        when(
          () => mockRepository.fetchCompletedOrderDetails(any()),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) =>
          bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.error,
          errorMessage: 'Server unreachable',
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'emits [loading, empty] when fetched model is blank',
      build: () {
        when(() => mockRepository.watchCompletedOrder(any())).thenAnswer(
          (_) => Stream.value(const DeliveryCompletedModel(
            orderId: '',
            walletBalance: 0,
            partnerName: '',
            partnerVehicleNo: '',
            customerName: '',
            deliveryAddress: '',
            timeTaken: '',
            distanceCovered: 0,
            paymentStatus: '',
            paymentMethod: '',
            customerRating: 0,
            deliveryEarnings: 0,
            completedAt: '',
            isCOD: false,
            codAmount: 0,
            collectedAmount: 0,
            isCodCollected: false,
            codReconciliationStatus: '',
          )),
        );
        when(() => mockRepository.fetchCompletedOrderDetails(any())).thenAnswer(
          (_) async => const DeliveryCompletedModel(
            orderId: '',
            walletBalance: 0,
            partnerName: '',
            partnerVehicleNo: '',
            customerName: '',
            deliveryAddress: '',
            timeTaken: '',
            distanceCovered: 0,
            paymentStatus: 'Paid Successfully',
            paymentMethod: '',
            customerRating: 5.0,
            deliveryEarnings: 0,
            completedAt: '',
          ),
        );
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) =>
          bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        ),
        const DeliveryCompletedPageState(status: DeliveryCompletedStatus.empty),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'emits [loading, completed] when CompleteOrderSubmittedEvent succeeds',
      build: () {
        when(
          () => mockRepository.completeOrder(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const CompleteOrderSubmittedEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
          model: mockModel,
          isCompleting: true,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.completed,
          model: mockModel,
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'ignores CompleteOrderSubmittedEvent when no model is loaded',
      build: () => DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) => bloc.add(const CompleteOrderSubmittedEvent('#ORD12345')),
      expect: () => <DeliveryCompletedPageState>[],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'keeps content and reports error when completing the order fails',
      build: () {
        when(
          () => mockRepository.completeOrder(any()),
        ).thenThrow(Exception('Network error'));
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const CompleteOrderSubmittedEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
          model: mockModel,
          isCompleting: true,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          errorMessage: 'Network error',
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'ReturnHomeRequestedEvent does not change state',
      build: () => DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) => bloc.add(const ReturnHomeRequestedEvent()),
      expect: () => <DeliveryCompletedPageState>[],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'RateCustomerEvent records the partner rating',
      build: () => DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const RateCustomerEvent(5)),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          ratedScore: 5,
          ratingSubmitted: true,
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'clamps out-of-range ratings and ignores when no model is loaded',
      build: () => DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const RateCustomerEvent(9)),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          ratedScore: 5,
          ratingSubmitted: true,
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'emits uploading progress then uploaded when proof media is valid',
      build: () {
        when(
          () => mockService.chunkedMediaUpload(any()),
        ).thenAnswer((_) => Stream<double>.fromIterable([0.5, 1.0]));
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) =>
          bloc.add(const UploadProofMediaEvent('proof_delivery.jpg')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          proofUploadStatus: DeliveryProofUploadStatus.uploading,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          proofUploadStatus: DeliveryProofUploadStatus.uploading,
          proofUploadProgress: 0.5,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          proofUploadStatus: DeliveryProofUploadStatus.uploading,
          proofUploadProgress: 1.0,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          proofUploadStatus: DeliveryProofUploadStatus.uploaded,
          proofUploadProgress: 1.0,
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'marks upload failed when media fails validation',
      build: () {
        when(
          () => mockService.validateMedia(any()),
        ).thenReturn('Unsupported file type: .txt');
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.success,
        model: mockModel,
      ),
      act: (bloc) => bloc.add(const UploadProofMediaEvent('receipt.txt')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
          proofUploadStatus: DeliveryProofUploadStatus.failed,
          errorMessage: 'Unsupported file type: .txt',
        ),
      ],
    );

    blocTest<DeliveryCompletedBloc, DeliveryCompletedPageState>(
      'RefreshCompletedOrderEvent reloads the completed details',
      build: () {
        when(
          () => mockRepository.fetchCompletedOrderDetails(any()),
        ).thenAnswer((_) async => mockModel);
        return DeliveryCompletedBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const RefreshCompletedOrderEvent('#ORD12345')),
      expect: () => [
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        ),
        const DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
          model: mockModel,
        ),
      ],
    );
  });
}
