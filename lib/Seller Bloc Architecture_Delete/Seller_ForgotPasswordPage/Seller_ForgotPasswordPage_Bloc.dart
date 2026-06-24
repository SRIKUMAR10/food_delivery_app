import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Seller_ForgotPasswordPage_Event.dart';
import 'Seller_ForgotPasswordPage_State.dart';

/// Business Logic Component managing the state of the Seller Forgot Password Screen.
class SellerForgotPasswordBloc extends Bloc<SellerForgotPasswordEvent, SellerForgotPasswordState> {
  final FirebaseAuth _firebaseAuth;

  SellerForgotPasswordBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const SellerForgotPasswordState()) {
    on<SellerForgotPasswordEmailChanged>(_onEmailChanged);
    on<SellerForgotPasswordSubmitted>(_onSubmitted);
  }

  /// Handles the email input change event.
  void _onEmailChanged(
    SellerForgotPasswordEmailChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: SellerForgotPasswordStatus.initial));
  }

  /// Submits the forgot password request to Firebase.
  Future<void> _onSubmitted(
    SellerForgotPasswordSubmitted event,
    Emitter<SellerForgotPasswordState> emit,
  ) async {
    // Prevent duplicate submissions or empty email
    if (state.status == SellerForgotPasswordStatus.loading) return;
    if (state.email.trim().isEmpty) return;

    emit(state.copyWith(status: SellerForgotPasswordStatus.loading));

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: state.email.trim());
      emit(state.copyWith(status: SellerForgotPasswordStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: SellerForgotPasswordStatus.failure,
          errorMessage: e.message ?? 'An unknown Firebase error occurred.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerForgotPasswordStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
