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
  group('BusinessHoursPage UI Tests', () {
    late MockBusinessHoursBloc mockBloc;

    setUp(() {
      mockBloc = MockBusinessHoursBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const BusinessHoursLoading());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BusinessHoursBloc>.value(
            value: mockBloc,
            child: const BusinessHoursView(),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders loaded state with full 7-day schedule', (WidgetTester tester) async {
      final schedule = BusinessDayModel.defaultWeeklySchedule();
      when(() => mockBloc.state).thenReturn(BusinessHoursLoaded(
        schedule: schedule,
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
      
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.text('Store is Open'), findsOneWidget);
      expect(find.text('Weekly Schedule'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget);
      expect(find.text('Friday'), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('09:00 AM'), findsWidgets);
      expect(find.text('10:00 PM'), findsWidgets);
    });

    testWidgets('renders error state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const BusinessHoursError('Network error'));
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BusinessHoursBloc>.value(
            value: mockBloc,
            child: const BusinessHoursView(),
          ),
        ),
      );
      
      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });
}

