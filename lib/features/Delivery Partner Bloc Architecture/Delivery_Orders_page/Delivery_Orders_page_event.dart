import 'package:equatable/equatable.dart';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersPageEvent extends Equatable {
  const DeliveryOrdersPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryOrdersInitEvent extends DeliveryOrdersPageEvent {
  const DeliveryOrdersInitEvent();
}

class DeliveryOrdersTabChangedEvent extends DeliveryOrdersPageEvent {
  final DeliveryOrdersTab tab;

  const DeliveryOrdersTabChangedEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class DeliveryOrdersSearchQueryChangedEvent extends DeliveryOrdersPageEvent {
  final String query;

  const DeliveryOrdersSearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeliveryOrdersRefreshEvent extends DeliveryOrdersPageEvent {
  const DeliveryOrdersRefreshEvent();
}

class DeliveryOrdersUpdateStatusEvent extends DeliveryOrdersPageEvent {
  final String orderId;
  final DeliveryOrderStatus status;

  const DeliveryOrdersUpdateStatusEvent({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class DeliveryOrdersSortChangedEvent extends DeliveryOrdersPageEvent {
  final DeliveryOrdersSort sortBy;

  const DeliveryOrdersSortChangedEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class DeliveryOrdersPaymentFilterChangedEvent extends DeliveryOrdersPageEvent {
  final DeliveryOrdersPaymentFilter paymentFilter;

  const DeliveryOrdersPaymentFilterChangedEvent(this.paymentFilter);

  @override
  List<Object?> get props => [paymentFilter];
}

class DeliveryOrdersAutoRefreshToggledEvent extends DeliveryOrdersPageEvent {
  final bool enabled;

  const DeliveryOrdersAutoRefreshToggledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
