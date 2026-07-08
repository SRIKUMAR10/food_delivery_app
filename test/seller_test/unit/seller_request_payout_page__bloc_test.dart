import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__state.dart';
import 'package:food_delivery_app/repositories/seller_request_payout_repository.dart';

class MockSellerRequestPayoutRepository extends Mock
    implements SellerRequestPayoutRepository {}

void main() {
  group('SellerRequestPayoutBloc Tests', () {
    late SellerRequestPayoutRepository repository;
    late SellerRequestPayoutBloc bloc;

    final mockBanks = ['HDFC Bank • 1234', 'ICICI Bank • 5678'];

    setUp(() {
      repository = MockSellerRequestPayoutRepository();
      bloc = SellerRequestPayoutBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is correct', () {
      expect(bloc.state, const SellerRequestPayoutInitial());
    });

    blocTest<SellerRequestPayoutBloc, SellerRequestPayoutState>(
      'emits [Loading, Loaded] when LoadPayoutDetails succeeds',
      build: () {
        when(
          () => repository.getAvailableBalance(),
        ).thenAnswer((_) async => 12680.00);
        when(
          () => repository.getBankAccounts(),
        ).thenAnswer((_) async => mockBanks);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPayoutDetails()),
      expect: () => [
        const SellerRequestPayoutLoading(),
        SellerRequestPayoutLoaded(balance: 12680.00, bankAccounts: mockBanks),
      ],
    );

    blocTest<SellerRequestPayoutBloc, SellerRequestPayoutState>(
      'emits [Loading, Error] when LoadPayoutDetails fails',
      build: () {
        when(
          () => repository.getAvailableBalance(),
        ).thenThrow(Exception('API error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPayoutDetails()),
      expect: () => [
        const SellerRequestPayoutLoading(),
        const SellerRequestPayoutError('Exception: API error'),
      ],
    );

    blocTest<SellerRequestPayoutBloc, SellerRequestPayoutState>(
      'emits Loaded with isSubmitting and isSuccess flags on successful payout submission',
      seed: () =>
          SellerRequestPayoutLoaded(balance: 12680.00, bankAccounts: mockBanks),
      build: () {
        when(
          () => repository.requestPayout(
            amount: 5000.0,
            bankAccount: 'HDFC Bank • 1234',
            upiId: 'seller@upi',
          ),
        ).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SubmitPayout(
          amount: 5000.0,
          bankAccount: 'HDFC Bank • 1234',
          upiId: 'seller@upi',
        ),
      ),
      expect: () => [
        SellerRequestPayoutLoaded(
          balance: 12680.00,
          bankAccounts: mockBanks,
          isSubmitting: true,
        ),
        SellerRequestPayoutLoaded(
          balance: 7680.00,
          bankAccounts: mockBanks,
          isSubmitting: false,
          isSuccess: true,
        ),
      ],
    );

    blocTest<SellerRequestPayoutBloc, SellerRequestPayoutState>(
      'emits Loaded with errorMessage when amount exceeds balance',
      seed: () =>
          SellerRequestPayoutLoaded(balance: 2000.0, bankAccounts: mockBanks),
      build: () => bloc,
      act: (bloc) => bloc.add(
        const SubmitPayout(
          amount: 5000.0,
          bankAccount: 'HDFC Bank • 1234',
          upiId: 'seller@upi',
        ),
      ),
      expect: () => [
        SellerRequestPayoutLoaded(
          balance: 2000.0,
          bankAccounts: mockBanks,
          errorMessage: 'Insufficient funds',
        ),
      ],
    );

    blocTest<SellerRequestPayoutBloc, SellerRequestPayoutState>(
      'emits Loaded with errorMessage when amount is invalid',
      seed: () =>
          SellerRequestPayoutLoaded(balance: 10000.0, bankAccounts: mockBanks),
      build: () => bloc,
      act: (bloc) => bloc.add(
        const SubmitPayout(
          amount: 0.0,
          bankAccount: 'HDFC Bank • 1234',
          upiId: 'seller@upi',
        ),
      ),
      expect: () => [
        SellerRequestPayoutLoaded(
          balance: 10000.0,
          bankAccounts: mockBanks,
          errorMessage: 'Invalid payout amount',
        ),
      ],
    );
  });
}
