import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_ui.dart';

class MockDisputesRefundsBloc extends Mock implements DisputesRefundsBloc {}

void main() {
  group('DisputesRefundsPage Golden Tests', () {
    late MockDisputesRefundsBloc mockBloc;

    setUp(() async {
      mockBloc = MockDisputesRefundsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testGoldens('Disputes page layout matches golden file', (tester) async {
      await loadAppFonts();

      when(() => mockBloc.state).thenReturn(DisputesRefundsLoaded(disputes: []));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
        ..addScenario(
          name: 'Disputes Empty State',
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocProvider<DisputesRefundsBloc>.value(
              value: mockBloc,
              child: const DisputesRefundsView(),
            ),
          ),
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'disputes_refunds_page_golden');
    });
  });
}
