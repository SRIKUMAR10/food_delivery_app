import 'package:equatable/equatable.dart';

abstract class DeliveryForgotPasswordEvent extends Equatable {
  const DeliveryForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryForgotPasswordEmailChanged extends DeliveryForgotPasswordEvent {
  final String email;
  const DeliveryForgotPasswordEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class DeliveryForgotPasswordSubmitted extends DeliveryForgotPasswordEvent {
  const DeliveryForgotPasswordSubmitted();
}
