import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for service layer dependencies
class MockChatService extends Mock implements ChatService {}

// Dummy classes for models
class ChatMessage {
  final String id;
  final String text;
  ChatMessage(this.id, this.text);
}

// Dummy service and repository for demonstration
abstract class ChatService {
  Future<List<ChatMessage>> fetchHistory();
  Future<bool> sendMessage(String message);
}

class ChatRepository {
  final ChatService service;
  ChatRepository(this.service);

  Future<List<ChatMessage>> getHistory() => service.fetchHistory();
  Future<bool> postMessage(String message) => service.sendMessage(message);
}

void main() {
  group('BuyerChatSupportRepository Unit Tests', () {
    late ChatRepository repository;
    late MockChatService mockChatService;

    setUp(() {
      mockChatService = MockChatService();
      repository = ChatRepository(mockChatService);
    });

    test('getHistory returns a list of messages on success', () async {
      // Arrange
      when(
        () => mockChatService.fetchHistory(),
      ).thenAnswer((_) async => [ChatMessage('1', 'Hello')]);

      // Act
      final messages = await repository.getHistory();

      // Assert
      expect(messages, isA<List<ChatMessage>>());
      expect(messages.length, 1);
    });

    test('postMessage returns true on success', () async {
      // Arrange
      when(
        () => mockChatService.sendMessage(any()),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.postMessage('Test');

      // Assert
      expect(result, isTrue);
      verify(() => mockChatService.sendMessage('Test')).called(1);
    });
  });
}
