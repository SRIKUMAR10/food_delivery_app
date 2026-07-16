import 'disputes_refunds_page_model.dart';

abstract class DisputesRefundsState {}

class DisputesRefundsInitial extends DisputesRefundsState {}

class DisputesRefundsLoading extends DisputesRefundsState {}

class DisputesRefundsLoaded extends DisputesRefundsState {
  final List<DisputeModel> disputes;
  final Set<String> processingIds;
  final String? successMessage;
  final String? errorMessage;

  DisputesRefundsLoaded({
    required this.disputes,
    this.processingIds = const {},
    this.successMessage,
    this.errorMessage,
  });

  DisputesRefundsLoaded copyWith({
    List<DisputeModel>? disputes,
    Set<String>? processingIds,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return DisputesRefundsLoaded(
      disputes: disputes ?? this.disputes,
      processingIds: processingIds ?? this.processingIds,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DisputesRefundsError extends DisputesRefundsState {
  final String message;
  DisputesRefundsError(this.message);
}
