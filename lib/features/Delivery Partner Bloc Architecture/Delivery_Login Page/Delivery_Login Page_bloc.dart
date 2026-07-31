import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Login Page_event.dart';
import 'Delivery_Login Page_state.dart';
import 'Delivery_Login Page_repository.dart';
import 'Delivery_Login Page_service.dart';

class DeliveryLoginPageBloc
    extends Bloc<DeliveryLoginPageEvent, DeliveryLoginPageState> {
  final DeliveryLoginRepositoryBase repository;
  final DeliveryLoginServiceBase service;

  DeliveryLoginPageBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryLoginPageState()) {
    on<DeliveryLoginInitEvent>(_onInit);
    on<DeliveryLoginPhoneChangedEvent>(_onPhoneChanged);
    on<DeliveryLoginPasswordChangedEvent>(_onPasswordChanged);
    on<DeliveryLoginTogglePasswordVisibilityEvent>(
        _onTogglePasswordVisibility);
    on<DeliveryLoginToggleRememberMeEvent>(_onToggleRememberMe);
    on<DeliveryLoginSubmittedEvent>(_onSubmitted);
    on<DeliveryLoginGoogleSubmittedEvent>(_onGoogleSubmitted);
    on<DeliveryLoginAppleSubmittedEvent>(_onAppleSubmitted);
    on<DeliveryLoginForgotPasswordSubmittedEvent>(
        _onForgotPasswordSubmitted);
    on<DeliveryLoginNavigateToSignUpEvent>(_onNavigateToSignUp);
  }

  Future<void> _onInit(
    DeliveryLoginInitEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryLoginStatus.loading));
    try {
      final isOnline = await service.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final savedPhone = await repository.getSavedPhone();

      emit(state.copyWith(
        status: DeliveryLoginStatus.initial,
        phone: savedPhone ?? '',
        isRememberMeChecked: savedPhone != null && savedPhone.isNotEmpty,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryLoginStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onPhoneChanged(
    DeliveryLoginPhoneChangedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      errorMessage: null,
      clearPhoneError: true,
    ));
  }

  void _onPasswordChanged(
    DeliveryLoginPasswordChangedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      errorMessage: null,
      clearPasswordError: true,
    ));
  }

  void _onTogglePasswordVisibility(
    DeliveryLoginTogglePasswordVisibilityEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleRememberMe(
    DeliveryLoginToggleRememberMeEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(isRememberMeChecked: !state.isRememberMeChecked));
  }

  Future<void> _onSubmitted(
    DeliveryLoginSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    final phoneError =
        state.phone.trim().isEmpty
            ? 'Phone number is required'
            : (state.phone.replaceAll(RegExp(r'\D'), '').length < 10
                ? 'Enter a valid 10-digit phone number'
                : null);

    final passwordError = state.password.isEmpty
        ? 'Password is required'
        : (state.password.length < 6
            ? 'Password must be at least 6 characters'
            : null);

    if (phoneError != null || passwordError != null) {
      emit(state.copyWith(
        status: DeliveryLoginStatus.error,
        phoneError: phoneError,
        passwordError: passwordError,
        errorMessage:
            phoneError ?? passwordError ?? 'Please check all fields.',
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryLoginStatus.loading,
      clearError: true,
      clearPhoneError: true,
      clearPasswordError: true,
    ));

    try {
      final isOnline = await service.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final formattedPhone =
          state.phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final fullPhone = formattedPhone.startsWith('+')
          ? formattedPhone
          : '+91$formattedPhone';

      await repository.loginWithPhone(fullPhone, state.password);

      if (state.isRememberMeChecked) {
        await repository.saveSavedPhone(state.phone);
      } else {
        await repository.saveSavedPhone('');
      }

      emit(state.copyWith(
        status: DeliveryLoginStatus.success,
        isLoggedIn: true,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryLoginStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onGoogleSubmitted(
    DeliveryLoginGoogleSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliveryLoginStatus.loading,
      clearError: true,
    ));
    try {
      await repository.loginWithGoogle();
      emit(state.copyWith(
        status: DeliveryLoginStatus.success,
        isLoggedIn: true,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryLoginStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAppleSubmitted(
    DeliveryLoginAppleSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliveryLoginStatus.loading,
      clearError: true,
    ));
    try {
      await repository.loginWithApple();
      emit(state.copyWith(
        status: DeliveryLoginStatus.success,
        isLoggedIn: true,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryLoginStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
    DeliveryLoginForgotPasswordSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    if (event.email.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter your email address.',
      ));
      return;
    }

    emit(state.copyWith(
      isForgotPasswordLoading: true,
      clearError: true,
    ));

    try {
      await repository.sendPasswordResetEmail(event.email.trim());
      emit(state.copyWith(
        isForgotPasswordLoading: false,
        isForgotPasswordSuccess: true,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isForgotPasswordLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onNavigateToSignUp(
    DeliveryLoginNavigateToSignUpEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    // Navigation handled by UI listener
  }
}
