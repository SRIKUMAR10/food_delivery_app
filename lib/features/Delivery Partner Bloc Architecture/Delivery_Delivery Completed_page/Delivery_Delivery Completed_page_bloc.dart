import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Delivery Completed_page_event.dart';
import 'Delivery_Delivery Completed_page_repository.dart';
import 'Delivery_Delivery Completed_page_service.dart';
import 'Delivery_Delivery Completed_page_state.dart';

class DeliveryCompletedBloc
    extends Bloc<DeliveryCompletedEvent, DeliveryCompletedPageState> {
  final DeliveryCompletedRepositoryBase repository;
  final DeliveryCompletedServiceBase service;

  DeliveryCompletedBloc({
    DeliveryCompletedRepositoryBase? repository,
    DeliveryCompletedServiceBase? service,
  })  : repository = repository ?? DeliveryCompletedRepository(),
        service = service ?? DeliveryCompletedService(),
        super(const DeliveryCompletedPageState()) {
    on<FetchCompletedOrderDetailsEvent>(_onFetchDetails);
    on<CompleteOrderSubmittedEvent>(_onCompleteOrder);
    on<ReturnHomeRequestedEvent>(_onReturnHome);
    on<RateCustomerEvent>(_onRateCustomer);
    on<UploadProofMediaEvent>(_onUploadProofMedia);
    on<RefreshCompletedOrderEvent>(_onRefresh);
  }

  Future<void> _onFetchDetails(
    FetchCompletedOrderDetailsEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliveryCompletedStatus.loading,
      clearError: true,
    ));
    try {
      final model = await repository.fetchCompletedOrderDetails(event.orderId);

      if (model.customerName.trim().isEmpty &&
          model.orderId.trim().isEmpty) {
        emit(state.copyWith(status: DeliveryCompletedStatus.empty));
        return;
      }

      emit(state.copyWith(
        status: DeliveryCompletedStatus.success,
        model: model,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryCompletedStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrderSubmittedEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) async {
    if (state.model == null) return;
    emit(state.copyWith(
      status: DeliveryCompletedStatus.loading,
      isCompleting: true,
      clearError: true,
    ));
    try {
      final model = await repository.completeOrder(event.orderId);
      emit(state.copyWith(
        status: DeliveryCompletedStatus.completed,
        model: model,
        isCompleting: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryCompletedStatus.success,
        isCompleting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onReturnHome(
    ReturnHomeRequestedEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) {
    // Navigation handling is delegated to the UI layer.
  }

  void _onRateCustomer(
    RateCustomerEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) {
    if (state.model == null) return;
    final rating = event.rating.clamp(1, 5).toInt();
    emit(state.copyWith(
      ratedScore: rating,
      ratingSubmitted: true,
      clearError: true,
    ));
  }

  Future<void> _onUploadProofMedia(
    UploadProofMediaEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) async {
    if (state.model == null) return;
    final validationError = service.validateMedia(event.filePath);
    if (validationError != null) {
      emit(state.copyWith(
        proofUploadStatus: DeliveryProofUploadStatus.failed,
        errorMessage: validationError,
      ));
      return;
    }

    emit(state.copyWith(
      proofUploadStatus: DeliveryProofUploadStatus.uploading,
      proofUploadProgress: 0.0,
      clearError: true,
    ));

    try {
      await for (final progress in service.chunkedMediaUpload(
        state.model!.orderId,
      )) {
        emit(state.copyWith(
          proofUploadStatus: DeliveryProofUploadStatus.uploading,
          proofUploadProgress: progress,
        ));
      }
      emit(state.copyWith(
        proofUploadStatus: DeliveryProofUploadStatus.uploaded,
        proofUploadProgress: 1.0,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        proofUploadStatus: DeliveryProofUploadStatus.failed,
        errorMessage: 'Upload failed: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshCompletedOrderEvent event,
    Emitter<DeliveryCompletedPageState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliveryCompletedStatus.loading,
      clearError: true,
    ));
    try {
      final model = await repository.fetchCompletedOrderDetails(event.orderId);
      if (model.customerName.trim().isEmpty &&
          model.orderId.trim().isEmpty) {
        emit(state.copyWith(status: DeliveryCompletedStatus.empty));
        return;
      }
      emit(state.copyWith(
        status: DeliveryCompletedStatus.success,
        model: model,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryCompletedStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
