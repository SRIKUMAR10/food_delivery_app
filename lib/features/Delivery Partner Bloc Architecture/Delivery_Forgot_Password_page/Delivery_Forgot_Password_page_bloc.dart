import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Forgot_Password_page_event.dart';
import 'Delivery_Forgot_Password_page_repository.dart';
import 'Delivery_Forgot_Password_page_service.dart';
import 'Delivery_Forgot_Password_page_state.dart';

class DeliveryForgotPasswordBloc
    extends Bloc<DeliveryForgotPasswordEvent, DeliveryForgotPasswordState> {
  final DeliveryForgotPasswordRepositoryBase repository;
  final DeliveryForgotPasswordServiceBase service;

  DeliveryForgotPasswordBloc({
    DeliveryForgotPasswordRepositoryBase? repository,
    DeliveryForgotPasswordServiceBase? service,
  })  : repository = repository ?? DeliveryForgotPasswordRepository(),
        service = service ?? DeliveryForgotPasswordService(),
        super(const DeliveryForgotPasswordState()) {
    on<DeliveryForgotPasswordEmailChanged>(_onEmailChanged);
    on<DeliveryForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    DeliveryForgotPasswordEmailChanged event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email, clearError: true));
  }

  Future<void> _onSubmitted(
    DeliveryForgotPasswordSubmitted event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) async {
    final validationError = service.validateEmail(state.email);
    if (validationError != null) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: validationError,
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryForgotPasswordStatus.loading,
      clearError: true,
    ));

    try {
      await repository.sendPasswordResetEmail(state.email.trim());
      emit(state.copyWith(status: DeliveryForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
