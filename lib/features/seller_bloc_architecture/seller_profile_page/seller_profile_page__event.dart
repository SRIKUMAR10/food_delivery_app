import 'package:equatable/equatable.dart';

abstract class SellerProfilePageEvent extends Equatable {
  const SellerProfilePageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends SellerProfilePageEvent {}

class LogoutRequested extends SellerProfilePageEvent {}

class NotificationSettingsChanged extends SellerProfilePageEvent {
  final bool isEnabled;

  const NotificationSettingsChanged(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}
