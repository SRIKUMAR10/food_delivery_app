import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_State.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes with concrete implementations to satisfy Null Safety
class MockWalletDatabase extends Mock implements WalletDatabase {
  @override
  String? get currentUserEmail => null;

  @override
  Stream<DocumentSnapshot> getWalletStream() {
    return const Stream.empty();
  }

  @override
  Stream<QuerySnapshot> getTransactionsStream() {
    return const Stream.empty();
  }

  @override
  Future<void> addTransaction({
    required double amount,
    required String title,
    required bool isCredit,
    String? paymentId,
    String? orderId,
    String status = 'success',
  }) async {}
}

class MockRazorpayApiService extends Mock implements RazorpayApiService {
  @override
  Future<Map<String, dynamic>> createOrder({
    required int amount,
    String currency = 'INR',
    required String receipt,
  }) async {
    return {'id': 'test_order_id'};
  }
}

void main() {
  group('WalletBloc Tests', () {
    late WalletBloc walletBloc;
    late MockWalletDatabase mockDatabase;
    late MockRazorpayApiService mockApiService;

    setUp(() {
      mockDatabase = MockWalletDatabase();
      mockApiService = MockRazorpayApiService();
      walletBloc = WalletBloc(mockDatabase, mockApiService);
    });

    tearDown(() {
      walletBloc.close();
    });

    test('initial state is correct', () {
      expect(walletBloc.state.paymentStatus, PaymentStatus.initial);
    });

    blocTest<WalletBloc, WalletState>(
      'emits [initial] when LoadWalletData is added',
      build: () => walletBloc,
      act: (bloc) => bloc.add(LoadWalletData()),
      expect: () => [const WalletState(paymentStatus: PaymentStatus.initial)],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [success] when PaymentSuccessEvent is added',
      build: () => walletBloc,
      act: (bloc) => bloc.add(
        PaymentSuccessEvent(
          amount: 100.0,
          paymentId: 'pay_test',
          orderId: 'order_test',
        ),
      ),
      expect: () => [
        const WalletState(
          paymentStatus: PaymentStatus.success,
          successMessage: 'Payment Successful',
          pendingAmount: null,
          orderId: null,
        ),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [failed] when PaymentFailedEvent is added (not user cancelled)',
      build: () => walletBloc,
      act: (bloc) => bloc.add(PaymentFailedEvent('Payment error')),
      expect: () => [
        const WalletState(
          paymentStatus: PaymentStatus.failed,
          errorMessage: 'Payment error',
        ),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [initial] when PaymentFailedEvent is added (user cancelled)',
      build: () => walletBloc,
      act: (bloc) =>
          bloc.add(PaymentFailedEvent('Cancelled', userCancelled: true)),
      expect: () => [
        const WalletState(
          paymentStatus: PaymentStatus.initial,
          errorMessage: null,
        ),
      ],
    );
  });
}
