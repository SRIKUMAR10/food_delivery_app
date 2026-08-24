import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AppGoogleMapEvent extends Equatable {
  const AppGoogleMapEvent();

  @override
  List<Object?> get props => [];
}

class MapInitializeEvent extends AppGoogleMapEvent {
  final LatLng? driverLocation;
  final LatLng? storeLocation;
  final LatLng? customerLocation;
  final double driverHeading;
  final double initialZoom;
  final bool autoFollowDriver;

  const MapInitializeEvent({
    this.driverLocation,
    this.storeLocation,
    this.customerLocation,
    this.driverHeading = 0.0,
    this.initialZoom = 15.0,
    this.autoFollowDriver = true,
  });

  @override
  List<Object?> get props => [
        driverLocation,
        storeLocation,
        customerLocation,
        driverHeading,
        initialZoom,
        autoFollowDriver,
      ];
}

class MapDataUpdatedEvent extends AppGoogleMapEvent {
  final LatLng? driverLocation;
  final LatLng? storeLocation;
  final LatLng? customerLocation;
  final double driverHeading;
  final bool isPickedUp;
  final bool forceRouteRefetch;

  const MapDataUpdatedEvent({
    this.driverLocation,
    this.storeLocation,
    this.customerLocation,
    this.driverHeading = 0.0,
    this.isPickedUp = false,
    this.forceRouteRefetch = false,
  });

  @override
  List<Object?> get props => [
        driverLocation,
        storeLocation,
        customerLocation,
        driverHeading,
        isPickedUp,
        forceRouteRefetch,
      ];
}

class ToggleMapTypeEvent extends AppGoogleMapEvent {}

class ToggleTrafficEvent extends AppGoogleMapEvent {}

class ToggleAutoFollowEvent extends AppGoogleMapEvent {}

class ToggleWeatherEvent extends AppGoogleMapEvent {}

class GpsLocationUpdatedEvent extends AppGoogleMapEvent {
  final LatLng location;

  const GpsLocationUpdatedEvent(this.location);

  @override
  List<Object?> get props => [location];
}

class FetchRoutePolylinesEvent extends AppGoogleMapEvent {
  final LatLng? driverLocation;
  final LatLng? storeLocation;
  final LatLng? customerLocation;
  final bool isPickedUp;

  const FetchRoutePolylinesEvent({
    this.driverLocation,
    this.storeLocation,
    this.customerLocation,
    this.isPickedUp = false,
  });

  @override
  List<Object?> get props => [
        driverLocation,
        storeLocation,
        customerLocation,
        isPickedUp,
      ];
}

class WebFallbackTriggeredEvent extends AppGoogleMapEvent {}

class FetchDistanceMatrixEtaEvent extends AppGoogleMapEvent {
  final LatLng origin;
  final LatLng destination;

  const FetchDistanceMatrixEtaEvent({
    required this.origin,
    required this.destination,
  });

  @override
  List<Object?> get props => [origin, destination];
}
