import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/live_location_bloc.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

class MockDeliveryPartnerRepository extends Mock implements DeliveryPartnerRepository {}

void main() {
  late MockDeliveryPartnerRepository mockRepo;

  setUp(() {
    mockRepo = MockDeliveryPartnerRepository();
  });

  group('LiveLocationBloc Tests', () {
    test('initial state has default values and isTracking false', () {
      final bloc = LiveLocationBloc(repository: mockRepo);
      expect(bloc.state.isTracking, false);
      expect(bloc.state.gpsStatus, 'active');
      bloc.close();
    });

    blocTest<LiveLocationBloc, LiveLocationState>(
      'LiveLocationStartTracking sets isTracking to true',
      build: () => LiveLocationBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const LiveLocationStartTracking(driverId: 'drv_123')),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.isTracking, 'isTracking', true)
            .having((s) => s.gpsStatus, 'gpsStatus', 'active'),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'LiveLocationStopTracking sets isTracking to false',
      seed: () => const LiveLocationState(isTracking: true),
      build: () => LiveLocationBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const LiveLocationStopTracking()),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.isTracking, 'isTracking', false),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'LiveLocationUpdated updates coordinates, heading, and speed',
      build: () => LiveLocationBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const LiveLocationUpdated(
        latitude: 13.0850,
        longitude: 80.2750,
        heading: 90.0,
        speedKmh: 35.0,
      )),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.latitude, 'latitude', 13.0850)
            .having((s) => s.longitude, 'longitude', 80.2750)
            .having((s) => s.heading, 'heading', 90.0)
            .having((s) => s.speedKmh, 'speedKmh', 35.0)
            .having((s) => s.lastUpdated, 'lastUpdated', isNotNull),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'LiveLocationGeofenceCheck detects when driver is within radius',
      seed: () => const LiveLocationState(
        latitude: 13.0827,
        longitude: 80.2707,
      ),
      build: () => LiveLocationBloc(repository: mockRepo),
      act: (bloc) => bloc.add(const LiveLocationGeofenceCheck(
        targetLat: 13.0828,
        targetLng: 80.2708,
        radiusMeters: 50.0,
      )),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.isInsideGeofence, 'isInsideGeofence', true),
      ],
    );
  });
}
