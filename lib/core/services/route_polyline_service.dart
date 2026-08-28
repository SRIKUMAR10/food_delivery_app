import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'google_maps_loader.dart';

/// Represents turn maneuver types parsed strictly from real routing APIs (Google Directions / OSRM)
enum RouteManeuver {
  turnLeft,
  turnRight,
  turnSlightLeft,
  turnSlightRight,
  turnSharpLeft,
  turnSharpRight,
  uturn,
  straight,
  roundabout,
  arrive,
  depart,
  unknown;

  static RouteManeuver fromString(String? val) {
    if (val == null || val.isEmpty) return RouteManeuver.unknown;
    final lower = val.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (lower.contains('slight_left') || lower.contains('turn_slight_left')) {
      return RouteManeuver.turnSlightLeft;
    }
    if (lower.contains('slight_right') || lower.contains('turn_slight_right')) {
      return RouteManeuver.turnSlightRight;
    }
    if (lower.contains('sharp_left') || lower.contains('turn_sharp_left')) {
      return RouteManeuver.turnSharpLeft;
    }
    if (lower.contains('sharp_right') || lower.contains('turn_sharp_right')) {
      return RouteManeuver.turnSharpRight;
    }
    if (lower.contains('u_turn') || lower.contains('uturn')) {
      return RouteManeuver.uturn;
    }
    if (lower.contains('left')) return RouteManeuver.turnLeft;
    if (lower.contains('right')) return RouteManeuver.turnRight;
    if (lower.contains('straight') || lower.contains('continue')) {
      return RouteManeuver.straight;
    }
    if (lower.contains('roundabout') || lower.contains('rotary')) {
      return RouteManeuver.roundabout;
    }
    if (lower.contains('arrive') || lower.contains('destination')) {
      return RouteManeuver.arrive;
    }
    if (lower.contains('depart') || lower.contains('start')) {
      return RouteManeuver.depart;
    }
    return RouteManeuver.straight;
  }
}

/// Data class representing a verified physical road navigation step from real APIs
class RouteStepInfo {
  final String instruction;
  final RouteManeuver maneuver;
  final String distanceText;
  final int distanceMeters;
  final String durationText;
  final int durationSeconds;
  final LatLng startLocation;
  final LatLng endLocation;
  final List<LatLng> polylinePoints;
  final String streetName;

  const RouteStepInfo({
    required this.instruction,
    required this.maneuver,
    required this.distanceText,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    required this.startLocation,
    required this.endLocation,
    this.polylinePoints = const [],
    this.streetName = '',
  });

  /// Parse from Google Directions API Step JSON
  factory RouteStepInfo.fromGoogleStep(Map<String, dynamic> json) {
    final rawInstruction = json['html_instructions']?.toString() ?? '';
    final cleanInstruction = rawInstruction
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final maneuverStr = json['maneuver']?.toString() ?? '';
    final maneuver = RouteManeuver.fromString(
        maneuverStr.isNotEmpty ? maneuverStr : cleanInstruction);

    final distanceMap = json['distance'] as Map<String, dynamic>? ?? {};
    final distanceText = distanceMap['text']?.toString() ?? '';
    final distanceMeters = (distanceMap['value'] as num?)?.toInt() ?? 0;

    final durationMap = json['duration'] as Map<String, dynamic>? ?? {};
    final durationText = durationMap['text']?.toString() ?? '';
    final durationSeconds = (durationMap['value'] as num?)?.toInt() ?? 0;

    final startLocMap = json['start_location'] as Map<String, dynamic>? ?? {};
    final endLocMap = json['end_location'] as Map<String, dynamic>? ?? {};

    final startLat = (startLocMap['lat'] as num?)?.toDouble() ?? 0.0;
    final startLng = (startLocMap['lng'] as num?)?.toDouble() ?? 0.0;
    final endLat = (endLocMap['lat'] as num?)?.toDouble() ?? 0.0;
    final endLng = (endLocMap['lng'] as num?)?.toDouble() ?? 0.0;

    final polyMap = json['polyline'] as Map<String, dynamic>? ?? {};
    final polyStr = polyMap['points']?.toString() ?? '';
    final points = polyStr.isNotEmpty
        ? RoutePolylineService.instance.decodePolyline(polyStr)
        : <LatLng>[];

    return RouteStepInfo(
      instruction:
          cleanInstruction.isNotEmpty ? cleanInstruction : 'Continue on route',
      maneuver: maneuver,
      distanceText: distanceText,
      distanceMeters: distanceMeters,
      durationText: durationText,
      durationSeconds: durationSeconds,
      startLocation: LatLng(startLat, startLng),
      endLocation: LatLng(endLat, endLng),
      polylinePoints: points,
    );
  }

  /// Parse from OSRM Step JSON
  factory RouteStepInfo.fromOsrmStep(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final maneuverMap = json['maneuver'] as Map<String, dynamic>? ?? {};
    final type = maneuverMap['type']?.toString() ?? '';
    final modifier = maneuverMap['modifier']?.toString() ?? '';
    final maneuver = RouteManeuver.fromString('$type $modifier');

    final distanceM = (json['distance'] as num?)?.toDouble() ?? 0.0;
    final durationSecs = (json['duration'] as num?)?.toDouble() ?? 0.0;

    String instruction = '';
    if (type == 'arrive') {
      instruction = 'You have arrived at your destination';
    } else if (type == 'depart') {
      instruction =
          name.isNotEmpty ? 'Head on $name' : 'Head towards destination';
    } else if (modifier.isNotEmpty && name.isNotEmpty) {
      instruction = 'Turn ${modifier.replaceAll('_', ' ')} onto $name';
    } else if (name.isNotEmpty) {
      instruction = 'Continue on $name';
    } else {
      instruction = 'Continue along the route';
    }

    final distanceMeters = distanceM.round();
    final distanceText = distanceMeters >= 1000
        ? '${(distanceMeters / 1000.0).toStringAsFixed(1)} km'
        : '$distanceMeters m';
    final durationSeconds = durationSecs.round();
    final durationText = '${(durationSeconds / 60).round().clamp(1, 120)} mins';

    final locList = maneuverMap['location'] as List<dynamic>?;
    final startLat = (locList != null && locList.length >= 2)
        ? (locList[1] as num).toDouble()
        : 0.0;
    final startLng = (locList != null && locList.length >= 2)
        ? (locList[0] as num).toDouble()
        : 0.0;

    final geometryStr = json['geometry']?.toString() ?? '';
    final points = geometryStr.isNotEmpty
        ? RoutePolylineService.instance.decodePolyline(geometryStr)
        : <LatLng>[];
    final endLocation =
        points.isNotEmpty ? points.last : LatLng(startLat, startLng);

    return RouteStepInfo(
      instruction: instruction,
      maneuver: maneuver,
      distanceText: distanceText,
      distanceMeters: distanceMeters,
      durationText: durationText,
      durationSeconds: durationSeconds,
      startLocation: LatLng(startLat, startLng),
      endLocation: endLocation,
      polylinePoints: points,
      streetName: name,
    );
  }
}

/// Data class representing the result of snapping a raw GPS coordinate to a polyline route.
class RouteSnapResult {
  final LatLng snappedPosition;
  final int segmentIndex;
  final double bearing;
  final double distanceFromPolylineMeters;
  final double remainingDistanceMeters;
  final List<LatLng> remainingPoints;

  const RouteSnapResult({
    required this.snappedPosition,
    required this.segmentIndex,
    required this.bearing,
    required this.distanceFromPolylineMeters,
    required this.remainingDistanceMeters,
    required this.remainingPoints,
  });
}

/// Data class holding decoded route waypoints, ETA information, API bounds, and navigation steps.
class RouteAndEtaResult {
  final List<LatLng> points;
  final String durationText;
  final int durationSeconds;
  final String distanceText;
  final int distanceMeters;
  final bool isFromCloudFunction;
  final LatLngBounds? bounds;
  final List<RouteStepInfo> steps;
  final DateTime cachedAt;

  RouteAndEtaResult({
    required this.points,
    required this.durationText,
    required this.durationSeconds,
    required this.distanceText,
    required this.distanceMeters,
    this.isFromCloudFunction = false,
    this.bounds,
    this.steps = const [],
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  /// Empty result for loading, empty, or unverified error states
  factory RouteAndEtaResult.empty() {
    return RouteAndEtaResult(
      points: const [],
      durationText: '-- mins',
      durationSeconds: 0,
      distanceText: '-- km',
      distanceMeters: 0,
      steps: const [],
      cachedAt: DateTime.now(),
    );
  }

  /// Parse from Google Directions API JSON response
  factory RouteAndEtaResult.fromDirectionsJson(
    Map<String, dynamic> json, {
    List<LatLng>? decodedPoints,
  }) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const FormatException('No route found in Directions API response.');
    }

    final primaryRoute = routes.first as Map<String, dynamic>;
    final legs = primaryRoute['legs'] as List<dynamic>?;
    final firstLeg = (legs != null && legs.isNotEmpty)
        ? legs.first as Map<String, dynamic>?
        : null;

    final overviewPolyline =
        primaryRoute['overview_polyline'] as Map<String, dynamic>?;
    final pointsEncoded = overviewPolyline?['points'] as String?;

    List<LatLng> points = decodedPoints ?? <LatLng>[];
    final List<RouteStepInfo> parsedSteps = [];

    if (legs != null && legs.isNotEmpty) {
      for (final leg in legs) {
        final rawSteps =
            (leg as Map<String, dynamic>?)?['steps'] as List<dynamic>?;
        if (rawSteps != null) {
          for (final st in rawSteps) {
            if (st is Map<String, dynamic>) {
              parsedSteps.add(RouteStepInfo.fromGoogleStep(st));
            }
          }
        }
      }
    }

    if (points.isEmpty) {
      final List<LatLng> stepWaypoints = [];
      for (final s in parsedSteps) {
        for (final pt in s.polylinePoints) {
          if (stepWaypoints.isEmpty ||
              (stepWaypoints.last.latitude - pt.latitude).abs() > 0.000001 ||
              (stepWaypoints.last.longitude - pt.longitude).abs() > 0.000001) {
            stepWaypoints.add(pt);
          }
        }
      }

      if (stepWaypoints.length >= 2) {
        points = stepWaypoints;
      } else if (pointsEncoded != null && pointsEncoded.isNotEmpty) {
        points = RoutePolylineService.instance.decodePolyline(pointsEncoded);
      }
    }

    final distanceMap = firstLeg?['distance'] as Map<String, dynamic>? ?? {};
    final distanceText = distanceMap['text']?.toString() ?? '-- km';
    final distanceMeters = (distanceMap['value'] as num?)?.toInt() ?? 0;

    final durationMap = firstLeg?['duration'] as Map<String, dynamic>? ?? {};
    final durationText = durationMap['text']?.toString() ?? '-- mins';
    final durationSeconds = (durationMap['value'] as num?)?.toInt() ?? 0;

    LatLngBounds? routeBounds;
    final boundsMap = primaryRoute['bounds'] as Map<String, dynamic>?;
    if (boundsMap != null) {
      final ne = boundsMap['northeast'] as Map<String, dynamic>?;
      final sw = boundsMap['southwest'] as Map<String, dynamic>?;
      if (ne != null && sw != null) {
        final neLat = (ne['lat'] as num?)?.toDouble();
        final neLng = (ne['lng'] as num?)?.toDouble();
        final swLat = (sw['lat'] as num?)?.toDouble();
        final swLng = (sw['lng'] as num?)?.toDouble();
        if (neLat != null && neLng != null && swLat != null && swLng != null) {
          routeBounds = LatLngBounds(
            southwest: LatLng(swLat, swLng),
            northeast: LatLng(neLat, neLng),
          );
        }
      }
    }

    return RouteAndEtaResult(
      points: points,
      durationText: durationText,
      durationSeconds: durationSeconds,
      distanceText: distanceText,
      distanceMeters: distanceMeters,
      bounds: routeBounds,
      steps: parsedSteps,
      cachedAt: DateTime.now(),
    );
  }

  /// Parse from OSRM JSON response
  factory RouteAndEtaResult.fromOsrmJson(
    Map<String, dynamic> json, {
    List<LatLng>? decodedPoints,
  }) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const FormatException('No routes found in OSRM response.');
    }

    final primaryRoute = routes.first as Map<String, dynamic>;
    final geometry = primaryRoute['geometry'] as String?;
    List<LatLng> points = decodedPoints ?? <LatLng>[];
    final List<RouteStepInfo> parsedSteps = [];

    final legs = primaryRoute['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      for (final leg in legs) {
        final rawSteps =
            (leg as Map<String, dynamic>?)?['steps'] as List<dynamic>?;
        if (rawSteps != null) {
          for (final st in rawSteps) {
            if (st is Map<String, dynamic>) {
              parsedSteps.add(RouteStepInfo.fromOsrmStep(st));
            }
          }
        }
      }
    }

    if (points.isEmpty) {
      final List<LatLng> stepWaypoints = [];
      for (final s in parsedSteps) {
        for (final pt in s.polylinePoints) {
          if (stepWaypoints.isEmpty ||
              (stepWaypoints.last.latitude - pt.latitude).abs() > 0.000001 ||
              (stepWaypoints.last.longitude - pt.longitude).abs() > 0.000001) {
            stepWaypoints.add(pt);
          }
        }
      }

      if (stepWaypoints.length >= 2) {
        points = stepWaypoints;
      } else if (geometry != null && geometry.isNotEmpty) {
        points = RoutePolylineService.instance.decodePolyline(geometry);
      }
    }

    final durationSecs = (primaryRoute['duration'] as num?)?.toDouble() ?? 0.0;
    final distanceM = (primaryRoute['distance'] as num?)?.toDouble() ?? 0.0;
    final durMins = (durationSecs / 60.0).round().clamp(1, 120);
    final distKm = distanceM / 1000.0;

    return RouteAndEtaResult(
      points: points,
      durationText: '$durMins mins',
      durationSeconds: durationSecs.round(),
      distanceText: '${distKm.toStringAsFixed(1)} km',
      distanceMeters: distanceM.round(),
      steps: parsedSteps,
      cachedAt: DateTime.now(),
    );
  }

  /// Parse from Firebase Cloud Function callable response data
  factory RouteAndEtaResult.fromCallableData(
    Map<dynamic, dynamic> data, {
    List<LatLng>? decodedPoints,
  }) {
    final pointsEncoded = data['points']?.toString() ?? '';
    final points = decodedPoints ??
        (pointsEncoded.isNotEmpty
            ? RoutePolylineService.instance.decodePolyline(pointsEncoded)
            : <LatLng>[]);
    final durationText = data['durationText']?.toString() ?? '-- mins';
    final durationSeconds = (data['durationValue'] as num?)?.toInt() ?? 0;
    final distanceText = data['distanceText']?.toString() ?? '-- km';
    final distanceMeters = (data['distanceValue'] as num?)?.toInt() ?? 0;

    return RouteAndEtaResult(
      points: points,
      durationText: durationText,
      durationSeconds: durationSeconds,
      distanceText: distanceText,
      distanceMeters: distanceMeters,
      isFromCloudFunction: true,
      cachedAt: DateTime.now(),
    );
  }
}

/// Cache entry with expiration timestamp for TTL management
class _CachedRouteEntry {
  final RouteAndEtaResult result;
  final DateTime cachedAt;

  _CachedRouteEntry(this.result, [DateTime? cachedAt])
      : cachedAt = cachedAt ?? DateTime.now();

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

/// 100% Real-Data-Source polyline calculation and styling service
/// for real-time delivery journeys using Google Directions API & OSRM Real Road Engine.
/// Strictly eliminates fake curves, synthetic splines, and imaginary roads.
class RoutePolylineService {
  static RoutePolylineService? _instance;
  static RoutePolylineService get instance =>
      _instance ??= RoutePolylineService();

  /// Default cache expiration duration (10 minutes)
  static const Duration defaultCacheTtl = Duration(minutes: 10);

  http.Client? _client;
  FirebaseFunctions? _functions;
  final Map<String, _CachedRouteEntry> _routeCache = {};

  RoutePolylineService({http.Client? client, FirebaseFunctions? functions})
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
      return dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ??
          dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _buildCacheKey(LatLng start, LatLng end) =>
      '${start.latitude.toStringAsFixed(5)},${start.longitude.toStringAsFixed(5)}->${end.latitude.toStringAsFixed(5)},${end.longitude.toStringAsFixed(5)}';

  /// Checks whether a genuine, non-expired real-road route exists in cache
  bool isCached(LatLng start, LatLng end) {
    final key = _buildCacheKey(start, end);
    final entry = _routeCache[key];
    if (entry == null) return false;
    return !entry.isExpired(defaultCacheTtl) && entry.result.points.length >= 2;
  }

  /// Fetches 100% real road waypoints between two coordinates.
  /// Strictly queries verified sources:
  /// 1. Identical coordinates fast-path
  /// 2. High-precision Real-Road Cache
  /// 3. Google Maps JS DirectionsService (Web)
  /// 4. Firebase Callable Function (Native)
  /// 5. Google Directions API REST (Native)
  /// 6. OSM / OSRM Real Road Routing Engine
  /// If all verified sources fail, returns empty list [] without fabricating fake routes.
  Future<List<LatLng>> fetchRoadRoute(LatLng start, LatLng end) async {
    final result = await fetchRoadRouteAndETA(start, end);
    return result.points;
  }

  /// Helper to fetch route via Google Maps JS DirectionsService on Web
  Future<RouteAndEtaResult?> _fetchGoogleDirectionsViaWebJs(
      LatLng start, LatLng end) async {
    if (!kIsWeb) return null;
    try {
      final res = await fetchWebGoogleDirectionsRoute(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      if (res != null && res['status'] == 'OK') {
        final List<LatLng> points = [];
        final rawPoints = res['points'];
        if (rawPoints is List) {
          for (final p in rawPoints) {
            if (p is Map) {
              final lat = (p['lat'] as num?)?.toDouble();
              final lng = (p['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                points.add(LatLng(lat, lng));
              }
            }
          }
        }
        if (points.isEmpty &&
            res['overview_polyline'] is String &&
            (res['overview_polyline'] as String).isNotEmpty) {
          points.addAll(decodePolyline(res['overview_polyline'] as String));
        }
        if (points.isNotEmpty) {
          return RouteAndEtaResult(
            points: points,
            durationText: res['durationText']?.toString() ?? '',
            durationSeconds: (res['durationSeconds'] as num?)?.toInt() ?? 0,
            distanceText: res['distanceText']?.toString() ?? '',
            distanceMeters: (res['distanceMeters'] as num?)?.toInt() ?? 0,
          );
        }
      }
    } catch (e) {
      debugPrint('[Directions JS Web] Error: $e');
    }
    return null;
  }

  /// Fetches real road waypoints and ETA between two coordinates using 100% verified real data sources
  Future<RouteAndEtaResult> fetchRoadRouteAndETA(
      LatLng start, LatLng end) async {
    // 0a. Identical coordinates fast-path (<1m distance)
    final latDiff = (end.latitude - start.latitude).abs();
    final lngDiff = (end.longitude - start.longitude).abs();
    if (latDiff < 0.00001 && lngDiff < 0.00001) {
      return RouteAndEtaResult(
        points: [start, end],
        durationText: '0 mins',
        durationSeconds: 0,
        distanceText: '0 km',
        distanceMeters: 0,
      );
    }

    final cacheKey = _buildCacheKey(start, end);

    // 0b. Real-road Cache lookup
    if (_routeCache.containsKey(cacheKey)) {
      final entry = _routeCache[cacheKey]!;
      if (!entry.isExpired(defaultCacheTtl) &&
          entry.result.points.length >= 2) {
        return entry.result;
      } else if (entry.isExpired(defaultCacheTtl)) {
        _routeCache.remove(cacheKey);
      }
    }

    // 0c. Google Maps JS DirectionsService (Web)
    if (kIsWeb) {
      final webJsResult = await _fetchGoogleDirectionsViaWebJs(start, end);
      if (webJsResult != null && webJsResult.points.isNotEmpty) {
        _routeCache[cacheKey] = _CachedRouteEntry(webJsResult);
        return webJsResult;
      }
    }

    // 1. Firebase Callable Function (Native)
    if (!kIsWeb && _firebaseFunctions != null) {
      try {
        final callable = _firebaseFunctions!.httpsCallable(
          'getDeliveryRouteAndETA',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 4)),
        );
        final response = await callable.call<Map<dynamic, dynamic>>({
          'originLat': start.latitude,
          'originLng': start.longitude,
          'destLat': end.latitude,
          'destLng': end.longitude,
        });

        final data = response.data;
        final result = RouteAndEtaResult.fromCallableData(data);
        if (result.points.isNotEmpty) {
          _routeCache[cacheKey] = _CachedRouteEntry(result);
          return result;
        }
      } catch (_) {}
    }

    // 2. Google Directions API REST (Native)
    if (!kIsWeb &&
        _apiKey.isNotEmpty &&
        !_apiKey.startsWith('your_') &&
        !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uri = Uri.https(
            'maps.googleapis.com', '/maps/api/directions/json', {
          'origin': '${start.latitude},${start.longitude}',
          'destination': '${end.latitude},${end.longitude}',
          'mode': 'driving',
          'key': _apiKey,
        });

        final response =
            await _httpClient.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'UNKNOWN';

          if (status == 'OK') {
            final result = RouteAndEtaResult.fromDirectionsJson(data);
            if (result.points.isNotEmpty) {
              _routeCache[cacheKey] = _CachedRouteEntry(result);
              return result;
            }
          }
        }
      } catch (_) {}
    }

    // 3. Multi-Source Verified OSRM / OpenStreetMap Live Real Road Engines
    final routingUrls = [
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline&steps=true',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline&steps=true',
      'https://us-central1-food-delivery-app-cd4ca.cloudfunctions.net/getDeliveryRouteAndETAHttp?originLat=${start.latitude}&originLng=${start.longitude}&destLat=${end.latitude}&destLng=${end.longitude}',
    ];

    for (final url in routingUrls) {
      try {
        final uri = Uri.parse(url);
        final response = await _httpClient.get(
          uri,
          headers: kIsWeb
              ? null
              : {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['code'] == 'Ok' || data['status'] == 'OK') {
            final result = data['code'] == 'Ok'
                ? RouteAndEtaResult.fromOsrmJson(data)
                : RouteAndEtaResult.fromDirectionsJson(data);
            if (result.points.isNotEmpty) {
              _routeCache[cacheKey] = _CachedRouteEntry(result);
              return result;
            }
          }
        }
      } catch (e) {
        debugPrint('[Road Routing Engine] Error for $url: $e');
      }
    }

    // 4. Strict real-data policy: If no verified road data is returned, return empty result
    return RouteAndEtaResult.empty();
  }

  /// Decodes a Google / OSRM encoded polyline string into a list of LatLng waypoints safely.
  List<LatLng> decodePolyline(String encoded) {
    if (encoded.isEmpty) return [];

    final List<LatLng> poly = [];
    final sanitized = encoded.replaceAll(r'\\', r'\');
    int index = 0;
    final int len = sanitized.length;
    int lat = 0;
    int lng = 0;

    try {
      while (index < len) {
        int b;
        int shift = 0;
        int result = 0;
        do {
          if (index >= len) break;
          b = sanitized.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          if (index >= len) break;
          b = sanitized.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        final double latitude = lat / 1E5;
        final double longitude = lng / 1E5;

        // Coordinate sanity check
        if (latitude.abs() <= 90.0 && longitude.abs() <= 180.0) {
          poly.add(LatLng(latitude, longitude));
        }
      }
    } catch (_) {
      return poly;
    }
    return poly;
  }

  /// Generates a set of 100% real road journey polylines connecting Restaurant -> Driver -> Customer asynchronously
  Future<Set<Polyline>> generateRealRoadJourneyPolylines({
    required LatLng? storeLocation,
    required LatLng? driverLocation,
    required LatLng? customerLocation,
    Color activeColor = const Color(0xFF2563EB),
    Color completedColor = const Color(0xFF94A3B8),
    Color upcomingColor = const Color(0xFF38BDF8),
    int width = 6,
    bool isPickedUp = false,
  }) async {
    final Set<Polyline> polylines = {};

    if (driverLocation == null &&
        storeLocation == null &&
        customerLocation == null) {
      return polylines;
    }

    if (storeLocation != null &&
        driverLocation != null &&
        customerLocation != null) {
      if (!isPickedUp) {
        // Leg 1: Driver -> Store (Active)
        final leg1Points = await fetchRoadRoute(driverLocation, storeLocation);
        if (leg1Points.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('driver_to_store_active'),
              points: leg1Points,
              color: activeColor,
              width: width,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              patterns: kIsWeb
                  ? const <PatternItem>[]
                  : [PatternItem.dash(18), PatternItem.gap(8)],
            ),
          );
        }

        // Leg 2: Store -> Customer (Upcoming)
        final leg2Points =
            await fetchRoadRoute(storeLocation, customerLocation);
        if (leg2Points.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('store_to_customer_upcoming'),
              points: leg2Points,
              color: upcomingColor.withValues(alpha: 0.6),
              width: width - 1,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              patterns: kIsWeb
                  ? const <PatternItem>[]
                  : [PatternItem.dot, PatternItem.gap(6)],
            ),
          );
        }
      } else {
        // Leg 1: Store -> Driver (Completed)
        final completedPoints =
            await fetchRoadRoute(storeLocation, driverLocation);
        if (completedPoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('store_to_driver_completed'),
              points: completedPoints,
              color: completedColor.withValues(alpha: 0.6),
              width: width - 1,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              patterns: kIsWeb
                  ? const <PatternItem>[]
                  : [PatternItem.dot, PatternItem.gap(6)],
            ),
          );
        }

        // Leg 2: Driver -> Customer (Active Delivery Leg)
        final activePoints =
            await fetchRoadRoute(driverLocation, customerLocation);
        if (activePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('driver_to_customer_active'),
              points: activePoints,
              color: activeColor,
              width: width,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        }
      }
      return polylines;
    }

    if (driverLocation != null && customerLocation != null) {
      final points = await fetchRoadRoute(driverLocation, customerLocation);
      if (points.isNotEmpty) {
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
      }
    } else if (driverLocation != null && storeLocation != null) {
      final points = await fetchRoadRoute(driverLocation, storeLocation);
      if (points.isNotEmpty) {
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
      }
    } else if (storeLocation != null && customerLocation != null) {
      final points = await fetchRoadRoute(storeLocation, customerLocation);
      if (points.isNotEmpty) {
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
    }

    return polylines;
  }

  /// Synchronous fallback - returns empty set so no synthetic/fake polylines are fabricated
  Set<Polyline> generateJourneyPolylines({
    required LatLng? storeLocation,
    required LatLng? driverLocation,
    required LatLng? customerLocation,
    Color activeColor = const Color(0xFF2563EB),
    Color completedColor = const Color(0xFF94A3B8),
    Color upcomingColor = const Color(0xFF38BDF8),
    int width = 6,
    bool isPickedUp = false,
  }) {
    // Under strict real data policy, never fabricate imaginary road curves synchronously
    return const <Polyline>{};
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

  /// Calculates great-circle distance between two LatLngs in meters using Haversine formula
  double haversineDistanceMeters(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000.0;
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180.0;
    final dLng = (p2.longitude - p1.longitude) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180.0) *
            math.cos(p2.latitude * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculates total cumulative distance along a list of waypoints in meters
  double calculateTotalPathDistanceMeters(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += haversineDistanceMeters(points[i], points[i + 1]);
    }
    return total;
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

  /// Snaps a GPS coordinate onto the closest road segment along the polyline.
  /// Computes orthogonal projection, matched heading bearing, distance deviation, and remaining road waypoints.
  RouteSnapResult snapToPolyline(
    LatLng point,
    List<LatLng> polyline, {
    double maxSnapDistanceMeters = 80.0,
  }) {
    if (polyline.isEmpty) {
      return RouteSnapResult(
        snappedPosition: point,
        segmentIndex: 0,
        bearing: 0.0,
        distanceFromPolylineMeters: 0.0,
        remainingDistanceMeters: 0.0,
        remainingPoints: [point],
      );
    }

    if (polyline.length == 1) {
      final dist = haversineDistanceMeters(point, polyline.first);
      return RouteSnapResult(
        snappedPosition: polyline.first,
        segmentIndex: 0,
        bearing: 0.0,
        distanceFromPolylineMeters: dist,
        remainingDistanceMeters: 0.0,
        remainingPoints: List<LatLng>.from(polyline),
      );
    }

    int bestSegmentIndex = 0;
    double minDistanceMeters = double.infinity;
    LatLng bestSnappedPoint = polyline.first;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];

      // Local Equirectangular projection
      final double latRad =
          (p1.latitude + p2.latitude) * 0.5 * (math.pi / 180.0);
      final double cosLat = math.cos(latRad);

      final double dx = (p2.longitude - p1.longitude) * cosLat;
      final double dy = p2.latitude - p1.latitude;
      final double l2 = dx * dx + dy * dy;

      LatLng candidatePoint;
      if (l2 <= 1e-12) {
        candidatePoint = p1;
      } else {
        final double px = (point.longitude - p1.longitude) * cosLat;
        final double py = point.latitude - p1.latitude;
        final double t = ((px * dx + py * dy) / l2).clamp(0.0, 1.0);
        final double projLat = p1.latitude + t * (p2.latitude - p1.latitude);
        final double projLng = p1.longitude + t * (p2.longitude - p1.longitude);
        candidatePoint = LatLng(projLat, projLng);
      }

      final double dist = haversineDistanceMeters(point, candidatePoint);
      if (dist < minDistanceMeters) {
        minDistanceMeters = dist;
        bestSegmentIndex = i;
        bestSnappedPoint = candidatePoint;
      }
    }

    final double bearing = calculateBearing(
      polyline[bestSegmentIndex],
      polyline[bestSegmentIndex + 1],
    );

    final List<LatLng> remaining = [bestSnappedPoint];
    for (int i = bestSegmentIndex + 1; i < polyline.length; i++) {
      remaining.add(polyline[i]);
    }

    final double remainingDist = calculateTotalPathDistanceMeters(remaining);

    return RouteSnapResult(
      snappedPosition: bestSnappedPoint,
      segmentIndex: bestSegmentIndex,
      bearing: bearing,
      distanceFromPolylineMeters: minDistanceMeters,
      remainingDistanceMeters: remainingDist,
      remainingPoints: remaining,
    );
  }

  /// Extracts the remaining road path from the current position to the destination
  List<LatLng> getRemainingPolyline(
      LatLng currentPosition, List<LatLng> fullPolyline) {
    if (fullPolyline.isEmpty) return [currentPosition];
    final snap = snapToPolyline(currentPosition, fullPolyline);
    return snap.remainingPoints;
  }

  /// Clears in-memory route cache
  void clearCache() {
    _routeCache.clear();
  }
}
