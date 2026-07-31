import 'package:equatable/equatable.dart';
import 'Delivery_Order History_page_state.dart';

abstract class DeliveryOrderHistoryPageEvent extends Equatable {
  const DeliveryOrderHistoryPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryOrderHistoryInitEvent extends DeliveryOrderHistoryPageEvent {
  const DeliveryOrderHistoryInitEvent();
}

class DeliveryOrderHistorySearchChangedEvent
    extends DeliveryOrderHistoryPageEvent {
  final String query;

  const DeliveryOrderHistorySearchChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeliveryOrderHistoryStatusFilterChangedEvent
    extends DeliveryOrderHistoryPageEvent {
  final DeliveryOrderHistoryStatusFilter filter;

  const DeliveryOrderHistoryStatusFilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryOrderHistoryDateRangeChangedEvent
    extends DeliveryOrderHistoryPageEvent {
  final int? startEpoch;
  final int? endEpoch;
  final String dateLabel;

  const DeliveryOrderHistoryDateRangeChangedEvent({
    this.startEpoch,
    this.endEpoch,
    this.dateLabel = 'May 18, 2025 - May 24, 2025',
  });

  @override
  List<Object?> get props => [startEpoch, endEpoch, dateLabel];
}

class DeliveryOrderHistoryPaymentFilterChangedEvent
    extends DeliveryOrderHistoryPageEvent {
  final DeliveryOrderHistoryPaymentFilter filter;

  const DeliveryOrderHistoryPaymentFilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryOrderHistoryPageChangedEvent extends DeliveryOrderHistoryPageEvent {
  final int page;

  const DeliveryOrderHistoryPageChangedEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class DeliveryOrderHistoryPageSizeChangedEvent
    extends DeliveryOrderHistoryPageEvent {
  final int pageSize;

  const DeliveryOrderHistoryPageSizeChangedEvent(this.pageSize);

  @override
  List<Object?> get props => [pageSize];
}

class DeliveryOrderHistoryRefreshEvent extends DeliveryOrderHistoryPageEvent {
  const DeliveryOrderHistoryRefreshEvent();
}

class DeliveryOrderHistoryToggleSidebarEvent
    extends DeliveryOrderHistoryPageEvent {
  const DeliveryOrderHistoryToggleSidebarEvent();
}
