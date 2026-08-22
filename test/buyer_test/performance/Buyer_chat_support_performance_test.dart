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
  group('BuyerChatPage Performance Tests', () {
    late MockIChatRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIChatRepository();
      mockAuthService = MockIAuthService();
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value('buyer_1'));
      when(() => mockAuthService.currentUserId).thenReturn('buyer_1');
    });

    testWidgets('Renders a large list of conversations efficiently', (
      WidgetTester tester,
    ) async {
      final conversations = List.generate(
        100,
        (index) => ConversationModel(
          id: 'conv_$index',
          buyerId: 'buyer_1',
          sellerId: 'seller_$index',
          buyerName: 'John',
          sellerName: 'Seller $index',
          shopName: 'Shop $index',
          sellerImageUrl: 'https://example.com/seller_$index.png',
          sellerPhone: '1234567890',
          lastMessage: 'Message $index',
          lastMessageTimestamp: DateTime(2026, 7, 20),
          createdAt: DateTime(2026, 7, 20),
          updatedAt: DateTime(2026, 7, 20),
        ),
      );
      when(() => mockRepository.getConversationsForUser(any(),
              isSeller: any(named: 'isSeller')))
          .thenAnswer((_) => Stream.value(conversations));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<IChatRepository>(create: (_) => mockRepository),
            RepositoryProvider<IAuthService>(create: (_) => mockAuthService),
          ],
          child: const MaterialApp(home: BuyerChatPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BuyerChatPage), findsOneWidget);

      final listFinder = find.descendant(
        of: find.byType(BuyerChatPage),
        matching: find.byType(ListView),
      );
      expect(listFinder, findsWidgets);
    });
  });
}
