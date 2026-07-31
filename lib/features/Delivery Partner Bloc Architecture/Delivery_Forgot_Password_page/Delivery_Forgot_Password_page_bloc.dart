import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'Delivery_Forgot_Password_page_event.dart';
import 'Delivery_Forgot_Password_page_state.dart';

class DeliveryForgotPasswordBloc
    extends Bloc<DeliveryForgotPasswordEvent, DeliveryForgotPasswordState> {
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryForgotPasswordBloc({DeliveryPartnerRepository? partnerRepo})
      : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository(),
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
    if (state.email.trim().isEmpty) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: 'Please enter your email address',
      ));
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(state.email.trim())) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: 'Please enter a valid email address',
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryForgotPasswordStatus.loading,
      clearError: true,
    ));

    try {
      await _partnerRepo.sendPasswordResetEmail(state.email.trim());
      emit(state.copyWith(status: DeliveryForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
