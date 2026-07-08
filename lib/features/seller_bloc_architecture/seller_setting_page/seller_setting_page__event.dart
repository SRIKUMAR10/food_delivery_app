import 'package:equatable/equatable.dart';

abstract class SellerSettingEvent extends Equatable {
  const SellerSettingEvent();

  @override
  List<Object> get props => [];
}

class LoadSellerSettings extends SellerSettingEvent {}

class UpdatePushNotifications extends SellerSettingEvent {
  final bool enabled;

  const UpdatePushNotifications(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateNewOrderSound extends SellerSettingEvent {
  final bool enabled;

  const UpdateNewOrderSound(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdatePromoAndOffers extends SellerSettingEvent {
  final bool enabled;

  const UpdatePromoAndOffers(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateLowStockAlerts extends SellerSettingEvent {
  final bool enabled;

  const UpdateLowStockAlerts(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateOrderUpdates extends SellerSettingEvent {
  final bool enabled;

  const UpdateOrderUpdates(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateAppTheme extends SellerSettingEvent {
  final String theme;

  const UpdateAppTheme(this.theme);

  @override
  List<Object> get props => [theme];
}

class UpdateLanguage extends SellerSettingEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object> get props => [language];
}
