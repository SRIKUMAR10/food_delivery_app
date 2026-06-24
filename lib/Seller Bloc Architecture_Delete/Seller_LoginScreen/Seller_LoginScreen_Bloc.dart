import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

import 'Seller_LoginScreen_Event.dart';
import 'Seller_LoginScreen_State.dart';

/// Business Logic Component managing the state of the Seller Login Screen.
class SellerLoginBloc extends Bloc<SellerLoginEvent, SellerLoginState> {
  final SellerRepository _sellerRepository;

  SellerLoginBloc({SellerRepository? sellerRepository})
    : _sellerRepository = sellerRepository ?? SellerRepository(),
      super(const SellerLoginState()) {
    on<SellerLoginEmailChanged>(_onEmailChanged);
    on<SellerLoginPasswordChanged>(_onPasswordChanged);
    on<SellerLoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<SellerLoginSubmitted>(_onSubmitted);
  }

  /// Handles the email input change event.
  void _onEmailChanged(
    SellerLoginEmailChanged event,
    Emitter<SellerLoginState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: SellerLoginStatus.initial));
  }

  /// Handles the password input change event.
  void _onPasswordChanged(
    SellerLoginPasswordChanged event,
    Emitter<SellerLoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        status: SellerLoginStatus.initial,
      ),
    );
  }

  /// Handles toggling the visibility of the password field.
  void _onPasswordVisibilityToggled(
    SellerLoginPasswordVisibilityToggled event,
    Emitter<SellerLoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Submits the login request to the SellerRepository.
  Future<void> _onSubmitted(
    SellerLoginSubmitted event,
    Emitter<SellerLoginState> emit,
  ) async {
    // Prevent duplicate submissions or empty fields
    if (state.status == SellerLoginStatus.loading) return;
    if (state.email.trim().isEmpty || state.password.trim().isEmpty) return;

    emit(state.copyWith(status: SellerLoginStatus.loading));

    try {
      await _sellerRepository.signIn(state.email.trim(), state.password.trim());
      emit(state.copyWith(status: SellerLoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerLoginStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
