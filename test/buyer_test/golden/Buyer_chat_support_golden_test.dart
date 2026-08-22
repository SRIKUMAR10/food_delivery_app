import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('BuyerChatPage Golden Tests', () {
    late MockIChatRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIChatRepository();
      mockAuthService = MockIAuthService();
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value('buyer_1'));
      when(() => mockAuthService.currentUserId).thenReturn('buyer_1');
    });

    Widget buildPage(List<ConversationModel> conversations) {
      when(() => mockRepository.getConversationsForUser(any(),
              isSeller: any(named: 'isSeller')))
          .thenAnswer((_) => Stream.value(conversations));
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IChatRepository>(create: (_) => mockRepository),
          RepositoryProvider<IAuthService>(create: (_) => mockAuthService),
        ],
        child: const MaterialApp(home: BuyerChatPage()),
      );
    }

    testWidgets('Renders conversation list when conversations are loaded', (
      WidgetTester tester,
    ) async {
      final conversation = ConversationModel(
        id: 'conv_1',
        buyerId: 'buyer_1',
        sellerId: 'seller_1',
        buyerName: 'John',
        sellerName: 'Sarah',
        shopName: 'Pizza Palace',
        sellerImageUrl: 'https://example.com/sarah.png',
        sellerPhone: '1234567890',
        lastMessage: 'Hello',
        lastMessageTimestamp: DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 20),
        updatedAt: DateTime(2026, 7, 20),
      );

      await tester.pumpWidget(buildPage([conversation]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BuyerChatPage), findsOneWidget);
      expect(find.text('Pizza Palace'), findsOneWidget);
    });
  });
}
