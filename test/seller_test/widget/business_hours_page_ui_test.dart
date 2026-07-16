import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';

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
      when(() => mockBloc.state).thenReturn(BusinessHoursLoading());
      
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
  });
}
