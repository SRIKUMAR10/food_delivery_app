import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/seller_repository.dart';
import 'Seller_SignUpPage_Event.dart';
import 'Seller_SignUpPage_State.dart';

/// Business Logic Component managing the state of the Seller Sign Up Screen.
class SellerSignUpBloc extends Bloc<SellerSignUpEvent, SellerSignUpState> {
  final SellerRepository _sellerRepository;

  SellerSignUpBloc({SellerRepository? sellerRepository})
      : _sellerRepository = sellerRepository ?? SellerRepository(),
        super(const SellerSignUpState()) {
    on<SellerSignUpNameChanged>(_onNameChanged);
    on<SellerSignUpEmailChanged>(_onEmailChanged);
    on<SellerSignUpPasswordChanged>(_onPasswordChanged);
    on<SellerSignUpPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<SellerSignUpSubmitted>(_onSubmitted);
  }

  /// Handles the name input change event.
  void _onNameChanged(
    SellerSignUpNameChanged event,
    Emitter<SellerSignUpState> emit,
  ) {
    emit(state.copyWith(name: event.name, status: SellerSignUpStatus.initial));
  }

  /// Handles the email input change event.
  void _onEmailChanged(
    SellerSignUpEmailChanged event,
    Emitter<SellerSignUpState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: SellerSignUpStatus.initial));
  }

  /// Handles the password input change event.
  void _onPasswordChanged(
    SellerSignUpPasswordChanged event,
    Emitter<SellerSignUpState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: SellerSignUpStatus.initial));
  }

  /// Handles toggling the visibility of the password field.
  void _onPasswordVisibilityToggled(
    SellerSignUpPasswordVisibilityToggled event,
    Emitter<SellerSignUpState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Submits the sign-up request to the SellerRepository.
  Future<void> _onSubmitted(
    SellerSignUpSubmitted event,
    Emitter<SellerSignUpState> emit,
  ) async {
    // Prevent duplicate submissions or empty fields
    if (state.status == SellerSignUpStatus.loading) return;
    if (state.name.trim().isEmpty || state.email.trim().isEmpty || state.password.trim().isEmpty) return;

    emit(state.copyWith(status: SellerSignUpStatus.loading));

    try {
      await _sellerRepository.signUp(
        state.email.trim(),
        state.password.trim(),
        state.name.trim(),
      );
      emit(state.copyWith(status: SellerSignUpStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
