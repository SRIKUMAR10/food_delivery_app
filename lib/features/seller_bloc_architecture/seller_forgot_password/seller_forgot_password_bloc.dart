import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'seller_forgot_password_event.dart';
import 'seller_forgot_password_state.dart';

class SellerForgotPasswordBloc
    extends Bloc<SellerForgotPasswordEvent, SellerForgotPasswordState> {
  final SellerRepository _authRepository;

  SellerForgotPasswordBloc({required SellerRepository authRepository})
      : _authRepository = authRepository,
        super(const SellerForgotPasswordState()) {
    on<SellerForgotPasswordEmailChanged>(_onEmailChanged);
    on<SellerForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    SellerForgotPasswordEmailChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  Future<void> _onSubmitted(
    SellerForgotPasswordSubmitted event,
    Emitter<SellerForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: SellerForgotPasswordStatus.loading));
    
    if (state.email.isEmpty) {
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.failure,
        errorMessage: 'Please enter your email',
      ));
      return;
    }

    try {
      await _authRepository.sendPasswordResetEmail(state.email);
      emit(state.copyWith(status: SellerForgotPasswordStatus.success));
    } catch (e) {
      String message = 'An error occurred';
      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.failure,
        errorMessage: message,
      ));
    }
  }
}
