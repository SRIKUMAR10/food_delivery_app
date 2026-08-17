import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_state.dart';

class MockSellerPaymentRepository extends Mock implements SellerPaymentRepository {}

void main() {
  const dummyBank = BankAccountDetails(
    accountHolderName: 'Test Seller',
    accountNumber: '1234567890',
    bankName: 'HDFC Bank',
    branchName: 'Main Branch',
    ifscCode: 'HDFC0001234',
    accountType: 'Current Account',
    upiId: 'test@upi',
  );

  const dummyData = PaymentData(
    walletBalance: 12500.0,
    totalRevenue: 25000.0,
    todayRevenue: 3500.0,
    weeklyRevenue: 12000.0,
    monthlyRevenue: 25000.0,
    orderRevenue: 21000.0,
    deliveryCharges: 2000.0,
    platformCommission: 1250.0,
    taxes: 1250.0,
    discounts: 500.0,
    refunds: 0.0,
    netEarnings: 22000.0,
    pendingSettlement: 2000.0,
    paidSettlement: 10500.0,
    bankDetails: dummyBank,
    transactions: [
      EarningsBreakdown(
        orderId: 'Order #ORD101',
        transactionId: 'TXN-101',
        amount: 500.0,
        itemSubtotal: 450.0,
        deliveryCharges: 50.0,
        platformCommission: 25.0,
        taxes: 25.0,
        discounts: 0.0,
        netEarnings: 450.0,
        status: 'Paid',
        isRefund: false,
        date: 'Today, 10:30',
      ),
    ],
    payouts: [
      PayoutRecord(
        id: 'PAY01',
        utrNumber: 'UTR-12345',
        amount: 5000.0,
        method: 'Bank Transfer',
        status: 'Paid',
        date: 'Yesterday, 14:00',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(dummyBank);
  });

  group('SellerPaymentPageBloc', () {
    late SellerPaymentPageBloc paymentBloc;
    late MockSellerPaymentRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerPaymentRepository();
      when(() => mockRepository.streamPaymentData(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) => Stream.value(dummyData));
      when(() => mockRepository.loadPaymentData(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) async => dummyData);

      paymentBloc = SellerPaymentPageBloc(repository: mockRepository);
    });

    tearDown(() {
      paymentBloc.close();
    });

    test('initial state should be SellerPaymentPageInitial', () {
      expect(paymentBloc.state, isA<SellerPaymentPageInitial>());
    });

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'emits [SellerPaymentPageLoading, SellerPaymentPageLoaded] when LoadPaymentData is added',
      build: () => paymentBloc,
      act: (bloc) => bloc.add(const LoadPaymentData()),
      expect: () => [
        isA<SellerPaymentPageLoading>(),
        isA<SellerPaymentPageLoaded>().having(
          (s) => s.data.walletBalance,
          'walletBalance',
          12500.0,
        ),
      ],
    );

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'emits updated timeframe filter when ChangeTimeframeFilter is added',
      build: () => paymentBloc,
      seed: () => const SellerPaymentPageLoaded(dummyData, selectedTimeframe: 'All Time'),
      act: (bloc) => bloc.add(const ChangeTimeframeFilter('Today')),
      expect: () => [
        isA<SellerPaymentPageLoaded>().having(
          (s) => s.selectedTimeframe,
          'selectedTimeframe',
          'Today',
        ),
      ],
    );

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'submits payout request successfully',
      build: () {
        when(() => mockRepository.requestPayout(
              amount: any(named: 'amount'),
              method: any(named: 'method'),
              destination: any(named: 'destination'),
            )).thenAnswer((_) async => true);
        return paymentBloc;
      },
      seed: () => const SellerPaymentPageLoaded(dummyData),
      act: (bloc) => bloc.add(const SubmitPayoutRequest(
        amount: 2000.0,
        method: 'Bank Account',
        destination: '1234567890',
      )),
      expect: () => [
        isA<SellerPaymentPageLoaded>().having(
          (s) => s.isPayoutSubmitting,
          'isPayoutSubmitting',
          true,
        ),
        isA<SellerPaymentPageLoaded>()
            .having((s) => s.isPayoutSubmitting, 'isPayoutSubmitting', false)
            .having(
              (s) => s.payoutSuccessMessage,
              'payoutSuccessMessage',
              contains('submitted successfully'),
            ),
      ],
    );

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'updates bank and upi details successfully',
      build: () {
        when(() => mockRepository.updateBankAndUpiDetails(
              details: any(named: 'details'),
            )).thenAnswer((_) async => true);
        return paymentBloc;
      },
      seed: () => const SellerPaymentPageLoaded(dummyData),
      act: (bloc) => bloc.add(const UpdateBankAndUpiDetails(dummyBank)),
      expect: () => [
        isA<SellerPaymentPageLoaded>().having(
          (s) => s.isUpdatingBankDetails,
          'isUpdatingBankDetails',
          true,
        ),
        isA<SellerPaymentPageLoaded>()
            .having((s) => s.isUpdatingBankDetails, 'isUpdatingBankDetails', false)
            .having((s) => s.bankUpdateSuccess, 'bankUpdateSuccess', true),
      ],
    );

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'refreshes data when RefreshPaymentData is added',
      build: () => paymentBloc,
      seed: () => SellerPaymentPageLoaded(
        dummyData.copyWith(walletBalance: 5000.0, totalRevenue: 10000.0),
      ),
      act: (bloc) => bloc.add(const RefreshPaymentData()),
      expect: () => [
        isA<SellerPaymentPageLoaded>().having(
          (s) => s.data.totalRevenue,
          'totalRevenue',
          25000.0,
        ),
      ],
    );
  });
}
