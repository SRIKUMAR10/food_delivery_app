import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/widgets/app_google_map_bloc/app_google_map_bloc.dart';
import 'package:food_delivery_app/core/widgets/app_google_map_bloc/app_google_map_event.dart';
import 'package:food_delivery_app/core/services/route_polyline_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppGoogleMapBloc Unit Tests', () {
    late AppGoogleMapBloc bloc;

    setUp(() {
      bloc = AppGoogleMapBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state contains default properties', () {
      expect(bloc.state.mapType, equals(MapType.normal));
      expect(bloc.state.trafficEnabled, isFalse);
      expect(bloc.state.autoFollowDriver, isTrue);
      expect(bloc.state.showWeatherOverlay, isTrue);
      expect(bloc.state.forceFallbackCanvas, isFalse);
      expect(bloc.state.roadPolylines, isEmpty);
      expect(bloc.state.isVoiceGuidanceEnabled, isTrue);
      expect(bloc.state.is3DTiltMode, isFalse);
      expect(bloc.state.showHeatmapLayer, isFalse);
    });

    test('ToggleMapTypeEvent toggles between normal and satellite', () {
      bloc.add(ToggleMapTypeEvent());
      expect(
        bloc.stream,
        emits(
            predicate<dynamic>((state) => state.mapType == MapType.satellite)),
      );
    });

    test('ToggleTrafficEvent toggles traffic visibility', () {
      bloc.add(ToggleTrafficEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.trafficEnabled == true)),
      );
    });

    test('ToggleAutoFollowEvent toggles auto-follow state', () {
      bloc.add(ToggleAutoFollowEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.autoFollowDriver == false)),
      );
    });

    test('ToggleWeatherEvent toggles weather overlay visibility', () {
      bloc.add(ToggleWeatherEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.showWeatherOverlay == false)),
      );
    });

    test('ToggleVoiceGuidanceEvent toggles voice navigation state', () {
      bloc.add(ToggleVoiceGuidanceEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>(
            (state) => state.isVoiceGuidanceEnabled == false)),
      );
    });

    test('Toggle3DTiltModeEvent toggles 3D perspective mode', () {
      bloc.add(Toggle3DTiltModeEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.is3DTiltMode == true)),
      );
    });

    test('ToggleHeatmapLayerEvent toggles heatmap visibility', () {
      bloc.add(ToggleHeatmapLayerEvent());
      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.showHeatmapLayer == true)),
      );
    });

    test('UpdateCurrentManeuverStepEvent updates step and distance', () {
      const step = RouteStepInfo(
        instruction: 'Turn right onto Anna Salai',
        maneuver: RouteManeuver.turnRight,
        distanceText: '200 m',
        distanceMeters: 200,
        durationText: '1 min',
        durationSeconds: 60,
        startLocation: LatLng(13.0827, 80.2707),
        endLocation: LatLng(13.0840, 80.2720),
        streetName: 'Anna Salai',
      );

      bloc.add(const UpdateCurrentManeuverStepEvent(
        step: step,
        distanceMeters: 180.0,
      ));

      expect(
        bloc.stream,
        emits(predicate<dynamic>((state) =>
            state.currentManeuverStep?.streetName == 'Anna Salai' &&
            state.distanceToNextTurnMeters == 180.0)),
      );
    });

    test('WebFallbackTriggeredEvent activates forceFallbackCanvas', () {
      bloc.add(WebFallbackTriggeredEvent());
      expect(
        bloc.stream,
        emits(
            predicate<dynamic>((state) => state.forceFallbackCanvas == true)),
      );
    });

    test('GpsLocationUpdatedEvent updates deviceGpsLocation in state', () {
      const location = LatLng(13.0827, 80.2707);
      bloc.add(const GpsLocationUpdatedEvent(location));
      expect(
        bloc.stream,
        emits(
            predicate<dynamic>((state) => state.deviceGpsLocation == location)),
      );
    });

    test('FetchDistanceMatrixEtaEvent computes and updates ETA in state',
        () async {
      const origin = LatLng(13.0827, 80.2707);
      const destination = LatLng(13.0850, 80.2750);
      bloc.add(const FetchDistanceMatrixEtaEvent(
        origin: origin,
        destination: destination,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) =>
            state.computedEtaText != null &&
            state.distanceMatrixResult != null)),
      );
    });
  });
}
