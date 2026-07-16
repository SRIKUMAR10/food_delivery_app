import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_repository.dart';

class MockChatSupportRepository extends Mock implements ChatSupportRepository {}

void main() {
  group('ChatSupportPage Error Handling Test', () {
    late ChatSupportBloc bloc;
    late MockChatSupportRepository mockRepository;

    setUp(() {
      mockRepository = MockChatSupportRepository();
      bloc = ChatSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Handles message send failure gracefully',
      build: () {
        // Assume loaded state first
        when(() => mockRepository.sendMessage(any(), any())).thenThrow(Exception('NetworkError'));
        return bloc;
      },
      seed: () => ChatSupportLoaded(activeSessions: []),
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
