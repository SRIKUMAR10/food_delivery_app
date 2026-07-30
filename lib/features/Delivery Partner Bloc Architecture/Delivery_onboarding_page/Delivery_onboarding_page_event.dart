import 'package:equatable/equatable.dart';

abstract class DeliveryOnboardingPageEvent extends Equatable {
  const DeliveryOnboardingPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryOnboardingInitEvent extends DeliveryOnboardingPageEvent {
  const DeliveryOnboardingInitEvent();
}

class DeliveryOnboardingLanguageChangedEvent
    extends DeliveryOnboardingPageEvent {
  final String languageCode;

  const DeliveryOnboardingLanguageChangedEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class DeliveryOnboardingGetStartedClickedEvent
    extends DeliveryOnboardingPageEvent {
  const DeliveryOnboardingGetStartedClickedEvent();
}

class DeliveryOnboardingLoginClickedEvent
    extends DeliveryOnboardingPageEvent {
  const DeliveryOnboardingLoginClickedEvent();
}

class DeliveryOnboardingRefreshEvent extends DeliveryOnboardingPageEvent {
  const DeliveryOnboardingRefreshEvent();
}

class DeliveryOnboardingSimulateVideoUploadEvent
    extends DeliveryOnboardingPageEvent {
  final String videoPath;

  const DeliveryOnboardingSimulateVideoUploadEvent(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}
