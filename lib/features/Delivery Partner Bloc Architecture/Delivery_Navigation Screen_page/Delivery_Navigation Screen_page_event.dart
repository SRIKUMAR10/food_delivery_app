import 'package:equatable/equatable.dart';
import 'Delivery_Navigation Screen_page_state.dart';

abstract class DeliveryNavigationEvent extends Equatable {
  const DeliveryNavigationEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryNavigationInitEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationInitEvent();
}

class DeliveryNavigationStartNavigationEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationStartNavigationEvent();
}

class DeliveryNavigationExitNavigationEvent extends DeliveryNavigationEvent {
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

class DeliveryNavigationLocationUpdatedEvent extends DeliveryNavigationEvent {
  final double lat;
  final double lng;
  final double heading;
  final double speed;
  final DateTime timestamp;

  const DeliveryNavigationLocationUpdatedEvent({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [lat, lng, heading, speed, timestamp];
}

class DeliveryNavigationStageChangedEvent extends DeliveryNavigationEvent {
  final NavigationStage stage;

  const DeliveryNavigationStageChangedEvent(this.stage);

  @override
  List<Object?> get props => [stage];
}

class DeliveryNavigationGpsStatusChangedEvent extends DeliveryNavigationEvent {
  final DeliveryGpsStatus status;

  const DeliveryNavigationGpsStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class DeliveryNavigationPermissionStatusChangedEvent
    extends DeliveryNavigationEvent {
  final bool hasPermission;

  const DeliveryNavigationPermissionStatusChangedEvent(this.hasPermission);

  @override
  List<Object?> get props => [hasPermission];
}

class DeliveryNavigationOrderUpdatedEvent extends DeliveryNavigationEvent {
  final Map<String, dynamic>? orderData;

  const DeliveryNavigationOrderUpdatedEvent(this.orderData);

  @override
  List<Object?> get props => [orderData];
}

class DeliveryNavigationArrivedAtPickupEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationArrivedAtPickupEvent();
}

class DeliveryNavigationConfirmPickupEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationConfirmPickupEvent();
}

class DeliveryNavigationArrivedAtCustomerEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationArrivedAtCustomerEvent();
}

class DeliveryNavigationConfirmDeliveryEvent extends DeliveryNavigationEvent {
  const DeliveryNavigationConfirmDeliveryEvent();
}

class DeliveryNavigationProfileUpdatedEvent extends DeliveryNavigationEvent {
  final Map<String, dynamic> profile;

  const DeliveryNavigationProfileUpdatedEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
