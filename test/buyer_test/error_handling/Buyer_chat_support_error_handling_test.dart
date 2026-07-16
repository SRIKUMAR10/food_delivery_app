import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerChatSupportBloc extends Mock implements BuyerChatSupportBloc {}

void main() {
  group('BuyerChatSupportPage Error Handling Tests', () {
    late MockBuyerChatSupportBloc mockBloc;

    setUp(() {
      mockBloc = MockBuyerChatSupportBloc();
    });

    testWidgets('Shows error message when state is error', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const BuyerChatSupportState(
          status: ChatStatus.error,
          errorMessage: 'Connection failed',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockBloc,
            child: const BuyerChatSupportView(),
          ),
        ),
      );

      expect(find.text('Connection failed'), findsOneWidget);
    });
  });
}
