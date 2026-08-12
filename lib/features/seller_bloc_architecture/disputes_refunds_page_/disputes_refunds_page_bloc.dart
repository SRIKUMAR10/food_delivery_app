// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'disputes_refunds_page_event.dart';
import 'disputes_refunds_page_state.dart';
import 'disputes_refunds_page_repository.dart';
import 'disputes_refunds_page_model.dart';

class _DisputesUpdatedEvent extends DisputesRefundsEvent {
  final List<DisputeModel> disputes;
  _DisputesUpdatedEvent(this.disputes);
}

class DisputesRefundsBloc extends Bloc<DisputesRefundsEvent, DisputesRefundsState> {
  final DisputesRefundsRepository repository;
  String? _sellerId;
  StreamSubscription? _disputesSub;

  DisputesRefundsBloc({required this.repository}) : super(DisputesRefundsInitial()) {
    on<LoadDisputesEvent>(_onLoadDisputes);
    on<_DisputesUpdatedEvent>(_onDisputesUpdated);
    on<ApproveRefundEvent>(_onApproveRefund);
    on<DeclineRefundEvent>(_onDeclineRefund);
  }

  @override
  Future<void> close() {
    _disputesSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadDisputes(LoadDisputesEvent event, Emitter<DisputesRefundsState> emit) async {
    _sellerId = event.sellerId;
    emit(DisputesRefundsLoading());
    try {
      await _disputesSub?.cancel();
      final disputes = await repository.getDisputes(event.sellerId);
      emit(DisputesRefundsLoaded(disputes: disputes));

      _disputesSub = repository.streamDisputes(event.sellerId).listen((liveDisputes) {
        if (!isClosed) {
          add(_DisputesUpdatedEvent(liveDisputes));
        }
      });
    } catch (e) {
      emit(DisputesRefundsError('Failed to load disputes: $e'));
    }
  }

  void _onDisputesUpdated(_DisputesUpdatedEvent event, Emitter<DisputesRefundsState> emit) {
    final currentState = state;
    if (currentState is DisputesRefundsLoaded) {
      emit(currentState.copyWith(disputes: event.disputes));
    } else {
      emit(DisputesRefundsLoaded(disputes: event.disputes));
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
