import 'package:equatable/equatable.dart';

abstract class BuyerForgotPasswordEvent extends Equatable {
  const BuyerForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class BuyerForgotPasswordPhoneChanged extends BuyerForgotPasswordEvent {
  final String phone;
  const BuyerForgotPasswordPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class BuyerForgotPasswordOtpChanged extends BuyerForgotPasswordEvent {
  final String otp;
  const BuyerForgotPasswordOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class BuyerForgotPasswordPasswordChanged extends BuyerForgotPasswordEvent {
  final String password;
  const BuyerForgotPasswordPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class BuyerForgotPasswordConfirmPasswordChanged extends BuyerForgotPasswordEvent {
  final String confirmPassword;
  const BuyerForgotPasswordConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class BuyerForgotPasswordTogglePasswordVisibility extends BuyerForgotPasswordEvent {
  const BuyerForgotPasswordTogglePasswordVisibility();
}

class BuyerForgotPasswordToggleConfirmPasswordVisibility extends BuyerForgotPasswordEvent {
  const BuyerForgotPasswordToggleConfirmPasswordVisibility();
}

class BuyerForgotPasswordSendOtpRequested extends BuyerForgotPasswordEvent {
  const BuyerForgotPasswordSendOtpRequested();
}

class BuyerForgotPasswordSubmitted extends BuyerForgotPasswordEvent {
  const BuyerForgotPasswordSubmitted();
}

