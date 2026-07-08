import 'package:equatable/equatable.dart';
import '../seller_wallet_page/seller_wallet_page__state.dart';

abstract class SellerPayoutHistoryState extends Equatable {
  const SellerPayoutHistoryState();

  @override
  List<Object?> get props => [];
}

class SellerPayoutHistoryInitial extends SellerPayoutHistoryState {
  const SellerPayoutHistoryInitial();
}

class SellerPayoutHistoryLoading extends SellerPayoutHistoryState {
  const SellerPayoutHistoryLoading();
}

class SellerPayoutHistoryLoaded extends SellerPayoutHistoryState {
  final List<PayoutItem> payouts;
  final bool hasReachedMax;
  final bool isPaginatedLoading;

  const SellerPayoutHistoryLoaded({
    required this.payouts,
    this.hasReachedMax = false,
    this.isPaginatedLoading = false,
  });

  SellerPayoutHistoryLoaded copyWith({
    List<PayoutItem>? payouts,
    bool? hasReachedMax,
    bool? isPaginatedLoading,
  }) {
    return SellerPayoutHistoryLoaded(
      payouts: payouts ?? this.payouts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginatedLoading: isPaginatedLoading ?? this.isPaginatedLoading,
    );
  }

  @override
  List<Object?> get props => [payouts, hasReachedMax, isPaginatedLoading];
}

class SellerPayoutHistoryError extends SellerPayoutHistoryState {
  final String message;
  const SellerPayoutHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
