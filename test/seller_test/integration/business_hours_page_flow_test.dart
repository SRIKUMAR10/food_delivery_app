import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

class MockBusinessHoursBloc extends Mock implements BusinessHoursBloc {}

void main() {
  group('BusinessHoursPage Flow Integration Test', () {
    late MockBusinessHoursBloc mockBloc;
    late StreamController<BusinessHoursState> stateController;

    final initialLoadedState = BusinessHoursLoaded(
      schedule: BusinessDayModel.defaultWeeklySchedule(),
      isEmergencyClosed: false,
    );

    final emergencyClosedState = BusinessHoursLoaded(
      schedule: BusinessDayModel.defaultWeeklySchedule(),
      isEmergencyClosed: true,
    );

    setUp(() {
      mockBloc = MockBusinessHoursBloc();
      stateController = StreamController<BusinessHoursState>.broadcast();
      when(() => mockBloc.stream).thenAnswer((_) => stateController.stream);
      when(() => mockBloc.state).thenReturn(initialLoadedState);
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      stateController.close();
    });

    testWidgets('Full Real-Time Integration Flow: Render schedule -> Stream emergency close', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BusinessHoursBloc>.value(
            value: mockBloc,
            child: const BusinessHoursView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify 7-day schedule header and days are displayed
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.text('Weekly Schedule'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Store is Open'), findsOneWidget);

      // 2. Stream real-time database update (emergency close)
      when(() => mockBloc.state).thenReturn(emergencyClosedState);
      stateController.add(emergencyClosedState);

      await tester.pumpAndSettle();

      // 3. Verify reactive UI rebuild with new Firestore emergency state
      expect(find.text('Store Temporarily Closed'), findsOneWidget);
    });
  });
}

