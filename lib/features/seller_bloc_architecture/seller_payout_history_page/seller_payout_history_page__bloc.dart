// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/seller_wallet_repository.dart';
import '../seller_wallet_page/seller_wallet_page__state.dart';
import 'seller_payout_history_page__event.dart';
import 'seller_payout_history_page__state.dart';

class SellerPayoutHistoryBloc
    extends Bloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState> {
  final SellerWalletRepository repository;
  static const int _pageSize = 10;
  StreamSubscription<List<PayoutItem>>? _payoutsSubscription;

  SellerPayoutHistoryBloc({required this.repository})
      : super(const SellerPayoutHistoryInitial()) {
    on<LoadPayoutHistory>(_onLoadPayoutHistory);
    on<RefreshPayoutHistory>(_onRefreshPayoutHistory);
    on<LoadMorePayoutHistory>(_onLoadMorePayoutHistory);
  }

  Future<void> _onLoadPayoutHistory(
    LoadPayoutHistory event,
    Emitter<SellerPayoutHistoryState> emit,
  ) async {
    emit(const SellerPayoutHistoryLoading());
    try {
      await _payoutsSubscription?.cancel();

      final payouts = await repository.getPayoutHistory(offset: 0, limit: _pageSize);
      emit(SellerPayoutHistoryLoaded(
        payouts: payouts,
        hasReachedMax: payouts.length < _pageSize,
        isPaginatedLoading: false,
      ));

      _payoutsSubscription = repository.streamPayoutHistory().listen((newPayouts) {
        final currentState = state;
        if (currentState is SellerPayoutHistoryLoaded && newPayouts.isNotEmpty) {
          add(RefreshPayoutHistory());
        }
      });
    } catch (e) {
      emit(SellerPayoutHistoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _payoutsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRefreshPayoutHistory(
    RefreshPayoutHistory event,
    Emitter<SellerPayoutHistoryState> emit,
  ) async {
    try {
      final payouts = await repository.getPayoutHistory(offset: 0, limit: _pageSize);
      emit(SellerPayoutHistoryLoaded(
        payouts: payouts,
        hasReachedMax: payouts.length < _pageSize,
        isPaginatedLoading: false,
      ));
    } catch (e) {
      emit(SellerPayoutHistoryError(e.toString()));
    }
  }

  Future<void> _onLoadMorePayoutHistory(
    LoadMorePayoutHistory event,
    Emitter<SellerPayoutHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellerPayoutHistoryLoaded &&
        !currentState.hasReachedMax &&
        !currentState.isPaginatedLoading) {
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
}