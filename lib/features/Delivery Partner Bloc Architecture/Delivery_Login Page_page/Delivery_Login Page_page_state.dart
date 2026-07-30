import 'package:equatable/equatable.dart';

enum DeliveryLoginStatus { initial, loading, success, error }

class DeliveryLoginPageState extends Equatable {
  final DeliveryLoginStatus status;
  final String phone;
  final String password;
  final bool isPasswordVisible;
  final bool isRememberMeChecked;
  final String? errorMessage;
  final String selectedLanguage;
  final double uploadProgress;
  final bool isLoggedIn;
  final bool isNavigatingToSignUp;

  const DeliveryLoginPageState({
    this.status = DeliveryLoginStatus.initial,
    this.phone = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isRememberMeChecked = false,
    this.errorMessage,
    this.selectedLanguage = 'en',
    this.uploadProgress = 0.0,
    this.isLoggedIn = false,
    this.isNavigatingToSignUp = false,
  });

  bool get isPhoneValid => phone.trim().isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length >= 10;
  bool get isPasswordValid => password.length >= 6;
  bool get isFormValid => isPhoneValid && isPasswordValid;

  DeliveryLoginPageState copyWith({
    DeliveryLoginStatus? status,
    String? phone,
    String? password,
    bool? isPasswordVisible,
    bool? isRememberMeChecked,
    String? errorMessage,
    String? selectedLanguage,
    double? uploadProgress,
    bool? isLoggedIn,
    bool? isNavigatingToSignUp,
  }) {
    return DeliveryLoginPageState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRememberMeChecked: isRememberMeChecked ?? this.isRememberMeChecked,
      errorMessage: errorMessage,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isNavigatingToSignUp: isNavigatingToSignUp ?? this.isNavigatingToSignUp,
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
        selectedLanguage,
        uploadProgress,
        isLoggedIn,
        isNavigatingToSignUp,
      ];
}
