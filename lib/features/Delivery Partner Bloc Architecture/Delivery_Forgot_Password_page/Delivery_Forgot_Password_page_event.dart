import 'package:equatable/equatable.dart';

abstract class DeliveryForgotPasswordEvent extends Equatable {
  const DeliveryForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryForgotPasswordPhoneChanged extends DeliveryForgotPasswordEvent {
  final String phone;
  const DeliveryForgotPasswordPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DeliveryForgotPasswordOtpChanged extends DeliveryForgotPasswordEvent {
  final String otp;
  const DeliveryForgotPasswordOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class DeliveryForgotPasswordPasswordChanged extends DeliveryForgotPasswordEvent {
  final String password;
  const DeliveryForgotPasswordPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class DeliveryForgotPasswordConfirmPasswordChanged extends DeliveryForgotPasswordEvent {
  final String confirmPassword;
  const DeliveryForgotPasswordConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class DeliveryForgotPasswordTogglePasswordVisibility extends DeliveryForgotPasswordEvent {
  const DeliveryForgotPasswordTogglePasswordVisibility();
}

class DeliveryForgotPasswordToggleConfirmPasswordVisibility extends DeliveryForgotPasswordEvent {
  const DeliveryForgotPasswordToggleConfirmPasswordVisibility();
}

class DeliveryForgotPasswordSendOtpRequested extends DeliveryForgotPasswordEvent {
  const DeliveryForgotPasswordSendOtpRequested();
}

class DeliveryForgotPasswordSubmitted extends DeliveryForgotPasswordEvent {
  const DeliveryForgotPasswordSubmitted();
}
