import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/buyer_notification_model.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_buyer_notification_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/CurvedNavigationBarView.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockHomePageBloc extends Mock implements HomePageBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockBuyerNotificationRepository extends Mock
    implements IBuyerNotificationRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late MockChatRepository mockChatRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockAuthService mockAuthService;
  late MockHomePageBloc mockHomePageBloc;
  late MockCartBloc mockCartBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockBuyerNotificationRepository mockBuyerNotificationRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockChatRepository = MockChatRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    mockAuthService = MockAuthService();
    mockHomePageBloc = MockHomePageBloc();
    mockCartBloc = MockCartBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    mockBuyerNotificationRepository = MockBuyerNotificationRepository();

    when(() => mockOrderRepository.getBuyerOrdersStream(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockUserProfileRepository.watchProfileImageUrl(any()))
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuthService.authStateChanges).thenAnswer(
      (_) => Stream<String?>.value('user_123').asBroadcastStream(),
    );
    when(() => mockChatRepository.getConversationsForUser(any(), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockChatRepository.getConversationsForUser(any(), role: any(named: 'role')))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockChatRepository.getMessagesStream(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockChatRepository.getConversationByOrderId(any(), userId: any(named: 'userId'), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) async => null);
    when(() => mockBuyerNotificationRepository.watchNotifications(any()))
        .thenAnswer((_) => Stream.value([]));

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
        RepositoryProvider<IBuyerNotificationRepository>.value(
          value: mockBuyerNotificationRepository,
        ),
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

  Future<void> pumpNavView(WidgetTester tester, {Size size = const Size(800, 600)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  OrderModel buildOrder(String id, OrderStatus status) {
    return OrderModel(
      id: id,
      customerId: 'user_123',
      customerName: 'John Doe',
      sellerId: 'seller_1',
      status: status,
      amount: 120.0,
      timestamp: DateTime(2026, 1, 1),
    );
  }

  ConversationModel buildConversation({int unread = 0}) {
    return ConversationModel(
      id: 'conv_1',
      buyerId: 'user_123',
      sellerId: 'seller_1',
      buyerName: 'John Doe',
      sellerName: 'Tasty Diner',
      buyerUnreadCount: unread,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  BuyerNotificationModel buildOfferNotification({bool unread = true}) {
    return BuyerNotificationModel(
      id: 'notif_1',
      userId: 'user_123',
      category: BuyerNotificationCategory.offerPromo,
      title: '20% Off',
      body: 'Use code FOODGO20',
      isRead: !unread,
    );
  }

  group('CurvedNavigationBarView Widget Tests', () {
    testWidgets('Renders navigation shell cleanly without GlobalKey assertions', (tester) async {
      await pumpNavView(tester);

      expect(find.byType(CurvedNavigationBarView), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Triggers supportNavigation without throwing _elements.contains assertion error', (tester) async {
      await pumpNavView(tester);

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

  group('Real-time Cart Badge Tests', () {
    testWidgets('Cart badge is hidden when the cart is empty', (tester) async {
      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_cart_badge')), findsNothing);
    });

    testWidgets('Cart badge displays the exact live item count', (tester) async {
      when(() => mockCartBloc.state)
          .thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 3));
      when(() => mockCartBloc.stream)
          .thenAnswer((_) => Stream.value(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 3)));

      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_cart_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('buyer_nav_cart_badge')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Cart badge disappears when the cart becomes empty', (tester) async {
      when(() => mockCartBloc.state)
          .thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 2));
      when(() => mockCartBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([
                const CartLoaded(items: [], totalAmount: 0.0, totalCount: 2),
                const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
              ]));

      await pumpNavView(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('buyer_nav_cart_badge')), findsNothing);
    });
  });

  group('Real-time Orders Badge Tests', () {
    testWidgets('Orders badge shows active in-flight order count', (tester) async {
      when(() => mockOrderRepository.getBuyerOrdersStream('user_123'))
          .thenAnswer((_) => Stream.value([
                buildOrder('o1', OrderStatus.preparing),
                buildOrder('o2', OrderStatus.delivered),
                buildOrder('o3', OrderStatus.cancelled),
              ]));

      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_orders_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('buyer_nav_orders_badge')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Orders badge is hidden when all orders are terminal', (tester) async {
      when(() => mockOrderRepository.getBuyerOrdersStream('user_123'))
          .thenAnswer((_) => Stream.value([
                buildOrder('o1', OrderStatus.delivered),
                buildOrder('o2', OrderStatus.cancelled),
              ]));

      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_orders_badge')), findsNothing);
    });

    testWidgets('Orders badge updates in real-time when order status changes', (tester) async {
      when(() => mockOrderRepository.getBuyerOrdersStream('user_123'))
          .thenAnswer((_) => Stream.fromIterable([
                [buildOrder('o1', OrderStatus.accepted)],
                [buildOrder('o1', OrderStatus.delivered)],
              ]));

      await pumpNavView(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('buyer_nav_orders_badge')), findsNothing);
    });
  });

  group('Real-time Support Badge Tests', () {
    testWidgets('Support badge sums unread messages across conversations', (tester) async {
      when(() => mockChatRepository.getConversationsForUser('user_123', role: 'buyer'))
          .thenAnswer((_) => Stream.value([
                buildConversation(unread: 2),
                buildConversation(unread: 1),
              ]));

      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_support_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('buyer_nav_support_badge')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Support badge is hidden when there are no unread messages', (tester) async {
      when(() => mockChatRepository.getConversationsForUser('user_123', role: 'buyer'))
          .thenAnswer((_) => Stream.value([
                buildConversation(unread: 0),
              ]));

      await pumpNavView(tester);

      expect(find.byKey(const Key('buyer_nav_support_badge')), findsNothing);
    });
  });

  group('Real-time Offers Badge Tests (Desktop Sidebar)', () {
    testWidgets('Offers badge shows unread promotional notifications', (tester) async {
      when(() => mockBuyerNotificationRepository.watchNotifications('user_123'))
          .thenAnswer((_) => Stream.value([
                buildOfferNotification(unread: true),
                buildOfferNotification(unread: false),
                buildOfferNotification(unread: true),
              ]));

      await pumpNavView(tester, size: const Size(1280, 800));

      expect(find.byKey(const Key('buyer_nav_offers_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('buyer_nav_offers_badge')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Offers badge is hidden when all promotions are read', (tester) async {
      when(() => mockBuyerNotificationRepository.watchNotifications('user_123'))
          .thenAnswer((_) => Stream.value([
                buildOfferNotification(unread: false),
              ]));

      await pumpNavView(tester, size: const Size(1280, 800));

      expect(find.byKey(const Key('buyer_nav_offers_badge')), findsNothing);
    });

    testWidgets('Desktop cart badge is hidden when cart is empty (no hardcoded count)', (tester) async {
      await pumpNavView(tester, size: const Size(1280, 800));

      expect(find.byKey(const Key('buyer_nav_cart_badge')), findsNothing);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('Desktop cart badge shows live count when cart has items', (tester) async {
      when(() => mockCartBloc.state)
          .thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 5));
      when(() => mockCartBloc.stream)
          .thenAnswer((_) => Stream.value(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 5)));

      await pumpNavView(tester, size: const Size(1280, 800));

      expect(find.byKey(const Key('buyer_nav_cart_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('buyer_nav_cart_badge')),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );
    });
  });
}
