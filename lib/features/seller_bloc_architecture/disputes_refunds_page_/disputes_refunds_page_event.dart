abstract class DisputesRefundsEvent {}

class LoadDisputesEvent extends DisputesRefundsEvent {
  final String sellerId;
  LoadDisputesEvent(this.sellerId);
}

class ApproveRefundEvent extends DisputesRefundsEvent {
  final String disputeId;
  ApproveRefundEvent(this.disputeId);
}

class DeclineRefundEvent extends DisputesRefundsEvent {
  final String disputeId;
  DeclineRefundEvent(this.disputeId);
}
