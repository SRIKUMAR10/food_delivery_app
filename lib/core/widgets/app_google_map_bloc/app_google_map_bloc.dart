import 'dart:async';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_distance_matrix_service.dart';
import '../../services/route_polyline_service.dart';
import '../../services/voice_navigation_service.dart';
import 'app_google_map_event.dart';
import 'app_google_map_state.dart';

class AppGoogleMapBloc extends Bloc<AppGoogleMapEvent, AppGoogleMapState> {
  StreamSubscription<Position>? _gpsStreamSub;

  AppGoogleMapBloc() : super(const AppGoogleMapState()) {
    on<MapInitializeEvent>(_onInitialize);
    on<MapDataUpdatedEvent>(_onDataUpdated);
    on<ToggleMapTypeEvent>(_onToggleMapType);
    on<ToggleTrafficEvent>(_onToggleTraffic);
    on<ToggleAutoFollowEvent>(_onToggleAutoFollow);
    on<ToggleWeatherEvent>(_onToggleWeather);
    on<ToggleVoiceGuidanceEvent>(_onToggleVoiceGuidance);
    on<Toggle3DTiltModeEvent>(_onToggle3DTiltMode);
    on<ToggleHeatmapLayerEvent>(_onToggleHeatmapLayer);
    on<UpdateCurrentManeuverStepEvent>(_onUpdateCurrentManeuverStep);
    on<GpsLocationUpdatedEvent>(_onGpsLocationUpdated);
    on<FetchRoutePolylinesEvent>(_onFetchRoutePolylines);
    on<FetchDistanceMatrixEtaEvent>(_onFetchDistanceMatrixEta);
    on<WebFallbackTriggeredEvent>(_onWebFallbackTriggered);
  }

  Future<void> _onInitialize(
    MapInitializeEvent event,
    Emitter<AppGoogleMapState> emit,
  ) async {
    emit(state.copyWith(autoFollowDriver: event.autoFollowDriver));
    _startGpsStream();

    add(FetchRoutePolylinesEvent(
      driverLocation: event.driverLocation,
      storeLocation: event.storeLocation,
      customerLocation: event.customerLocation,
      isPickedUp: false,
    ));

    final targetDest = event.storeLocation ?? event.customerLocation;
    if (event.driverLocation != null && targetDest != null) {
      add(FetchDistanceMatrixEtaEvent(
        origin: event.driverLocation!,
        destination: targetDest,
      ));
    }
  }

  Future<void> _onDataUpdated(
    MapDataUpdatedEvent event,
    Emitter<AppGoogleMapState> emit,
  ) async {
    if (event.forceRouteRefetch || _shouldRefetchRoute(event)) {
      add(FetchRoutePolylinesEvent(
        driverLocation: event.driverLocation,
        storeLocation: event.storeLocation,
        customerLocation: event.customerLocation,
        isPickedUp: event.isPickedUp,
      ));

      final dest = event.isPickedUp
          ? (event.customerLocation ?? event.storeLocation)
          : (event.storeLocation ?? event.customerLocation);

      if (event.driverLocation != null && dest != null) {
        add(FetchDistanceMatrixEtaEvent(
          origin: event.driverLocation!,
          destination: dest,
        ));
      }
    }
  }

  Future<void> _onFetchDistanceMatrixEta(
    FetchDistanceMatrixEtaEvent event,
    Emitter<AppGoogleMapState> emit,
  ) async {
    try {
      final result = await GoogleDistanceMatrixService.instance
          .computeDistanceAndEta(
        origin: event.origin,
        destination: event.destination,
      );

      emit(state.copyWith(
        distanceMatrixResult: result,
        computedEtaText: result.effectiveEtaText,
        computedDistanceKm: result.distanceKm,
      ));
    } catch (_) {}
  }

  bool _shouldRefetchRoute(MapDataUpdatedEvent event) {
    return true;
  }

  void _onToggleMapType(
    ToggleMapTypeEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    final nextType = state.mapType == MapType.normal
        ? MapType.satellite
        : MapType.normal;
    emit(state.copyWith(mapType: nextType));
  }

  void _onToggleTraffic(
    ToggleTrafficEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(trafficEnabled: !state.trafficEnabled));
  }

  void _onToggleAutoFollow(
    ToggleAutoFollowEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(autoFollowDriver: !state.autoFollowDriver));
  }

  void _onToggleWeather(
    ToggleWeatherEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(showWeatherOverlay: !state.showWeatherOverlay));
  }

  void _onToggleVoiceGuidance(
    ToggleVoiceGuidanceEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    final nextState = !state.isVoiceGuidanceEnabled;
    VoiceNavigationService.instance.setMuted(!nextState);
    emit(state.copyWith(isVoiceGuidanceEnabled: nextState));
  }

  void _onToggle3DTiltMode(
    Toggle3DTiltModeEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(is3DTiltMode: !state.is3DTiltMode));
  }

  void _onToggleHeatmapLayer(
    ToggleHeatmapLayerEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(showHeatmapLayer: !state.showHeatmapLayer));
  }

  void _onUpdateCurrentManeuverStep(
    UpdateCurrentManeuverStepEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(
      currentManeuverStep: event.step,
      distanceToNextTurnMeters: event.distanceMeters,
    ));
  }

  void _onGpsLocationUpdated(
    GpsLocationUpdatedEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    RouteSnapResult? snapResult;
    LatLng snappedPos = event.location;
    double bearing = state.driverBearing;

    // Find the active route polyline to snap onto
    if (state.roadPolylines.isNotEmpty) {
      for (final poly in state.roadPolylines) {
        if (poly.points.length >= 2) {
          snapResult = RoutePolylineService.instance.snapToPolyline(
            event.location,
            poly.points,
          );
          snappedPos = snapResult.snappedPosition;
          bearing = snapResult.bearing;
          break;
        }
      }
    }

    // Identify nearest upcoming navigation maneuver step
    RouteStepInfo? activeStep = state.currentManeuverStep;
    double distToStep = state.distanceToNextTurnMeters;

    if (state.navigationSteps.isNotEmpty) {
      for (int i = 0; i < state.navigationSteps.length; i++) {
        final step = state.navigationSteps[i];
        final dist = RoutePolylineService.instance
            .haversineDistanceMeters(snappedPos, step.endLocation);
        if (dist > 15.0) {
          activeStep = step;
          distToStep = dist;

          if (state.isVoiceGuidanceEnabled) {
            VoiceNavigationService.instance.announceManeuver(
              step: step,
              distanceToStepMeters: dist,
              stepIndex: i,
            );
          }
          break;
        }
      }
    }

    emit(state.copyWith(
      deviceGpsLocation: event.location,
      snappedDriverLocation: snappedPos,
      driverBearing: bearing,
      routeSnapResult: snapResult,
      currentManeuverStep: activeStep,
      distanceToNextTurnMeters: distToStep,
    ));
  }

  Future<void> _onFetchRoutePolylines(
    FetchRoutePolylinesEvent event,
    Emitter<AppGoogleMapState> emit,
  ) async {
    emit(state.copyWith(isRouteLoading: true, routeErrorMessage: null));

    try {
      final origin = event.driverLocation ?? event.storeLocation;
      final target = event.isPickedUp
          ? (event.customerLocation ?? event.storeLocation)
          : (event.storeLocation ?? event.customerLocation);

      List<RouteStepInfo> parsedSteps = [];
      if (origin != null && target != null) {
        final routeResult = await RoutePolylineService.instance
            .fetchRoadRouteAndETA(origin, target);
        parsedSteps = routeResult.steps;
      }

      // Asynchronously fetch high-accuracy real road polylines
      final polylines = await RoutePolylineService.instance
          .generateRealRoadJourneyPolylines(
        storeLocation: event.storeLocation,
        driverLocation: event.driverLocation,
        customerLocation: event.customerLocation,
        isPickedUp: event.isPickedUp,
        activeColor: const Color(0xFF1A73E8),
      );

      emit(state.copyWith(
        roadPolylines: polylines,
        isRouteLoading: false,
        navigationSteps: parsedSteps,
        currentManeuverStep:
            parsedSteps.isNotEmpty ? parsedSteps.first : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRouteLoading: false,
        routeErrorMessage: e.toString(),
      ));
    }
  }

  void _onWebFallbackTriggered(
    WebFallbackTriggeredEvent event,
    Emitter<AppGoogleMapState> emit,
  ) {
    emit(state.copyWith(forceFallbackCanvas: true));
  }

  void _startGpsStream() {
    _gpsStreamSub?.cancel();
    try {
      _gpsStreamSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (Position pos) {
          final fresh = LatLng(pos.latitude, pos.longitude);
          if (!isClosed) {
            add(GpsLocationUpdatedEvent(fresh));
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _gpsStreamSub?.cancel();
    return super.close();
  }
}
