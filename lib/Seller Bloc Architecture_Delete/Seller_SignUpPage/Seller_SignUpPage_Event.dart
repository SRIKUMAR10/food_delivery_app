import 'package:equatable/equatable.dart';

/// Events for the SellerSignUpBloc
sealed class SellerSignUpEvent extends Equatable {
  const SellerSignUpEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user changes the name input.
class SellerSignUpNameChanged extends SellerSignUpEvent {
  final String name;
  const SellerSignUpNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// Dispatched when the user changes the email input.
class SellerSignUpEmailChanged extends SellerSignUpEvent {
  final String email;
  const SellerSignUpEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user changes the password input.
class SellerSignUpPasswordChanged extends SellerSignUpEvent {
  final String password;
  const SellerSignUpPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Dispatched when the user toggles the password visibility.
class SellerSignUpPasswordVisibilityToggled extends SellerSignUpEvent {
  const SellerSignUpPasswordVisibilityToggled();
}

/// Dispatched when the user attempts to submit the sign up form.
class SellerSignUpSubmitted extends SellerSignUpEvent {
  const SellerSignUpSubmitted();
}
