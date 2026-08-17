import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/delivery_partner_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class LiveLocationEvent extends Equatable {
  const LiveLocationEvent();

  @override
  List<Object?> get props => [];
}

class LiveLocationStartTracking extends LiveLocationEvent {
  final String driverId;
  const LiveLocationStartTracking({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

class LiveLocationStopTracking extends LiveLocationEvent {
  const LiveLocationStopTracking();
}

class LiveLocationUpdated extends LiveLocationEvent {
  final double latitude;
  final double longitude;
  final double heading;
  final double speedKmh;

  const LiveLocationUpdated({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.speedKmh = 0.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, heading, speedKmh];
}

class LiveLocationGeofenceCheck extends LiveLocationEvent {
  final double targetLat;
  final double targetLng;
  final double radiusMeters;

  const LiveLocationGeofenceCheck({
    required this.targetLat,
    required this.targetLng,
    this.radiusMeters = 100.0,
  });

  @override
  List<Object?> get props => [targetLat, targetLng, radiusMeters];
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class LiveLocationState extends Equatable {
  final bool isTracking;
  final double latitude;
  final double longitude;
  final double heading;
  final double speedKmh;
  final DateTime? lastUpdated;
  final bool isInsideGeofence;
  final double? distanceToTargetMeters;
  final String gpsStatus; // 'active', 'disabled', 'permission_denied'
  final String? errorMessage;

  const LiveLocationState({
    this.isTracking = false,
    this.latitude = 13.0827,
    this.longitude = 80.2707,
    this.heading = 0.0,
    this.speedKmh = 0.0,
    this.lastUpdated,
    this.isInsideGeofence = false,
    this.distanceToTargetMeters,
    this.gpsStatus = 'active',
    this.errorMessage,
  });

  LiveLocationState copyWith({
    bool? isTracking,
    double? latitude,
    double? longitude,
    double? heading,
    double? speedKmh,
    DateTime? lastUpdated,
    bool? isInsideGeofence,
    double? distanceToTargetMeters,
    String? gpsStatus,
    String? errorMessage,
  }) {
    return LiveLocationState(
      isTracking: isTracking ?? this.isTracking,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speedKmh: speedKmh ?? this.speedKmh,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      distanceToTargetMeters: distanceToTargetMeters ?? this.distanceToTargetMeters,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isTracking,
        latitude,
        longitude,
        heading,
        speedKmh,
        lastUpdated,
        isInsideGeofence,
        distanceToTargetMeters,
        gpsStatus,
        errorMessage,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────────────────

class LiveLocationBloc extends Bloc<LiveLocationEvent, LiveLocationState> {
  final DeliveryPartnerRepository _repository;
  String? _currentDriverId;
  DateTime? _lastFirestoreSyncTime;

  LiveLocationBloc({
    DeliveryPartnerRepository? repository,
  })  : _repository = repository ?? DeliveryPartnerRepository(),
        super(const LiveLocationState()) {
    on<LiveLocationStartTracking>(_onStartTracking);
    on<LiveLocationStopTracking>(_onStopTracking);
    on<LiveLocationUpdated>(_onLocationUpdated);
    on<LiveLocationGeofenceCheck>(_onGeofenceCheck);
  }

  void _onStartTracking(
    LiveLocationStartTracking event,
    Emitter<LiveLocationState> emit,
  ) {
    _currentDriverId = event.driverId;
    emit(state.copyWith(
      isTracking: true,
      gpsStatus: 'active',
      errorMessage: null,
    ));
  }

  void _onStopTracking(
    LiveLocationStopTracking event,
    Emitter<LiveLocationState> emit,
  ) {
    _currentDriverId = null;
    emit(state.copyWith(isTracking: false));
  }

  Future<void> _onLocationUpdated(
    LiveLocationUpdated event,
    Emitter<LiveLocationState> emit,
  ) async {
    final now = DateTime.now();
    emit(state.copyWith(
      latitude: event.latitude,
      longitude: event.longitude,
      heading: event.heading,
      speedKmh: event.speedKmh,
      lastUpdated: now,
    ));

    // Throttled Firestore sync (max once every 5 seconds)
    if (_currentDriverId != null &&
        (_lastFirestoreSyncTime == null ||
            now.difference(_lastFirestoreSyncTime!).inSeconds >= 5)) {
      _lastFirestoreSyncTime = now;
      try {
        await _repository.updateDriverLocation(
          _currentDriverId!,
          event.latitude,
          event.longitude,
        );
      } catch (e) {
        // Silently handle location sync glitches
      }
    }
  }

  void _onGeofenceCheck(
    LiveLocationGeofenceCheck event,
    Emitter<LiveLocationState> emit,
  ) {
    final dist = _calculateHaversineDistanceMeters(
      state.latitude,
      state.longitude,
      event.targetLat,
      event.targetLng,
    );
    final inside = dist <= event.radiusMeters;
    emit(state.copyWith(
      isInsideGeofence: inside,
      distanceToTargetMeters: dist,
    ));
  }

  double _calculateHaversineDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}
