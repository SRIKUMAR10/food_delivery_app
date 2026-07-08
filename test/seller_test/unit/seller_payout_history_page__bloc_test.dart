import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';
import 'package:food_delivery_app/repositories/seller_payout_history_repository.dart';

class MockSellerPayoutHistoryRepository extends Mock
    implements SellerPayoutHistoryRepository {}

void main() {
  group('SellerPayoutHistoryBloc Tests', () {
    late SellerPayoutHistoryRepository repository;
    late SellerPayoutHistoryBloc bloc;

    final mockPayouts = [
      PayoutItem(
        id: 'payout_1',
        title: 'Payout #0001',
        amount: 2000.0,
        status: 'Paid',
        date: DateTime(2024, 5, 1),
      ),
    ];

    setUp(() {
      repository = MockSellerPayoutHistoryRepository();
      bloc = SellerPayoutHistoryBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is correct', () {
      expect(bloc.state, const SellerPayoutHistoryInitial());
    });

    blocTest<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
      'emits [Loading, Loaded] when LoadPayoutHistory succeeds',
      build: () {
        when(
          () => repository.getPayoutHistory(offset: 0, limit: 10),
        ).thenAnswer((_) async => mockPayouts);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPayoutHistory()),
      expect: () => [
        const SellerPayoutHistoryLoading(),
        SellerPayoutHistoryLoaded(
          payouts: mockPayouts,
          hasReachedMax: true,
          isPaginatedLoading: false,
        ),
      ],
    );

    blocTest<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
      'emits [Loading, Error] when LoadPayoutHistory fails',
      build: () {
        when(
          () => repository.getPayoutHistory(offset: 0, limit: 10),
        ).thenThrow(Exception('API failure'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPayoutHistory()),
      expect: () => [
        const SellerPayoutHistoryLoading(),
        const SellerPayoutHistoryError('Exception: API failure'),
      ],
    );

    blocTest<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
      'emits [Loaded] when RefreshPayoutHistory succeeds',
      seed: () => SellerPayoutHistoryLoaded(payouts: mockPayouts),
      build: () {
        when(
          () => repository.getPayoutHistory(offset: 0, limit: 10),
        ).thenAnswer((_) async => mockPayouts);
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshPayoutHistory()),
      expect: () => [
        SellerPayoutHistoryLoaded(
          payouts: mockPayouts,
          hasReachedMax: true,
          isPaginatedLoading: false,
        ),
      ],
    );

    blocTest<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
      'emits [Error] when RefreshPayoutHistory fails',
      seed: () => SellerPayoutHistoryLoaded(payouts: mockPayouts),
      build: () {
        when(
          () => repository.getPayoutHistory(offset: 0, limit: 10),
        ).thenThrow(Exception('API error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshPayoutHistory()),
      expect: () => [const SellerPayoutHistoryError('Exception: API error')],
    );

    blocTest<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
      'emits Loaded with isPaginatedLoading and appends payouts on LoadMorePayoutHistory success',
      seed: () =>
          SellerPayoutHistoryLoaded(payouts: mockPayouts, hasReachedMax: false),
      build: () {
        when(
          () => repository.getPayoutHistory(offset: 1, limit: 10),
        ).thenAnswer(
          (_) async => [
            PayoutItem(
              id: 'payout_2',
              title: 'Payout #0002',
              amount: 3000.0,
              status: 'Paid',
              date: DateTime(2024, 5, 2),
            ),
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMorePayoutHistory()),
      expect: () => [
        SellerPayoutHistoryLoaded(
          payouts: mockPayouts,
          isPaginatedLoading: true,
        ),
        SellerPayoutHistoryLoaded(
          payouts: [
            ...mockPayouts,
            PayoutItem(
              id: 'payout_2',
              title: 'Payout #0002',
              amount: 3000.0,
              status: 'Paid',
              date: DateTime(2024, 5, 2),
            ),
          ],
          isPaginatedLoading: false,
          hasReachedMax: true,
        ),
      ],
    );
  });
}
