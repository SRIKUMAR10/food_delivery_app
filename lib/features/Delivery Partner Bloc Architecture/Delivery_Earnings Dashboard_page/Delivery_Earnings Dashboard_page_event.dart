import 'package:equatable/equatable.dart';
import 'Delivery_Earnings Dashboard_page_state.dart';

abstract class DeliveryEarningsDashboardPageEvent extends Equatable {
  const DeliveryEarningsDashboardPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryEarningsInitEvent extends DeliveryEarningsDashboardPageEvent {
  const DeliveryEarningsInitEvent();
}

class DeliveryEarningsRefreshEvent extends DeliveryEarningsDashboardPageEvent {
  const DeliveryEarningsRefreshEvent();
}

class DeliveryEarningsRangeChangedEvent
    extends DeliveryEarningsDashboardPageEvent {
  final EarningsDateRange range;
  const DeliveryEarningsRangeChangedEvent(this.range);

  @override
  List<Object?> get props => [range];
}

class DeliveryEarningsTabChangedEvent
    extends DeliveryEarningsDashboardPageEvent {
  final EarningsTab tab;
  const DeliveryEarningsTabChangedEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class DeliveryEarningsWithdrawEvent
    extends DeliveryEarningsDashboardPageEvent {
  final double amount;
  const DeliveryEarningsWithdrawEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class DeliveryEarningsSubmitCashEvent
    extends DeliveryEarningsDashboardPageEvent {
  final double amount;
  final String method;
  const DeliveryEarningsSubmitCashEvent({
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [amount, method];
}

class DeliveryEarningsMediaUploadStartedEvent
    extends DeliveryEarningsDashboardPageEvent {
  const DeliveryEarningsMediaUploadStartedEvent();
}

class DeliveryEarningsMediaUploadProgressEvent
    extends DeliveryEarningsDashboardPageEvent {
  final double progress;
  const DeliveryEarningsMediaUploadProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DeliveryEarningsMediaUploadCompletedEvent
    extends DeliveryEarningsDashboardPageEvent {
  const DeliveryEarningsMediaUploadCompletedEvent();
}
