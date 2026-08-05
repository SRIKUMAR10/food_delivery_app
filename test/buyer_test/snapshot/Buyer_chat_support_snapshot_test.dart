import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('BuyerChatState Snapshot Tests', () {
    test('Initial state matches snapshot', () {
      final authService = MockIAuthService();
      when(() => authService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      final bloc = BuyerChatBloc(
        repository: MockIChatRepository(),
        authService: authService,
      );
      expect(bloc.state, isA<BuyerChatInitial>());
      bloc.close();
    });

    test('Loaded state matches snapshot', () {
      const loaded = BuyerChatLoaded(
        currentUserId: 'buyer_1',
        conversations: [],
      );
      expect(loaded.currentUserId, 'buyer_1');
      expect(loaded.conversations, isEmpty);
      expect(loaded.searchQuery, '');
      expect(loaded.selectedConversationId, isNull);
    });

    test('Error state matches snapshot', () {
      const error = BuyerChatError('Connection failed');
      expect(error.message, 'Connection failed');
    });
  });
}
