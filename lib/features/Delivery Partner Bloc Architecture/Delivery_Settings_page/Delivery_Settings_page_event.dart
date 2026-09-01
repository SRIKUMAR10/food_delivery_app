import 'package:equatable/equatable.dart';

abstract class DeliverySettingsEvent extends Equatable {
  const DeliverySettingsEvent();

  @override
  List<Object?> get props => [];
}

class DeliverySettingsInitEvent extends DeliverySettingsEvent {
  const DeliverySettingsInitEvent();
}

class DeliverySettingsStreamUpdatedEvent extends DeliverySettingsEvent {
  final Map<String, dynamic> data;

  const DeliverySettingsStreamUpdatedEvent(this.data);

  @override
  List<Object?> get props => [data];
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

class DeliverySettingsToggleSunModeEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleSunModeEvent();
}

class DeliverySettingsToggleOledModeEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleOledModeEvent();
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

class DeliverySettingsToggleSoundAlertsEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleSoundAlertsEvent();
}

class DeliverySettingsToggleVibrationAlertsEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleVibrationAlertsEvent();
}

class DeliverySettingsToggleHighAccuracyGpsEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleHighAccuracyGpsEvent();
}

class DeliverySettingsToggleBackgroundLocationEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleBackgroundLocationEvent();
}

class DeliverySettingsToggleBiometricLockEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleBiometricLockEvent();
}

class DeliverySettingsToggleTwoFactorAuthEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleTwoFactorAuthEvent();
}

class DeliverySettingsToggleDataSharingEvent extends DeliverySettingsEvent {
  const DeliverySettingsToggleDataSharingEvent();
}

class DeliverySettingsChangePasswordEvent extends DeliverySettingsEvent {
  final String currentPassword;
  final String newPassword;

  const DeliverySettingsChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class DeliverySettingsDeactivateAccountEvent extends DeliverySettingsEvent {
  final String? reason;

  const DeliverySettingsDeactivateAccountEvent({this.reason});

  @override
  List<Object?> get props => [reason];
}

class DeliverySettingsDeleteAccountEvent extends DeliverySettingsEvent {
  final String? reason;

  const DeliverySettingsDeleteAccountEvent({this.reason});

  @override
  List<Object?> get props => [reason];
}

class DeliverySettingsClearCacheEvent extends DeliverySettingsEvent {
  const DeliverySettingsClearCacheEvent();
}

