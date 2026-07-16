import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_service.dart';

class MockChatSupportService extends Mock implements ChatSupportService {}

void main() {
  group('ChatSupportRepository', () {
    late ChatSupportRepository repository;
    late MockChatSupportService mockService;

    setUp(() {
      mockService = MockChatSupportService();
      repository = ChatSupportRepository(service: mockService);
    });

    test('getActiveSessions calls service fetchChatSessions', () async {
      when(() => mockService.fetchChatSessions(any())).thenAnswer((_) async => []);
      await repository.getActiveSessions('seller1');
      verify(() => mockService.fetchChatSessions('seller1')).called(1);
    });
  });
}
