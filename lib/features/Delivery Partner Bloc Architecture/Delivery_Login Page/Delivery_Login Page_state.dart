import 'package:equatable/equatable.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';

enum DeliveryLoginStatus { initial, loading, success, error }

class DeliveryLoginPageState extends Equatable {
  final DeliveryLoginStatus status;
  final String phone;
  final String password;
  final bool isPasswordVisible;
  final bool isRememberMeChecked;
  final String? errorMessage;
  final bool isLoggedIn;
  final bool isOnboardingCompleted;
  final DeliveryPartnerModel? partner;

  final String? phoneError;
  final String? passwordError;

  final String forgotPasswordEmail;
  final bool isForgotPasswordLoading;
  final bool isForgotPasswordSuccess;

  const DeliveryLoginPageState({
    this.status = DeliveryLoginStatus.initial,
    this.phone = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isRememberMeChecked = false,
    this.errorMessage,
    this.isLoggedIn = false,
    this.isOnboardingCompleted = false,
    this.partner,
    this.phoneError,
    this.passwordError,
    this.forgotPasswordEmail = '',
    this.isForgotPasswordLoading = false,
    this.isForgotPasswordSuccess = false,
  });

  bool get isPhoneValid =>
      phone.trim().isNotEmpty &&
      phone.replaceAll(RegExp(r'\D'), '').length >= 10;
  bool get isPasswordValid => password.length >= 6;
  bool get isFormValid => isPhoneValid && isPasswordValid;

  DeliveryLoginPageState copyWith({
    DeliveryLoginStatus? status,
    String? phone,
    String? password,
    bool? isPasswordVisible,
    bool? isRememberMeChecked,
    String? errorMessage,
    bool clearError = false,
    bool? isLoggedIn,
    bool? isOnboardingCompleted,
    DeliveryPartnerModel? partner,
    String? phoneError,
    bool clearPhoneError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? forgotPasswordEmail,
    bool? isForgotPasswordLoading,
    bool? isForgotPasswordSuccess,
  }) {
    return DeliveryLoginPageState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRememberMeChecked: isRememberMeChecked ?? this.isRememberMeChecked,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      partner: partner ?? this.partner,
      phoneError:
          clearPhoneError ? null : (phoneError ?? this.phoneError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      forgotPasswordEmail:
          forgotPasswordEmail ?? this.forgotPasswordEmail,
      isForgotPasswordLoading:
          isForgotPasswordLoading ?? this.isForgotPasswordLoading,
      isForgotPasswordSuccess:
          isForgotPasswordSuccess ?? this.isForgotPasswordSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status,
        phone,
        password,
        isPasswordVisible,
        isRememberMeChecked,
        errorMessage,
        isLoggedIn,
        isOnboardingCompleted,
        partner,
        phoneError,
        passwordError,
        forgotPasswordEmail,
        isForgotPasswordLoading,
        isForgotPasswordSuccess,
      ];
}
