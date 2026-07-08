import 'package:equatable/equatable.dart';

abstract class SellerPayoutHistoryEvent extends Equatable {
  const SellerPayoutHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayoutHistory extends SellerPayoutHistoryEvent {
  const LoadPayoutHistory();
}

class RefreshPayoutHistory extends SellerPayoutHistoryEvent {
  const RefreshPayoutHistory();
}

class LoadMorePayoutHistory extends SellerPayoutHistoryEvent {
  const LoadMorePayoutHistory();
}
