import 'package:equatable/equatable.dart';

abstract class BuyerLoginEvent extends Equatable {
  const BuyerLoginEvent();

  @override
  List<Object?> get props => [];
}

class BuyerLoginPhoneChanged extends BuyerLoginEvent {
  final String phone;
  const BuyerLoginPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class BuyerLoginPasswordChanged extends BuyerLoginEvent {
  final String password;
  const BuyerLoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class BuyerLoginTogglePasswordVisibility extends BuyerLoginEvent {
  const BuyerLoginTogglePasswordVisibility();
}

class BuyerLoginSubmitted extends BuyerLoginEvent {
  final String phone;
  final String password;

  const BuyerLoginSubmitted({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

class BuyerLoginGoogleSubmitted extends BuyerLoginEvent {
  const BuyerLoginGoogleSubmitted();
}

class BuyerLoginAppleSubmitted extends BuyerLoginEvent {
  const BuyerLoginAppleSubmitted();
}
