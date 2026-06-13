import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/user_repository.dart';
import 'SignUpPage_Event.dart';
import 'SignUpPage_State.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository userRepository;

  SignUpBloc({required this.userRepository}) : super(const SignUpState()) {
    on<SignUpPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  void _onPasswordVisibilityToggled(
    SignUpPasswordVisibilityToggled event,
    Emitter<SignUpState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading, errorMessage: null));

    try {
      await userRepository.signUp(event.email, event.password, event.name);
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(state.copyWith(status: SignUpStatus.failure, errorMessage: e.toString()));
    }
  }
}
