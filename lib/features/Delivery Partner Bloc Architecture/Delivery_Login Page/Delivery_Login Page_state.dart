import 'package:equatable/equatable.dart';

enum DeliveryLoginStatus { initial, loading, success, error }

class DeliveryLoginPageState extends Equatable {
  final DeliveryLoginStatus status;
  final String phone;
  final String password;
  final bool isPasswordVisible;
  final bool isRememberMeChecked;
  final String? errorMessage;
  final bool isLoggedIn;

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
        phoneError,
        passwordError,
        forgotPasswordEmail,
        isForgotPasswordLoading,
        isForgotPasswordSuccess,
      ];
}
