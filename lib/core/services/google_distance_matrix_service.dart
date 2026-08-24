import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Data class representing the computed distance and ETA travel time.
class DistanceMatrixResult {
  final double distanceKm;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final int durationMinutes;
  final String durationText;
  final int? durationInTrafficSeconds;
  final String? durationInTrafficText;
  final String status;
  final bool isFallback;

  const DistanceMatrixResult({
    required this.distanceKm,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationMinutes,
    required this.durationText,
    this.durationInTrafficSeconds,
    this.durationInTrafficText,
    this.status = 'OK',
    this.isFallback = false,
  });

  /// Formatted ETA string preferred for UI display (uses traffic duration when available).
  String get effectiveEtaText {
    if (durationInTrafficText != null && durationInTrafficText!.isNotEmpty) {
      return durationInTrafficText!;
    }
    if (durationText.isNotEmpty) {
      return durationText;
    }
    if (durationMinutes <= 1) {
      return '1 min';
    }
    return '$durationMinutes mins';
  }

  /// Formatted distance string preferred for UI display.
  String get effectiveDistanceText {
    if (distanceText.isNotEmpty) {
      return distanceText;
    }
    if (distanceKm < 1.0) {
      return '$distanceMeters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  factory DistanceMatrixResult.fromGoogleElement(Map<String, dynamic> element) {
    final status = element['status']?.toString() ?? 'ZERO_RESULTS';
    if (status != 'OK') {
      return DistanceMatrixResult(
        distanceKm: 0.0,
        distanceMeters: 0,
        distanceText: '0 km',
        durationSeconds: 0,
        durationMinutes: 0,
        durationText: '0 mins',
        status: status,
      );
    }

    final distance = element['distance'] as Map<String, dynamic>?;
    final duration = element['duration'] as Map<String, dynamic>?;
    final durationInTraffic = element['duration_in_traffic'] as Map<String, dynamic>?;

    final meters = (distance?['value'] as num?)?.toInt() ?? 0;
    final distText = distance?['text']?.toString() ?? '${(meters / 1000).toStringAsFixed(1)} km';
    final seconds = (duration?['value'] as num?)?.toInt() ?? 0;
    final durText = duration?['text']?.toString() ?? '${(seconds / 60).round()} mins';

    int? trafficSeconds;
    String? trafficText;
    if (durationInTraffic != null) {
      trafficSeconds = (durationInTraffic['value'] as num?)?.toInt();
      trafficText = durationInTraffic['text']?.toString();
    }

    final mins = math.max(1, (trafficSeconds ?? seconds) ~/ 60);

    return DistanceMatrixResult(
      distanceKm: meters / 1000.0,
      distanceMeters: meters,
      distanceText: distText,
      durationSeconds: seconds,
      durationMinutes: mins,
      durationText: durText,
      durationInTrafficSeconds: trafficSeconds,
      durationInTrafficText: trafficText,
      status: status,
      isFallback: false,
    );
  }

  factory DistanceMatrixResult.fallback({
    required double distanceKm,
    required int durationMinutes,
  }) {
    final meters = (distanceKm * 1000).round();
    final distText = distanceKm < 1.0
        ? '$meters m'
        : '${distanceKm.toStringAsFixed(1)} km';
    final durText = durationMinutes <= 1 ? '1 min' : '$durationMinutes mins';

    return DistanceMatrixResult(
      distanceKm: distanceKm,
      distanceMeters: meters,
      distanceText: distText,
      durationSeconds: durationMinutes * 60,
      durationMinutes: durationMinutes,
      durationText: durText,
      durationInTrafficSeconds: durationMinutes * 60,
      durationInTrafficText: durText,
      status: 'OK',
      isFallback: true,
    );
  }
}

/// Service providing Distance Matrix calculations with Firebase Callable Cloud Function,
/// Google Distance Matrix API, OSRM real-road driving fallback, Haversine urban traffic estimation, and quantized coordinate caching.
class GoogleDistanceMatrixService {
  static GoogleDistanceMatrixService? _instance;
  static GoogleDistanceMatrixService get instance =>
      _instance ??= GoogleDistanceMatrixService();

  http.Client? _client;
  FirebaseFunctions? _functions;
  final Map<String, DistanceMatrixResult> _cache = {};

  GoogleDistanceMatrixService({http.Client? client, FirebaseFunctions? functions})
      : _client = client,
        _functions = functions;

  http.Client get _httpClient => _client ??= http.Client();

  FirebaseFunctions? get _firebaseFunctions {
    if (_functions != null) return _functions;
    try {
      if (Firebase.apps.isNotEmpty) {
        return _functions = FirebaseFunctions.instance;
      }
    } catch (_) {}
    return null;
  }

  String get _apiKey {
    try {
      return dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ??
          dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Computes accurate distance and ETA between origin and destination coordinates.
  /// Priority:
  /// 1. Coincident coordinates fast path (~1m distance)
  /// 2. Quantized in-memory cache (~10m precision)
  /// 3. Firebase Callable Cloud Function (Enterprise Zero Key Exposure + Cache)
  /// 4. Google Distance Matrix API (Native)
  /// 5. OSRM Routing Engine API (CORS enabled for Flutter Web)
  /// 6. Haversine Urban Traffic Model Fallback
  Future<DistanceMatrixResult> computeDistanceAndEta({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
    DateTime? departureTime,
  }) async {
    // 1. Identical coordinates fast-path
    final latDiff = (destination.latitude - origin.latitude).abs();
    final lngDiff = (destination.longitude - origin.longitude).abs();
    if (latDiff < 0.00001 && lngDiff < 0.00001) {
      return const DistanceMatrixResult(
        distanceKm: 0.0,
        distanceMeters: 0,
        distanceText: '0 m',
        durationSeconds: 0,
        durationMinutes: 0,
        durationText: '0 mins',
        durationInTrafficSeconds: 0,
        durationInTrafficText: '0 mins',
        status: 'OK',
        isFallback: false,
      );
    }

    // 2. Quantized cache key (~10m precision)
    final cacheKey =
        '${origin.latitude.toStringAsFixed(4)},${origin.longitude.toStringAsFixed(4)}->${destination.latitude.toStringAsFixed(4)},${destination.longitude.toStringAsFixed(4)}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 3. Firebase Callable Function (Enterprise Security: Zero client-side API Key & Server Cache for Mobile/Native)
    if (!kIsWeb && _firebaseFunctions != null) {
      try {
        final callable = _firebaseFunctions!.httpsCallable(
          'getDeliveryRouteAndETA',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 3)),
        );
        final response = await callable.call<Map<dynamic, dynamic>>({
          'originLat': origin.latitude,
          'originLng': origin.longitude,
          'destLat': destination.latitude,
          'destLng': destination.longitude,
        });

        final data = response.data;
        final durationText = data['durationText']?.toString() ?? '-- mins';
        final durationSeconds = (data['durationValue'] as num?)?.toInt() ?? 0;
        final distanceText = data['distanceText']?.toString() ?? '-- km';
        final distanceMeters = (data['distanceValue'] as num?)?.toInt() ?? 0;

        if (distanceMeters > 0 || durationSeconds > 0) {
          final result = DistanceMatrixResult(
            distanceKm: distanceMeters / 1000.0,
            distanceMeters: distanceMeters,
            distanceText: distanceText,
            durationSeconds: durationSeconds,
            durationMinutes: math.max(1, durationSeconds ~/ 60),
            durationText: durationText,
            durationInTrafficSeconds: durationSeconds,
            durationInTrafficText: durationText,
            status: 'OK',
            isFallback: false,
          );
          _cache[cacheKey] = result;
          return result;
        }
      } catch (_) {}
    }

    // 4. Google Distance Matrix API (Native platforms)
    if (!kIsWeb &&
        _apiKey.isNotEmpty &&
        !_apiKey.startsWith('your_') &&
        !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final queryParams = {
          'origins': '${origin.latitude},${origin.longitude}',
          'destinations': '${destination.latitude},${destination.longitude}',
          'mode': mode,
          'departure_time': 'now',
          'traffic_model': 'best_guess',
          'key': _apiKey,
        };

        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/distancematrix/json',
          queryParams,
        );

        final response =
            await _httpClient.get(uri).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final rows = data['rows'] as List<dynamic>?;
            if (rows != null && rows.isNotEmpty) {
              final elements = rows.first['elements'] as List<dynamic>?;
              if (elements != null && elements.isNotEmpty) {
                final element = elements.first as Map<String, dynamic>;
                if (element['status'] == 'OK') {
                  final result = DistanceMatrixResult.fromGoogleElement(element);
                  _cache[cacheKey] = result;
                  return result;
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // 5. High-Performance Driving Engine API (OSM & OSRM with full Web CORS support)
    final routingUrls = [
      'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=false',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=false',
    ];

    for (final url in routingUrls) {
      try {
        final uri = Uri.parse(url);
        final response = await _httpClient.get(
          uri,
          headers: kIsWeb ? null : {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['code'] == 'Ok') {
            final routes = data['routes'] as List<dynamic>?;
            if (routes != null && routes.isNotEmpty) {
              final route = routes.first as Map<String, dynamic>;
              final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
              final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;

              final distanceKm = distanceMeters / 1000.0;
              // Add a realistic 15% urban congestion factor to OSRM pure freeflow time
              final adjustedSeconds = (durationSeconds * 1.15).round();
              final durationMinutes = math.max(1, (adjustedSeconds / 60).round());

              final result = DistanceMatrixResult(
                distanceKm: distanceKm,
                distanceMeters: distanceMeters.round(),
                distanceText: distanceKm < 1.0
                    ? '${distanceMeters.round()} m'
                    : '${distanceKm.toStringAsFixed(1)} km',
                durationSeconds: adjustedSeconds,
                durationMinutes: durationMinutes,
                durationText: durationMinutes <= 1
                    ? '1 min'
                    : '$durationMinutes mins',
                durationInTrafficSeconds: adjustedSeconds,
                durationInTrafficText: durationMinutes <= 1
                    ? '1 min'
                    : '$durationMinutes mins',
                status: 'OK',
                isFallback: false,
              );

              _cache[cacheKey] = result;
              return result;
            }
          }
        }
      } catch (_) {}
    }

    // 5. Haversine Urban Traffic Model Fallback
    final haversineDistanceKm = calculateHaversineDistanceKm(origin, destination);
    // Urban speed ~22 km/h (0.366 km/min) + 2 min base buffer for signals & turns
    final etaMinutes = math.max(2, (haversineDistanceKm / 0.366 + 2.0).round());

    final fallbackResult = DistanceMatrixResult.fallback(
      distanceKm: haversineDistanceKm,
      durationMinutes: etaMinutes,
    );

    _cache[cacheKey] = fallbackResult;
    return fallbackResult;
  }

  /// Calculates Haversine distance in kilometers between two LatLng coordinates.
  double calculateHaversineDistanceKm(LatLng start, LatLng end) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        math.cos((end.latitude - start.latitude) * p) / 2 +
        math.cos(start.latitude * p) *
            math.cos(end.latitude * p) *
            (1 - math.cos((end.longitude - start.longitude) * p)) /
            2;
    return 12742.0 * math.asin(math.sqrt(math.max(0.0, a))); // 2 * R; R = 6371 km
  }

  /// Clears in-memory distance matrix cache.
  void clearCache() {
    _cache.clear();
  }
}
