import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Profile_page_event.dart';
import 'Delivery_Profile_page_state.dart';
import 'Delivery_Profile_page_repository.dart';
import 'Delivery_Profile_page_service.dart';

class DeliveryProfileBloc
    extends Bloc<DeliveryProfileEvent, DeliveryProfileState> {
  final DeliveryProfileRepositoryBase repository;
  final DeliveryProfileServiceBase service;

  DeliveryProfileBloc({
    DeliveryProfileRepositoryBase? repository,
    DeliveryProfileServiceBase? service,
  })  : repository = repository ?? DeliveryProfileRepository(),
        service = service ?? DeliveryProfileService(),
        super(const DeliveryProfileState()) {
    on<DeliveryProfileInitEvent>(_onInit);
    on<DeliveryProfileUpdateFieldEvent>(_onUpdateField);
    on<DeliveryProfilePickImageEvent>(_onPickImage);
    on<DeliveryProfileUploadDocumentEvent>(_onUploadDocument);
    on<DeliveryProfileSaveEvent>(_onSave);
    on<DeliveryProfileRetryEvent>(_onRetry);
  }

  Future<void> _onInit(
    DeliveryProfileInitEvent event,
    Emitter<DeliveryProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliveryProfileStatus.loading,
      clearError: true,
    ));
    try {
      final profile = await repository.fetchProfile();

      if (profile.fullName.trim().isEmpty &&
          profile.phone.trim().isEmpty &&
          profile.email.trim().isEmpty) {
        emit(profile.copyWith(
          status: DeliveryProfileStatus.empty,
        ));
        return;
      }

      final merged = _recalculate(profile.copyWith(
        status: DeliveryProfileStatus.loaded,
        localeCode: state.localeCode,
        clearError: true,
      ));
      emit(merged);
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryProfileStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onUpdateField(
    DeliveryProfileUpdateFieldEvent event,
    Emitter<DeliveryProfileState> emit,
  ) {
    final updated = switch (event.field) {
      'fullName' => state.copyWith(
          fullName: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'phone' => state.copyWith(
          phone: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'email' => state.copyWith(
          email: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'dob' => state.copyWith(
          dob: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'gender' => state.copyWith(
          gender: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'vehicleType' => state.copyWith(
          vehicleType: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'vehicleNumber' => state.copyWith(
          vehicleNumber: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'licenseNumber' => state.copyWith(
          licenseNumber: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      'licenseValidTill' => state.copyWith(
          licenseValidTill: event.value,
          status: DeliveryProfileStatus.loaded,
          clearError: true,
        ),
      _ => state,
    };
    emit(_recalculate(updated));
  }

  Future<void> _onPickImage(
    DeliveryProfilePickImageEvent event,
    Emitter<DeliveryProfileState> emit,
  ) async {
    try {
      final path = await repository.pickProfileImage();
      await repository.saveAvatarPath(path);
      emit(state.copyWith(
        avatarPath: path,
        clearAvatar: path == null,
        status: DeliveryProfileStatus.loaded,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUploadDocument(
    DeliveryProfileUploadDocumentEvent event,
    Emitter<DeliveryProfileState> emit,
  ) async {
    final documents = List<DeliveryProfileDocument>.from(state.documents);
    final index = documents.indexWhere((d) => d.id == event.documentId);
    if (index == -1) return;

    emit(state.copyWith(
      documents: _replaceDocument(
        documents,
        index,
        documents[index].copyWith(
          status: DeliveryProfileDocumentStatus.uploading,
          progress: 0.0,
        ),
      ),
      uploadProgress: 0.0,
    ));

    try {
      await for (final progress in service.chunkedUpload(event.documentId)) {
        final current = List<DeliveryProfileDocument>.from(state.documents);
        final currentIndex = current.indexWhere((d) => d.id == event.documentId);
        if (currentIndex == -1) continue;
        emit(state.copyWith(
          documents: _replaceDocument(
            current,
            currentIndex,
            current[currentIndex].copyWith(
              status: DeliveryProfileDocumentStatus.uploading,
              progress: progress,
            ),
          ),
          uploadProgress: progress,
        ));
      }

      final completed =
          List<DeliveryProfileDocument>.from(state.documents);
      final completedIndex =
          completed.indexWhere((d) => d.id == event.documentId);
      if (completedIndex == -1) return;
      completed[completedIndex] = completed[completedIndex].copyWith(
        status: DeliveryProfileDocumentStatus.uploaded,
        progress: 1.0,
      );

      final verificationStatuses =
          Map<String, bool>.from(state.verificationStatuses);
      if (completed.every((d) => d.isUploaded)) {
        verificationStatuses['document'] = true;
      }

      emit(_recalculate(state.copyWith(
        documents: completed,
        uploadProgress: 1.0,
        verificationStatuses: verificationStatuses,
        clearError: true,
      )));
    } catch (e) {
      final failed = List<DeliveryProfileDocument>.from(state.documents);
      final failedIndex = failed.indexWhere((d) => d.id == event.documentId);
      if (failedIndex != -1) {
        failed[failedIndex] = failed[failedIndex].copyWith(
          status: DeliveryProfileDocumentStatus.notUploaded,
          progress: 0.0,
        );
      }
      emit(state.copyWith(
        documents: failed,
        errorMessage: 'Upload failed: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onSave(
    DeliveryProfileSaveEvent event,
    Emitter<DeliveryProfileState> emit,
  ) async {
    emit(state.copyWith(
      saveStatus: DeliveryProfileSaveStatus.saving,
      clearError: true,
    ));
    try {
      await repository.saveProfile(state);
      emit(state.copyWith(
        saveStatus: DeliveryProfileSaveStatus.saved,
        status: DeliveryProfileStatus.loaded,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        saveStatus: DeliveryProfileSaveStatus.failed,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRetry(
    DeliveryProfileRetryEvent event,
    Emitter<DeliveryProfileState> emit,
  ) async {
    add(const DeliveryProfileInitEvent());
  }

  DeliveryProfileState _recalculate(DeliveryProfileState current) {
    final completion = computeDeliveryProfileCompletion(
      fullName: current.fullName,
      phone: current.phone,
      email: current.email,
      dob: current.dob,
      vehicleType: current.vehicleType,
      vehicleNumber: current.vehicleNumber,
      licenseNumber: current.licenseNumber,
      licenseValidTill: current.licenseValidTill,
      documents: current.documents,
    );
    final checklist = DeliveryProfileRepository.buildDefaultChecklist(
      profile: current,
    );
    return current.copyWith(
      completionPercentage: completion,
      checklist: checklist,
    );
  }

  List<DeliveryProfileDocument> _replaceDocument(
    List<DeliveryProfileDocument> documents,
    int index,
    DeliveryProfileDocument updated,
  ) {
    final result = List<DeliveryProfileDocument>.from(documents);
    result[index] = updated;
    return result;
  }
}
