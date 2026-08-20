import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_model.dart';

class MockDisputesRefundsRepository extends Mock implements DisputesRefundsRepository {}

void main() {
  group('DisputesRefundsBloc', () {
    late DisputesRefundsBloc bloc;
    late MockDisputesRefundsRepository mockRepository;

    final testDispute = DisputeModel(
      id: 'disp_1',
      orderId: 'ord_101',
      customerName: 'Rahul Kumar',
      reason: 'Missing item in pack',
      status: 'Pending',
      refundAmount: 120.0,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockRepository = MockDisputesRefundsRepository();
      bloc = DisputesRefundsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is DisputesRefundsInitial', () {
      expect(bloc.state, isA<DisputesRefundsInitial>());
    });

    blocTest<DisputesRefundsBloc, DisputesRefundsState>(
      'emits [Loading, Loaded] when LoadDisputesEvent is added and stream emits disputes',
      build: () {
        when(() => mockRepository.getDisputes('seller1')).thenAnswer((_) async => [testDispute]);
        when(() => mockRepository.streamDisputes('seller1')).thenAnswer((_) => const Stream.empty());
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDisputesEvent('seller1')),
      expect: () => [
        isA<DisputesRefundsLoading>(),
        isA<DisputesRefundsLoaded>().having((s) => s.disputes.length, 'disputes length', 1),
      ],
    );

    blocTest<DisputesRefundsBloc, DisputesRefundsState>(
      'approves refund on ApproveRefundEvent',
      build: () {
        when(() => mockRepository.getDisputes('seller1')).thenAnswer((_) async => [testDispute]);
        when(() => mockRepository.streamDisputes('seller1')).thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.resolveDispute('seller1', 'disp_1', 'Refunded')).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadDisputesEvent('seller1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(ApproveRefundEvent('disp_1'));
      },
      skip: 2,
      expect: () => [
        isA<DisputesRefundsLoaded>().having((s) => s.processingIds.contains('disp_1'), 'processing', true),
        isA<DisputesRefundsLoaded>()
            .having((s) => s.processingIds.contains('disp_1'), 'processing', false)
            .having((s) => s.successMessage, 'successMessage', 'Refund approved successfully.')
            .having((s) => s.disputes.first.status, 'dispute status', 'Refunded'),
      ],
      verify: (_) {
        verify(() => mockRepository.resolveDispute('seller1', 'disp_1', 'Refunded')).called(1);
      },
    );

    blocTest<DisputesRefundsBloc, DisputesRefundsState>(
      'declines refund on DeclineRefundEvent',
      build: () {
        when(() => mockRepository.getDisputes('seller1')).thenAnswer((_) async => [testDispute]);
        when(() => mockRepository.streamDisputes('seller1')).thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.resolveDispute('seller1', 'disp_1', 'Declined')).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadDisputesEvent('seller1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(DeclineRefundEvent('disp_1'));
      },
      skip: 2,
      expect: () => [
        isA<DisputesRefundsLoaded>().having((s) => s.processingIds.contains('disp_1'), 'processing', true),
        isA<DisputesRefundsLoaded>()
            .having((s) => s.processingIds.contains('disp_1'), 'processing', false)
            .having((s) => s.successMessage, 'successMessage', 'Refund request declined.')
            .having((s) => s.disputes.first.status, 'dispute status', 'Declined'),
      ],
      verify: (_) {
        verify(() => mockRepository.resolveDispute('seller1', 'disp_1', 'Declined')).called(1);
      },
    );
  });
}
