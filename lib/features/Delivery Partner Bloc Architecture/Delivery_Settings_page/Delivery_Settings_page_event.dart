import 'package:equatable/equatable.dart';

abstract class DeliverySettingsEvent extends Equatable {
  const DeliverySettingsEvent();

  @override
  List<Object?> get props => [];
}

class DeliverySettingsInitEvent extends DeliverySettingsEvent {
  const DeliverySettingsInitEvent();
}

class DeliverySettingsToggleNotificationEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleNotificationEvent();
}

class DeliverySettingsToggleAutoAcceptEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleAutoAcceptEvent();
}

class DeliverySettingsToggleDarkModeEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleDarkModeEvent();
}

class DeliverySettingsUpdateRadiusEvent extends DeliverySettingsEvent {
  final double radius;

  const DeliverySettingsUpdateRadiusEvent(this.radius);

  @override
  List<Object?> get props => [radius];
}

class DeliverySettingsChangeLanguageEvent extends DeliverySettingsEvent {
  final String languageCode;

  const DeliverySettingsChangeLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class DeliverySettingsSaveEvent extends DeliverySettingsEvent {
  const DeliverySettingsSaveEvent();
}

class DeliverySettingsRetryEvent extends DeliverySettingsEvent {
  const DeliverySettingsRetryEvent();
}
