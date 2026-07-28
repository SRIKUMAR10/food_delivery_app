import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'ForgotPasswordPage_Event.dart';
import 'ForgotPasswordPage_State.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final UserRepository _userRepository;

  ForgotPasswordBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: ForgotPasswordStatus.initial));
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state.status == ForgotPasswordStatus.loading) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    try {
      await _userRepository.sendPasswordResetEmail(state.email.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }
}
