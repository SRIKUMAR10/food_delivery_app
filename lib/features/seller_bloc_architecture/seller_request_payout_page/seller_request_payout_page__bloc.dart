import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/seller_request_payout_repository.dart';
import 'seller_request_payout_page__event.dart';
import 'seller_request_payout_page__state.dart';

class SellerRequestPayoutBloc extends Bloc<SellerRequestPayoutEvent, SellerRequestPayoutState> {
  final SellerRequestPayoutRepository repository;

  SellerRequestPayoutBloc({required this.repository}) : super(const SellerRequestPayoutInitial()) {
    on<LoadPayoutDetails>(_onLoadPayoutDetails);
    on<SubmitPayout>(_onSubmitPayout);
  }

  Future<void> _onLoadPayoutDetails(
    LoadPayoutDetails event,
    Emitter<SellerRequestPayoutState> emit,
  ) async {
    emit(const SellerRequestPayoutLoading());
    try {
      final balance = await repository.getAvailableBalance();
      final banks = await repository.getBankAccounts();
      emit(SellerRequestPayoutLoaded(
        balance: balance,
        bankAccounts: banks,
      ));
    } catch (e) {
      emit(SellerRequestPayoutError(e.toString()));
    }
  }

  Future<void> _onSubmitPayout(
    SubmitPayout event,
    Emitter<SellerRequestPayoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellerRequestPayoutLoaded && !currentState.isSubmitting) {
      if (event.amount <= 0) {
        emit(currentState.copyWith(
          errorMessage: 'Invalid payout amount',
          isSuccess: false,
        ));
        return;
      }
      if (event.amount > currentState.balance) {
        emit(currentState.copyWith(
          errorMessage: 'Insufficient funds',
          isSuccess: false,
        ));
        return;
      }
      if (event.bankAccount.isEmpty && event.upiId.isEmpty) {
        emit(currentState.copyWith(
          errorMessage: 'Please provide either a bank account or UPI ID',
          isSuccess: false,
        ));
        return;
      }

      emit(currentState.copyWith(
        isSubmitting: true,
        isSuccess: false,
        errorMessage: null,
      ));

      try {
        final success = await repository.requestPayout(
          amount: event.amount,
          bankAccount: event.bankAccount,
          upiId: event.upiId,
        );

        if (success) {
          final newBalance = currentState.balance - event.amount;
          emit(currentState.copyWith(
            balance: newBalance,
            isSubmitting: false,
            isSuccess: true,
            errorMessage: null,
          ));
        } else {
          emit(currentState.copyWith(
            isSubmitting: false,
            isSuccess: false,
            errorMessage: 'Payout request failed',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }
}
