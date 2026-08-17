import 'package:equatable/equatable.dart';
import 'Delivery_Dashboard_page_state.dart';

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

class DeliveryDashboardChangeStatusEvent extends DeliveryDashboardPageEvent {
  final DeliveryPartnerStatusType status;
  const DeliveryDashboardChangeStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class DeliveryDashboardSetAvailableEvent extends DeliveryDashboardPageEvent {
  final bool isAvailable;
  const DeliveryDashboardSetAvailableEvent(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class DeliveryDashboardSetBusyEvent extends DeliveryDashboardPageEvent {
  final bool isBusy;
  final String? currentOrderId;
  const DeliveryDashboardSetBusyEvent(this.isBusy, {this.currentOrderId});

  @override
  List<Object?> get props => [isBusy, currentOrderId];
}

class DeliveryDashboardAutoOfflineEvent extends DeliveryDashboardPageEvent {
  const DeliveryDashboardAutoOfflineEvent();
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
