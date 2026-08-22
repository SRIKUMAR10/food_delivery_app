import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';

class MockOrdersListBloc extends MockBloc<OrdersListEvent, OrdersListState> implements OrdersListBloc {}
class MockProductListBloc extends MockBloc<ProductListPageEvent, ProductListPageState> implements ProductListBloc {}
class MockSellerWalletBloc extends MockBloc<SellerWalletEvent, SellerWalletState> implements SellerWalletBloc {}
class MockChatSupportBloc extends MockBloc<ChatSupportEvent, ChatSupportState> implements ChatSupportBloc {}
class MockOverallRatingBloc extends MockBloc<OverallRatingEvent, OverallRatingState> implements OverallRatingBloc {}
class MockSellerCustomerBloc extends MockBloc<SellerCustomerEvent, SellerCustomerState> implements SellerCustomerBloc {}

void main() {
  late MockOrdersListBloc mockOrdersBloc;
  late MockProductListBloc mockProductBloc;
  late MockSellerWalletBloc mockWalletBloc;
  late MockChatSupportBloc mockChatBloc;
  late MockOverallRatingBloc mockRatingBloc;
  late MockSellerCustomerBloc mockCustomerBloc;

  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockOrdersBloc = MockOrdersListBloc();
    mockProductBloc = MockProductListBloc();
    mockWalletBloc = MockSellerWalletBloc();
    mockChatBloc = MockChatSupportBloc();
    mockRatingBloc = MockOverallRatingBloc();
    mockCustomerBloc = MockSellerCustomerBloc();

    when(() => mockOrdersBloc.state).thenReturn(OrdersListInitial());
    when(() => mockProductBloc.state).thenReturn(ProductListInitial());
    when(() => mockWalletBloc.state).thenReturn(const SellerWalletInitial());
    when(() => mockChatBloc.state).thenReturn(ChatSupportInitial());
    when(() => mockRatingBloc.state).thenReturn(OverallRatingInitial());
    when(() => mockCustomerBloc.state).thenReturn(const SellerCustomerInitial());
  });

  Widget buildDesktopWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SellerNavigationBarViewPageBloc()),
          BlocProvider<OrdersListBloc>.value(value: mockOrdersBloc),
          BlocProvider<ProductListBloc>.value(value: mockProductBloc),
          BlocProvider<SellerWalletBloc>.value(value: mockWalletBloc),
          BlocProvider<ChatSupportBloc>.value(value: mockChatBloc),
          BlocProvider<OverallRatingBloc>.value(value: mockRatingBloc),
          BlocProvider<SellerCustomerBloc>.value(value: mockCustomerBloc),
        ],
        child: Scaffold(
          body: SellerDesktopSideMenu(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );
  }

  Widget buildMobileDrawerWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SellerNavigationBarViewPageBloc()),
          BlocProvider<OrdersListBloc>.value(value: mockOrdersBloc),
          BlocProvider<ProductListBloc>.value(value: mockProductBloc),
          BlocProvider<SellerWalletBloc>.value(value: mockWalletBloc),
          BlocProvider<ChatSupportBloc>.value(value: mockChatBloc),
          BlocProvider<OverallRatingBloc>.value(value: mockRatingBloc),
          BlocProvider<SellerCustomerBloc>.value(value: mockCustomerBloc),
        ],
        child: const Scaffold(
          body: SellerSideDrawer(
            currentIndex: 0,
            onTap: _dummyTap,
          ),
        ),
      ),
    );
  }

  group('Seller NavigationBarView Page Widget Tests', () {
    testWidgets('renders all side navigation menu items including Wallet, Support Chat, Ratings & Reviews, Customer Insights on desktop', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildDesktopWidget());
      await tester.pumpAndSettle();

      expect(find.text('Picarhub'), findsOneWidget);
      expect(find.text('Seller Portal'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Support Chat'), findsOneWidget);
      expect(find.text('Ratings & Reviews'), findsOneWidget);
      expect(find.text('Customer Insights'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Go Premium'), findsOneWidget);
    });

    testWidgets('renders drawer on mobile with all navigation items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildMobileDrawerWidget());
      await tester.pumpAndSettle();

      expect(find.text('Picarhub'), findsOneWidget);
      expect(find.text('Seller Portal'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Support Chat'), findsOneWidget);
      expect(find.text('Ratings & Reviews'), findsOneWidget);
      expect(find.text('Customer Insights'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders badges correctly when BLoC states have badge items', (WidgetTester tester) async {
      when(() => mockProductBloc.state).thenReturn(
        const ProductListLoaded(
          products: [],
          activeFilter: 'All',
          searchQuery: '',
          allCount: 3,
          activeCount: 3,
          inactiveCount: 0,
          lowStockCount: 0,
          vegCount: 0,
          nonVegCount: 0,
          archivedCount: 0,
          averageRating: 4.5,
          totalRevenue: 1000.0,
        ),
      );

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildDesktopWidget());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

  });
}

void _dummyTap(int index) {}


