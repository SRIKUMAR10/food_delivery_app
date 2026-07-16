import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';

class MockBusinessHoursBloc extends Mock implements BusinessHoursBloc {}

void main() {
  group('BusinessHoursPage Golden Tests', () {
    late MockBusinessHoursBloc mockBloc;

    setUp(() async {
      mockBloc = MockBusinessHoursBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testGoldens('BusinessHours page layout should match golden file', (tester) async {
      await loadAppFonts();

      when(() => mockBloc.state).thenReturn(BusinessHoursLoaded(
        schedule: [],
        isEmergencyClosed: false,
      ));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
        ..addScenario(
          name: 'BusinessHours Loaded State',
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocProvider<BusinessHoursBloc>.value(
              value: mockBloc,
              child: const BusinessHoursView(),
            ),
          ),
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'business_hours_page_golden');
    });
  });
}
