import 'package:equatable/equatable.dart';

abstract class DeliveryOtpVerificationEvent extends Equatable {
  const DeliveryOtpVerificationEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryOtpChangedEvent extends DeliveryOtpVerificationEvent {
  final String otp;

  const DeliveryOtpChangedEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

class DeliveryOtpVerifySubmittedEvent extends DeliveryOtpVerificationEvent {
  const DeliveryOtpVerifySubmittedEvent();
}

class DeliveryOtpResendRequestedEvent extends DeliveryOtpVerificationEvent {
  const DeliveryOtpResendRequestedEvent();
}

class DeliveryOtpTimerTickedEvent extends DeliveryOtpVerificationEvent {
  final int duration;

  const DeliveryOtpTimerTickedEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}
