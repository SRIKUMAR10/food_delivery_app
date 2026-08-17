import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_state.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerPaymentRepository Unit Tests', () {
    test('instantiates SellerPaymentRepository without errors', () {
      final repository = SellerPaymentRepository();
      expect(repository, isNotNull);
    });

    test('PaymentData model equality and calculation checks', () {
      const bank = BankAccountDetails(
        accountHolderName: 'Karthik',
        accountNumber: '9876543210',
        bankName: 'Axis Bank',
        branchName: 'Anna Nagar',
        ifscCode: 'UTIB0001234',
        accountType: 'Current Account',
      );

      const paymentData = PaymentData(
        walletBalance: 8500.0,
        totalRevenue: 15000.0,
        todayRevenue: 2500.0,
        weeklyRevenue: 8000.0,
        monthlyRevenue: 15000.0,
        orderRevenue: 13000.0,
        deliveryCharges: 1000.0,
        platformCommission: 750.0,
        taxes: 750.0,
        discounts: 300.0,
        refunds: 200.0,
        netEarnings: 13200.0,
        pendingSettlement: 1500.0,
        paidSettlement: 7000.0,
        bankDetails: bank,
        transactions: [],
        payouts: [],
      );

      expect(paymentData.walletBalance, 8500.0);
      expect(paymentData.totalRevenue, 15000.0);
      expect(paymentData.orderRevenue, 13000.0);
      expect(paymentData.netEarnings, 13200.0);
      expect(paymentData.revenue, 15000.0); // backward-compatible getter
    });

    test('EarningsBreakdown model supports all required dimensions', () {
      final breakdown = EarningsBreakdown(
        orderId: 'Order #7890',
        transactionId: 'TXN-7890',
        amount: 800.0,
        itemSubtotal: 720.0,
        deliveryCharges: 40.0,
        platformCommission: 40.0,
        taxes: 40.0,
        discounts: 20.0,
        netEarnings: 700.0,
        status: 'Paid',
        isRefund: false,
        date: 'Today, 12:00',
        timestamp: DateTime.now(),
      );

      expect(breakdown.orderId, 'Order #7890');
      expect(breakdown.netEarnings, 700.0);
      expect(breakdown.isRefund, isFalse);
    });

    test('PayoutRecord model equality and formatting', () {
      const payout = PayoutRecord(
        id: 'PAY99',
        utrNumber: 'UTR-99999',
        amount: 3000.0,
        method: 'UPI',
        status: 'Paid',
        date: 'Today, 11:15',
      );

      expect(payout.id, 'PAY99');
      expect(payout.amount, 3000.0);
      expect(payout.method, 'UPI');
    });
  });
}
