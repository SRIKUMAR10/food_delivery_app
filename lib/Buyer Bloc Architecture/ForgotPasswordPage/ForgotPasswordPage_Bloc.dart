import 'package:flutter_bloc/flutter_bloc.dart';
import 'ForgotPasswordPage_Event.dart';
import 'ForgotPasswordPage_State.dart';

/// Business Logic Component managing the state of the Forgot Password Screen.
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  /// Handles the email input change event.
  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: ForgotPasswordStatus.initial));
  }

  /// Submits the forgot password request.
  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    // Prevent duplicate submissions
    if (state.status == ForgotPasswordStatus.loading) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    try {
      // Simulate network request for resetting password
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
