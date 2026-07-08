import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';

import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
// WALLET DATABASE (REPOSITORY)
// ─────────────────────────────────────────────

/// Handles database operations related to the user's wallet.
class WalletDatabase {
  const WalletDatabase();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get currentUserEmail => _auth.currentUser?.email;
  String? get _uid => _auth.currentUser?.uid;

  /// Returns a stream of the user's wallet document.
  Stream<DocumentSnapshot> getWalletStream() {
    return _firestore.collection('users').doc(_uid).snapshots();
  }

  /// Returns a stream of the user's wallet transactions, ordered by time.
  Stream<QuerySnapshot> getTransactionsStream() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
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
    if (_uid == null) return;

    final userRef = _firestore.collection('users').doc(_uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      double currentBalance =
          (snapshot.data() as Map<String, dynamic>?)?['wallet']?.toDouble() ??
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
            FieldValue.serverTimestamp(), // kept for backwards compatibility
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

  WalletBloc(this.database, this.razorpayApiService)
    : super(const WalletState()) {
    // Load initial wallet data
    on<LoadWalletData>((event, emit) {
      emit(state.copyWith(paymentStatus: PaymentStatus.initial));
    });

    // Request to initiate a payment
    on<InitiatePaymentRequested>((event, emit) async {
      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.creatingOrder,
          pendingAmount: event.amount,
          errorMessage: null,
          successMessage: null,
        ),
      );

      try {
        String? orderId;
        
        // Create order via the secure Cloud Function
        final orderResponse = await razorpayApiService.createOrder(
          amount: (event.amount * 100).toInt(),
          receipt: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        );
        orderId = orderResponse['id'];

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
            errorMessage: e.toString(),
          ),
        );
      }
    });

    // Request to retry a failed payment
    on<PaymentRetryRequested>((event, emit) {
      add(InitiatePaymentRequested(event.amount));
    });

    // Handle payment success
    on<PaymentSuccessEvent>((event, emit) async {
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
    });

    // Handle payment failure or user cancellation
    on<PaymentFailedEvent>((event, emit) {
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
    });
  }
}
