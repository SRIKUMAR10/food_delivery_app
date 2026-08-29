import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

class MockBusinessHoursBloc extends Mock implements BusinessHoursBloc {}

void main() {
  group('BusinessHoursPage State Restoration Test', () {
    late MockBusinessHoursBloc mockBloc;

    setUp(() {
      mockBloc = MockBusinessHoursBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('App retains data on rotation/rebuild', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      when(() => mockBloc.state).thenReturn(BusinessHoursLoaded(
        schedule: BusinessDayModel.defaultWeeklySchedule(),
        isEmergencyClosed: false,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BusinessHoursBloc>.value(
            value: mockBloc,
            child: const BusinessHoursView(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Business Hours'), findsOneWidget);

      // Re-pump with landscape size simulating rotation
      await tester.binding.setSurfaceSize(const Size(2400, 1200));
      await tester.pumpAndSettle();
      expect(find.text('Business Hours'), findsOneWidget);
    });
  });
}

