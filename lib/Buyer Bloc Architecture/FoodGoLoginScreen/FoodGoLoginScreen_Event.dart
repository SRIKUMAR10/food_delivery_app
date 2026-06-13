import 'package:equatable/equatable.dart';

/// Events for the FoodGoLoginBloc
sealed class FoodGoLoginEvent extends Equatable {
  const FoodGoLoginEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user changes the email input.
class LoginEmailChanged extends FoodGoLoginEvent {
  final String email;
  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user changes the password input.
class LoginPasswordChanged extends FoodGoLoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Dispatched when the user taps the visibility icon on the password field.
class LoginPasswordVisibilityToggled extends FoodGoLoginEvent {
  const LoginPasswordVisibilityToggled();
}

/// Dispatched when the user attempts to submit the login form.
class LoginSubmitted extends FoodGoLoginEvent {
  const LoginSubmitted();
}
