import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Navigation Screen_page_event.dart';
import 'Delivery_Navigation Screen_page_state.dart';
import 'Delivery_Navigation Screen_page_repository.dart';
import 'Delivery_Navigation Screen_page_service.dart';

class DeliveryNavigationBloc
    extends Bloc<DeliveryNavigationEvent, DeliveryNavigationState> {
  final DeliveryNavigationRepositoryBase repository;
  final DeliveryNavigationServiceBase service;

  StreamSubscription<double>? _locationSub;

  DeliveryNavigationBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryNavigationState()) {
    on<DeliveryNavigationInitEvent>(_onInit);
    on<DeliveryNavigationStartNavigationEvent>(_onStartNavigation);
    on<DeliveryNavigationExitNavigationEvent>(_onExitNavigation);
    on<DeliveryNavigationRecenterMapEvent>(_onRecenterMap);
    on<DeliveryNavigationToggleAudioEvent>(_onToggleAudio);
    on<DeliveryNavigationSOSClickedEvent>(_onSOSClicked);
    on<DeliveryNavigationRefreshEvent>(_onRefresh);
    on<DeliveryNavigationLocaleChangedEvent>(_onLocaleChanged);
    on<DeliveryNavigationLocationTickEvent>(_onLocationTick);
    on<DeliveryNavigationToggleMapEvent>(_onToggleMap);
  }

  @override
  Future<void> close() async {
    await _locationSub?.cancel();
    _locationSub = null;
    await super.close();
  }

  Future<void> _onInit(
    DeliveryNavigationInitEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryNavigationStatus.loading));
    try {
      final isOnline = await service.checkConnectivity();
      final hasPermission = await service.checkLocationPermission();
      final order = await repository.fetchOrderSummary();
      final pickup = await repository.fetchPickup();
      final drop = await repository.fetchDrop();
      final audioEnabled = await repository.getAudioEnabled();
      final emergencyMode = await repository.getEmergencyMode();
      final localeCode = await repository.getLocaleCode();

      if (order.orderId.trim().isEmpty) {
        emit(state.copyWith(
          status: DeliveryNavigationStatus.empty,
          isOffline: !isOnline,
          hasLocationPermission: hasPermission,
          audioEnabled: audioEnabled,
          emergencyMode: emergencyMode,
          localeCode: localeCode,
          errorMessage: null,
          clearError: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: DeliveryNavigationStatus.loaded,
        order: order,
        pickup: pickup,
        drop: drop,
        isOffline: !isOnline,
        hasLocationPermission: hasPermission,
        audioEnabled: audioEnabled,
        emergencyMode: emergencyMode,
        localeCode: localeCode,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onStartNavigation(
    DeliveryNavigationStartNavigationEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    if (state.status == DeliveryNavigationStatus.navigating) {
      return;
    }
    await repository.saveAudioEnabled(true);
    _startLocationStream();
    emit(state.copyWith(
      status: DeliveryNavigationStatus.navigating,
      audioEnabled: true,
      emergencyMode: false,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onExitNavigation(
    DeliveryNavigationExitNavigationEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    _locationSub?.cancel();
    _locationSub = null;
    emit(state.copyWith(
      status: DeliveryNavigationStatus.loaded,
      emergencyMode: false,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onRecenterMap(
    DeliveryNavigationRecenterMapEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      mapZoomLevel: 15.0,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onToggleAudio(
    DeliveryNavigationToggleAudioEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    final enabled = !state.audioEnabled;
    await repository.saveAudioEnabled(enabled);
    emit(state.copyWith(
      audioEnabled: enabled,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onToggleMap(
    DeliveryNavigationToggleMapEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    emit(state.copyWith(
      showMap: !state.showMap,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onSOSClicked(
    DeliveryNavigationSOSClickedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    await repository.saveEmergencyMode(true);
    emit(state.copyWith(
      emergencyMode: true,
      errorMessage: null,
      clearError: true,
    ));
  }

  Future<void> _onRefresh(
    DeliveryNavigationRefreshEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    try {
      final isOnline = await service.checkConnectivity();
      final hasPermission = await service.checkLocationPermission();
      final order = await repository.fetchOrderSummary();
      final pickup = await repository.fetchPickup();
      final drop = await repository.fetchDrop();
      final audioEnabled = await repository.getAudioEnabled();
      final emergencyMode = await repository.getEmergencyMode();

      if (order.orderId.trim().isEmpty) {
        emit(state.copyWith(
          status: DeliveryNavigationStatus.empty,
          isOffline: !isOnline,
          hasLocationPermission: hasPermission,
          audioEnabled: audioEnabled,
          emergencyMode: emergencyMode,
          errorMessage: null,
          clearError: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: DeliveryNavigationStatus.loaded,
        order: order,
        pickup: pickup,
        drop: drop,
        isOffline: !isOnline,
        hasLocationPermission: hasPermission,
        audioEnabled: audioEnabled,
        emergencyMode: emergencyMode,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLocaleChanged(
    DeliveryNavigationLocaleChangedEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) async {
    await repository.saveLocaleCode(event.localeCode);
    emit(state.copyWith(localeCode: event.localeCode));
  }

  void _onLocationTick(
    DeliveryNavigationLocationTickEvent event,
    Emitter<DeliveryNavigationState> emit,
  ) {
    emit(state.copyWith(
      turnDistanceMeters: math.max(
        0,
        state.turnDistanceMeters - event.deltaMeters,
      ),
    ));
  }

  void _startLocationStream() {
    _locationSub?.cancel();
    _locationSub = service.simulateLiveLocation().listen(
      (deltaMeters) {
        if (isClosed) return;
        add(DeliveryNavigationLocationTickEvent(deltaMeters));
      },
      onError: (Object _) {
        // Degrade gracefully: keep the last known guidance state.
      },
    );
  }
}
