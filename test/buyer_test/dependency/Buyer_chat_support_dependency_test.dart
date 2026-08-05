import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('BuyerChatBloc Dependency Tests', () {
    late MockIChatRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIChatRepository();
      mockAuthService = MockIAuthService();
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
    });

    test('is constructed with repository and authService dependencies', () {
      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );
      expect(bloc.state, isA<BuyerChatInitial>());
      expect(bloc.repository, mockRepository);
      expect(bloc.authService, mockAuthService);
      bloc.close();
    });

    test('emits error when the user is not logged in', () async {
      when(() => mockAuthService.currentUserId).thenReturn(null);
      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );
      final states = <BuyerChatState>[];
      bloc.stream.listen(states.add);
      bloc.add(LoadBuyerConversations());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(states.last, isA<BuyerChatError>());
      expect((states.last as BuyerChatError).message, 'User not logged in');
      await bloc.close();
    });
  });
}
