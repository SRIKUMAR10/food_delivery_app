import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  group('ChatSupportPage Error Handling Test', () {
    late ChatSupportBloc bloc;
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
      bloc = ChatSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Handles message send failure gracefully',
      build: () {
        when(
          () => mockRepository.sendMessage(
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            senderRole: any(named: 'senderRole'),
          ),
        ).thenThrow(Exception('NetworkError'));
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [],
      ),
      act: (bloc) => bloc.add(SendMessageEvent('session1', 'Hello')),
      expect: () => [
        isA<ChatSupportLoaded>().having((s) => s.isSendingMessage, 'isSending', true),
        isA<ChatSupportLoaded>()
          .having((s) => s.isSendingMessage, 'isSending', false)
          .having((s) => s.errorMessage, 'error', contains('Failed to send message')),
      ],
    );
  });
}
