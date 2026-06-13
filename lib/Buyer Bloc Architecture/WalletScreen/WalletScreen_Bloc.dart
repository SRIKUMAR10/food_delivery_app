import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
//  WALLET BLOC
// ─────────────────────────────────────────────

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletDatabase database;

  WalletBloc(this.database) : super(WalletState()) {
    on<LoadWalletData>((event, emit) {
      emit(state.copyWith(isLoading: false));
    });

    on<AddFundsRequested>((event, emit) {
      emit(
        state.copyWith(
          isLoading: true,
          pendingAmount: () => event.amount,
          successMessage: () => null,
          errorMessage: () => null,
        ),
      );
    });

    on<PaymentSuccessEvent>((event, emit) async {
      final amount = state.pendingAmount;
      if (amount != null && amount > 0) {
        try {
          // Save transaction with new schema in Firestore
          await database.addTransaction(amount, event.paymentId);
          emit(
            state.copyWith(
              isLoading: false,
              pendingAmount: () => null,
              successMessage: () => "₹${amount.toStringAsFixed(0)} added successfully! 🎉",
              errorMessage: () => null,
            ),
          );
        } catch (e) {
          emit(
            state.copyWith(
              isLoading: false,
              pendingAmount: () => null,
              successMessage: () => null,
              errorMessage: () => "Failed to update wallet: $e",
            ),
          );
        }
      }
    });

    on<PaymentFailedEvent>((event, emit) {
      emit(
        state.copyWith(
          isLoading: false,
          pendingAmount: () => null,
          successMessage: () => null,
          errorMessage: () => event.message,
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
//  WALLET DATABASE HELPER
// ─────────────────────────────────────────────

class WalletDatabase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WalletDatabase({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserEmail => _auth.currentUser?.email;
  String? get _uid => _auth.currentUser?.uid;

  Stream<DocumentSnapshot> getWalletStream() {
    return _firestore.collection('users').doc(_uid).snapshots();
  }

  Stream<QuerySnapshot> getTransactionsStream() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// New schema: amount, currency, status, paymentId, createdAt
  Future<void> addTransaction(double amount, String paymentId) async {
    if (_uid == null) return;

    final userRef = _firestore.collection('users').doc(_uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      double currentBalance =
          (snapshot.data() as Map<String, dynamic>)['wallet']?.toDouble() ?? 0.0;

      // Wallet balance update
      transaction.update(userRef, {
        'wallet': currentBalance + amount,
      });

      // New transaction doc - requested schema
      transaction.set(userRef.collection('transactions').doc(), {
        'amount': amount,
        'currency': 'INR',
        'status': 'success',
        'paymentId': paymentId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
