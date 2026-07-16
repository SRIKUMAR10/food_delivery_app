import 'package:flutter_bloc/flutter_bloc.dart';
import 'disputes_refunds_page_event.dart';
import 'disputes_refunds_page_state.dart';
import 'disputes_refunds_page_repository.dart';

class DisputesRefundsBloc extends Bloc<DisputesRefundsEvent, DisputesRefundsState> {
  final DisputesRefundsRepository repository;
  String? _sellerId;

  DisputesRefundsBloc({required this.repository}) : super(DisputesRefundsInitial()) {
    on<LoadDisputesEvent>(_onLoadDisputes);
    on<ApproveRefundEvent>(_onApproveRefund);
    on<DeclineRefundEvent>(_onDeclineRefund);
  }

  Future<void> _onLoadDisputes(LoadDisputesEvent event, Emitter<DisputesRefundsState> emit) async {
    _sellerId = event.sellerId;
    emit(DisputesRefundsLoading());
    try {
      final disputes = await repository.getDisputes(event.sellerId);
      emit(DisputesRefundsLoaded(disputes: disputes));
    } catch (e) {
      emit(DisputesRefundsError('Failed to load disputes: $e'));
    }
  }

  Future<void> _onApproveRefund(ApproveRefundEvent event, Emitter<DisputesRefundsState> emit) async {
    await _handleStatusChange(event.disputeId, 'Refunded', 'Refund approved successfully.', emit);
  }

  Future<void> _onDeclineRefund(DeclineRefundEvent event, Emitter<DisputesRefundsState> emit) async {
    await _handleStatusChange(event.disputeId, 'Declined', 'Refund request declined.', emit);
  }

  Future<void> _handleStatusChange(
    String disputeId, 
    String newStatus, 
    String successMsg,
    Emitter<DisputesRefundsState> emit
  ) async {
    final currentState = state;
    if (currentState is! DisputesRefundsLoaded) return;

    final updatedProcessingIds = Set<String>.from(currentState.processingIds)..add(disputeId);
    emit(currentState.copyWith(processingIds: updatedProcessingIds, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      await repository.resolveDispute(_sellerId!, disputeId, newStatus);
      
      final updatedDisputes = currentState.disputes.map((d) {
        if (d.id == disputeId) return d.copyWith(status: newStatus);
        return d;
      }).toList();

      updatedProcessingIds.remove(disputeId);
      emit(currentState.copyWith(
        disputes: updatedDisputes,
        processingIds: updatedProcessingIds,
        successMessage: successMsg,
      ));
    } catch (e) {
      updatedProcessingIds.remove(disputeId);
      emit(currentState.copyWith(
        processingIds: updatedProcessingIds,
        errorMessage: 'Operation failed: $e',
      ));
    }
  }
}
