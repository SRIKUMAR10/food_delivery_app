import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

class MockChatSupportBloc extends Mock implements ChatSupportBloc {}

void main() {
  group('ChatSupportPage UI Tests', () {
    late MockChatSupportBloc mockBloc;

    setUp(() {
      mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(ChatSupportLoading());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatSupportBloc>.value(
            value: mockBloc,
            child: const ChatSupportView(),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
