import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/delivery_city_zone_service.dart';

void main() {
  group('DeliveryCityZoneService Unit Tests', () {
    late DeliveryCityZoneService service;

    setUp(() {
      service = DeliveryCityZoneService.instance;
    });

    test('returns catalog of major operational delivery cities', () {
      final cities = service.getAllCities();
      expect(cities.isNotEmpty, isTrue);
      expect(cities.any((c) => c.cityName == 'Chennai'), isTrue);
      expect(cities.any((c) => c.cityName == 'Bengaluru'), isTrue);
      expect(cities.any((c) => c.cityName == 'Coimbatore'), isTrue);
      expect(cities.any((c) => c.cityName == 'Hyderabad'), isTrue);
      expect(cities.any((c) => c.cityName == 'Mumbai'), isTrue);
      expect(cities.any((c) => c.cityName == 'Delhi NCR'), isTrue);
    });

    test('returns popular cities correctly', () {
      final popular = service.getPopularCities();
      expect(popular.isNotEmpty, isTrue);
      expect(popular.every((c) => c.isPopular), isTrue);
      expect(popular.any((c) => c.cityName == 'Chennai'), isTrue);
    });

    test('finds city by exact and alias names', () {
      final chennai = service.findCityByName('Chennai');
      expect(chennai, isNotNull);
      expect(chennai?.state, 'Tamil Nadu');

      final blr = service.findCityByName('Bangalore');
      expect(blr, isNotNull);
      expect(blr?.cityName, 'Bengaluru');

      final madras = service.findCityByName('Madras');
      expect(madras, isNotNull);
      expect(madras?.cityName, 'Chennai');
    });

    test('returns specific operating zones for Chennai', () {
      final zones = service.getZoneNamesForCity('Chennai');
      expect(zones.contains('Central Zone'), isTrue);
      expect(zones.contains('Anna Nagar Zone'), isTrue);
      expect(zones.contains('T. Nagar & Mylapore Hub'), isTrue);
      expect(zones.contains('OMR IT Corridor Hub'), isTrue);
      expect(zones.contains('Tambaram & Chromepet Hub'), isTrue);
    });

    test('returns specific operating zones for Bengaluru and Coimbatore', () {
      final blrZones = service.getZoneNamesForCity('Bengaluru');
      expect(blrZones.contains('Koramangala & HSR Hub'), isTrue);
      expect(blrZones.contains('Whitefield IT Hub'), isTrue);

      final cbeZones = service.getZoneNamesForCity('Coimbatore');
      expect(cbeZones.contains('RS Puram & Town Hall Hub'), isTrue);
      expect(cbeZones.contains('Peelamedu & Hopes Hub'), isTrue);
    });

    test('generates dynamic systematic zones for unlisted or custom cities', () {
      final customZones = service.getZoneNamesForCity('Tiruvannamalai');
      expect(customZones.contains('Central Zone'), isTrue);
      expect(customZones.contains('North Tiruvannamalai Hub'), isTrue);
      expect(customZones.contains('South Tiruvannamalai Hub'), isTrue);
    });

    test('searchCities filters by city name, state, and hub keyword', () {
      final tamilNaduCities = service.searchCities('Tamil Nadu');
      expect(tamilNaduCities.any((c) => c.cityName == 'Chennai'), isTrue);
      expect(tamilNaduCities.any((c) => c.cityName == 'Coimbatore'), isTrue);

      final omrSearch = service.searchCities('OMR');
      expect(omrSearch.any((c) => c.cityName == 'Chennai'), isTrue);

      final emptySearch = service.searchCities('');
      expect(emptySearch.length, service.getAllCities().length);
    });

    test('findNearestCity locates closest metro based on GPS coordinates', () {
      // Near Chennai Marina Beach (13.0475, 80.2824)
      final nearestToMarina = service.findNearestCity(13.0475, 80.2824);
      expect(nearestToMarina.cityName, 'Chennai');

      // Near Bengaluru MG Road (12.9756, 77.6066)
      final nearestToBlr = service.findNearestCity(12.9756, 77.6066);
      expect(nearestToBlr.cityName, 'Bengaluru');
    });

    test('findNearestHub locates closest operating hub in a city', () {
      // Near Egmore, Chennai (13.0784, 80.2608)
      final hub = service.findNearestHub('Chennai', 13.0784, 80.2608);
      expect(hub.hubName, 'Central Zone');
    });

    test('models serialize to and from JSON properly', () {
      const hub = DeliveryZoneHubInfo(
        hubId: 'test_hub',
        hubName: 'Test Hub',
        city: 'Chennai',
        hubCode: 'CHN-TST-01',
        description: 'Test Area',
        latitude: 13.0,
        longitude: 80.0,
        surgeStatus: '🔥 High Surge Zone',
      );

      final json = hub.toJson();
      final fromJson = DeliveryZoneHubInfo.fromJson(json);
      expect(fromJson.hubId, hub.hubId);
      expect(fromJson.hubName, hub.hubName);
      expect(fromJson.surgeStatus, hub.surgeStatus);
    });
  });
}
