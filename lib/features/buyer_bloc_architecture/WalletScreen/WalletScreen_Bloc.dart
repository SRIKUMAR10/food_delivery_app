// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/repositories/firebase_user_profile_repository.dart';

import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
// WALLET DATABASE (REPOSITORY ADAPTER)
// ─────────────────────────────────────────────

/// Thin adapter exposing wallet database operations through the shared
/// [IUserProfileRepository] contract. All Firestore access lives in
/// `FirebaseUserProfileRepository`; this adapter keeps the legacy
/// `WalletDatabase` API stable for callers and tests.
class WalletDatabase {
  final IAuthService authService;
  final IUserProfileRepository _repository;

  WalletDatabase({required this.authService, IUserProfileRepository? repository})
    : _repository = repository ?? FirebaseUserProfileRepository();

  String? get _uid => authService.currentUserId;

  /// Returns a stream of the wallet balance.
  Stream<double?> getWalletBalanceStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _repository.watchWalletBalance(uid);
  }

  /// Returns a stream of transactions, sorted by createdAt descending.
  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _repository.watchTransactions(uid);
  }

  /// Fetches the initial wallet balance.
  Future<double?> getInitialBalance() async {
    final uid = _uid;
    if (uid == null) return null;
    return _repository.loadWalletBalance(uid);
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
    await _repository.addWalletTransaction(
      userId: uid,
      amount: amount,
      title: title,
      isCredit: isCredit,
      paymentId: paymentId,
      orderId: orderId,
      status: status,
    );
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
    on<WalletBalanceUpdatedInternal>(_onWalletBalanceUpdatedInternal);
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

  void _onWalletBalanceUpdatedInternal(
    WalletBalanceUpdatedInternal event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(
      walletBalance: event.balance,
      paymentStatus: PaymentStatus.initial,
    ));
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
      emit(state.copyWith(
        walletBalance: balance ?? 0.0,
        paymentStatus: PaymentStatus.initial,
      ));

      _balanceSubscription = database.getWalletBalanceStream().listen((liveBalance) {
        if (!isClosed && liveBalance != null && liveBalance != state.walletBalance) {
          add(WalletBalanceUpdatedInternal(liveBalance));
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
    if (event.amount < 10 || event.amount > 50000) {
      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.failed,
          errorMessage: 'Please enter a valid amount between ₹10 and ₹50,000',
        ),
      );
      return;
    }

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
        amount: event.amount,
        receipt: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      );
      final orderId = orderResponse['orderId'] as String? ??
          orderResponse['id'] as String?;

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
    if (event.amount <= 0) return;

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
