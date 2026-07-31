import 'package:equatable/equatable.dart';

abstract class DeliverySignUpPageEvent extends Equatable {
  const DeliverySignUpPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliverySignUpInitEvent extends DeliverySignUpPageEvent {
  const DeliverySignUpInitEvent();
}

class DeliverySignUpNameChanged extends DeliverySignUpPageEvent {
  final String name;
  const DeliverySignUpNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class DeliverySignUpPhoneChanged extends DeliverySignUpPageEvent {
  final String phone;
  const DeliverySignUpPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class DeliverySignUpEmailChanged extends DeliverySignUpPageEvent {
  final String email;
  const DeliverySignUpEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class DeliverySignUpPasswordChanged extends DeliverySignUpPageEvent {
  final String password;
  const DeliverySignUpPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class DeliverySignUpConfirmPasswordChanged extends DeliverySignUpPageEvent {
  final String confirmPassword;
  const DeliverySignUpConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

class DeliverySignUpPasswordVisibilityToggled
    extends DeliverySignUpPageEvent {
  const DeliverySignUpPasswordVisibilityToggled();
}

class DeliverySignUpConfirmPasswordVisibilityToggled
    extends DeliverySignUpPageEvent {
  const DeliverySignUpConfirmPasswordVisibilityToggled();
}

class DeliverySignUpTermsToggled extends DeliverySignUpPageEvent {
  const DeliverySignUpTermsToggled();
}

class DeliverySignUpSubmitted extends DeliverySignUpPageEvent {
  const DeliverySignUpSubmitted();
}

class DeliverySignUpBackPressed extends DeliverySignUpPageEvent {
  const DeliverySignUpBackPressed();
}

class DeliverySignUpLoginNavigated extends DeliverySignUpPageEvent {
  const DeliverySignUpLoginNavigated();
}
