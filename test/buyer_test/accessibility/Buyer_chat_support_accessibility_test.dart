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
  group('BuyerChatPage Accessibility Tests', () {
    late MockIChatRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIChatRepository();
      mockAuthService = MockIAuthService();
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAuthService.currentUserId).thenReturn('buyer_1');
      final conversation = ConversationModel(
        id: 'conv_1',
        buyerId: 'buyer_1',
        sellerId: 'seller_1',
        buyerName: 'John',
        sellerName: 'Sarah',
        shopName: 'Pizza Palace',
        lastMessage: 'Hello',
        lastMessageTimestamp: DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 20),
        updatedAt: DateTime(2026, 7, 20),
      );
      when(() => mockRepository.getConversationsForUser(any(),
              isSeller: any(named: 'isSeller')))
          .thenAnswer((_) => Stream.value([conversation]));
    });

    testWidgets('Passes accessibility guidelines', (WidgetTester tester) async {
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

      final SemanticsHandle semantics = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });
  });
}
