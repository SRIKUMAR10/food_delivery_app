import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Model representing a single address autocomplete prediction.
class GooglePlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;
  final List<String> types;

  const GooglePlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
    this.types = const [],
  });

  factory GooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    final main = structured?['main_text']?.toString() ??
        json['name']?.toString() ??
        (json['display_name']?.toString().split(',').first) ??
        '';
    final secondary = structured?['secondary_text']?.toString() ??
        (json['display_name'] != null
            ? json['display_name'].toString().split(',').skip(1).join(',').trim()
            : '');
    final desc = json['description']?.toString() ??
        json['display_name']?.toString() ??
        '$main, $secondary';

    final typesList = (json['types'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return GooglePlacePrediction(
      placeId: json['place_id']?.toString() ?? json['osm_id']?.toString() ?? '',
      mainText: main.isNotEmpty ? main : desc,
      secondaryText: secondary,
      description: desc,
      types: typesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'main_text': mainText,
        'secondary_text': secondaryText,
        'description': description,
        'types': types,
      };
}

/// Model representing detailed information for a specific place/address.
class GooglePlaceDetails {
  final String placeId;
  final String formattedAddress;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;
  final String? postalCode;
  final String? city;
  final String? state;
  final String? country;

  const GooglePlaceDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.mainText,
    this.secondaryText = '',
    this.latitude,
    this.longitude,
    this.postalCode,
    this.city,
    this.state,
    this.country,
  });

  factory GooglePlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final formattedAddress = result['formatted_address']?.toString() ??
        result['display_name']?.toString() ??
        '';
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    double? lat = (location?['lat'] as num?)?.toDouble() ??
        (result['lat'] != null ? double.tryParse(result['lat'].toString()) : null);
    double? lng = (location?['lng'] as num?)?.toDouble() ??
        (result['lon'] != null ? double.tryParse(result['lon'].toString()) : null);

    String? postalCode;
    String? city;
    String? state;
    String? country;

    final addressComponents = result['address_components'] as List<dynamic>?;
    if (addressComponents != null) {
      for (final comp in addressComponents) {
        final types = (comp['types'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
        final longName = comp['long_name']?.toString() ?? '';
        if (types.contains('postal_code')) postalCode = longName;
        if (types.contains('locality') || types.contains('administrative_area_level_2')) city = longName;
        if (types.contains('administrative_area_level_1')) state = longName;
        if (types.contains('country')) country = longName;
      }
    } else if (result['address'] is Map<String, dynamic>) {
      final addr = result['address'] as Map<String, dynamic>;
      postalCode = addr['postcode']?.toString();
      city = addr['city']?.toString() ?? addr['town']?.toString() ?? addr['village']?.toString() ?? addr['suburb']?.toString();
      state = addr['state']?.toString();
      country = addr['country']?.toString();
    }

    final name = result['name']?.toString() ??
        (formattedAddress.split(',').isNotEmpty ? formattedAddress.split(',').first.trim() : '');
    final secondary = formattedAddress.split(',').skip(1).join(',').trim();

    return GooglePlaceDetails(
      placeId: result['place_id']?.toString() ?? result['osm_id']?.toString() ?? '',
      formattedAddress: formattedAddress,
      mainText: name.isNotEmpty ? name : formattedAddress,
      secondaryText: secondary,
      latitude: lat,
      longitude: lng,
      postalCode: postalCode,
      city: city,
      state: state,
      country: country,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'formatted_address': formattedAddress,
        'main_text': mainText,
        'secondary_text': secondaryText,
        'latitude': latitude,
        'longitude': longitude,
        'postal_code': postalCode,
        'city': city,
        'state': state,
        'country': country,
      };
}

/// Result of a completed address selection from the interactive address
/// picker dialogs (GPS, Places Autocomplete, or Draggable Map Pin).
class AddressSelectionResult {
  final String address;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;

  const AddressSelectionResult({
    required this.address,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
  });

  String? get effectiveGoogleMapsUrl {
    if (googleMapsUrl != null && googleMapsUrl!.isNotEmpty) {
      return googleMapsUrl;
    }
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps?q=${latitude!.toStringAsFixed(6)},${longitude!.toStringAsFixed(6)}';
    }
    return null;
  }
}

/// Service providing Google Places Autocomplete, Geocoding, and GPS Device location lookup.
class GooglePlacesService {
  static GooglePlacesService? _instance;
  static GooglePlacesService get instance => _instance ??= GooglePlacesService();

  http.Client? _client;

  GooglePlacesService({http.Client? client}) : _client = client;

  http.Client get _httpClient => _client ??= http.Client();

  String get _apiKey {
    try {
      return dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Searches addresses using Google Places Autocomplete API with graceful fallback.
  Future<List<GooglePlacePrediction>> searchPlaces(
    String query, {
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    // 1. Attempt Google Places Autocomplete API if key is available (Native only - web browsers enforce CORS)
    if (!kIsWeb && _apiKey.isNotEmpty && !_apiKey.startsWith('your_') && !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uriBuilder = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
          'input': cleanQuery,
          'key': _apiKey,
          'types': 'geocode|establishment',
          if (sessionToken != null) 'sessiontoken': sessionToken,
          if (latitude != null && longitude != null)
            'location': '$latitude,$longitude',
          if (latitude != null && longitude != null) 'radius': '50000',
        });

        final response = await _httpClient.get(uriBuilder).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final status = data['status']?.toString();
          if (status == 'OK' || status == 'ZERO_RESULTS') {
            final predictions = data['predictions'] as List<dynamic>? ?? [];
            if (predictions.isNotEmpty) {
              return predictions
                  .map((p) => GooglePlacePrediction.fromJson(p as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      } catch (e) {
        debugPrint('Google Places API search error, switching to fallback: $e');
      }
    }

    // 2. Resilient OpenStreetMap / Nominatim Fallback (CORS enabled for Web and resilient native fallback)
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': cleanQuery,
        'format': 'json',
        'addressdetails': '1',
        'limit': '6',
      });

      final response = await _httpClient.get(
        uri,
        headers: kIsWeb ? null : {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        if (list.isNotEmpty) {
          return list.map((item) {
            final map = item as Map<String, dynamic>;
            final displayName = map['display_name']?.toString() ?? '';
            final parts = displayName.split(',');
            final main = parts.first.trim();
            final secondary = parts.skip(1).join(',').trim();

            return GooglePlacePrediction(
              placeId: map['place_id']?.toString() ?? map['osm_id']?.toString() ?? '',
              mainText: main,
              secondaryText: secondary,
              description: displayName,
              types: [map['type']?.toString() ?? 'geocode'],
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Fallback Nominatim search error: $e');
    }

    // 3. Fallback: Return empty list so UI presents genuine empty/error state when no places are found
    return const <GooglePlacePrediction>[];
  }

  /// Searches world-wide cities matching a query using Google Places / OpenStreetMap.
  Future<List<GooglePlacePrediction>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];

    // 1. Google Places Autocomplete API with types=(cities) on non-web platforms if key present
    if (!kIsWeb && _apiKey.isNotEmpty && !_apiKey.startsWith('your_') && !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uriBuilder = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
          'input': cleanQuery,
          'key': _apiKey,
          'types': '(cities)',
        });

        final response = await _httpClient.get(uriBuilder).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final status = data['status']?.toString();
          if (status == 'OK' || status == 'ZERO_RESULTS') {
            final predictions = data['predictions'] as List<dynamic>? ?? [];
            if (predictions.isNotEmpty) {
              return predictions
                  .map((p) => GooglePlacePrediction.fromJson(p as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      } catch (e) {
        debugPrint('Google Places City search error: $e');
      }
    }

    // 2. OpenStreetMap Nominatim City Search Fallback (CORS enabled for Web and Global)
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'city': cleanQuery,
        'format': 'json',
        'addressdetails': '1',
        'limit': '10',
      });

      final response = await _httpClient.get(
        uri,
        headers: kIsWeb ? null : {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        if (list.isNotEmpty) {
          return list.map((item) {
            final map = item as Map<String, dynamic>;
            final addr = (map['address'] as Map<String, dynamic>?) ?? {};
            final cityName = addr['city']?.toString() ??
                addr['town']?.toString() ??
                addr['municipality']?.toString() ??
                addr['village']?.toString() ??
                (map['name']?.toString() ?? '');
            final stateName = addr['state']?.toString() ?? addr['county']?.toString() ?? '';
            final countryName = addr['country']?.toString() ?? '';
            final secondary = [stateName, countryName].where((s) => s.isNotEmpty).join(', ');

            return GooglePlacePrediction(
              placeId: map['place_id']?.toString() ?? map['osm_id']?.toString() ?? '',
              mainText: cityName.isNotEmpty ? cityName : (map['display_name']?.toString().split(',').first ?? cleanQuery),
              secondaryText: secondary.isNotEmpty ? secondary : (map['display_name']?.toString() ?? ''),
              description: map['display_name']?.toString() ?? cityName,
              types: const ['city'],
            );
          }).where((p) => p.mainText.isNotEmpty).toList();
        }
      }
    } catch (e) {
      debugPrint('Nominatim City Search error: $e');
    }

    return const [];
  }

  /// Fetches place details including precise coordinates and address components.
  Future<GooglePlaceDetails?> getPlaceDetails(
    String placeId, {
    String? sessionToken,
    String? fallbackAddress,
  }) async {
    if (placeId.isEmpty && (fallbackAddress == null || fallbackAddress.isEmpty)) {
      return null;
    }

    // 1. Try Google Place Details API (Native platforms only - browser CORS blocks direct REST calls)
    if (!kIsWeb && placeId.isNotEmpty && _apiKey.isNotEmpty && !_apiKey.startsWith('your_') && !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
          'place_id': placeId,
          'fields': 'address_components,formatted_address,geometry,name,place_id',
          'key': _apiKey,
          if (sessionToken != null) 'sessiontoken': sessionToken,
        });

        final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK' && data['result'] != null) {
            return GooglePlaceDetails.fromJson(data['result'] as Map<String, dynamic>);
          }
        }
      } catch (e) {
        debugPrint('Google Place Details error: $e');
      }
    }

    // 2. Try Nominatim Details by PlaceId or search (CORS enabled)
    try {
      final queryParam = fallbackAddress ?? placeId;
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': queryParam,
        'format': 'json',
        'addressdetails': '1',
        'limit': '1',
      });

      final response = await _httpClient.get(
        uri,
        headers: kIsWeb ? null : {'User-Agent': 'FoodDeliveryApp/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        if (list.isNotEmpty) {
          return GooglePlaceDetails.fromJson(list.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // 3. Fallback direct object
    final addressText = fallbackAddress ?? placeId;
    final parts = addressText.split(',');
    return GooglePlaceDetails(
      placeId: placeId,
      formattedAddress: addressText,
      mainText: parts.first.trim(),
      secondaryText: parts.skip(1).join(',').trim(),
      latitude: 13.0827,
      longitude: 80.2707,
    );
  }

  /// Reverse geocodes latitude and longitude into a structured human-readable address.
  Future<GooglePlaceDetails?> reverseGeocode(double latitude, double longitude) async {
    // 1. BigDataCloud Reverse Geocoding API (Fast, Free, No API Key, CORS-enabled, Global)
    try {
      final uri = Uri.https('api.bigdatacloud.net', '/data/reverse-geocode-client', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'localityLanguage': 'en',
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final locality = (data['locality'] ?? '').toString().trim();
        final city = (data['city'] ?? data['principalSubdivisionCity'] ?? '').toString().trim();
        final state = (data['principalSubdivision'] ?? '').toString().trim();
        final postcode = (data['postcode'] ?? '').toString().trim();
        final country = (data['countryName'] ?? '').toString().trim();

        final parts = <String>[];
        if (locality.isNotEmpty) parts.add(locality);
        if (city.isNotEmpty && city != locality) parts.add(city);
        if (state.isNotEmpty) parts.add(state);
        if (postcode.isNotEmpty) parts.add(postcode);
        if (country.isNotEmpty) parts.add(country);

        if (parts.isNotEmpty) {
          final formatted = parts.join(', ');
          final main = locality.isNotEmpty ? locality : (city.isNotEmpty ? city : formatted);
          final secondary = parts.where((p) => p != main).join(', ');
          return GooglePlaceDetails(
            placeId: 'bdc_${latitude}_$longitude',
            formattedAddress: formatted,
            mainText: main,
            secondaryText: secondary,
            latitude: latitude,
            longitude: longitude,
            postalCode: postcode.isNotEmpty ? postcode : null,
            city: city.isNotEmpty ? city : locality,
            state: state.isNotEmpty ? state : null,
            country: country.isNotEmpty ? country : null,
          );
        }
      }
    } catch (e) {
      debugPrint('BigDataCloud Reverse Geocode error: $e');
    }

    // 2. Nominatim Reverse API (OpenStreetMap)
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'jsonv2',
        'addressdetails': '1',
      });

      final response = await _httpClient.get(
        uri,
        headers: {
          'User-Agent': 'FoodGoFoodDelivery/1.0 (contact@foodgo.app)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final displayName = (data['display_name'] ?? '').toString().trim();
        if (displayName.isNotEmpty) {
          return GooglePlaceDetails.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Nominatim Reverse Geocode error: $e');
    }

    // 3. Google Geocoding API (Native platforms only with valid key)
    if (!kIsWeb && _apiKey.isNotEmpty && !_apiKey.startsWith('your_') && !_apiKey.startsWith('AIzaSyDummy')) {
      try {
        final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
        });

        final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final results = data['results'] as List<dynamic>?;
            if (results != null && results.isNotEmpty) {
              return GooglePlaceDetails.fromJson(results.first as Map<String, dynamic>);
            }
          }
        }
      } catch (e) {
        debugPrint('Google Reverse Geocode error: $e');
      }
    }

    // 4. Photon Reverse Geocoding
    try {
      final uri = Uri.https('photon.komoot.io', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      });
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final props = features.first['properties'] as Map<String, dynamic>?;
          if (props != null) {
            final name = (props['name'] ?? props['street'] ?? '').toString().trim();
            final city = (props['city'] ?? props['town'] ?? props['district'] ?? '').toString().trim();
            final state = (props['state'] ?? '').toString().trim();
            final postcode = (props['postcode'] ?? '').toString().trim();
            final country = (props['country'] ?? '').toString().trim();
            final parts = [name, city, state, postcode, country].where((s) => s.isNotEmpty).toList();
            if (parts.isNotEmpty) {
              final formatted = parts.join(', ');
              return GooglePlaceDetails(
                placeId: 'photon_${latitude}_$longitude',
                formattedAddress: formatted,
                mainText: name.isNotEmpty ? name : (city.isNotEmpty ? city : formatted),
                secondaryText: parts.skip(1).join(', '),
                latitude: latitude,
                longitude: longitude,
                postalCode: postcode.isNotEmpty ? postcode : null,
                city: city.isNotEmpty ? city : null,
                state: state.isNotEmpty ? state : null,
                country: country.isNotEmpty ? country : null,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Photon Reverse Geocode error: $e');
    }

    // 5. Clean Human-Readable Fallback
    final latStr = latitude.toStringAsFixed(4);
    final lngStr = longitude.toStringAsFixed(4);
    return GooglePlaceDetails(
      placeId: 'gps_${latitude}_$longitude',
      formattedAddress: 'Pinned Delivery Location ($latStr, $lngStr)',
      mainText: 'Pinned Delivery Location',
      secondaryText: 'Coordinates: $latStr, $lngStr',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Requests device location permission and fetches the current GPS location address.
  Future<GooglePlaceDetails?> getCurrentLocationAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      return await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location address: $e');
      return null;
    }
  }
}
