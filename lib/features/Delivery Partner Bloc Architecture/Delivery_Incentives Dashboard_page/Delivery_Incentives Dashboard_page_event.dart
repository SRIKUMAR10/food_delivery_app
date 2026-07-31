import 'package:equatable/equatable.dart';
import 'Delivery_Incentives Dashboard_page_state.dart';

abstract class DeliveryIncentivesDashboardPageEvent extends Equatable {
  const DeliveryIncentivesDashboardPageEvent();

  @override
  List<Object?> get props => [];
}

class FetchIncentivesDataEvent extends DeliveryIncentivesDashboardPageEvent {
  const FetchIncentivesDataEvent();
}

class RefreshIncentivesDataEvent extends DeliveryIncentivesDashboardPageEvent {
  const RefreshIncentivesDataEvent();
}

class FilterRewardHistoryEvent extends DeliveryIncentivesDashboardPageEvent {
  final RewardFilterType filter;
  const FilterRewardHistoryEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ChangePageEvent extends DeliveryIncentivesDashboardPageEvent {
  final int page;
  const ChangePageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class ExportRewardHistoryEvent extends DeliveryIncentivesDashboardPageEvent {
  const ExportRewardHistoryEvent();
}

class UpdateDateRangeEvent extends DeliveryIncentivesDashboardPageEvent {
  final IncentivesDateRange range;
  const UpdateDateRangeEvent(this.range);

  @override
  List<Object?> get props => [range];
}
