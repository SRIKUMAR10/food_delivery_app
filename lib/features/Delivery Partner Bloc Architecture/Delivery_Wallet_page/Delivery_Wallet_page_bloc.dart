// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Wallet_page_event.dart';
import 'Delivery_Wallet_page_repository.dart';
import 'Delivery_Wallet_page_service.dart';
import 'Delivery_Wallet_page_state.dart';

class DeliveryWalletPageBloc
    extends Bloc<DeliveryWalletPageEvent, DeliveryWalletPageState> {
  final DeliveryWalletPageRepositoryBase repository;
  final DeliveryWalletPageServiceBase service;
  StreamSubscription<DeliveryWalletPageState>? _walletSubscription;
  StreamSubscription<List<DeliveryWalletTransaction>>? _transactionsSubscription;

  DeliveryWalletPageBloc({
    DeliveryWalletPageRepositoryBase? repository,
    DeliveryWalletPageServiceBase? service,
  }) : repository = repository ?? DeliveryWalletPageRepository(),
       service = service ?? DeliveryWalletPageService(),
       super(const DeliveryWalletPageState()) {
    on<DeliveryWalletInitEvent>(_onInit);
    on<DeliveryWalletRefreshEvent>(_onRefresh);
    on<DeliveryWalletFilterTransactionsEvent>(_onFilterTransactions);
    on<DeliveryWalletTransactionsUpdatedEvent>(_onTransactionsUpdated);
    on<DeliveryWalletWithdrawRequestedEvent>(_onWithdrawRequested);
    on<DeliveryWalletFilterPeriodChangedEvent>(_onFilterPeriodChanged);
    on<DeliveryWalletAddPaymentMethodEvent>(_onAddPaymentMethod);
  }

  void _subscribeTransactions(DeliveryWalletTransactionFilter filter) {
    _transactionsSubscription?.cancel();
    _transactionsSubscription = repository.watchTransactions(filter).listen(
      (transactions) {
        add(DeliveryWalletTransactionsUpdatedEvent(transactions));
      },
      onError: (_) {},
    );
  }

  Future<void> _onInit(
    DeliveryWalletInitEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryWalletStatus.loading));
    try {
      await _walletSubscription?.cancel();
      final dataState = await repository.loadWalletData();
      emit(dataState);

      _walletSubscription = repository.watchWalletData().listen((liveState) {
        add(DeliveryWalletRefreshEvent());
      });
      _subscribeTransactions(state.activeFilter);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryWalletStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _walletSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRefresh(
    DeliveryWalletRefreshEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryWalletStatus.refreshing));
    try {
      final dataState = await repository.loadWalletData();
      emit(dataState);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryWalletStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFilterTransactions(
    DeliveryWalletFilterTransactionsEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) async {
    emit(state.copyWith(activeFilter: event.filter));
    _subscribeTransactions(event.filter);
  }

  void _onTransactionsUpdated(
    DeliveryWalletTransactionsUpdatedEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) {
    emit(state.copyWith(
      transactions: event.transactions,
      activeFilter: state.activeFilter,
    ));
  }

  Future<void> _onWithdrawRequested(
    DeliveryWalletWithdrawRequestedEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) async {
    if (event.amount <= 0) {
      emit(
        state.copyWith(errorMessage: 'Please enter a valid withdrawal amount.'),
      );
      return;
    }
    if (event.amount > state.walletBalance) {
      emit(
        state.copyWith(
          errorMessage:
              'Withdrawal amount exceeds your available wallet balance.',
        ),
      );
      return;
    }

    emit(state.copyWith(isWithdrawing: true));
    try {
      final updatedState = await repository.withdraw(event.amount);
      emit(
        updatedState.copyWith(
          isWithdrawing: false,
          activeFilter: state.activeFilter,
          selectedPeriod: state.selectedPeriod,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isWithdrawing: false,
          errorMessage: 'Withdrawal failed. Please try again.',
        ),
      );
    }
  }

  void _onFilterPeriodChanged(
    DeliveryWalletFilterPeriodChangedEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) {
    emit(state.copyWith(selectedPeriod: event.period));
  }

  Future<void> _onAddPaymentMethod(
    DeliveryWalletAddPaymentMethodEvent event,
    Emitter<DeliveryWalletPageState> emit,
  ) async {
    try {
      final updatedState = await repository.addPaymentMethod(event.method);
      emit(
        updatedState.copyWith(
          activeFilter: state.activeFilter,
          selectedPeriod: state.selectedPeriod,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not add payment method. Please try again.',
        ),
      );
    }
  }
}
