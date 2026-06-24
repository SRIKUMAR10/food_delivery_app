import 'package:equatable/equatable.dart';

/// Events for the ForgotPasswordBloc
sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user changes the email input.
class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user attempts to submit the forgot password form.
class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordSubmitted();
}
