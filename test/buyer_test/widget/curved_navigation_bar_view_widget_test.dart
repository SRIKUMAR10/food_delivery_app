import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/CurvedNavigationBarView.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockHomePageBloc extends Mock implements HomePageBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late MockChatRepository mockChatRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockAuthService mockAuthService;
  late MockHomePageBloc mockHomePageBloc;
  late MockCartBloc mockCartBloc;
  late MockFavoritesBloc mockFavoritesBloc;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockChatRepository = MockChatRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    mockAuthService = MockAuthService();
    mockHomePageBloc = MockHomePageBloc();
    mockCartBloc = MockCartBloc();
    mockFavoritesBloc = MockFavoritesBloc();

    when(() => mockOrderRepository.getBuyerOrdersStream(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockUserProfileRepository.watchProfileImageUrl(any()))
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value('user_123'));
    when(() => mockChatRepository.getConversationsForUser(any(), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockChatRepository.getMessagesStream(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockChatRepository.getConversationByOrderId(any(), userId: any(named: 'userId'), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) async => null);

    when(() => mockHomePageBloc.state)
        .thenReturn(const HomePageLoading('', []));
    when(() => mockHomePageBloc.stream)
        .thenAnswer((_) => Stream.value(const HomePageLoading('', [])));
    when(() => mockHomePageBloc.close()).thenAnswer((_) async {});

    when(() => mockCartBloc.state)
        .thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0));
    when(() => mockCartBloc.stream)
        .thenAnswer((_) => Stream.value(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0)));
    when(() => mockCartBloc.close()).thenAnswer((_) async {});

    when(() => mockFavoritesBloc.state)
        .thenReturn(const FavoritesLoaded(items: [], favoriteIds: {}));
    when(() => mockFavoritesBloc.stream)
        .thenAnswer((_) => Stream.value(const FavoritesLoaded(items: [], favoriteIds: {})));
    when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IOrderRepository>.value(value: mockOrderRepository),
        RepositoryProvider<IChatRepository>.value(value: mockChatRepository),
        RepositoryProvider<IUserProfileRepository>.value(value: mockUserProfileRepository),
        RepositoryProvider<IAuthService>.value(value: mockAuthService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomePageBloc>.value(value: mockHomePageBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
        ],
        child: const MaterialApp(
          home: CurvedNavigationBarView(),
        ),
      ),
    );
  }

  group('CurvedNavigationBarView Widget Tests', () {
    testWidgets('Renders navigation shell cleanly without GlobalKey assertions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CurvedNavigationBarView), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Triggers supportNavigation without throwing _elements.contains assertion error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      const supportData = SupportNavigationData(
        orderId: 'ORDER_123',
        sellerId: 'SELLER_456',
        sellerName: 'Test Seller',
        buyerName: 'John Doe',
        shopName: 'Tasty Diner',
        orderTitle: '2x Burger',
        orderTotal: 25.0,
      );

      CurvedNavigationBarView.supportNavigation.value = supportData;
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BuyerChatPage), findsWidgets);

      CurvedNavigationBarView.returnFromSupport.value = true;
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });
}
