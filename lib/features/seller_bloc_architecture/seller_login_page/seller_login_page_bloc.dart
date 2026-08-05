import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'seller_login_page_event.dart';
import 'seller_login_page_state.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SellerLoginPageBloc
///
/// Clean Architecture:
///  - Depends on [SellerRepository] (abstracted — easy to mock in tests).
///  - All business logic lives here, zero UI code.
///  - Every event handler validates, delegates to repository, emits new state.
///  - OTP countdown is driven by a [Timer] that fires [SellerLoginOtpTimerTicked]
///    events — disposed properly in [close()].
///
/// SOLID compliance:
///  - SRP: Each handler does one thing.
///  - OCP: New screens → new events + handlers, no existing code modified.
///  - DIP: Depends on SellerRepository abstraction, not Firebase directly.
/// ─────────────────────────────────────────────────────────────────────────────
class SellerLoginPageBloc
    extends Bloc<SellerLoginPageEvent, SellerLoginPageState> {
  final SellerRepository authRepository;
  final String countryCode;

  Timer? _otpTimer;

  SellerLoginPageBloc({
    required this.authRepository,
    this.countryCode = '+91',
  }) : super(const SellerLoginPageState()) {
    // ── Field / credential changes ──────────────────────────────────────────
    on<SellerLoginFieldChanged>(_onFieldChanged);
    on<SellerLoginPasswordChanged>(_onPasswordChanged);
    on<SellerLoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);

    // ── Primary login ───────────────────────────────────────────────────────
    on<SellerLoginSubmitted>(_onLoginSubmitted);
    on<SellerLoginEmailPhoneContinued>(_onEmailPhoneContinued);
    on<SellerLoginPasswordStepSubmitted>(_onPasswordStepSubmitted);

    // ── Login OTP (Screen 4) ────────────────────────────────────────────────
    on<SellerLoginOtpDigitChanged>(_onOtpDigitChanged);
    on<SellerLoginOtpVerifySubmitted>(_onOtpVerifySubmitted);
    on<SellerLoginOtpResendRequested>(_onOtpResendRequested);
    on<SellerLoginOtpTimerTicked>(_onOtpTimerTicked);

    // ── Login success (Screen 5) ────────────────────────────────────────────
    on<SellerLoginGoToDashboardPressed>(_onGoToDashboard);

    // ── Forgot Password (Screens 6–7) ───────────────────────────────────────
    on<SellerLoginForgotPasswordNavigated>(_onForgotPasswordNavigated);
    on<SellerLoginForgotPasswordEmailChanged>(_onForgotPasswordEmailChanged);
    on<SellerLoginForgotPasswordLinkSent>(_onForgotPasswordLinkSent);
    on<SellerLoginBackToLoginPressed>(_onBackToLoginPressed);

    // ── Social sign-in ──────────────────────────────────────────────────────
    on<SellerLoginGoogleSignInPressed>(_onGoogleSignIn);
    on<SellerLoginAppleSignInPressed>(_onAppleSignIn);

    // ── Navigation / lifecycle ──────────────────────────────────────────────
    on<SellerLoginBackPressed>(_onBackPressed);
    on<SellerLoginErrorDismissed>(_onErrorDismissed);
    on<SellerLoginAppLifecycleResumed>(_onAppLifecycleResumed);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Field handlers
  // ──────────────────────────────────────────────────────────────────────────

  void _onFieldChanged(
      SellerLoginFieldChanged event, Emitter<SellerLoginPageState> emit) {
    final isPhone = _looksLikePhone(event.emailOrPhone);
    emit(state.copyWith(
      emailOrPhone: event.emailOrPhone,
      isPhoneLogin: isPhone,
      clearEmailPhoneError: true,
      clearError: true,
    ));
  }

  void _onPasswordChanged(
      SellerLoginPasswordChanged event, Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
      password: event.password,
      clearPasswordError: true,
      clearError: true,
    ));
  }

  void _onPasswordVisibilityToggled(SellerLoginPasswordVisibilityToggled event,
      Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 1 – Direct Login
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onLoginSubmitted(
      SellerLoginSubmitted event, Emitter<SellerLoginPageState> emit) async {
    // ── Validation ──────────────────────────────────────────────────────────
    if (state.emailOrPhone.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: 'Please enter Email and Password.',
      ));
      return;
    }

    emit(state.copyWith(status: SellerLoginStatus.loading, clearError: true));

    try {
      if (state.isPhoneLogin) {
        // Phone login → send OTP flow
        final formattedPhone = _formatPhoneNumber(state.emailOrPhone);
        await authRepository.requestPhoneLoginOtp(formattedPhone);
        _startOtpCountdown();
        emit(state.copyWith(
          status: SellerLoginStatus.otpSent,
          step: SellerLoginStep.otpVerification,
          otpDigits: List.filled(6, ''),
          otpCountdown: 25,
          isOtpResendAvailable: false,
        ));
      } else {
        // Email/password login
        await authRepository.signIn(state.emailOrPhone, state.password);
        final uid = authRepository.currentUser?.uid;
        if (uid != null) {
          await authRepository.updateSellerData(uid, {'isOnline': true});
        }
        emit(state.copyWith(
          status: SellerLoginStatus.success,
          step: SellerLoginStep.loginSuccess,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 2 – Email/Phone Continue
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onEmailPhoneContinued(SellerLoginEmailPhoneContinued event,
      Emitter<SellerLoginPageState> emit) async {
    final input = state.emailOrPhone.trim();
    if (input.isEmpty) {
      emit(state.copyWith(emailPhoneError: 'Please enter Email or Phone Number.'));
      return;
    }

    final isPhone = _looksLikePhone(input);

    if (isPhone) {
      // Phone flow: send OTP immediately
      emit(state.copyWith(
          status: SellerLoginStatus.loading, clearEmailPhoneError: true));
      try {
        final formattedPhone = _formatPhoneNumber(input);
        await authRepository.requestPhoneLoginOtp(formattedPhone);
        _startOtpCountdown();
        emit(state.copyWith(
          status: SellerLoginStatus.otpSent,
          step: SellerLoginStep.otpVerification,
          isPhoneLogin: true,
          otpDigits: List.filled(6, ''),
          otpCountdown: 25,
          isOtpResendAvailable: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: SellerLoginStatus.failure,
          errorMessage: _friendlyError(e.toString()),
        ));
      }
    } else {
      // Email flow: move to password screen
      if (!_validEmail(input)) {
        emit(state.copyWith(emailPhoneError: 'Please enter a valid Email.'));
        return;
      }
      emit(state.copyWith(
        step: SellerLoginStep.enterPassword,
        status: SellerLoginStatus.initial,
        clearEmailPhoneError: true,
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 3 – Password Step Submit
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onPasswordStepSubmitted(SellerLoginPasswordStepSubmitted event,
      Emitter<SellerLoginPageState> emit) async {
    if (state.password.isEmpty) {
      emit(state.copyWith(passwordError: 'Please enter Password.'));
      return;
    }
    emit(state.copyWith(
        status: SellerLoginStatus.loading, clearPasswordError: true));
    try {
      await authRepository.signIn(state.emailOrPhone, state.password);
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        await authRepository.updateSellerData(uid, {'isOnline': true});
      }
      emit(state.copyWith(
        status: SellerLoginStatus.success,
        step: SellerLoginStep.loginSuccess,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 4 – OTP Verification (Login)
  // ──────────────────────────────────────────────────────────────────────────

  void _onOtpDigitChanged(
      SellerLoginOtpDigitChanged event, Emitter<SellerLoginPageState> emit) {
    final digits = List<String>.from(state.otpDigits);
    digits[event.index] = event.digit;
    emit(state.copyWith(otpDigits: digits, clearError: true));
  }

  Future<void> _onOtpVerifySubmitted(SellerLoginOtpVerifySubmitted event,
      Emitter<SellerLoginPageState> emit) async {
    if (!state.isOtpComplete) {
      emit(state.copyWith(
          errorMessage: 'Please enter the complete 6-digit OTP.'));
      return;
    }
    emit(state.copyWith(status: SellerLoginStatus.loading, clearError: true));
    try {
      final formattedPhone = _formatPhoneNumber(state.emailOrPhone);
      final success = await authRepository.verifyPhoneLoginOtp(
          state.otpCode, formattedPhone);
      if (success) {
        _cancelOtpTimer();
        final uid = authRepository.currentUser?.uid;
        if (uid != null) {
          await authRepository.updateSellerData(uid, {'isOnline': true});
        }
        emit(state.copyWith(
          status: SellerLoginStatus.success,
          step: SellerLoginStep.loginSuccess,
        ));
      } else {
        emit(state.copyWith(
          status: SellerLoginStatus.failure,
          errorMessage: 'Invalid OTP. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  Future<void> _onOtpResendRequested(SellerLoginOtpResendRequested event,
      Emitter<SellerLoginPageState> emit) async {
    emit(state.copyWith(status: SellerLoginStatus.loading));
    try {
      final formattedPhone = _formatPhoneNumber(state.emailOrPhone);
      await authRepository.requestPhoneLoginOtp(formattedPhone);
      _cancelOtpTimer();
      _startOtpCountdown();
      emit(state.copyWith(
        status: SellerLoginStatus.otpSent,
        otpDigits: List.filled(6, ''),
        otpCountdown: 25,
        isOtpResendAvailable: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  void _onOtpTimerTicked(
      SellerLoginOtpTimerTicked event, Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
      otpCountdown: event.secondsRemaining,
      isOtpResendAvailable: event.secondsRemaining == 0,
    ));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 5 – Login Success → Dashboard
  // ──────────────────────────────────────────────────────────────────────────

  void _onGoToDashboard(SellerLoginGoToDashboardPressed event,
      Emitter<SellerLoginPageState> emit) {
    // Navigation is handled in the UI via BlocListener.
    // We keep state as-is; UI will push /sellerDashboard.
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Screen 6 – Forgot Password
  // ──────────────────────────────────────────────────────────────────────────

  void _onForgotPasswordNavigated(SellerLoginForgotPasswordNavigated event,
      Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
      step: SellerLoginStep.forgotPassword,
      status: SellerLoginStatus.initial,
      clearError: true,
    ));
  }

  void _onForgotPasswordEmailChanged(SellerLoginForgotPasswordEmailChanged event,
      Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
      forgotPasswordEmail: event.email,
      clearError: true,
    ));
  }

  Future<void> _onForgotPasswordLinkSent(SellerLoginForgotPasswordLinkSent event,
      Emitter<SellerLoginPageState> emit) async {
    final email = state.forgotPasswordEmail.trim();
    if (!_validEmail(email)) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: 'Please enter a valid Email.',
      ));
      return;
    }
    emit(state.copyWith(status: SellerLoginStatus.loading, clearError: true));
    try {
      await authRepository.sendPasswordResetEmail(email);
      emit(state.copyWith(
        status: SellerLoginStatus.passwordResetSent,
        step: SellerLoginStep.forgotPasswordSuccess,
      ));
    } catch (e) {
      final msg = e.toString();
      String userMsg;
      if (msg.contains('GOOGLE_ACCOUNT_EXISTS')) {
        userMsg = 'This Email uses a Google Account. Please log in with Google.';
      } else if (msg.contains('APPLE_ACCOUNT_EXISTS')) {
        userMsg = 'This Email uses an Apple Account. Please log in with Apple.';
      } else {
        userMsg = _friendlyError(msg);
      }
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: userMsg,
      ));
    }
  }

  void _onBackToLoginPressed(
      SellerLoginBackToLoginPressed event, Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
        step: SellerLoginStep.loginForm,
        status: SellerLoginStatus.initial,
        clearError: true));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Social Sign-In
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onGoogleSignIn(SellerLoginGoogleSignInPressed event,
      Emitter<SellerLoginPageState> emit) async {
    emit(state.copyWith(status: SellerLoginStatus.loading, clearError: true));
    try {
      await authRepository.signInWithGoogle();
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        await authRepository.updateSellerData(uid, {'isOnline': true});
      }
      emit(state.copyWith(
        status: SellerLoginStatus.success,
        step: SellerLoginStep.loginSuccess,
      ));
    } catch (e) {
      final str = e.toString();
      if (str.contains('Google Sign-In was cancelled') ||
          str.contains('popup-closed-by-user') ||
          str.contains('aborted by user') ||
          str.contains('user-cancelled')) {
        emit(state.copyWith(
          status: SellerLoginStatus.initial,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: SellerLoginStatus.failure,
          errorMessage: _friendlyError(str),
        ));
      }
    }
  }

  Future<void> _onAppleSignIn(SellerLoginAppleSignInPressed event,
      Emitter<SellerLoginPageState> emit) async {
    emit(state.copyWith(status: SellerLoginStatus.loading, clearError: true));
    try {
      await authRepository.signInWithApple();
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        await authRepository.updateSellerData(uid, {'isOnline': true});
      }
      emit(state.copyWith(
        status: SellerLoginStatus.success,
        step: SellerLoginStep.loginSuccess,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SellerLoginStatus.failure,
        errorMessage: _friendlyError(e.toString()),
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Navigation & Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  void _onBackPressed(
      SellerLoginBackPressed event, Emitter<SellerLoginPageState> emit) {
    switch (state.step) {
      case SellerLoginStep.enterPassword:
        emit(state.copyWith(
            step: SellerLoginStep.enterEmailPhone,
            status: SellerLoginStatus.initial,
            clearError: true));
        break;
      case SellerLoginStep.otpVerification:
        _cancelOtpTimer();
        emit(state.copyWith(
            step: SellerLoginStep.loginForm,
            status: SellerLoginStatus.initial,
            clearError: true));
        break;
      case SellerLoginStep.forgotPassword:
      case SellerLoginStep.forgotPasswordSuccess:
        emit(state.copyWith(
            step: SellerLoginStep.loginForm,
            status: SellerLoginStatus.initial,
            clearError: true));
        break;
      default:
        break;
    }
  }

  void _onErrorDismissed(
      SellerLoginErrorDismissed event, Emitter<SellerLoginPageState> emit) {
    emit(state.copyWith(
      status: SellerLoginStatus.initial,
      clearError: true,
    ));
  }

  void _onAppLifecycleResumed(SellerLoginAppLifecycleResumed event,
      Emitter<SellerLoginPageState> emit) {
    // Re-check current auth state on app resume if needed.
    final user = authRepository.currentUser;
    if (user != null &&
        state.step != SellerLoginStep.loginSuccess) {
      emit(state.copyWith(
        status: SellerLoginStatus.success,
        step: SellerLoginStep.loginSuccess,
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Timer helpers (Memory-safe – cancelled in close())
  // ──────────────────────────────────────────────────────────────────────────

  void _startOtpCountdown() {
    _cancelOtpTimer();
    int seconds = 25;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      add(SellerLoginOtpTimerTicked(seconds));
      if (seconds <= 0) timer.cancel();
    });
  }

  void _cancelOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Utility
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns true if the input looks like a phone number (digits / '+' / spaces).
  bool _looksLikePhone(String input) {
    final trimmed = input.trim().replaceAll(' ', '');
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(trimmed);
  }

  /// Formats the phone number to always include the [countryCode] (defaults to +91).
  String _formatPhoneNumber(String input) {
    String formatted = input.trim().replaceAll(' ', '');
    if (_looksLikePhone(formatted)) {
      if (!formatted.startsWith('+')) {
        final ccDigits = countryCode.replaceAll('+', '');
        if (formatted.length == ccDigits.length - 1 && formatted.startsWith(ccDigits.substring(0, ccDigits.length - 1))) {
          return '+$formatted';
        }
        return '$countryCode$formatted';
      }
    }
    return formatted;
  }

  bool _validEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  String _friendlyError(String raw) {
    if (raw.contains('PHONE_NOT_REGISTERED')) {
      return 'This Phone Number is not registered. Please sign up.';
    }
    if (raw.contains('GOOGLE_ACCOUNT_EXISTS')) {
      return 'This Email uses a Google Account. Please log in with Google.';
    }
    if (raw.contains('APPLE_ACCOUNT_EXISTS')) {
      return 'This Email uses an Apple Account. Please log in with Apple.';
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect password. Please try again.';
    }
    if (raw.contains('user-not-found')) {
      return 'Account not found. Please sign up.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many failed attempts. Try again after a few minutes.';
    }
    if (raw.contains('network')) {
      return 'Please check your internet connection.';
    }
    if (raw.contains('invalid-recaptcha-token')) {
      return 'reCAPTCHA verification failed. Please refresh and try again.';
    }
    // Clean up raw Firebase codes like [firebase_auth/popup-closed-by-user]
    String cleaned = raw.replaceAll(RegExp(r'\[firebase_auth\/[a-zA-Z0-9_-]+\]\s*'), '');
    return cleaned.replaceAll(RegExp(r'^Exception:\s*'), '').trim();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dispose – critical for memory management
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> close() {
    _cancelOtpTimer();
    return super.close();
  }
}
