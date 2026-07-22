import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  group('ChatSupportPage Integration Flow', () {
    testWidgets('Load and display chats', (WidgetTester tester) async {
      final mockRepo = MockIChatRepository();
      when(() => mockRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([]));

      final bloc = ChatSupportBloc(repository: mockRepo);
      addTearDown(() => bloc.close());

      final gesture = await tester.createGesture();
      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ChatSupportBloc>.value(
          value: bloc..add(LoadChatSessionsEvent('test_seller')),
          child: const ChatSupportView(),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Support Chat'), findsOneWidget);
    });
  });
}
