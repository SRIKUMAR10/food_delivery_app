import 'package:equatable/equatable.dart';

abstract class DeliveryLoginPageEvent extends Equatable {
  const DeliveryLoginPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryLoginInitEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginInitEvent();
}

class DeliveryLoginPhoneChangedEvent extends DeliveryLoginPageEvent {
  final String phone;
  const DeliveryLoginPhoneChangedEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DeliveryLoginPasswordChangedEvent extends DeliveryLoginPageEvent {
  final String password;
  const DeliveryLoginPasswordChangedEvent(this.password);

  @override
  List<Object?> get props => [password];
}

class DeliveryLoginTogglePasswordVisibilityEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginTogglePasswordVisibilityEvent();
}

class DeliveryLoginToggleRememberMeEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginToggleRememberMeEvent();
}

class DeliveryLoginSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginSubmittedEvent();
}

class DeliveryLoginGoogleSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginGoogleSubmittedEvent();
}

class DeliveryLoginAppleSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginAppleSubmittedEvent();
}

class DeliveryLoginForgotPasswordSubmittedEvent extends DeliveryLoginPageEvent {
  final String email;
  const DeliveryLoginForgotPasswordSubmittedEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class DeliveryLoginNavigateToSignUpEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginNavigateToSignUpEvent();
}
