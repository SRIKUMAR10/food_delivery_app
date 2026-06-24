import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_State.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';

/// Business Logic Component managing the state of the Login Screen.
class FoodGoLoginBloc extends Bloc<FoodGoLoginEvent, FoodGoLoginState> {
  final UserRepository _userRepository;

  FoodGoLoginBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const FoodGoLoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
  }

  /// Handles the email input change event.
  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<FoodGoLoginState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial));
  }

  /// Handles the password input change event.
  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<FoodGoLoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial));
  }

  /// Toggles the visibility of the password field.
  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<FoodGoLoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Submits the login request to the UserRepository.
  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<FoodGoLoginState> emit,
  ) async {
    // Prevent duplicate submissions.
    if (state.status == LoginStatus.loading) return;

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await _userRepository.signIn(state.email.trim(), state.password.trim());
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
