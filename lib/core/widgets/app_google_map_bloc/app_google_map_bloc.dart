import 'dart:async';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_distance_matrix_service.dart';
import '../../services/route_polyline_service.dart';
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
    // Basic heuristic: if the driver has moved significantly or we have a new destination.
    // Full logic will depend on how the widget feeds the BLoC.
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

    emit(state.copyWith(
      deviceGpsLocation: event.location,
      snappedDriverLocation: snappedPos,
      driverBearing: bearing,
      routeSnapResult: snapResult,
    ));
  }

  Future<void> _onFetchRoutePolylines(
    FetchRoutePolylinesEvent event,
    Emitter<AppGoogleMapState> emit,
  ) async {
    // 1. Instantly provide smooth journey polylines (0ms delay) so map is never empty
    if (state.roadPolylines.isEmpty) {
      final instant = RoutePolylineService.instance.generateJourneyPolylines(
        storeLocation: event.storeLocation,
        driverLocation: event.driverLocation,
        customerLocation: event.customerLocation,
        isPickedUp: event.isPickedUp,
        activeColor: const Color(0xFF1A73E8),
      );
      if (instant.isNotEmpty) {
        emit(state.copyWith(roadPolylines: instant));
      }
    }

    // 2. Asynchronously fetch high-accuracy turn-by-turn road polylines from OSRM / Google Directions
    try {
      final polylines = await RoutePolylineService.instance
          .generateRealRoadJourneyPolylines(
        storeLocation: event.storeLocation,
        driverLocation: event.driverLocation,
        customerLocation: event.customerLocation,
        isPickedUp: event.isPickedUp,
        activeColor: const Color(0xFF1A73E8),
      );
      if (polylines.isNotEmpty) {
        emit(state.copyWith(roadPolylines: polylines));
      }
    } catch (_) {
      // Fallback already emitted
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
