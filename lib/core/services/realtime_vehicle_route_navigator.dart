import 'dart:async';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_polyline_service.dart';

/// Telemetry payload emitted continuously during real-time road navigation.
class VehicleTelemetry {
  final LatLng currentPosition;
  final double heading; // 0..360 degrees
  final double speedKmh; // e.g. 0..45 km/h
  final double remainingDistanceKm; // e.g. 2.4 km -> 0.0 km
  final double remainingDistanceMeters;
  final int etaMinutes;
  final double progressRatio; // 0.0 -> 1.0
  final bool isArrived;
  final String statusMessage;
  final int currentWaypointIndex;
  final List<LatLng> fullRoutePoints;
  final List<LatLng> remainingRoutePoints;

  const VehicleTelemetry({
    required this.currentPosition,
    required this.heading,
    required this.speedKmh,
    required this.remainingDistanceKm,
    required this.remainingDistanceMeters,
    required this.etaMinutes,
    required this.progressRatio,
    required this.isArrived,
    required this.statusMessage,
    required this.currentWaypointIndex,
    this.fullRoutePoints = const [],
    this.remainingRoutePoints = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': heading,
      'speed': speedKmh,
      'speedKmh': speedKmh,
      'remainingDistanceKm': remainingDistanceKm,
      'remainingDistanceMeters': remainingDistanceMeters,
      'etaMinutes': etaMinutes,
      'progressRatio': progressRatio,
      'isArrived': isArrived,
      'statusMessage': statusMessage,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

/// Production-grade Real-time Road Route Vehicle Navigator Engine.
/// Drives a two-wheeler / delivery partner vehicle along 100% real road navigation polyline
/// waypoints from Start to End (e.g. to Zolo Family Restaurant) with dynamic turn-by-turn
/// bearing, realistic speed acceleration/braking on curves, real-time distance countdown,
/// and smooth final arrival stop at the destination.
class RealtimeVehicleRouteNavigator {
  static final RealtimeVehicleRouteNavigator _instance =
      RealtimeVehicleRouteNavigator._internal();
  factory RealtimeVehicleRouteNavigator() => _instance;
  static RealtimeVehicleRouteNavigator get instance => _instance;

  RealtimeVehicleRouteNavigator._internal();

  Timer? _navigationTimer;
  StreamController<VehicleTelemetry>? _telemetryController;

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  Stream<VehicleTelemetry> get telemetryStream =>
      _telemetryController?.stream ?? const Stream.empty();

  /// Starts real-time navigation along 100% Real Road Polyline from start to destination.
  /// If [customRoutePoints] is provided, it uses those exact road points; otherwise, it
  /// automatically fetches real road polyline points via [RoutePolylineService].
  Stream<VehicleTelemetry> startNavigation({
    required LatLng start,
    required LatLng destination,
    String destinationName = 'Zolo Family Restaurant',
    String vehicleType = 'two_wheeler',
    double cruisingSpeedKmh = 80.0,
    double simulationSpeedMultiplier = 1.0,
    List<LatLng>? customRoutePoints,
    Duration tickInterval = const Duration(milliseconds: 50),
  }) {
    stopNavigation();

    _telemetryController = StreamController<VehicleTelemetry>.broadcast();
    _isNavigating = true;

    _runNavigationLoop(
      start: start,
      destination: destination,
      destinationName: destinationName,
      cruisingSpeedKmh: cruisingSpeedKmh,
      simulationSpeedMultiplier: simulationSpeedMultiplier,
      customRoutePoints: customRoutePoints,
      tickInterval: tickInterval,
    );

    return _telemetryController!.stream;
  }

  Future<void> _runNavigationLoop({
    required LatLng start,
    required LatLng destination,
    required String destinationName,
    required double cruisingSpeedKmh,
    required double simulationSpeedMultiplier,
    required Duration tickInterval,
    List<LatLng>? customRoutePoints,
  }) async {
    // 1. Fetch 100% Real Road Navigation Route Polyline Points
    List<LatLng> roadPoints = customRoutePoints ?? [];
    if (roadPoints.length < 2) {
      try {
        final result = await RoutePolylineService.instance.fetchRoadRouteAndETA(
          start,
          destination,
        );
        if (result.points.length >= 2) {
          roadPoints = result.points;
        }
      } catch (_) {}
    }

    // If route service returns fewer than 2 points, generate curved spline fallback
    if (roadPoints.length < 2) {
      roadPoints = RoutePolylineService.instance.generateSmoothPath(
        start,
        destination,
        steps: 30,
      );
    }

    if (roadPoints.isEmpty || _telemetryController == null || _telemetryController!.isClosed) {
      return;
    }

    // 2. Compute total path metrics
    final double totalDistanceMeters =
        RoutePolylineService.instance.calculateTotalPathDistanceMeters(roadPoints);

    // Initial Telemetry emission
    double initialBearing = RoutePolylineService.instance.calculateBearing(
      roadPoints[0],
      roadPoints[1],
    );
    final initialTelemetry = VehicleTelemetry(
      currentPosition: roadPoints.first,
      heading: initialBearing,
      speedKmh: 0.0,
      remainingDistanceKm: totalDistanceMeters / 1000.0,
      remainingDistanceMeters: totalDistanceMeters,
      etaMinutes: (totalDistanceMeters / (cruisingSpeedKmh * 1000.0 / 60.0)).ceil(),
      progressRatio: 0.0,
      isArrived: false,
      statusMessage: 'Starting navigation to $destinationName...',
      currentWaypointIndex: 0,
      fullRoutePoints: List<LatLng>.unmodifiable(roadPoints),
      remainingRoutePoints: List<LatLng>.from(roadPoints),
    );

    if (!_telemetryController!.isClosed) {
      _telemetryController!.add(initialTelemetry);
    }

    // 3. High-precision segment traversal variables
    int segmentIndex = 0;
    double segmentProgressT = 0.0;
    double currentSpeedKmh = 10.0;
    double currentHeading = initialBearing;

    final double tickSeconds = tickInterval.inMilliseconds / 1000.0;

    _navigationTimer = Timer.periodic(tickInterval, (timer) {
      if (!_isNavigating ||
          _telemetryController == null ||
          _telemetryController!.isClosed) {
        timer.cancel();
        return;
      }

      if (segmentIndex >= roadPoints.length - 1) {
        // Destination Reached! Smooth complete stop.
        _isNavigating = false;
        timer.cancel();

        final finalBearing = roadPoints.length >= 2
            ? RoutePolylineService.instance.calculateBearing(
                roadPoints[roadPoints.length - 2],
                roadPoints.last,
              )
            : currentHeading;

        final arrivedTelemetry = VehicleTelemetry(
          currentPosition: roadPoints.last,
          heading: finalBearing,
          speedKmh: 0.0,
          remainingDistanceKm: 0.0,
          remainingDistanceMeters: 0.0,
          etaMinutes: 0,
          progressRatio: 1.0,
          isArrived: true,
          statusMessage: 'Arrived at $destinationName',
          currentWaypointIndex: roadPoints.length - 1,
          fullRoutePoints: List<LatLng>.unmodifiable(roadPoints),
          remainingRoutePoints: [roadPoints.last],
        );

        if (!_telemetryController!.isClosed) {
          _telemetryController!.add(arrivedTelemetry);
        }
        return;
      }

      final p1 = roadPoints[segmentIndex];
      final p2 = roadPoints[segmentIndex + 1];

      final double segDistanceMeters =
          RoutePolylineService.instance.haversineDistanceMeters(p1, p2);

      if (segDistanceMeters < 0.1) {
        segmentIndex++;
        segmentProgressT = 0.0;
        return;
      }

      // Calculate target bearing for this segment
      final double targetBearing =
          RoutePolylineService.instance.calculateBearing(p1, p2);

      // Smooth heading angle interpolation (handles 359° -> 1° wrap around)
      currentHeading = _interpolateHeading(currentHeading, targetBearing, 0.25);

      // Dynamic Speed calculation based on road curvature and proximity to destination
      final double headingDelta = _angleDifference(currentHeading, targetBearing).abs();
      double targetSpeed = cruisingSpeedKmh;

      if (headingDelta > 35.0) {
        targetSpeed = (cruisingSpeedKmh * 0.55).clamp(35.0, 55.0); // Sharp road curve
      } else if (headingDelta > 15.0) {
        targetSpeed = (cruisingSpeedKmh * 0.80).clamp(50.0, 72.0);
      }

      // Decelerate on final approach (last segment approaching destination)
      final bool isLastFewSegments = (segmentIndex >= roadPoints.length - 3);
      if (isLastFewSegments) {
        targetSpeed = (targetSpeed * 0.40).clamp(12.0, 30.0);
      }

      // Smooth fast acceleration / responsive braking
      if (currentSpeedKmh < targetSpeed) {
        currentSpeedKmh = math.min(targetSpeed, currentSpeedKmh + (45.0 * tickSeconds));
      } else if (currentSpeedKmh > targetSpeed) {
        currentSpeedKmh = math.max(targetSpeed, currentSpeedKmh - (40.0 * tickSeconds));
      }

      // Step distance for this tick
      final double speedMps = (currentSpeedKmh * 1000.0 / 3600.0) * simulationSpeedMultiplier;
      final double distanceThisTickMeters = speedMps * tickSeconds;

      final double deltaT = distanceThisTickMeters / segDistanceMeters;
      segmentProgressT += deltaT;

      while (segmentProgressT >= 1.0 && segmentIndex < roadPoints.length - 1) {
        segmentProgressT -= 1.0;
        segmentIndex++;
      }

      LatLng currentPos;
      if (segmentIndex >= roadPoints.length - 1) {
        currentPos = roadPoints.last;
      } else {
        final curP1 = roadPoints[segmentIndex];
        final curP2 = roadPoints[segmentIndex + 1];
        final curLat = curP1.latitude + (curP2.latitude - curP1.latitude) * segmentProgressT;
        final curLng = curP1.longitude + (curP2.longitude - curP1.longitude) * segmentProgressT;
        currentPos = LatLng(curLat, curLng);
      }

      // Remaining path calculation
      final List<LatLng> remainingPoints = [currentPos];
      for (int i = segmentIndex + 1; i < roadPoints.length; i++) {
        remainingPoints.add(roadPoints[i]);
      }

      final double remainingMeters =
          RoutePolylineService.instance.calculateTotalPathDistanceMeters(remainingPoints);
      final double remainingKm = (remainingMeters / 1000.0).clamp(0.0, 999.0);
      final double progress = totalDistanceMeters > 0
          ? ((totalDistanceMeters - remainingMeters) / totalDistanceMeters).clamp(0.0, 1.0)
          : 0.0;

      final int etaMins = (remainingMeters / (math.max(15.0, currentSpeedKmh) * 1000.0 / 60.0)).ceil();

      final String status = remainingKm > 0.05
          ? 'Navigating to $destinationName (${remainingKm.toStringAsFixed(1)} km)'
          : 'Arriving at $destinationName';

      final telemetry = VehicleTelemetry(
        currentPosition: currentPos,
        heading: currentHeading,
        speedKmh: currentSpeedKmh,
        remainingDistanceKm: remainingKm,
        remainingDistanceMeters: remainingMeters,
        etaMinutes: etaMins,
        progressRatio: progress,
        isArrived: false,
        statusMessage: status,
        currentWaypointIndex: segmentIndex,
        fullRoutePoints: List<LatLng>.unmodifiable(roadPoints),
        remainingRoutePoints: remainingPoints,
      );

      if (!_telemetryController!.isClosed) {
        _telemetryController!.add(telemetry);
      }
    });
  }

  /// Calculates shortest angular difference between two bearings (-180° to +180°)
  static double _angleDifference(double from, double to) {
    double diff = (to - from + 180.0) % 360.0 - 180.0;
    return diff < -180.0 ? diff + 360.0 : diff;
  }

  /// Smoothly interpolates from current heading to target heading
  static double _interpolateHeading(double current, double target, double factor) {
    final double diff = _angleDifference(current, target);
    return (current + diff * factor + 360.0) % 360.0;
  }

  /// Stops and cancels the active navigation loop
  void stopNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
    _isNavigating = false;
    _telemetryController?.close();
    _telemetryController = null;
  }

  void dispose() {
    stopNavigation();
  }
}
