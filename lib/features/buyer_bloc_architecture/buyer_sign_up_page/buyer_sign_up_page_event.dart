import 'package:equatable/equatable.dart';

abstract class BuyerSignUpEvent extends Equatable {
  const BuyerSignUpEvent();

  @override
  List<Object?> get props => [];
}

class BuyerSignUpSubmitted extends BuyerSignUpEvent {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String confirmPassword;

  const BuyerSignUpSubmitted({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        mobileNumber,
        password,
        confirmPassword,
      ];
}

class BuyerSignUpTogglePasswordVisibility extends BuyerSignUpEvent {
  const BuyerSignUpTogglePasswordVisibility();
}

class BuyerSignUpToggleConfirmPasswordVisibility extends BuyerSignUpEvent {
  const BuyerSignUpToggleConfirmPasswordVisibility();
}
