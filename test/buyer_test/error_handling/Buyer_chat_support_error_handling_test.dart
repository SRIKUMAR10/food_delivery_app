import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('BuyerChatView Error Handling Tests', () {
    late MockIChatRepository mockRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockRepository = MockIChatRepository();
      mockAuthService = MockIAuthService();
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
    });

    testWidgets('Shows error message when conversations stream fails', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthService.currentUserId).thenReturn('buyer_1');
      when(() => mockRepository.getConversationsForUser(any(),
              isSeller: any(named: 'isSeller')))
          .thenAnswer((_) => Stream.error(Exception('Connection failed')));

      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const BuyerChatView(),
          ),
        ),
      );

      bloc.add(LoadBuyerConversations());
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Failed to load conversations: Exception: Connection failed'),
        findsOneWidget,
      );
    });

    testWidgets('Shows login prompt when user is not logged in', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthService.currentUserId).thenReturn(null);

      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const BuyerChatView(),
          ),
        ),
      );

      bloc.add(LoadBuyerConversations());
      await tester.pump();
      await tester.pump();

      expect(find.text('Please log in to access support'), findsOneWidget);
    });
  });
}
