import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_distance_matrix_service.dart';
import '../../services/route_polyline_service.dart';

class AppGoogleMapState extends Equatable {
  final MapType mapType;
  final bool trafficEnabled;
  final bool autoFollowDriver;
  final bool showWeatherOverlay;
  final LatLng? deviceGpsLocation;
  final LatLng? snappedDriverLocation;
  final double driverBearing;
  final RouteSnapResult? routeSnapResult;
  final Set<Polyline> roadPolylines;
  final bool forceFallbackCanvas;
  final bool isFetchingGps;
  final DistanceMatrixResult? distanceMatrixResult;
  final String? computedEtaText;
  final double? computedDistanceKm;
  final bool isVoiceGuidanceEnabled;
  final bool is3DTiltMode;
  final bool isRouteLoading;
  final String? routeErrorMessage;
  final List<RouteStepInfo> navigationSteps;
  final RouteStepInfo? currentManeuverStep;
  final double distanceToNextTurnMeters;
  final bool showHeatmapLayer;

  const AppGoogleMapState({
    this.mapType = MapType.normal,
    this.trafficEnabled = false,
    this.autoFollowDriver = true,
    this.showWeatherOverlay = true,
    this.deviceGpsLocation,
    this.snappedDriverLocation,
    this.driverBearing = 0.0,
    this.routeSnapResult,
    this.roadPolylines = const {},
    this.forceFallbackCanvas = false,
    this.isFetchingGps = false,
    this.distanceMatrixResult,
    this.computedEtaText,
    this.computedDistanceKm,
    this.isVoiceGuidanceEnabled = true,
    this.is3DTiltMode = false,
    this.isRouteLoading = false,
    this.routeErrorMessage,
    this.navigationSteps = const [],
    this.currentManeuverStep,
    this.distanceToNextTurnMeters = 0.0,
    this.showHeatmapLayer = false,
  });

  AppGoogleMapState copyWith({
    MapType? mapType,
    bool? trafficEnabled,
    bool? autoFollowDriver,
    bool? showWeatherOverlay,
    LatLng? deviceGpsLocation,
    LatLng? snappedDriverLocation,
    double? driverBearing,
    RouteSnapResult? routeSnapResult,
    Set<Polyline>? roadPolylines,
    bool? forceFallbackCanvas,
    bool? isFetchingGps,
    DistanceMatrixResult? distanceMatrixResult,
    String? computedEtaText,
    double? computedDistanceKm,
    bool? isVoiceGuidanceEnabled,
    bool? is3DTiltMode,
    bool? isRouteLoading,
    String? routeErrorMessage,
    List<RouteStepInfo>? navigationSteps,
    RouteStepInfo? currentManeuverStep,
    double? distanceToNextTurnMeters,
    bool? showHeatmapLayer,
  }) {
    return AppGoogleMapState(
      mapType: mapType ?? this.mapType,
      trafficEnabled: trafficEnabled ?? this.trafficEnabled,
      autoFollowDriver: autoFollowDriver ?? this.autoFollowDriver,
      showWeatherOverlay: showWeatherOverlay ?? this.showWeatherOverlay,
      deviceGpsLocation: deviceGpsLocation ?? this.deviceGpsLocation,
      snappedDriverLocation:
          snappedDriverLocation ?? this.snappedDriverLocation,
      driverBearing: driverBearing ?? this.driverBearing,
      routeSnapResult: routeSnapResult ?? this.routeSnapResult,
      roadPolylines: roadPolylines ?? this.roadPolylines,
      forceFallbackCanvas: forceFallbackCanvas ?? this.forceFallbackCanvas,
      isFetchingGps: isFetchingGps ?? this.isFetchingGps,
      distanceMatrixResult: distanceMatrixResult ?? this.distanceMatrixResult,
      computedEtaText: computedEtaText ?? this.computedEtaText,
      computedDistanceKm: computedDistanceKm ?? this.computedDistanceKm,
      isVoiceGuidanceEnabled:
          isVoiceGuidanceEnabled ?? this.isVoiceGuidanceEnabled,
      is3DTiltMode: is3DTiltMode ?? this.is3DTiltMode,
      isRouteLoading: isRouteLoading ?? this.isRouteLoading,
      routeErrorMessage: routeErrorMessage ?? this.routeErrorMessage,
      navigationSteps: navigationSteps ?? this.navigationSteps,
      currentManeuverStep: currentManeuverStep ?? this.currentManeuverStep,
      distanceToNextTurnMeters:
          distanceToNextTurnMeters ?? this.distanceToNextTurnMeters,
      showHeatmapLayer: showHeatmapLayer ?? this.showHeatmapLayer,
    );
  }

  @override
  List<Object?> get props => [
        mapType,
        trafficEnabled,
        autoFollowDriver,
        showWeatherOverlay,
        deviceGpsLocation,
        snappedDriverLocation,
        driverBearing,
        routeSnapResult,
        roadPolylines,
        forceFallbackCanvas,
        isFetchingGps,
        distanceMatrixResult,
        computedEtaText,
        computedDistanceKm,
        isVoiceGuidanceEnabled,
        is3DTiltMode,
        isRouteLoading,
        routeErrorMessage,
        navigationSteps,
        currentManeuverStep,
        distanceToNextTurnMeters,
        showHeatmapLayer,
      ];
}
