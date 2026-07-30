import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_onboarding_page_event.dart';
import 'Delivery_onboarding_page_state.dart';
import 'Delivery_onboarding_page_repository.dart';
import 'Delivery_onboarding_page_service.dart';

class DeliveryOnboardingPageBloc
    extends Bloc<DeliveryOnboardingPageEvent, DeliveryOnboardingPageState> {
  final DeliveryOnboardingRepositoryBase repository;
  final DeliveryOnboardingServiceBase service;
  StreamSubscription<double>? _uploadSubscription;

  DeliveryOnboardingPageBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryOnboardingPageState()) {
    on<DeliveryOnboardingInitEvent>(_onInit);
    on<DeliveryOnboardingLanguageChangedEvent>(_onLanguageChanged);
    on<DeliveryOnboardingGetStartedClickedEvent>(_onGetStartedClicked);
    on<DeliveryOnboardingLoginClickedEvent>(_onLoginClicked);
    on<DeliveryOnboardingRefreshEvent>(_onRefresh);
    on<DeliveryOnboardingSimulateVideoUploadEvent>(_onSimulateVideoUpload);
  }

  Future<void> _onInit(
    DeliveryOnboardingInitEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryOnboardingStatus.loading));
    try {
      final isOnline = await service.checkNetworkConnectivity();
      if (!isOnline) {
        emit(
          state.copyWith(
            status: DeliveryOnboardingStatus.error,
            errorMessage: 'Network connection unavailable',
          ),
        );
        return;
      }

      final lang = await repository.getSelectedLanguage();
      final features = await repository.getFeatures();
      final stats = await repository.getPartnerStats();

      emit(
        state.copyWith(
          status: DeliveryOnboardingStatus.loaded,
          selectedLanguage: lang,
          features: features,
          partnerStats: stats,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryOnboardingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLanguageChanged(
    DeliveryOnboardingLanguageChangedEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    await repository.saveSelectedLanguage(event.languageCode);
    emit(state.copyWith(selectedLanguage: event.languageCode));
  }

  Future<void> _onGetStartedClicked(
    DeliveryOnboardingGetStartedClickedEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    emit(state.copyWith(isStarted: true));
  }

  Future<void> _onLoginClicked(
    DeliveryOnboardingLoginClickedEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    emit(state.copyWith(isNavigatingToLogin: true));
  }

  Future<void> _onRefresh(
    DeliveryOnboardingRefreshEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    add(const DeliveryOnboardingInitEvent());
  }

  Future<void> _onSimulateVideoUpload(
    DeliveryOnboardingSimulateVideoUploadEvent event,
    Emitter<DeliveryOnboardingPageState> emit,
  ) async {
    await _uploadSubscription?.cancel();
    final completer = Completer<void>();

    _uploadSubscription = service.uploadVideoChunked(event.videoPath).listen(
      (progress) {
        if (!isClosed) {
          emit(state.copyWith(uploadProgress: progress));
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (err) {
        if (!isClosed) {
          emit(state.copyWith(errorMessage: err.toString()));
        }
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  @override
  Future<void> close() {
    _uploadSubscription?.cancel();
    return super.close();
  }
}
