import 'package:equatable/equatable.dart';

abstract class DeliveryLoginPageEvent extends Equatable {
  const DeliveryLoginPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryLoginInitEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginInitEvent();
}

class DeliveryLoginPhoneChangedEvent extends DeliveryLoginPageEvent {
  final String phone;
  const DeliveryLoginPhoneChangedEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DeliveryLoginPasswordChangedEvent extends DeliveryLoginPageEvent {
  final String password;
  const DeliveryLoginPasswordChangedEvent(this.password);

  @override
  List<Object?> get props => [password];
}

class DeliveryLoginTogglePasswordVisibilityEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginTogglePasswordVisibilityEvent();
}

class DeliveryLoginToggleRememberMeEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginToggleRememberMeEvent();
}

class DeliveryLoginSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginSubmittedEvent();
}

class DeliveryLoginGoogleSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginGoogleSubmittedEvent();
}

class DeliveryLoginAppleSubmittedEvent extends DeliveryLoginPageEvent {
  const DeliveryLoginAppleSubmittedEvent();
}

class DeliveryLoginLanguageChangedEvent extends DeliveryLoginPageEvent {
  final String languageCode;
  const DeliveryLoginLanguageChangedEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class DeliveryLoginSimulateVideoUploadEvent extends DeliveryLoginPageEvent {
  final String videoPath;
  const DeliveryLoginSimulateVideoUploadEvent(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}
