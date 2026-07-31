import 'package:equatable/equatable.dart';

abstract class DeliveryDashboardPageEvent extends Equatable {
  const DeliveryDashboardPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryDashboardInitEvent extends DeliveryDashboardPageEvent {
  const DeliveryDashboardInitEvent();
}

class DeliveryDashboardToggleOnlineEvent extends DeliveryDashboardPageEvent {
  final bool isOnline;
  const DeliveryDashboardToggleOnlineEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class DeliveryDashboardRefreshEvent extends DeliveryDashboardPageEvent {
  const DeliveryDashboardRefreshEvent();
}

class DeliveryDashboardFilterActivityEvent extends DeliveryDashboardPageEvent {
  final String filter;
  const DeliveryDashboardFilterActivityEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryDashboardQuickActionExecutedEvent extends DeliveryDashboardPageEvent {
  final String actionId;
  const DeliveryDashboardQuickActionExecutedEvent(this.actionId);

  @override
  List<Object?> get props => [actionId];
}
