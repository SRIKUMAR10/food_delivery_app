import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

class MockChatSupportBloc extends MockBloc<ChatSupportEvent, ChatSupportState> implements ChatSupportBloc {}

void main() {
  group('ChatSupportPage Widget Tests', () {
    late MockChatSupportBloc mockBloc;

    setUp(() async {
      mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Chat Support page renders empty state', (tester) async {
      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(currentUserId: 'seller1', conversations: []));

      final gesture = await tester.createGesture();
      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BlocProvider<ChatSupportBloc>.value(
            value: mockBloc,
            child: const ChatSupportView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support Chat'), findsOneWidget);
      expect(find.text('No active customer chats'), findsOneWidget);
    });
  });
}
