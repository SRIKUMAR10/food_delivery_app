import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Sign_Up_page_event.dart';
import 'Delivery_Sign_Up_page_state.dart';
import 'Delivery_Sign_Up_page_repository.dart';
import 'Delivery_Sign_Up_page_service.dart';

class DeliverySignUpPageBloc
    extends Bloc<DeliverySignUpPageEvent, DeliverySignUpPageState> {
  final DeliverySignUpRepositoryBase repository;
  final DeliverySignUpServiceBase service;

  DeliverySignUpPageBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliverySignUpPageState()) {
    on<DeliverySignUpInitEvent>(_onInit);
    on<DeliverySignUpNameChanged>(_onNameChanged);
    on<DeliverySignUpPhoneChanged>(_onPhoneChanged);
    on<DeliverySignUpEmailChanged>(_onEmailChanged);
    on<DeliverySignUpPasswordChanged>(_onPasswordChanged);
    on<DeliverySignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<DeliverySignUpPasswordVisibilityToggled>(
        _onPasswordVisibilityToggled);
    on<DeliverySignUpConfirmPasswordVisibilityToggled>(
        _onConfirmPasswordVisibilityToggled);
    on<DeliverySignUpTermsToggled>(_onTermsToggled);
    on<DeliverySignUpSubmitted>(_onSubmitted);
    on<DeliverySignUpBackPressed>(_onBackPressed);
    on<DeliverySignUpLoginNavigated>(_onLoginNavigated);
  }

  void _onInit(
    DeliverySignUpInitEvent event,
    Emitter<DeliverySignUpPageState> emit,
  ) {}

  void _onNameChanged(
    DeliverySignUpNameChanged event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
      name: event.name,
      clearNameError: true,
      clearError: true,
    ));
  }

  void _onPhoneChanged(
    DeliverySignUpPhoneChanged event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      clearPhoneError: true,
      clearError: true,
    ));
  }

  void _onEmailChanged(
    DeliverySignUpEmailChanged event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
      email: event.email,
      clearEmailError: true,
      clearError: true,
    ));
  }

  void _onPasswordChanged(
    DeliverySignUpPasswordChanged event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      clearPasswordError: true,
      clearError: true,
    ));
  }

  void _onConfirmPasswordChanged(
    DeliverySignUpConfirmPasswordChanged event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      clearConfirmPasswordError: true,
      clearError: true,
    ));
  }

  void _onPasswordVisibilityToggled(
    DeliverySignUpPasswordVisibilityToggled event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
        isPasswordObscured: !state.isPasswordObscured));
  }

  void _onConfirmPasswordVisibilityToggled(
    DeliverySignUpConfirmPasswordVisibilityToggled event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(
        isConfirmPasswordObscured: !state.isConfirmPasswordObscured));
  }

  void _onTermsToggled(
    DeliverySignUpTermsToggled event,
    Emitter<DeliverySignUpPageState> emit,
  ) {
    emit(state.copyWith(termsAccepted: !state.termsAccepted));
  }

  Future<void> _onSubmitted(
    DeliverySignUpSubmitted event,
    Emitter<DeliverySignUpPageState> emit,
  ) async {
    final nameError =
        state.name.trim().length < 2 ? 'Name must be at least 2 characters' : null;
    final phoneError = state.phone.replaceAll(RegExp(r'\D'), '').length < 10
        ? 'Enter a valid 10-digit phone number'
        : null;
    final emailError = !state.isEmailValid
        ? 'Enter a valid email address'
        : null;
    final passwordError = state.password.length < 6
        ? 'Password must be at least 6 characters'
        : null;
    final confirmPasswordError = state.password != state.confirmPassword
        ? 'Passwords do not match'
        : null;

    if (nameError != null ||
        phoneError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        !state.termsAccepted) {
      emit(state.copyWith(
        status: DeliverySignUpStatus.failure,
        errorMessage: 'Please check all fields.',
        nameError: nameError,
        phoneError: phoneError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliverySignUpStatus.loading,
      clearError: true,
      clearNameError: true,
      clearPhoneError: true,
      clearEmailError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
    ));

    try {
      final isOnline = await service.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: DeliverySignUpStatus.failure,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final verificationId = await repository.sendPhoneOtp(
        phone: state.phone.trim(),
      );

      emit(state.copyWith(
        status: DeliverySignUpStatus.otpSent,
        verificationId: verificationId,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliverySignUpStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onBackPressed(
    DeliverySignUpBackPressed event,
    Emitter<DeliverySignUpPageState> emit,
  ) {}

  void _onLoginNavigated(
    DeliverySignUpLoginNavigated event,
    Emitter<DeliverySignUpPageState> emit,
  ) {}
}
