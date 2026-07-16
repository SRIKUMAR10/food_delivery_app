import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock for a generic API client (e.g., http, dio, or a Firebase client)
class MockApiClient extends Mock implements ApiClient {}

// Dummy classes for demonstration
class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint) async => {'data': []};
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async => {'success': true};
}

class ChatService {
  final ApiClient client;
  ChatService(this.client);

  Future<void> fetchHistory() async {
    await client.get('chat/history');
  }

  Future<void> sendMessage(String message) async {
    await client.post('chat/send', {'message': message});
  }
}

void main() {
  group('BuyerChatSupportService Unit Tests', () {
    late ChatService service;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      service = ChatService(mockApiClient);
    });

    test('sendMessage calls the correct API endpoint', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => {});
      await service.sendMessage('Hello');
      verify(
        () => mockApiClient.post('chat/send', {'message': 'Hello'}),
      ).called(1);
    });
  });
}
