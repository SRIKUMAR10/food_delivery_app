import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'buyer_login_page_event.dart';
import 'buyer_login_page_state.dart';
import 'buyer_login_page_repository.dart';

class BuyerLoginBloc extends Bloc<BuyerLoginEvent, BuyerLoginState> {
  final BuyerLoginRepository repository;

  BuyerLoginBloc({BuyerLoginRepository? repository})
      : repository = repository ?? BuyerLoginRepository(),
        super(const BuyerLoginState()) {
    on<BuyerLoginPhoneChanged>(_onPhoneChanged);
    on<BuyerLoginPasswordChanged>(_onPasswordChanged);
    on<BuyerLoginTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<BuyerLoginSubmitted>(_onSubmitted);
    on<BuyerLoginGoogleSubmitted>(_onGoogleSubmitted);
    on<BuyerLoginAppleSubmitted>(_onAppleSubmitted);
  }

  void _onPhoneChanged(
    BuyerLoginPhoneChanged event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      status: BuyerLoginStatus.initial,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(
    BuyerLoginPasswordChanged event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      status: BuyerLoginStatus.initial,
      errorMessage: null,
    ));
  }

  void _onTogglePasswordVisibility(
    BuyerLoginTogglePasswordVisibility event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  Future<void> _onSubmitted(
    BuyerLoginSubmitted event,
    Emitter<BuyerLoginState> emit,
  ) async {
    final trimmedPhone = event.phone.trim();
    if (trimmedPhone.isEmpty || trimmedPhone == '+91') {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: 'Please enter your phone number or email.',
      ));
      return;
    }
    if (!trimmedPhone.contains('@')) {
      final digits = trimmedPhone.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty && digits.length < 10) {
        emit(state.copyWith(
          status: BuyerLoginStatus.failure,
          errorMessage: 'Please enter a valid 10-digit mobile number.',
        ));
        return;
      }
    }
    if (event.password.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: 'Please enter your password.',
      ));
      return;
    }

    emit(state.copyWith(status: BuyerLoginStatus.loading));

    try {
      final isOnline = await repository.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: BuyerLoginStatus.failure,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final userId = await repository.login(
        phone: event.phone,
        password: event.password,
      );

      final profileStatus = await repository.checkKycAndOnboardingStatus(userId);

      emit(state.copyWith(
        status: BuyerLoginStatus.success,
        userId: userId,
        isKycCompleted: profileStatus.isKycCompleted,
        fullName: profileStatus.fullName.isNotEmpty ? profileStatus.fullName : null,
        email: profileStatus.email.isNotEmpty ? profileStatus.email : (event.phone.contains('@') ? event.phone : null),
        phone: profileStatus.phone.isNotEmpty ? profileStatus.phone : (!event.phone.contains('@') ? event.phone : null),
        avatarUrl: profileStatus.imageUrl,
        isPhoneVerified: profileStatus.isPhoneVerified || !event.phone.contains('@'),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  Future<void> _onGoogleSubmitted(
    BuyerLoginGoogleSubmitted event,
    Emitter<BuyerLoginState> emit,
  ) async {
    emit(state.copyWith(status: BuyerLoginStatus.loading));
    try {
      final isOnline = await repository.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: BuyerLoginStatus.failure,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final userId = await repository.loginWithGoogle();
      if (userId != null) {
        final profileStatus = await repository.checkKycAndOnboardingStatus(userId);
        emit(state.copyWith(
          status: BuyerLoginStatus.success,
          userId: userId,
          isKycCompleted: profileStatus.isKycCompleted,
          fullName: profileStatus.fullName.isNotEmpty ? profileStatus.fullName : null,
          email: profileStatus.email.isNotEmpty ? profileStatus.email : null,
          phone: profileStatus.phone.isNotEmpty ? profileStatus.phone : null,
          avatarUrl: profileStatus.imageUrl,
          isPhoneVerified: profileStatus.isPhoneVerified,
        ));
      } else {
        emit(state.copyWith(status: BuyerLoginStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  Future<void> _onAppleSubmitted(
    BuyerLoginAppleSubmitted event,
    Emitter<BuyerLoginState> emit,
  ) async {
    emit(state.copyWith(status: BuyerLoginStatus.loading));
    try {
      final isOnline = await repository.checkNetworkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(
          status: BuyerLoginStatus.failure,
          errorMessage: 'No internet connection. Please check your network.',
        ));
        return;
      }

      final userId = await repository.loginWithApple();
      if (userId != null) {
        final profileStatus = await repository.checkKycAndOnboardingStatus(userId);
        emit(state.copyWith(
          status: BuyerLoginStatus.success,
          userId: userId,
          isKycCompleted: profileStatus.isKycCompleted,
          fullName: profileStatus.fullName.isNotEmpty ? profileStatus.fullName : null,
          email: profileStatus.email.isNotEmpty ? profileStatus.email : null,
          phone: profileStatus.phone.isNotEmpty ? profileStatus.phone : null,
          avatarUrl: profileStatus.imageUrl,
          isPhoneVerified: profileStatus.isPhoneVerified,
        ));
      } else {
        emit(state.copyWith(status: BuyerLoginStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }
}
