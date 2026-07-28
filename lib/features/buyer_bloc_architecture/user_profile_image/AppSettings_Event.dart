import 'package:equatable/equatable.dart';

abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object> get props => [];
}

class AppSettingsLoadStarted extends AppSettingsEvent {
  const AppSettingsLoadStarted();
}

class PushNotificationToggled extends AppSettingsEvent {
  final bool enabled;
  const PushNotificationToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class OrderNotificationToggled extends AppSettingsEvent {
  final bool enabled;
  const OrderNotificationToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class OfferNotificationToggled extends AppSettingsEvent {
  final bool enabled;
  const OfferNotificationToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class ChatNotificationToggled extends AppSettingsEvent {
  final bool enabled;
  const ChatNotificationToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class NotificationSoundToggled extends AppSettingsEvent {
  final bool enabled;
  const NotificationSoundToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class VibrationToggled extends AppSettingsEvent {
  final bool enabled;
  const VibrationToggled(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class ThemeChanged extends AppSettingsEvent {
  final String theme;
  const ThemeChanged(this.theme);
  @override
  List<Object> get props => [theme];
}

class LanguageChanged extends AppSettingsEvent {
  final String language;
  const LanguageChanged(this.language);
  @override
  List<Object> get props => [language];
}

class ClearCacheRequested extends AppSettingsEvent {
  const ClearCacheRequested();
}

class DeleteAccountRequested extends AppSettingsEvent {
  final String password;
  const DeleteAccountRequested(this.password);
  @override
  List<Object> get props => [password];
}

class LogoutRequested extends AppSettingsEvent {
  const LogoutRequested();
}

class AppSettingsErrorDismissed extends AppSettingsEvent {
  const AppSettingsErrorDismissed();
}

class AppSettingsRetryRequested extends AppSettingsEvent {
  const AppSettingsRetryRequested();
}
