import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';
import 'package:food_delivery_app/repositories/seller_wallet_repository.dart';

class MockSellerWalletRepository extends Mock
    implements SellerWalletRepository {}

void main() {
  group('SellerWalletBloc Tests', () {
    late SellerWalletRepository repository;
    late SellerWalletBloc bloc;

    final mockPayouts = [
      PayoutItem(
        id: 'payout_1',
        title: 'Payout #0001',
        amount: 1500.0,
        status: 'Paid',
        date: DateTime(2024, 4, 25),
      ),
    ];

    setUp(() {
      repository = MockSellerWalletRepository();
      bloc = SellerWalletBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is correct', () {
      expect(bloc.state, const SellerWalletInitial());
    });

    blocTest<SellerWalletBloc, SellerWalletState>(
      'emits [Loading, Loaded] when LoadWalletData succeeds',
      build: () {
        when(
          () => repository.getWalletBalance(),
        ).thenAnswer((_) async => 12680.00);
        when(
          () => repository.getPayoutHistory(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => mockPayouts);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWalletData()),
      expect: () => [
        const SellerWalletLoading(),
        SellerWalletLoaded(
          balance: 12680.00,
          payouts: mockPayouts,
          hasReachedMax: true, // Only 1 payout, size is 10
        ),
      ],
    );

    blocTest<SellerWalletBloc, SellerWalletState>(
      'emits [Loading, Error] when LoadWalletData fails',
      build: () {
        when(
          () => repository.getWalletBalance(),
        ).thenThrow(Exception('API error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWalletData()),
      expect: () => [
        const SellerWalletLoading(),
        const SellerWalletError('Exception: API error'),
      ],
    );

    blocTest<SellerWalletBloc, SellerWalletState>(
      'emits Loaded with pagination flags when LoadMorePayoutHistory is called',
      seed: () => SellerWalletLoaded(
        balance: 1000.0,
        payouts: mockPayouts,
        hasReachedMax: false,
      ),
      build: () {
        when(
          () => repository.getPayoutHistory(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => [
            PayoutItem(
              id: 'payout_2',
              title: 'Payout #0002',
              amount: 500.0,
              status: 'Paid',
              date: DateTime(2024, 5, 1),
            ),
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMorePayoutHistory()),
      expect: () => [
        SellerWalletLoaded(
          balance: 1000.0,
          payouts: mockPayouts,
          hasReachedMax: false,
          isPaginatedLoading: true,
        ),
        SellerWalletLoaded(
          balance: 1000.0,
          payouts: [
            mockPayouts[0],
            PayoutItem(
              id: 'payout_2',
              title: 'Payout #0002',
              amount: 500.0,
              status: 'Paid',
              date: DateTime(2024, 5, 1),
            ),
          ],
          hasReachedMax: true,
          isPaginatedLoading: false,
        ),
      ],
    );

    blocTest<SellerWalletBloc, SellerWalletState>(
      'emits Loaded with updated balance when InitiateWithdrawal is successful',
      seed: () => SellerWalletLoaded(balance: 5000.0, payouts: mockPayouts),
      build: () {
        when(
          () => repository.withdrawFunds(any()),
        ).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const InitiateWithdrawal(2000.0)),
      expect: () => [
        SellerWalletLoaded(
          balance: 5000.0,
          payouts: mockPayouts,
          isWithdrawing: true,
        ),
        predicate<SellerWalletState>((state) {
          if (state is SellerWalletLoaded) {
            return state.balance == 3000.0 &&
                state.withdrawalSuccess == true &&
                state.payouts.length == 2 &&
                state.payouts[0].amount == 2000.0;
          }
          return false;
        }),
      ],
    );
  });
}
