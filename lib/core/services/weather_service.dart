import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum WeatherType { clear, cloudy, rainy, stormy }

class WeatherInfo {
  final WeatherType type;
  final double temperature;
  final bool isRaining;
  final String locationName;
  final String safetyMessage;
  final String safetyMessageTamil;

  const WeatherInfo({
    required this.type,
    required this.temperature,
    required this.isRaining,
    required this.locationName,
    required this.safetyMessage,
    required this.safetyMessageTamil,
  });

  factory WeatherInfo.clear({String? locationName, String location = 'Bhavani, Erode'}) {
    final loc = locationName ?? location;
    return WeatherInfo(
      type: WeatherType.clear,
      temperature: 29.0,
      isRaining: false,
      locationName: loc,
      safetyMessage: 'Clear skies near $loc',
      safetyMessageTamil: '$loc பகுதியில் வானிலை சீராக உள்ளது',
    );
  }

  factory WeatherInfo.rain({String? locationName, String location = 'Bhavani, Erode', double temp = 25.0}) {
    final loc = locationName ?? location;
    return WeatherInfo(
      type: WeatherType.rainy,
      temperature: temp,
      isRaining: true,
      locationName: loc,
      safetyMessage: '🌧️ Rain near $loc · Partner delivering safely with extra care',
      safetyMessageTamil: '🌧️ $loc பகுதியில் மழை பெய்கிறது · டெலிவரி பார்ட்னர் கவனமுடன் பயணிக்கிறார்',
    );
  }
}

/// Centralized, production-grade Weather Service using Open-Meteo API.
/// Free, non-metered, real-time live meteorological data with 15-minute caching.
class WeatherService {
  WeatherService._internal();
  static final WeatherService _instance = WeatherService._internal();
  static WeatherService get instance => _instance;

  WeatherInfo? _cachedWeather = WeatherInfo.clear(location: 'Bhavani, Erode');
  DateTime? _lastFetchTime;
  bool _mockRain = false;

  WeatherInfo get cachedWeather =>
      _mockRain ? WeatherInfo.rain() : (_cachedWeather ?? WeatherInfo.clear());

  /// Toggle mock rain for testing or simulation
  void setMockRain(bool value) {
    _mockRain = value;
    _cachedWeather = null;
    _lastFetchTime = null;
  }

  /// Fetches real-time weather status for given latitude and longitude.
  Future<WeatherInfo> fetchWeather({
    double lat = 11.4427872,
    double lng = 77.6760544,
    String locationName = 'Bhavani',
  }) async {
    if (_mockRain) {
      return WeatherInfo.rain(locationName: locationName);
    }

    if (_cachedWeather != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 15) {
      return _cachedWeather!;
    }

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final weatherCode = (current['weathercode'] as num?)?.toInt() ?? 0;
        final temp = (current['temperature'] as num?)?.toDouble() ?? 28.0;

        // Open-Meteo weather codes for drizzle/rain/thunderstorm: 51-67, 80-82, 95-99
        final isRainy = (weatherCode >= 51 && weatherCode <= 67) ||
            (weatherCode >= 80 && weatherCode <= 82) ||
            (weatherCode >= 95 && weatherCode <= 99);

        final result = isRainy
            ? WeatherInfo.rain(locationName: locationName, temp: temp)
            : WeatherInfo(
                type: WeatherType.clear,
                temperature: temp,
                isRaining: false,
                locationName: locationName,
                safetyMessage: 'Clear weather near $locationName',
                safetyMessageTamil: '$locationName பகுதியில் வானிலை சீராக உள்ளது',
              );

        _cachedWeather = result;
        _lastFetchTime = DateTime.now();
        return result;
      }
    } catch (e) {
      debugPrint('WeatherService fetch error: $e');
    }

    // Default safe fallback
    return WeatherInfo.clear(location: locationName);
  }
}
