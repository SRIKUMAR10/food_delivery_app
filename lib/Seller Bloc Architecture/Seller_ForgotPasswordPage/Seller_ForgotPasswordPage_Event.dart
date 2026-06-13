import 'package:equatable/equatable.dart';

/// Events for the SellerForgotPasswordBloc
sealed class SellerForgotPasswordEvent extends Equatable {
  const SellerForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user changes the email input.
class SellerForgotPasswordEmailChanged extends SellerForgotPasswordEvent {
  final String email;
  const SellerForgotPasswordEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user attempts to submit the forgot password form.
class SellerForgotPasswordSubmitted extends SellerForgotPasswordEvent {
  const SellerForgotPasswordSubmitted();
}
