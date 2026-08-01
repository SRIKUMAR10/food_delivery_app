import 'package:equatable/equatable.dart';

abstract class DeliveryNavigationBarEvent extends Equatable {
  const DeliveryNavigationBarEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryNavigationBarInitEvent extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarInitEvent();
}

class DeliveryNavigationBarTabChangedEvent extends DeliveryNavigationBarEvent {
  final int index;

  const DeliveryNavigationBarTabChangedEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class DeliveryNavigationBarContactSupportClickedEvent
    extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarContactSupportClickedEvent();
}

class DeliveryNavigationBarRefreshEvent extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarRefreshEvent();
}

class DeliveryNavigationBarSimulateUploadEvent
    extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarSimulateUploadEvent();
}

class DeliveryNavigationBarPermissionRequestedEvent
    extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarPermissionRequestedEvent();
}

class DeliveryNavigationBarLocaleChangedEvent
    extends DeliveryNavigationBarEvent {
  final String localeCode;

  const DeliveryNavigationBarLocaleChangedEvent(this.localeCode);

  @override
  List<Object?> get props => [localeCode];
}
class DeliveryNavigationBarLogoutRequestedEvent extends DeliveryNavigationBarEvent {
  const DeliveryNavigationBarLogoutRequestedEvent();
}
