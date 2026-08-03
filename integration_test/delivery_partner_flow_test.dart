import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';

void main() {
  group('Delivery Partner - Full Delivery Flow (BLoC Level)', () {
    late DeliveryActiveOrderSessionRepository sessionRepo;

    setUp(() {
      sessionRepo = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      sessionRepo.dispose();
    });

    test('Session state machine: idle → incomingOrder → acceptedOrder → pickupConfirmation → navigatingToCustomer → deliveryCompleted', () {
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));

      sessionRepo.triggerIncomingOrder(
        orderId: '#ORD-FLOW-001',
        storeName: 'Green Mart',
        storeAddress: '24, Anna Salai, Chennai',
        customerName: 'Arun Kumar',
        customerAddress: '12, Beach Road, Chennai',
        orderAmount: 620.00,
      );
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));
      expect(sessionRepo.currentState.activeOrderId, equals('#ORD-FLOW-001'));
      expect(sessionRepo.currentState.orderAmount, equals(620.00));

      sessionRepo.acceptOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.acceptedOrder));

      sessionRepo.confirmPickup();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.navigatingToCustomer));

      sessionRepo.completeDelivery();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.deliveryCompleted));
      expect(sessionRepo.currentState.completedOrdersCount, greaterThan(0));
      expect(sessionRepo.currentState.totalEarningsToday, greaterThan(1280.00));
    });

    test('Session: declineOrder resets to idle', () {
      sessionRepo.triggerIncomingOrder(orderId: '#ORD-FLOW-002');
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));

      sessionRepo.declineOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
    });

    test('Session: toggleOnlineStatus and setOnlineStatus work', () {
      expect(sessionRepo.currentState.isOnline, isTrue);
      sessionRepo.toggleOnlineStatus();
      expect(sessionRepo.currentState.isOnline, isFalse);
      sessionRepo.setOnlineStatus(true);
      expect(sessionRepo.currentState.isOnline, isTrue);
    });

    test('Session: processWithdrawal updates balances correctly', () {
      final initialBalance = sessionRepo.currentState.walletBalance;
      sessionRepo.processWithdrawal(500.0);
      expect(sessionRepo.currentState.walletBalance, equals(initialBalance - 500.0));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(500.0 + 500.0));
    });

    test('Session: resetOrder clears active order', () {
      sessionRepo.triggerIncomingOrder(orderId: '#ORD-FLOW-003');
      sessionRepo.acceptOrder();
      sessionRepo.resetOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
    });
  });

  group('Delivery Partner - Incoming Order BLoC', () {
    test('initial state has default values', () {
      final bloc = DeliveryIncomingOrderBloc();
      expect(bloc.state.status, equals(IncomingOrderStatus.initial));
      expect(bloc.state.remainingSeconds, equals(15));
      expect(bloc.state.orderId, equals('#ORD98234'));
      bloc.close();
    });

    test('onLoad fetches from repository and emits loaded with timer', () async {
      final repository = DeliveryIncomingOrderRepository();
      final bloc = DeliveryIncomingOrderBloc(repository: repository);

      bloc.add(const DeliveryIncomingOrderLoadEvent());
      await Future.delayed(const Duration(milliseconds: 400));

      expect(bloc.state.status, equals(IncomingOrderStatus.loaded));
      expect(bloc.state.orderId, equals('#ORD98234'));
      expect(bloc.state.storeName, equals('Green Mart'));

      bloc.close();
    });

    test('onAccept emits accepted and cancels timer', () async {
      final bloc = DeliveryIncomingOrderBloc();
      bloc.add(const DeliveryIncomingOrderAcceptEvent());
      await Future.delayed(const Duration(milliseconds: 300));

      expect(bloc.state.status, equals(IncomingOrderStatus.accepted));
      bloc.close();
    });

    test('onDecline emits declined and cancels timer', () async {
      final bloc = DeliveryIncomingOrderBloc();
      bloc.add(const DeliveryIncomingOrderDeclineEvent());
      await Future.delayed(const Duration(milliseconds: 300));

      expect(bloc.state.status, equals(IncomingOrderStatus.declined));
      bloc.close();
    });
  });

  group('Delivery Partner - Pickup Confirmation BLoC', () {
    test('initial state has default values', () {
      final bloc = DeliveryPickupConfirmationPageBloc();
      expect(bloc.state.status, equals(PickupConfirmationStatus.initial));
      bloc.close();
    });

    test('fetchOrderDetails loads data successfully', () async {
      final bloc = DeliveryPickupConfirmationPageBloc();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.status, equals(PickupConfirmationStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-FLOW-001'));

      bloc.close();
    });

    test('startDelivery transitions to deliveryStarted', () async {
      final bloc = DeliveryPickupConfirmationPageBloc();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 700));
      expect(bloc.state.status, equals(PickupConfirmationStatus.success));

      bloc.add(const StartDeliveryEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(bloc.state.status, equals(PickupConfirmationStatus.deliveryStarted));

      bloc.close();
    });
  });

  group('Delivery Partner - Delivery Completed BLoC', () {
    test('initial state has default values', () {
      final bloc = DeliveryCompletedBloc();
      expect(bloc.state.status, equals(DeliveryCompletedStatus.initial));
      bloc.close();
    });

    test('fetchCompletedOrderDetails loads data', () async {
      final bloc = DeliveryCompletedBloc();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.status, equals(DeliveryCompletedStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-FLOW-001'));

      bloc.close();
    });

    test('completeOrder transitions to completed', () async {
      final bloc = DeliveryCompletedBloc();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 700));

      bloc.add(const CompleteOrderSubmittedEvent('#ORD-FLOW-001'));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(bloc.state.status, equals(DeliveryCompletedStatus.completed));

      bloc.close();
    });
  });

  group('Delivery Partner - Forgot Password BLoC (Post-Fix)', () {
    test('initial state has default values', () {
      final bloc = DeliveryForgotPasswordBloc();
      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.initial));
      expect(bloc.state.email, isEmpty);
      bloc.close();
    });

    test('email validation rejects empty email', () async {
      final bloc = DeliveryForgotPasswordBloc();
      bloc.add(const DeliveryForgotPasswordSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.failure));
      expect(bloc.state.errorMessage, isNotNull);
      bloc.close();
    });

    test('email validation rejects invalid email', () async {
      final bloc = DeliveryForgotPasswordBloc();
      bloc.add(DeliveryForgotPasswordEmailChanged('not-an-email'));
      bloc.add(const DeliveryForgotPasswordSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.failure));
      bloc.close();
    });
  });

  group('Delivery Partner - Settings BLoC', () {
    test('initial state has default values', () {
      final bloc = DeliverySettingsBloc();
      expect(bloc.state.status, equals(DeliverySettingsStatus.initial));
      expect(bloc.state.notificationsEnabled, isTrue);
      expect(bloc.state.deliveryRadius, equals(5.0));
      bloc.close();
    });

    test('toggleNotification toggles notifications', () {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsToggleNotificationEvent());
      expect(bloc.state.notificationsEnabled, isFalse);
      bloc.close();
    });

    test('updateRadius changes delivery radius', () {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsUpdateRadiusEvent(10.0));
      expect(bloc.state.deliveryRadius, equals(10.0));
      bloc.close();
    });

    test('changeLanguage updates locale', () {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsChangeLanguageEvent('ta'));
      expect(bloc.state.languageCode, equals('ta'));
      expect(bloc.state.localeCode, equals('ta'));
      bloc.close();
    });
  });

  group('Delivery Partner - NavigationBar BLoC', () {
    test('initial state has default values', () {
      final bloc = DeliveryNavigationBarPageBloc();
      expect(bloc.state.status, equals(DeliveryNavigationBarStatus.initial));
      expect(bloc.state.selectedIndex, equals(0));
      expect(bloc.state.isOffline, isFalse);
      bloc.close();
    });

    test('tab changed updates selected index', () async {
      final bloc = DeliveryNavigationBarPageBloc();
      bloc.add(const DeliveryNavigationBarInitEvent());
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const DeliveryNavigationBarTabChangedEvent(3));
      expect(bloc.state.selectedIndex, equals(3));
      bloc.close();
    });
  });

  group('Delivery Partner - Dashboard BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryDashboardPageBloc();
      expect(bloc.state.status, equals(DeliveryDashboardStatus.initial));
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.partnerName, equals('Ravi Kumar'));
      bloc.close();
    });

    test('toggleOnline changes online status', () {
      final bloc = DeliveryDashboardPageBloc();
      bloc.add(const DeliveryDashboardToggleOnlineEvent(false));
      expect(bloc.state.isOnline, isFalse);
      bloc.close();
    });

    test('filterActivity changes selected filter', () {
      final bloc = DeliveryDashboardPageBloc();
      bloc.add(const DeliveryDashboardFilterActivityEvent('recent'));
      expect(bloc.state.selectedFilter, equals('recent'));
      bloc.close();
    });
  });

  group('Delivery Partner - Order Details BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryOrderDetailsPageBloc();
      expect(bloc.state.status, equals(OrderDetailsStatus.initial));
      bloc.close();
    });

    test('fetchOrderDetails loads order data', () async {
      final bloc = DeliveryOrderDetailsPageBloc();
      bloc.add(const FetchOrderDetailsEvent('#ORD12345'));
      await Future.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.status, equals(OrderDetailsStatus.success));
      expect(bloc.state.order, isNotNull);
      expect(bloc.state.order!.id, equals('#ORD12345'));

      bloc.close();
    });
  });

  group('Delivery Partner - Login BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryLoginPageBloc();
      expect(bloc.state.status, equals(DeliveryLoginStatus.initial));
      expect(bloc.state.isLoggedIn, isFalse);
      bloc.close();
    });

    test('phoneChanged updates phone field', () {
      final bloc = DeliveryLoginPageBloc();
      bloc.add(const DeliveryLoginPhoneChangedEvent('9876543210'));
      expect(bloc.state.phone, equals('9876543210'));
      bloc.close();
    });

    test('passwordChanged updates password field', () {
      final bloc = DeliveryLoginPageBloc();
      bloc.add(const DeliveryLoginPasswordChangedEvent('test1234'));
      expect(bloc.state.password, equals('test1234'));
      bloc.close();
    });
  });

  group('Delivery Partner - NavigationBar UI Widget', () {
    testWidgets('renders NavigationBar page with skeleton loader initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(DeliveryNavigationBarPageView), findsOneWidget);
    });
  });

  group('Delivery Partner - Dashboard UI Widget', () {
    testWidgets('renders Dashboard page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DeliveryDashboardPage(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
    });
  });

  group('Delivery Partner - Incoming Order UI Widget', () {
    testWidgets('renders incoming order page with timer', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DeliveryIncomingOrderPageUi(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('INCOMING ORDER REQUEST'), findsOneWidget);
      expect(find.text('ACCEPT ORDER'), findsOneWidget);
      expect(find.text('DECLINE ORDER'), findsOneWidget);
    });
  });

  group('Delivery Partner - Pickup Confirmation UI Widget', () {
    testWidgets('renders pickup confirmation page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryPickupConfirmationPage(orderId: '#ORD-FLOW-001'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);
      expect(find.text('Start Delivery'), findsWidgets);
    });
  });

  group('Delivery Partner - Delivery Completed UI Widget', () {
    testWidgets('renders completed page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryCompletedPage(orderId: '#ORD-FLOW-001'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.text('Complete Order'), findsWidgets);
    });
  });

  group('Delivery Partner - Forgot Password UI Widget (Post-Fix)', () {
    testWidgets('renders forgot password page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryForgotPasswordPage(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });
  });
}
