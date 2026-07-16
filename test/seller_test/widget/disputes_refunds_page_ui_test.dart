import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_ui.dart';

class MockDisputesRefundsBloc extends Mock implements DisputesRefundsBloc {}

void main() {
  group('DisputesRefundsPage UI Tests', () {
    late MockDisputesRefundsBloc mockBloc;

    setUp(() {
      mockBloc = MockDisputesRefundsBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(DisputesRefundsLoading());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DisputesRefundsBloc>.value(
            value: mockBloc,
            child: const DisputesRefundsView(),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
