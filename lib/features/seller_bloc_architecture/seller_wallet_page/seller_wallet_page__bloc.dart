import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/seller_wallet_repository.dart';
import 'seller_wallet_page__event.dart';
import 'seller_wallet_page__state.dart';

class SellerWalletBloc extends Bloc<SellerWalletEvent, SellerWalletState> {
  final SellerWalletRepository repository;
  static const int _pageSize = 10;

  SellerWalletBloc({required this.repository}) : super(const SellerWalletInitial()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<RefreshWalletData>(_onRefreshWalletData);
    on<LoadMorePayoutHistory>(_onLoadMorePayoutHistory);
    on<InitiateWithdrawal>(_onInitiateWithdrawal);
  }

  Future<void> _onLoadWalletData(
    LoadWalletData event,
    Emitter<SellerWalletState> emit,
  ) async {
    emit(const SellerWalletLoading());
    try {
      final balance = await repository.getWalletBalance();
      final payouts = await repository.getPayoutHistory(offset: 0, limit: _pageSize);

      emit(SellerWalletLoaded(
        balance: balance,
        payouts: payouts,
        hasReachedMax: payouts.length < _pageSize,
        isPaginatedLoading: false,
        isWithdrawing: false,
      ));
    } catch (e) {
      emit(SellerWalletError(e.toString()));
    }
  }

  Future<void> _onRefreshWalletData(
    RefreshWalletData event,
    Emitter<SellerWalletState> emit,
  ) async {
    // Refresh works directly by fetching fresh data
    try {
      final balance = await repository.getWalletBalance();
      final payouts = await repository.getPayoutHistory(offset: 0, limit: _pageSize);

      emit(SellerWalletLoaded(
        balance: balance,
        payouts: payouts,
        hasReachedMax: payouts.length < _pageSize,
        isPaginatedLoading: false,
        isWithdrawing: false,
      ));
    } catch (e) {
      emit(SellerWalletError(e.toString()));
    }
  }

  Future<void> _onLoadMorePayoutHistory(
    LoadMorePayoutHistory event,
    Emitter<SellerWalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellerWalletLoaded && !currentState.hasReachedMax && !currentState.isPaginatedLoading) {
      emit(currentState.copyWith(isPaginatedLoading: true));
      try {
        final nextPayouts = await repository.getPayoutHistory(
          offset: currentState.payouts.length,
          limit: _pageSize,
        );

        if (nextPayouts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isPaginatedLoading: false));
        } else {
          emit(currentState.copyWith(
            payouts: List.of(currentState.payouts)..addAll(nextPayouts),
            hasReachedMax: nextPayouts.length < _pageSize,
            isPaginatedLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(isPaginatedLoading: false));
      }
    }
  }

  Future<void> _onInitiateWithdrawal(
    InitiateWithdrawal event,
    Emitter<SellerWalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellerWalletLoaded && !currentState.isWithdrawing) {
      if (event.amount <= 0) {
        emit(currentState.copyWith(
          withdrawalError: 'Invalid amount',
          withdrawalSuccess: false,
        ));
        return;
      }
      if (event.amount > currentState.balance) {
        emit(currentState.copyWith(
          withdrawalError: 'Insufficient funds',
          withdrawalSuccess: false,
        ));
        return;
      }

      emit(currentState.copyWith(isWithdrawing: true, withdrawalSuccess: false, withdrawalError: null));

      try {
        final success = await repository.withdrawFunds(event.amount);
        if (success) {
          final newBalance = currentState.balance - event.amount;
          
          // Add a new local pending payout record to payouts list for visual feedback
          final newPayout = PayoutItem(
            id: 'payout_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Payout #${(currentState.payouts.length + 1).toString().padLeft(4, '0')}',
            amount: event.amount,
            status: 'Paid',
            date: DateTime.now(),
          );

          emit(currentState.copyWith(
            balance: newBalance,
            payouts: List.of(currentState.payouts)..insert(0, newPayout),
            isWithdrawing: false,
            withdrawalSuccess: true,
            withdrawalError: null,
          ));
        } else {
          emit(currentState.copyWith(
            isWithdrawing: false,
            withdrawalSuccess: false,
            withdrawalError: 'Withdrawal failed',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isWithdrawing: false,
          withdrawalSuccess: false,
          withdrawalError: e.toString(),
        ));
      }
    }
  }
}
