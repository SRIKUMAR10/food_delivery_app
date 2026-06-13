import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_Event.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_State.dart';

class MockWalletDatabase extends Mock implements WalletDatabase {}

void main() {
  group('WalletBloc', () {
    late WalletBloc walletBloc;
    late MockWalletDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockWalletDatabase();
      walletBloc = WalletBloc(mockDatabase);
    });

    tearDown(() {
      walletBloc.close();
    });

    test('initial state is correct', () {
      expect(walletBloc.state.isLoading, false);
      expect(walletBloc.state.pendingAmount, null);
      expect(walletBloc.state.successMessage, null);
      expect(walletBloc.state.errorMessage, null);
    });

    blocTest<WalletBloc, WalletState>(
      'emits [isLoading: false] when LoadWalletData is added',
      build: () => walletBloc,
      act: (bloc) => bloc.add(LoadWalletData()),
      expect: () => [
        isA<WalletState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits correct state when AddFundsRequested is added',
      build: () => walletBloc,
      act: (bloc) => bloc.add(AddFundsRequested(500.0)),
      expect: () => [
        isA<WalletState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.pendingAmount, 'pendingAmount', 500.0)
            .having((s) => s.successMessage, 'successMessage', null)
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits correct state on PaymentSuccessEvent when pendingAmount > 0 and db succeeds',
      build: () {
        when(() => mockDatabase.addTransaction(500.0, 'pay_123'))
            .thenAnswer((_) async => Future.value());
        return walletBloc;
      },
      seed: () => WalletState(
        isLoading: true,
        pendingAmount: 500.0,
      ),
      act: (bloc) => bloc.add(PaymentSuccessEvent('pay_123')),
      expect: () => [
        isA<WalletState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pendingAmount, 'pendingAmount', null)
            .having((s) => s.successMessage, 'successMessage', '₹500 added successfully! 🎉')
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
      verify: (_) {
        verify(() => mockDatabase.addTransaction(500.0, 'pay_123')).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'emits correct state on PaymentSuccessEvent when db fails',
      build: () {
        when(() => mockDatabase.addTransaction(500.0, 'pay_123'))
            .thenThrow(Exception('DB Error'));
        return walletBloc;
      },
      seed: () => WalletState(
        isLoading: true,
        pendingAmount: 500.0,
      ),
      act: (bloc) => bloc.add(PaymentSuccessEvent('pay_123')),
      expect: () => [
        isA<WalletState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pendingAmount, 'pendingAmount', null)
            .having((s) => s.successMessage, 'successMessage', null)
            .having((s) => s.errorMessage, 'errorMessage', 'Failed to update wallet: Exception: DB Error'),
      ],
      verify: (_) {
        verify(() => mockDatabase.addTransaction(500.0, 'pay_123')).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'emits correct state on PaymentFailedEvent',
      build: () => walletBloc,
      seed: () => WalletState(
        isLoading: true,
        pendingAmount: 500.0,
      ),
      act: (bloc) => bloc.add(PaymentFailedEvent('Payment Cancelled')),
      expect: () => [
        isA<WalletState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pendingAmount, 'pendingAmount', null)
            .having((s) => s.successMessage, 'successMessage', null)
            .having((s) => s.errorMessage, 'errorMessage', 'Payment Cancelled'),
      ],
    );
  });
}
