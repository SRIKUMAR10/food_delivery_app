// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

/// BLoC for the seller sign-up 5-step wizard.
///
/// Wizard flow:
///   Screen 1: welcome
///   Screen 2: personalDetails   (name, shopName, businessDetails)
///   Screen 3: contactPassword   (phone, email, password, confirmPassword, terms)
///   Screen 4: otpVerification   (6-digit OTP + 25s countdown)
///   Screen 5: signUpSuccess
///
/// Memory-safe: OTP timer is cancelled on [close].
class SellerSignUpPageBloc
    extends Bloc<SellerSignUpPageEvent, SellerSignUpPageState> {
  final SellerRepository _repo;

  Timer? _otpTimer;

  SellerSignUpPageBloc({SellerRepository? authRepository})
    : _repo = authRepository ?? SellerRepository(),
      super(const SellerSignUpPageState()) {
    // ── Screen 1 ──────────────────────────────────────────────────────────────
    // Welcome screen removed
    on<SellerSignUpLoginNavigated>(_onLoginNavigated);

    // ── Screen 2 ──────────────────────────────────────────────────────────────
    on<SellerSignUpNameChanged>(_onNameChanged);
    on<SellerSignUpShopNameChanged>(_onShopNameChanged);
    on<SellerSignUpBusinessDetailsChanged>(_onBusinessDetailsChanged);
    on<SellerSignUpPersonalDetailsSubmitted>(_onPersonalDetailsSubmitted);

    // ── Screen 3 ──────────────────────────────────────────────────────────────
    on<SellerSignUpPhoneChanged>(_onPhoneChanged);
    on<SellerSignUpEmailChanged>(_onEmailChanged);
    on<SellerSignUpPasswordChanged>(_onPasswordChanged);
    on<SellerSignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SellerSignUpPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<SellerSignUpConfirmPasswordVisibilityToggled>(
      _onConfirmPasswordVisibilityToggled,
    );
    on<SellerSignUpTermsToggled>(_onTermsToggled);
    on<SellerSignUpContactSubmitted>(_onContactSubmitted);

    // ── Screen 4 ──────────────────────────────────────────────────────────────
    on<SellerSignUpOtpDigitChanged>(_onOtpDigitChanged);
    on<SellerSignUpOtpVerifySubmitted>(_onOtpVerifySubmitted);
    on<SellerSignUpOtpTimerTicked>(_onOtpTimerTicked);
    on<SellerSignUpOtpResendRequested>(_onOtpResendRequested);

    // ── Screen 5 ──────────────────────────────────────────────────────────────
    on<SellerSignUpEmailVerifyCheckPressed>(_onEmailVerifyCheckPressed);

    // ── Screen 6 ──────────────────────────────────────────────────────────────
    on<SellerSignUpGoToDashboardPressed>(_onGoToDashboard);

    // ── Global ────────────────────────────────────────────────────────────────
    on<SellerSignUpBackPressed>(_onBackPressed);
    on<SellerSignUpErrorDismissed>(_onErrorDismissed);
    on<SellerSignUpAppLifecycleResumed>(_onAppLifecycleResumed);

    // ── Social ────────────────────────────────────────────────────────────────
    on<SellerSignUpGooglePressed>(_onGoogleSignUp);
    on<SellerSignUpApplePressed>(_onAppleSignUp);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Maps raw exception messages to user-friendly Tamil strings.
  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('GOOGLE_ACCOUNT_EXISTS')) {
      return 'A Google Account exists for this Email. Please Login with Google.';
    }
    if (msg.contains('APPLE_ACCOUNT_EXISTS')) {
      return 'An Apple Account exists for this Email. Please Login with Apple.';
    }
    if (msg.contains('already registered')) {
      return msg.replaceAll('Exception: ', '');
    }
    if (msg.contains('PHONE_NOT_REGISTERED') ||
        msg.contains('phone-number-already-exists')) {
      return 'This Phone Number is already registered. Please Login.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please try again in a few minutes.';
    }
    if (msg.contains('network') || msg.contains('Network')) {
      return 'Please check your internet connection.';
    }
    if (msg.contains('OTP')) {
      return 'Invalid OTP. Please try again.';
    }
    if (msg.contains('sign_in_cancelled') || msg.contains('NSUserCancelled')) {
      return 'Sign in cancelled.';
    }
    return 'An error occurred: $msg';
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    int countdown = 25;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      countdown--;
      add(SellerSignUpOtpTimerTicked(countdown));
      if (countdown <= 0) timer.cancel();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 1 – Welcome
  // ─────────────────────────────────────────────────────────────────────────


  void _onLoginNavigated(
    SellerSignUpLoginNavigated event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    // No state change – handled by UI navigator
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 2 – Personal Details
  // ─────────────────────────────────────────────────────────────────────────

  void _onNameChanged(
    SellerSignUpNameChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(name: event.name, clearNameError: true, clearError: true),
    );
  }

  void _onShopNameChanged(
    SellerSignUpShopNameChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        shopName: event.shopName,
        clearShopNameError: true,
        clearError: true,
      ),
    );
  }

  void _onBusinessDetailsChanged(
    SellerSignUpBusinessDetailsChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        businessDetails: event.businessDetails,
        clearBusinessDetailsError: true,
        clearError: true,
      ),
    );
  }

  void _onPersonalDetailsSubmitted(
    SellerSignUpPersonalDetailsSubmitted event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    // Validate all screen-2 fields
    final nameError = state.name.trim().length < 2
        ? 'Name must be at least 2 characters.'
        : null;
    final shopNameError = state.shopName.trim().length < 2
        ? 'Shop name must be at least 2 characters.'
        : null;
    final bizError = state.businessDetails.trim().isEmpty
        ? 'Enter business details.'
        : null;

    if (nameError != null || shopNameError != null || bizError != null) {
      emit(
        state.copyWith(
          nameError: nameError,
          shopNameError: shopNameError,
          businessDetailsError: bizError,
          status: SellerSignUpStatus.failure,
          errorMessage: 'Please fill all fields.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: SellerSignUpStep.contactPassword,
        clearError: true,
        clearNameError: true,
        clearShopNameError: true,
        clearBusinessDetailsError: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 3 – Contact & Password
  // ─────────────────────────────────────────────────────────────────────────

  void _onPhoneChanged(
    SellerSignUpPhoneChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        phone: event.phone,
        clearPhoneError: true,
        clearError: true,
      ),
    );
  }

  void _onEmailChanged(
    SellerSignUpEmailChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        clearEmailError: true,
        clearError: true,
      ),
    );
  }

  void _onPasswordChanged(
    SellerSignUpPasswordChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        clearPasswordError: true,
        clearError: true,
      ),
    );
  }

  void _onConfirmPasswordChanged(
    SellerSignUpConfirmPasswordChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        clearConfirmPasswordError: true,
        clearError: true,
      ),
    );
  }

  void _onPasswordVisibilityToggled(
    SellerSignUpPasswordVisibilityToggled event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  void _onConfirmPasswordVisibilityToggled(
    SellerSignUpConfirmPasswordVisibilityToggled event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
      ),
    );
  }

  void _onTermsToggled(
    SellerSignUpTermsToggled event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(state.copyWith(termsAccepted: !state.termsAccepted));
  }

  Future<void> _onContactSubmitted(
    SellerSignUpContactSubmitted event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    final phoneError = state.phone.trim().isEmpty 
        ? 'Phone number is required.' 
        : (!state.isPhoneValid ? 'Enter Phone Number in +91XXXXXXXXXX format.' : null);

    final emailError = state.email.trim().isEmpty 
        ? 'Email address is required.' 
        : (!state.isEmailValid ? 'Enter a valid Email address.' : null);

    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    final passwordError = state.password.isEmpty
        ? 'Password is required.'
        : (!passwordRegEx.hasMatch(state.password)
            ? 'Password must be at least 8 chars with 1 uppercase, 1 number & 1 special char.'
            : null);

    final confirmPasswordError = state.confirmPassword.isEmpty
        ? 'Confirm password is required.'
        : (state.password != state.confirmPassword ? 'Passwords do not match.' : null);

    final termsError = !state.termsAccepted
        ? 'Please accept the terms & conditions.'
        : null;

    if (phoneError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        termsError != null) {
      
      final isAnyFieldEmpty = state.phone.trim().isEmpty || state.email.trim().isEmpty || state.password.isEmpty || state.confirmPassword.isEmpty;
      final errorMsg = termsError ?? (isAnyFieldEmpty ? 'Please fill out all required fields.' : 'Please check all fields.');

      emit(
        state.copyWith(
          phoneError: phoneError,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          status: SellerSignUpStatus.failure,
          errorMessage: errorMsg,
        ),
      );
      return;
    }

    // ── Call repository ───────────────────────────────────────────────────────
    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));

    try {
      await _repo.initiateSignUp(
        name: state.name.trim(),
        shopName: state.shopName.trim(),
        businessDetails: state.businessDetails.trim(),
        phoneNumber: state.phone.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      _startOtpTimer();

      emit(
        state.copyWith(
          status: SellerSignUpStatus.otpSent,
          step: SellerSignUpStep.otpVerification,
          otpDigits: List.filled(6, ''),
          otpCountdown: 25,
          isOtpResendAvailable: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 4 – OTP Verification
  // ─────────────────────────────────────────────────────────────────────────

  void _onOtpDigitChanged(
    SellerSignUpOtpDigitChanged event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    final updated = List<String>.from(state.otpDigits);
    if (event.index >= 0 && event.index < 6) {
      updated[event.index] = event.digit;
    }
    emit(
      state.copyWith(otpDigits: updated, clearOtpError: true, clearError: true),
    );
  }

  Future<void> _onOtpVerifySubmitted(
    SellerSignUpOtpVerifySubmitted event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    if (!state.isOtpComplete) {
      emit(
        state.copyWith(
          otpError: 'Please enter the complete 6-digit OTP.',
          errorMessage: '6-digit OTP முழுவதும் உள்ளிடவும்.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));

    try {
      final success = await _repo.confirmSignUpOtp(
        otpCode: state.otpCode,
        phoneNumber: state.phone.trim(),
        name: state.name.trim(),
        shopName: state.shopName.trim(),
        businessDetails: state.businessDetails.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      if (success) {
        _otpTimer?.cancel();
        emit(
          state.copyWith(
            status: SellerSignUpStatus.initial,
            step: SellerSignUpStep.emailVerification,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SellerSignUpStatus.failure,
            otpError: 'OTP தவறானது. மீண்டும் முயற்சிக்கவும்.',
            errorMessage: 'OTP தவறானது. மீண்டும் முயற்சிக்கவும்.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
          otpError: 'OTP தவறானது. மீண்டும் முயற்சிக்கவும்.',
        ),
      );
    }
  }

  void _onOtpTimerTicked(
    SellerSignUpOtpTimerTicked event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(
      state.copyWith(
        otpCountdown: event.remaining,
        isOtpResendAvailable: event.remaining <= 0,
      ),
    );
  }

  Future<void> _onOtpResendRequested(
    SellerSignUpOtpResendRequested event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    if (!state.isOtpResendAvailable) return;

    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));

    try {
      await _repo.sendOtp(state.phone.trim());
      _startOtpTimer();

      emit(
        state.copyWith(
          status: SellerSignUpStatus.otpSent,
          otpDigits: List.filled(6, ''),
          otpCountdown: 25,
          isOtpResendAvailable: false,
          clearOtpError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 5 – Email Verification Sent
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onEmailVerifyCheckPressed(
    SellerSignUpEmailVerifyCheckPressed event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));
    try {
      final isVerified = await _repo.checkEmailVerified();
      if (isVerified) {
        emit(
          state.copyWith(
            status: SellerSignUpStatus.success,
            step: SellerSignUpStep.signUpSuccess,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SellerSignUpStatus.failure,
            errorMessage: 'Email not verified yet. Please check your inbox.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen 6 – Success
  // ─────────────────────────────────────────────────────────────────────────

  void _onGoToDashboard(
    SellerSignUpGoToDashboardPressed event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    // Navigation handled by UI listener
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Global Events
  // ─────────────────────────────────────────────────────────────────────────

  void _onBackPressed(
    SellerSignUpBackPressed event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    switch (state.step) {
      case SellerSignUpStep.contactPassword:
        emit(state.copyWith(step: SellerSignUpStep.personalDetails));
      case SellerSignUpStep.otpVerification:
        _otpTimer?.cancel();
        emit(
          state.copyWith(
            step: SellerSignUpStep.contactPassword,
            status: SellerSignUpStatus.initial,
            clearError: true,
          ),
        );
      case SellerSignUpStep.emailVerification:
        // Let them stay or go back to contact if needed? usually email verification is the final step
        // we'll just not do anything, or maybe they can't go back from here unless they log out.
        // For now, let's keep them here.
        break;
      default:
        // welcome / signUpSuccess – let system pop
        break;
    }
  }

  void _onErrorDismissed(
    SellerSignUpErrorDismissed event,
    Emitter<SellerSignUpPageState> emit,
  ) {
    emit(state.copyWith(status: SellerSignUpStatus.initial, clearError: true));
  }

  Future<void> _onAppLifecycleResumed(
    SellerSignUpAppLifecycleResumed event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    final user = _repo.currentUser;
    if (user != null && state.step == SellerSignUpStep.emailVerification) {
      final isVerified = await _repo.checkEmailVerified();
      if (isVerified) {
        emit(
          state.copyWith(
            step: SellerSignUpStep.signUpSuccess,
            status: SellerSignUpStatus.success,
          ),
        );
      }
    } else if (user != null && state.step != SellerSignUpStep.signUpSuccess) {
      // Social sign-ins typically verified implicitly or don't need this, but we'll leave as is.
      // Or maybe if email verified is true, jump to success.
      if (user.emailVerified) {
        emit(
          state.copyWith(
            step: SellerSignUpStep.signUpSuccess,
            status: SellerSignUpStatus.success,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Social Sign-Up
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onGoogleSignUp(
    SellerSignUpGooglePressed event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));
    try {
      await _repo.signInWithGoogle();
      emit(
        state.copyWith(
          status: SellerSignUpStatus.success,
          step: SellerSignUpStep.signUpSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> _onAppleSignUp(
    SellerSignUpApplePressed event,
    Emitter<SellerSignUpPageState> emit,
  ) async {
    emit(state.copyWith(status: SellerSignUpStatus.loading, clearError: true));
    try {
      await _repo.signInWithApple();
      emit(
        state.copyWith(
          status: SellerSignUpStatus.success,
          step: SellerSignUpStep.signUpSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SellerSignUpStatus.failure,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
