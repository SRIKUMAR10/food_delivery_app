import 'package:equatable/equatable.dart';

enum BuyerOtpStatus { initial, loading, success, failure }

class BuyerOtpState extends Equatable {
  final BuyerOtpStatus status;
  final String? errorMessage;

  const BuyerOtpState({
    this.status = BuyerOtpStatus.initial,
    this.errorMessage,
  });

  BuyerOtpState copyWith({
    BuyerOtpStatus? status,
    String? errorMessage,
  }) {
    return BuyerOtpState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
