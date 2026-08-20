import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/weather_service.dart';

void main() {
  group('WeatherService Unit Tests', () {
    late WeatherService weatherService;

    setUp(() {
      weatherService = WeatherService.instance;
      weatherService.setMockRain(false);
    });

    test('Initial clear state returns correct default parameters', () {
      final clearInfo = WeatherInfo.clear(location: 'Bhavani');
      expect(clearInfo.isRaining, isFalse);
      expect(clearInfo.type, equals(WeatherType.clear));
      expect(clearInfo.locationName, equals('Bhavani'));
      expect(clearInfo.safetyMessage, contains('Clear'));
      expect(clearInfo.safetyMessageTamil, contains('வானிலை சீராக'));
    });

    test('Rain factory returns correct rain alert and safety messages', () {
      final rainInfo = WeatherInfo.rain(location: 'Bhavani', temp: 24.0);
      expect(rainInfo.isRaining, isTrue);
      expect(rainInfo.type, equals(WeatherType.rainy));
      expect(rainInfo.temperature, equals(24.0));
      expect(rainInfo.safetyMessage, contains('🌧️ Rain near Bhavani'));
      expect(rainInfo.safetyMessageTamil, contains('மழை பெய்கிறது'));
    });

    test('setMockRain toggles simulated rain accurately', () async {
      weatherService.setMockRain(true);
      final weather = await weatherService.fetchWeather(locationName: 'Bhavani');
      expect(weather.isRaining, isTrue);
      expect(weather.type, equals(WeatherType.rainy));
      expect(weather.safetyMessage, contains('Rain'));

      weatherService.setMockRain(false);
    });
  });
}
