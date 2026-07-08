import 'package:equatable/equatable.dart';

abstract class SellerForgotPasswordEvent extends Equatable {
  const SellerForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class SellerForgotPasswordEmailChanged extends SellerForgotPasswordEvent {
  final String email;

  const SellerForgotPasswordEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class SellerForgotPasswordSubmitted extends SellerForgotPasswordEvent {
  const SellerForgotPasswordSubmitted();
}
