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
  group('BusinessHoursPage Localization Test', () {
    late MockBusinessHoursBloc mockBloc;

    setUp(() {
      mockBloc = MockBusinessHoursBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Strings and localized day labels are rendered accurately', (WidgetTester tester) async {
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
      expect(find.text('Set your store opening and closing times'), findsOneWidget);
      expect(find.text('Store is Open'), findsOneWidget);
      expect(find.text('You are currently accepting new orders.'), findsOneWidget);
      expect(find.text('Weekly Schedule'), findsOneWidget);
      expect(find.text('Tap time to edit'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
    });
  });
}

