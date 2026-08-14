// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
// WALLET DATABASE (REPOSITORY)
// ─────────────────────────────────────────────

/// Handles database operations related to the user's wallet.
class WalletDatabase {
  final IAuthService authService;

  WalletDatabase({required this.authService});

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get _uid => authService.currentUserId;

  /// Returns a stream of the wallet balance.
  Stream<double?> getWalletBalanceStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('buyer_user').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return (data?['wallet'] as num?)?.toDouble();
    });
  }

  /// Returns a stream of transactions, sorted by createdAt descending.
  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('buyer_user')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
        }
        return data;
      }).toList();
    });
  }

  /// Fetches the initial wallet balance.
  Future<double?> getInitialBalance() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('buyer_user').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data == null) return null;
        return (data['wallet'] as num?)?.toDouble();
      }
    } catch (_) {}
    return null;
  }

  /// Adds a transaction to the user's wallet and updates their balance.
  Future<void> addTransaction({
    required double amount,
    required String title,
    required bool isCredit,
    String? paymentId,
    String? orderId,
    String status = 'success',
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final userRef = _firestore.collection('buyer_user').doc(uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      final data = snapshot.data() as Map<String, dynamic>?;
      double currentBalance =
          (data?['wallet']?.toDouble()) ??
          0.0;

      transaction.set(userRef, {
        'wallet': isCredit ? currentBalance + amount : currentBalance - amount,
      }, SetOptions(merge: true));

      transaction.set(userRef.collection('transactions').doc(), {
        'amount': amount,
        'title': title,
        'isCredit': isCredit,
        'status': status,
        if (paymentId != null) 'paymentId': paymentId,
        if (orderId != null) 'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp':
            FieldValue.serverTimestamp(),
      });
    });
  }
}

// ─────────────────────────────────────────────
// WALLET BLOC
// ─────────────────────────────────────────────

/// Manages the state and business logic for the wallet screen.
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletDatabase database;
  final RazorpayApiService razorpayApiService;
  StreamSubscription<double?>? _balanceSubscription;

  WalletBloc(this.database, this.razorpayApiService)
    : super(const WalletState()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<InitiatePaymentRequested>(_onInitiatePaymentRequested);
    on<PaymentRetryRequested>((event, emit) {
      add(InitiatePaymentRequested(event.amount));
    });
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentFailedEvent>(_onPaymentFailed);
  }

  @override
  Future<void> close() {
    _balanceSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadWalletData(
    LoadWalletData event,
    Emitter<WalletState> emit,
  ) async {
    final uid = database.authService.currentUserId;
    if (uid == null) {
      emit(const WalletState(paymentStatus: PaymentStatus.initial));
      return;
    }

    emit(state.copyWith(paymentStatus: PaymentStatus.loading));

    try {
      await _balanceSubscription?.cancel();
      final balance = await database.getInitialBalance();
      if (balance != null) {
        emit(state.copyWith(walletBalance: balance));
      }

      _balanceSubscription = database.getWalletBalanceStream().listen((liveBalance) {
        if (!isClosed && liveBalance != null) {
          add(LoadWalletData());
        }
      });
    } catch (_) {
      emit(state.copyWith(paymentStatus: PaymentStatus.initial));
    }
  }

  Future<void> _onInitiatePaymentRequested(
    InitiatePaymentRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(
      state.copyWith(
        paymentStatus: PaymentStatus.creatingOrder,
        pendingAmount: event.amount,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final orderResponse = await razorpayApiService.createOrder(
        amount: (event.amount * 100).toInt(),
        receipt: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      );
      final orderId = orderResponse['id'];

      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.orderCreated,
          orderId: orderId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.failed,
          errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
        ),
      );
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<WalletState> emit,
  ) async {
    await database.addTransaction(
      amount: event.amount,
      title: 'Wallet Top-up',
      isCredit: true,
      paymentId: event.paymentId,
      orderId: event.orderId,
      status: 'success',
    );

    emit(
      state.copyWith(
        paymentStatus: PaymentStatus.success,
        successMessage: "Payment Successful",
        pendingAmount: null,
        orderId: null,
      ),
    );
  }

  void _onPaymentFailed(
    PaymentFailedEvent event,
    Emitter<WalletState> emit,
  ) {
    emit(
      state.copyWith(
        paymentStatus: event.userCancelled
            ? PaymentStatus.initial
            : PaymentStatus.failed,
        errorMessage: event.userCancelled ? null : event.message,
        pendingAmount: event.userCancelled ? null : state.pendingAmount,
        orderId: event.userCancelled ? null : state.orderId,
      ),
    );
  }

}
