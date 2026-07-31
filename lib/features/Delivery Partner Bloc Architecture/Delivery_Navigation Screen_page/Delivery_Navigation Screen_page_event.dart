import 'package:equatable/equatable.dart';

abstract class DeliveryNavigationEvent extends Equatable {
  const DeliveryNavigationEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryNavigationInitEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationInitEvent();
}

class DeliveryNavigationStartNavigationEvent
    extends DeliveryNavigationEvent {
  const DeliveryNavigationStartNavigationEvent();
}

class DeliveryNavigationExitNavigationEvent
    extends DeliveryNavigationEvent {
  const DeliveryNavigationExitNavigationEvent();
}

class DeliveryNavigationRecenterMapEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationRecenterMapEvent();
}

class DeliveryNavigationToggleAudioEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationToggleAudioEvent();
}

class DeliveryNavigationSOSClickedEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationSOSClickedEvent();
}

class DeliveryNavigationRefreshEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationRefreshEvent();
}

class DeliveryNavigationLocaleChangedEvent extends DeliveryNavigationEvent {
  final String localeCode;

  const DeliveryNavigationLocaleChangedEvent(this.localeCode);

  @override
  List<Object?> get props => [localeCode];
}

class DeliveryNavigationLocationTickEvent extends DeliveryNavigationEvent {
  final double deltaMeters;

  const DeliveryNavigationLocationTickEvent(this.deltaMeters);

  @override
  List<Object?> get props => [deltaMeters];
}

class DeliveryNavigationToggleMapEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationToggleMapEvent();
}
