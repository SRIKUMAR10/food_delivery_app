import 'package:equatable/equatable.dart';

abstract class SellerForgotPasswordEvent extends Equatable {
  const SellerForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SellerForgotPasswordPhoneChanged extends SellerForgotPasswordEvent {
  final String phone;

  const SellerForgotPasswordPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class SellerForgotPasswordOtpChanged extends SellerForgotPasswordEvent {
  final String otp;

  const SellerForgotPasswordOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class SellerForgotPasswordPasswordChanged extends SellerForgotPasswordEvent {
  final String password;

  const SellerForgotPasswordPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SellerForgotPasswordConfirmPasswordChanged extends SellerForgotPasswordEvent {
  final String confirmPassword;

  const SellerForgotPasswordConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class SellerForgotPasswordTogglePasswordVisibility extends SellerForgotPasswordEvent {
  const SellerForgotPasswordTogglePasswordVisibility();
}

class SellerForgotPasswordToggleConfirmPasswordVisibility extends SellerForgotPasswordEvent {
  const SellerForgotPasswordToggleConfirmPasswordVisibility();
}

class SellerForgotPasswordSendOtpRequested extends SellerForgotPasswordEvent {
  const SellerForgotPasswordSendOtpRequested();
}

class SellerForgotPasswordSubmitted extends SellerForgotPasswordEvent {
  const SellerForgotPasswordSubmitted();
}
