import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';

class MockDeliveryWalletPageRepository extends Mock
    implements DeliveryWalletPageRepositoryBase {}

class MockDeliveryWalletPageService extends Mock
    implements DeliveryWalletPageServiceBase {}

DeliveryWalletPageState buildLoadedState() {
  final now = DateTime(2026, 7, 31);
  return DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    walletBalance: 24580.50,
    totalEarnings: 128450.00,
    totalWithdrawn: 89450.00,
    bonusEarnings: 12500.00,
    transactions: [
      DeliveryWalletTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: now,
        amount: 640.00,
        type: 'income',
        status: 'completed',
      ),
      DeliveryWalletTransaction(
        id: 'tx_2',
        title: 'Wallet Withdrawal',
        date: now,
        amount: 5000.00,
        type: 'withdrawal',
        status: 'processing',
      ),
      DeliveryWalletTransaction(
        id: 'tx_3',
        title: 'Peak Hour Bonus',
        date: now,
        amount: 350.00,
        type: 'bonus',
        status: 'completed',
      ),
    ],
    paymentMethods: [
      DeliveryPaymentMethod(
        id: 'pm_1',
        type: 'UPI',
        label: 'Google Pay',
        maskedIdentifier: 'ravi@okhdfcbank',
        isDefault: true,
      ),
    ],
    bankAccount: DeliveryBankAccount(
      bankName: 'HDFC Bank',
      accountHolder: 'Ravi Kumar',
      maskedAccountNumber: 'xxxx4821',
      ifscCode: 'HDFC0001234',
      isVerified: true,
    ),
    settlementSchedule: [
      DeliverySettlementItem(
        period: 'This Week',
        amount: 1890.00,
        status: 'scheduled',
        date: now,
      ),
    ],
    periodEarnings: {
      DeliveryWalletPeriod.thisMonth: [
        DeliveryWalletEarningsPoint(label: 'W1', value: 22850.0, date: now),
        DeliveryWalletEarningsPoint(label: 'W2', value: 26400.0, date: now),
      ],
    },
    earningsBreakdown: [
      DeliveryWalletBreakdownSlice(
        label: 'Delivery Income',
        value: 96850.0,
        colorHex: '#00E676',
      ),
    ],
  );
}

void main() {
  late MockDeliveryWalletPageRepository mockRepository;
  late MockDeliveryWalletPageService mockService;

  setUpAll(() {
    registerFallbackValue(DeliveryWalletTransactionFilter.all);
    registerFallbackValue(
      const DeliveryPaymentMethod(
        id: 'fallback',
        type: 'UPI',
        label: 'Fallback',
        maskedIdentifier: 'fallback@upi',
      ),
    );
  });

  setUp(() {
    mockRepository = MockDeliveryWalletPageRepository();
    mockService = MockDeliveryWalletPageService();
  });

  group('DeliveryWalletPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = DeliveryWalletPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state.status, DeliveryWalletStatus.initial);
      expect(bloc.state.walletBalance, 24580.50);
      expect(bloc.state.totalEarnings, 128450.00);
      expect(bloc.state.totalWithdrawn, 89450.00);
      expect(bloc.state.bonusEarnings, 12500.00);
      expect(bloc.state.activeFilter, DeliveryWalletTransactionFilter.all);
      expect(bloc.state.selectedPeriod, DeliveryWalletPeriod.thisMonth);
      expect(bloc.state.transactions, isEmpty);
      expect(bloc.state.paymentMethods, isEmpty);
      expect(bloc.state.bankAccount, isNull);
      expect(bloc.state.settlementSchedule, isEmpty);
      expect(bloc.state.isWithdrawing, isFalse);
      expect(bloc.state.isFromCache, isFalse);
      bloc.close();
    });

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'emits [loading, loaded] on init success',
      build: () {
        when(
          () => mockRepository.loadWalletData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryWalletInitEvent()),
      expect: () => [
        const DeliveryWalletPageState(status: DeliveryWalletStatus.loading),
        buildLoadedState(),
      ],
      verify: (_) {
        verify(() => mockRepository.loadWalletData()).called(1);
      },
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'emits [loading, error] on init failure',
      build: () {
        when(
          () => mockRepository.loadWalletData(),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryWalletInitEvent()),
      expect: () => [
        const DeliveryWalletPageState(status: DeliveryWalletStatus.loading),
        const DeliveryWalletPageState(
          status: DeliveryWalletStatus.error,
          errorMessage: 'Exception: Server unreachable',
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'emits [refreshing, loaded] on refresh success',
      build: () {
        when(
          () => mockRepository.loadWalletData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryWalletRefreshEvent()),
      expect: () => [
        buildLoadedState().copyWith(status: DeliveryWalletStatus.refreshing),
        buildLoadedState(),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'emits refreshed error on refresh failure',
      build: () {
        when(
          () => mockRepository.loadWalletData(),
        ).thenThrow(Exception('offline'));
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryWalletRefreshEvent()),
      expect: () => [
        buildLoadedState().copyWith(status: DeliveryWalletStatus.refreshing),
        buildLoadedState().copyWith(
          status: DeliveryWalletStatus.error,
          errorMessage: 'Exception: offline',
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'filters transactions by income type',
      build: () {
        when(
          () => mockRepository.filterTransactions(
            DeliveryWalletTransactionFilter.income,
          ),
        ).thenAnswer(
          (_) async => [
            DeliveryWalletTransaction(
              id: 'tx_1',
              title: 'Delivery Earnings',
              date: DateTime(2026, 7, 31),
              amount: 640.00,
              type: 'income',
              status: 'completed',
            ),
          ],
        );
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryWalletFilterTransactionsEvent(
          DeliveryWalletTransactionFilter.income,
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          activeFilter: DeliveryWalletTransactionFilter.income,
        ),
        buildLoadedState().copyWith(
          activeFilter: DeliveryWalletTransactionFilter.income,
          transactions: [
            DeliveryWalletTransaction(
              id: 'tx_1',
              title: 'Delivery Earnings',
              date: DateTime(2026, 7, 31),
              amount: 640.00,
              type: 'income',
              status: 'completed',
            ),
          ],
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.filterTransactions(
            DeliveryWalletTransactionFilter.income,
          ),
        ).called(1);
      },
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'filter failure falls back to local filter state without throwing',
      build: () {
        when(
          () => mockRepository.filterTransactions(any()),
        ).thenThrow(Exception('offline'));
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryWalletFilterTransactionsEvent(
          DeliveryWalletTransactionFilter.bonuses,
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          activeFilter: DeliveryWalletTransactionFilter.bonuses,
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'withdraw emits withdrawing and updated balance on success',
      build: () {
        when(() => mockRepository.withdraw(500.0)).thenAnswer(
          (_) async => buildLoadedState().copyWith(walletBalance: 24080.50),
        );
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const DeliveryWalletWithdrawRequestedEvent(500.0)),
      expect: () => [
        buildLoadedState().copyWith(isWithdrawing: true),
        buildLoadedState().copyWith(walletBalance: 24080.50),
      ],
      verify: (_) {
        verify(() => mockRepository.withdraw(500.0)).called(1);
      },
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'withdraw rejects non-positive amounts without calling repository',
      build: () => DeliveryWalletPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryWalletWithdrawRequestedEvent(0.0)),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Please enter a valid withdrawal amount.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.withdraw(any()));
      },
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'withdraw rejects amounts exceeding wallet balance',
      build: () => DeliveryWalletPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const DeliveryWalletWithdrawRequestedEvent(999999.0)),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage:
              'Withdrawal amount exceeds your available wallet balance.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.withdraw(any()));
      },
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'withdraw failure emits friendly error and resets withdrawing',
      build: () {
        when(
          () => mockRepository.withdraw(500.0),
        ).thenThrow(Exception('Gateway timeout'));
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const DeliveryWalletWithdrawRequestedEvent(500.0)),
      expect: () => [
        buildLoadedState().copyWith(isWithdrawing: true),
        buildLoadedState().copyWith(
          isWithdrawing: false,
          errorMessage: 'Withdrawal failed. Please try again.',
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'emits updated period when period changed event is added',
      build: () => DeliveryWalletPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryWalletFilterPeriodChangedEvent(
          DeliveryWalletPeriod.lastMonth,
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          selectedPeriod: DeliveryWalletPeriod.lastMonth,
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'add payment method updates payment methods on success',
      build: () {
        when(() => mockRepository.addPaymentMethod(any())).thenAnswer(
          (_) async => buildLoadedState().copyWith(
            paymentMethods: [
              buildLoadedState().paymentMethods.first,
              const DeliveryPaymentMethod(
                id: 'pm_2',
                type: 'UPI',
                label: 'PhonePe',
                maskedIdentifier: 'partner@okicici',
                isDefault: false,
              ),
            ],
          ),
        );
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryWalletAddPaymentMethodEvent(
          DeliveryPaymentMethod(
            id: 'pm_2',
            type: 'UPI',
            label: 'PhonePe',
            maskedIdentifier: 'partner@okicici',
            isDefault: false,
          ),
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          paymentMethods: [
            buildLoadedState().paymentMethods.first,
            const DeliveryPaymentMethod(
              id: 'pm_2',
              type: 'UPI',
              label: 'PhonePe',
              maskedIdentifier: 'partner@okicici',
              isDefault: false,
            ),
          ],
        ),
      ],
    );

    blocTest<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      'add payment method failure emits friendly error',
      build: () {
        when(
          () => mockRepository.addPaymentMethod(any()),
        ).thenThrow(Exception('offline'));
        return DeliveryWalletPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryWalletAddPaymentMethodEvent(
          DeliveryPaymentMethod(
            id: 'pm_2',
            type: 'UPI',
            label: 'PhonePe',
            maskedIdentifier: 'partner@okicici',
            isDefault: false,
          ),
        ),
      ),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Could not add payment method. Please try again.',
        ),
      ],
    );
  });
}
