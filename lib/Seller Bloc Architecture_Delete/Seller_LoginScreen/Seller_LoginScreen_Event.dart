import 'package:equatable/equatable.dart';

/// Events for the SellerLoginBloc
sealed class SellerLoginEvent extends Equatable {
  const SellerLoginEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user changes the email input.
class SellerLoginEmailChanged extends SellerLoginEvent {
  final String email;
  const SellerLoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user changes the password input.
class SellerLoginPasswordChanged extends SellerLoginEvent {
  final String password;
  const SellerLoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Dispatched when the user toggles the password visibility.
class SellerLoginPasswordVisibilityToggled extends SellerLoginEvent {
  const SellerLoginPasswordVisibilityToggled();
}

/// Dispatched when the user attempts to submit the login form.
class SellerLoginSubmitted extends SellerLoginEvent {
  const SellerLoginSubmitted();
}
