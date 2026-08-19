import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_State.dart';

class MockWalletDatabase extends Mock implements WalletDatabase {}
class MockRazorpayApiService extends Mock implements RazorpayApiService {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('WalletBloc Unit Tests', () {
    late MockWalletDatabase mockDatabase;
    late MockRazorpayApiService mockRazorpayApiService;
    late MockAuthService mockAuthService;
    late WalletBloc walletBloc;

    setUp(() {
      mockDatabase = MockWalletDatabase();
      mockRazorpayApiService = MockRazorpayApiService();
      mockAuthService = MockAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('test_buyer_456');
      when(() => mockDatabase.authService).thenReturn(mockAuthService);
      when(() => mockDatabase.getInitialBalance()).thenAnswer((_) async => 250.0);
      when(() => mockDatabase.getWalletBalanceStream())
          .thenAnswer((_) => Stream.value(250.0));

      walletBloc = WalletBloc(mockDatabase, mockRazorpayApiService);
    });

    tearDown(() {
      walletBloc.close();
    });

    test('initial state is correct', () {
      expect(walletBloc.state.paymentStatus, PaymentStatus.initial);
      expect(walletBloc.state.walletBalance, 0.0);
    });

    test('LoadWalletData loads initial balance and sets up stream listener', () async {
      walletBloc.add(const LoadWalletData());

      await expectLater(
        walletBloc.stream,
        emitsInOrder([
          isA<WalletState>().having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.loading),
          isA<WalletState>().having((s) => s.walletBalance, 'walletBalance', 250.0),
        ]),
      );

      verify(() => mockDatabase.getInitialBalance()).called(1);
      verify(() => mockDatabase.getWalletBalanceStream()).called(1);
    });

    test('InitiatePaymentRequested calls RazorpayApiService and emits orderCreated', () async {
      when(() => mockRazorpayApiService.createOrder(
            amount: any(named: 'amount'),
            receipt: any(named: 'receipt'),
          )).thenAnswer((_) async => {
            'orderId': 'order_rzp_999',
            'amount': 50000,
          });

      walletBloc.add(const InitiatePaymentRequested(500.0));

      await expectLater(
        walletBloc.stream,
        emitsInOrder([
          isA<WalletState>()
              .having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.creatingOrder)
              .having((s) => s.pendingAmount, 'pendingAmount', 500.0),
          isA<WalletState>()
              .having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.orderCreated)
              .having((s) => s.orderId, 'orderId', 'order_rzp_999'),
        ]),
      );

      verify(() => mockRazorpayApiService.createOrder(
            amount: 50000,
            receipt: any(named: 'receipt'),
          )).called(1);
    });

    test('PaymentSuccessEvent records transaction and emits success state', () async {
      when(() => mockDatabase.addTransaction(
            amount: any(named: 'amount'),
            title: any(named: 'title'),
            isCredit: any(named: 'isCredit'),
            paymentId: any(named: 'paymentId'),
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          )).thenAnswer((_) async {});

      walletBloc.add(const PaymentSuccessEvent(
        amount: 500.0,
        paymentId: 'pay_123',
        orderId: 'order_rzp_999',
      ));

      await expectLater(
        walletBloc.stream,
        emits(isA<WalletState>()
            .having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.success)
            .having((s) => s.successMessage, 'successMessage', 'Payment Successful')),
      );

      verify(() => mockDatabase.addTransaction(
            amount: 500.0,
            title: 'Wallet Top-up',
            isCredit: true,
            paymentId: 'pay_123',
            orderId: 'order_rzp_999',
            status: 'success',
          )).called(1);
    });

    test('PaymentFailedEvent emits failed state or initial when user cancelled', () async {
      walletBloc.add(const PaymentFailedEvent('Bank server error', userCancelled: false));

      await expectLater(
        walletBloc.stream,
        emits(isA<WalletState>()
            .having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.failed)
            .having((s) => s.errorMessage, 'errorMessage', 'Bank server error')),
      );

      walletBloc.add(const PaymentFailedEvent('', userCancelled: true));

      await expectLater(
        walletBloc.stream,
        emits(isA<WalletState>()
            .having((s) => s.paymentStatus, 'paymentStatus', PaymentStatus.initial)),
      );
    });
  });
}
