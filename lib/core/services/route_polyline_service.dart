import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Cost-effective, high-performance polyline calculation and styling service
/// for real-time delivery journeys with Google Directions API & OSRM fallback.
class RoutePolylineService {
  static RoutePolylineService? _instance;
  static RoutePolylineService get instance => _instance ??= RoutePolylineService();

  http.Client? _client;
  final Map<String, List<LatLng>> _routeCache = {};

  RoutePolylineService({http.Client? client}) : _client = client;

  http.Client get _httpClient => _client ??= http.Client();

  String get _apiKey {
    try {
      return dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ??
          dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Fetches real road waypoints between two coordinates.
  /// Priority: 1. Same coords fast-path -> 2. Cache -> 3. Google Directions API (Native) -> 4. OSRM Driving Engine (CORS enabled) -> 5. Spline Fallback
  Future<List<LatLng>> fetchRoadRoute(LatLng start, LatLng end) async {
    // 0a. Identical coordinates fast-path (~1 meter threshold)
    final latDiff = (end.latitude - start.latitude).abs();
    final lngDiff = (end.longitude - start.longitude).abs();
    if (latDiff < 0.00001 && lngDiff < 0.00001) {
      return [start, end];
    }

    // 0b. Cache lookup with 4 decimal digits (~11 meters quantization)
    final cacheKey =
        '${start.latitude.toStringAsFixed(4)},${start.longitude.toStringAsFixed(4)}->${end.latitude.toStringAsFixed(4)},${end.longitude.toStringAsFixed(4)}';

    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey]!;
    }

    // 1. Google Directions API (Native platforms only - browser CORS policy prevents direct REST HTTP requests on Flutter Web)
    if (!kIsWeb && _apiKey.isNotEmpty && !_apiKey.startsWith('your_') && !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
          'origin': '${start.latitude},${start.longitude}',
          'destination': '${end.latitude},${end.longitude}',
          'mode': 'driving',
          'key': _apiKey,
        });

        final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final routes = data['routes'] as List<dynamic>?;
            if (routes != null && routes.isNotEmpty) {
              final overviewPolyline = routes.first['overview_polyline'] as Map<String, dynamic>?;
              final pointsEncoded = overviewPolyline?['points'] as String?;
              if (pointsEncoded != null && pointsEncoded.isNotEmpty) {
                final points = decodePolyline(pointsEncoded);
                if (points.isNotEmpty) {
                  _routeCache[cacheKey] = points;
                  return points;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Google Directions API error, using OSRM fallback: $e');
      }
    }

    // 2. OSRM (Open Source Routing Machine) Fallback (Provides real road routing with full CORS headers on Web & resilient native fallback)
    try {
      final uri = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline');

      final response = await _httpClient.get(
        uri,
        headers: {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok') {
          final routes = data['routes'] as List<dynamic>?;
          if (routes != null && routes.isNotEmpty) {
            final geometry = routes.first['geometry'] as String?;
            if (geometry != null && geometry.isNotEmpty) {
              final points = decodePolyline(geometry);
              if (points.isNotEmpty) {
                _routeCache[cacheKey] = points;
                return points;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM Route fallback error: $e');
    }

    // 3. Mathematical Spline fallback
    final fallback = generateSmoothPath(start, end);
    _routeCache[cacheKey] = fallback;
    return fallback;
  }

  /// Decodes a Google / OSRM encoded polyline string into a list of LatLng waypoints.
  List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final double latitude = lat / 1E5;
      final double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }
    return poly;
  }

  /// Generates a set of real road journey polylines connecting Restaurant -> Driver -> Customer asynchronously
  Future<Set<Polyline>> generateRealRoadJourneyPolylines({
    required LatLng? storeLocation,
    required LatLng? driverLocation,
    required LatLng? customerLocation,
    Color activeColor = const Color(0xFFE52121),
    Color completedColor = const Color(0xFF94A3B8),
    Color upcomingColor = const Color(0xFF3B82F6),
    int width = 5,
    bool isPickedUp = false,
  }) async {
    final Set<Polyline> polylines = {};

    if (driverLocation == null && storeLocation == null && customerLocation == null) {
      return polylines;
    }

    if (storeLocation != null && driverLocation != null && customerLocation != null) {
      if (!isPickedUp) {
        // Leg 1: Driver -> Store (Active)
        final leg1Points = await fetchRoadRoute(driverLocation, storeLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_to_store_active'),
            points: leg1Points,
            color: activeColor,
            width: width,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dash(18), PatternItem.gap(8)],
          ),
        );

        // Leg 2: Store -> Customer (Upcoming)
        final leg2Points = await fetchRoadRoute(storeLocation, customerLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('store_to_customer_upcoming'),
            points: leg2Points,
            color: upcomingColor.withValues(alpha: 0.6),
            width: width - 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dot, PatternItem.gap(6)],
          ),
        );
      } else {
        // Leg 1: Store -> Driver (Completed)
        final leg1Points = await fetchRoadRoute(storeLocation, driverLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('store_to_driver_completed'),
            points: leg1Points,
            color: completedColor.withValues(alpha: 0.45),
            width: width - 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );

        // Leg 2: Driver -> Customer (Active Delivery)
        final leg2Points = await fetchRoadRoute(driverLocation, customerLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_to_customer_active'),
            points: leg2Points,
            color: activeColor,
            width: width + 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
      return polylines;
    }

    if (driverLocation != null && customerLocation != null) {
      final points = await fetchRoadRoute(driverLocation, customerLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_destination'),
          points: points,
          color: activeColor,
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    } else if (driverLocation != null && storeLocation != null) {
      final points = await fetchRoadRoute(driverLocation, storeLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_store'),
          points: points,
          color: activeColor,
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    } else if (storeLocation != null && customerLocation != null) {
      final points = await fetchRoadRoute(storeLocation, customerLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('store_to_customer_direct'),
          points: points,
          color: activeColor.withValues(alpha: 0.8),
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }

  /// Instant synchronous multi-point fallback path generator
  Set<Polyline> generateJourneyPolylines({
    required LatLng? storeLocation,
    required LatLng? driverLocation,
    required LatLng? customerLocation,
    Color activeColor = const Color(0xFFE52121),
    Color completedColor = const Color(0xFF94A3B8),
    Color upcomingColor = const Color(0xFF3B82F6),
    int width = 5,
    bool isPickedUp = false,
  }) {
    final Set<Polyline> polylines = {};

    if (driverLocation == null && storeLocation == null && customerLocation == null) {
      return polylines;
    }

    if (storeLocation != null && driverLocation != null && customerLocation != null) {
      if (!isPickedUp) {
        final leg1Points = generateSmoothPath(driverLocation, storeLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_to_store_active'),
            points: leg1Points,
            color: activeColor,
            width: width,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dash(18), PatternItem.gap(8)],
          ),
        );

        final leg2Points = generateSmoothPath(storeLocation, customerLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('store_to_customer_upcoming'),
            points: leg2Points,
            color: upcomingColor.withValues(alpha: 0.6),
            width: width - 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dot, PatternItem.gap(6)],
          ),
        );
      } else {
        final leg1Points = generateSmoothPath(storeLocation, driverLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('store_to_driver_completed'),
            points: leg1Points,
            color: completedColor.withValues(alpha: 0.45),
            width: width - 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );

        final leg2Points = generateSmoothPath(driverLocation, customerLocation);
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_to_customer_active'),
            points: leg2Points,
            color: activeColor,
            width: width + 1,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
      return polylines;
    }

    if (driverLocation != null && customerLocation != null) {
      final points = generateSmoothPath(driverLocation, customerLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_destination'),
          points: points,
          color: activeColor,
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    } else if (driverLocation != null && storeLocation != null) {
      final points = generateSmoothPath(driverLocation, storeLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_store'),
          points: points,
          color: activeColor,
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    } else if (storeLocation != null && customerLocation != null) {
      final points = generateSmoothPath(storeLocation, customerLocation);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('store_to_customer_direct'),
          points: points,
          color: activeColor.withValues(alpha: 0.8),
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }

  /// Generates a realistic intermediate multi-point path between two LatLngs with subtle curvature
  List<LatLng> generateSmoothPath(LatLng start, LatLng end, {int steps = 16}) {
    final List<LatLng> path = [];
    final double latDiff = end.latitude - start.latitude;
    final double lngDiff = end.longitude - start.longitude;

    if (latDiff.abs() < 0.00001 && lngDiff.abs() < 0.00001) {
      return [start, end];
    }

    final double perpLat = -lngDiff * 0.08;
    final double perpLng = latDiff * 0.08;

    for (int i = 0; i <= steps; i++) {
      final double t = i / steps.toDouble();
      final double u = 1 - t;
      final double tt = t * t;
      final double uu = u * u;
      final double tu2 = 2 * u * t;

      final double ctrlLat = (start.latitude + end.latitude) / 2 + perpLat;
      final double ctrlLng = (start.longitude + end.longitude) / 2 + perpLng;

      final double lat = uu * start.latitude + tu2 * ctrlLat + tt * end.latitude;
      final double lng = uu * start.longitude + tu2 * ctrlLng + tt * end.longitude;
      path.add(LatLng(lat, lng));
    }
    return path;
  }

  /// Calculates bearing / heading in degrees between two coordinates
  double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * (math.pi / 180.0);
    final double lon1 = start.longitude * (math.pi / 180.0);
    final double lat2 = end.latitude * (math.pi / 180.0);
    final double lon2 = end.longitude * (math.pi / 180.0);

    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final double radians = math.atan2(y, x);
    final double degrees = (radians * (180.0 / math.pi) + 360.0) % 360.0;
    return degrees;
  }

  /// Calculates LatLngBounds to fit all active markers on screen
  LatLngBounds computeBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(13.0827, 80.2707),
        northeast: const LatLng(13.0827, 80.2707),
      );
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    const double padding = 0.003;
    return LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
  }

  /// Clears in-memory route cache
  void clearCache() {
    _routeCache.clear();
  }
}
