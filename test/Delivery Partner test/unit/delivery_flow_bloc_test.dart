import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';

void main() {
  group('Session State Machine', () {
    late DeliveryActiveOrderSessionRepository sessionRepo;

    setUp(() {
      sessionRepo = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      sessionRepo.dispose();
    });

    test('initial state has correct defaults', () {
      expect(sessionRepo.currentState.isOnline, isTrue);
      expect(sessionRepo.currentState.walletBalance, equals(2450.50));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(500.00));
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
      expect(sessionRepo.currentState.completedOrdersCount, equals(14));
      expect(sessionRepo.currentState.totalEarningsToday, equals(1280.00));
    });

    test('full delivery flow: idle → incoming → accepted → pickup → navigating → completed', () {
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
      expect(sessionRepo.currentState.storeName, equals('Green Mart'));
      expect(sessionRepo.currentState.customerName, equals('Arun Kumar'));
      expect(sessionRepo.currentState.orderAmount, equals(620.00));

      sessionRepo.acceptOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.acceptedOrder));

      sessionRepo.confirmPickup();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.navigatingToCustomer));

      final prevEarnings = sessionRepo.currentState.totalEarningsToday;
      final prevCompleted = sessionRepo.currentState.completedOrdersCount;

      sessionRepo.completeDelivery();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.deliveryCompleted));
      expect(sessionRepo.currentState.totalEarningsToday, greaterThan(prevEarnings));
      expect(sessionRepo.currentState.completedOrdersCount, equals(prevCompleted + 1));
      expect(sessionRepo.currentState.walletBalance, greaterThan(2450.50));
    });

    test('declineOrder returns to idle and clears active order', () {
      sessionRepo.triggerIncomingOrder(orderId: '#ORD-FLOW-002');
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));
      expect(sessionRepo.currentState.activeOrderId, equals('#ORD-FLOW-002'));

      sessionRepo.declineOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
      expect(sessionRepo.currentState.storeName, isNull);
    });

    test('resetOrder clears active order and returns to idle', () {
      sessionRepo.triggerIncomingOrder(orderId: '#ORD-FLOW-003');
      sessionRepo.acceptOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.acceptedOrder));
      expect(sessionRepo.currentState.activeOrderId, equals('#ORD-FLOW-003'));

      sessionRepo.resetOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
    });

    test('processWithdrawal rejects invalid amounts', () {
      final initial = sessionRepo.currentState.walletBalance;
      sessionRepo.processWithdrawal(-100.0);
      expect(sessionRepo.currentState.walletBalance, equals(initial));
      sessionRepo.processWithdrawal(0.0);
      expect(sessionRepo.currentState.walletBalance, equals(initial));
    });

    test('processWithdrawal updates balances correctly', () {
      final initial = sessionRepo.currentState.walletBalance;
      sessionRepo.processWithdrawal(500.0);
      expect(sessionRepo.currentState.walletBalance, equals(initial - 500.0));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(500.0 + 500.0));
    });

    test('toggleOnlineStatus and setOnlineStatus work', () {
      expect(sessionRepo.currentState.isOnline, isTrue);
      sessionRepo.toggleOnlineStatus();
      expect(sessionRepo.currentState.isOnline, isFalse);
      sessionRepo.setOnlineStatus(true);
      expect(sessionRepo.currentState.isOnline, isTrue);
    });

    test('stream emits events on state change', () async {
      final states = <DeliverySessionState>[];
      final sub = sessionRepo.sessionStream.listen(states.add);

      sessionRepo.triggerIncomingOrder(orderId: '#ORD-STREAM');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(1));
      expect(states.last.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));

      sessionRepo.acceptOrder();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(2));

      sessionRepo.confirmPickup();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(3));

      sessionRepo.completeDelivery();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(4));

      await sub.cancel();
    });
  });

  group('Incoming Order BLoC', () {
    test('initial state has correct defaults', () {
      final bloc = DeliveryIncomingOrderBloc();
      expect(bloc.state.status, equals(IncomingOrderStatus.initial));
      expect(bloc.state.remainingSeconds, equals(15));
      expect(bloc.state.orderId, equals('#ORD98234'));
      bloc.close();
    });

    test('load fetches from repository and transitions to loaded', () async {
      final bloc = DeliveryIncomingOrderBloc(
        repository: DeliveryIncomingOrderRepository(),
      );
      bloc.add(const DeliveryIncomingOrderLoadEvent());
      await Future.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.status, equals(IncomingOrderStatus.loaded));
      expect(bloc.state.orderId, equals('#ORD98234'));
      expect(bloc.state.storeName, equals('Green Mart'));

      bloc.add(const DeliveryIncomingOrderDeclineEvent());
      await Future.delayed(const Duration(milliseconds: 300));
      bloc.close();
    });

    test('accept transitions to accepted', () async {
      final bloc = DeliveryIncomingOrderBloc();
      bloc.add(const DeliveryIncomingOrderAcceptEvent());
      await Future.delayed(const Duration(milliseconds: 400));

      expect(bloc.state.status, equals(IncomingOrderStatus.accepted));
      bloc.close();
    });

    test('decline transitions to declined', () async {
      final bloc = DeliveryIncomingOrderBloc();
      bloc.add(const DeliveryIncomingOrderDeclineEvent());
      await Future.delayed(const Duration(milliseconds: 400));

      expect(bloc.state.status, equals(IncomingOrderStatus.declined));
      bloc.close();
    });
  });

  group('Pickup Confirmation BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryPickupConfirmationPageBloc();
      expect(bloc.state.status, equals(PickupConfirmationStatus.initial));
      expect(bloc.state.model, isNull);
      expect(bloc.state.localeCode, equals('en'));
      bloc.close();
    });

    test('fetch details loads model', () async {
      final bloc = DeliveryPickupConfirmationPageBloc();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-PU-001'));
      await Future.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.status, equals(PickupConfirmationStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-PU-001'));
      expect(bloc.state.model!.pickupLocationName, isNotEmpty);
      expect(bloc.state.model!.customerName, isNotEmpty);

      bloc.close();
    });

    test('startDelivery transitions to deliveryStarted', () async {
      final bloc = DeliveryPickupConfirmationPageBloc();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-PU-002'));
      await Future.delayed(const Duration(milliseconds: 700));
      expect(bloc.state.status, equals(PickupConfirmationStatus.success));

      bloc.add(const StartDeliveryEvent('#ORD-PU-002'));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(bloc.state.status, equals(PickupConfirmationStatus.deliveryStarted));

      bloc.close();
    });
  });

  group('Delivery Completed BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryCompletedBloc();
      expect(bloc.state.status, equals(DeliveryCompletedStatus.initial));
      expect(bloc.state.model, isNull);
      expect(bloc.state.isCompleting, isFalse);
      bloc.close();
    });

    test('fetch details loads model', () async {
      final bloc = DeliveryCompletedBloc();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-001'));
      await Future.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.status, equals(DeliveryCompletedStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-CO-001'));

      bloc.close();
    });

    test('completeOrder transitions to completed', () async {
      final bloc = DeliveryCompletedBloc();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-002'));
      await Future.delayed(const Duration(milliseconds: 700));

      bloc.add(const CompleteOrderSubmittedEvent('#ORD-CO-002'));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(bloc.state.status, equals(DeliveryCompletedStatus.completed));

      bloc.close();
    });

    test('rateCustomer stores rating', () async {
      final bloc = DeliveryCompletedBloc();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-003'));
      await Future.delayed(const Duration(milliseconds: 700));

      bloc.add(const RateCustomerEvent(4));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.ratedScore, equals(4));
      expect(bloc.state.ratingSubmitted, isTrue);
      bloc.close();
    });
  });

  group('Forgot Password BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryForgotPasswordBloc(
        service: DeliveryForgotPasswordService(),
      );
      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.initial));
      expect(bloc.state.phoneNumber, isEmpty);
      bloc.close();
    }, skip: 'Requires Firebase mock for DeliveryPartnerRepository');

    test('phoneChanged updates phone', () {
      final bloc = DeliveryForgotPasswordBloc(
        service: DeliveryForgotPasswordService(),
      );
      bloc.add(const DeliveryForgotPasswordPhoneChanged('9876543210'));
      expect(bloc.state.phoneNumber, equals('9876543210'));
      bloc.close();
    }, skip: 'Requires Firebase mock for DeliveryPartnerRepository');

    test('submit empty phone fails', () async {
      final bloc = DeliveryForgotPasswordBloc(
        service: DeliveryForgotPasswordService(),
      );
      bloc.add(const DeliveryForgotPasswordSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.failure));
      expect(bloc.state.errorMessage, isNotNull);
      bloc.close();
    }, skip: 'Requires Firebase mock for DeliveryPartnerRepository');

    test('submit invalid phone fails', () async {
      final bloc = DeliveryForgotPasswordBloc(
        service: DeliveryForgotPasswordService(),
      );
      bloc.add(const DeliveryForgotPasswordPhoneChanged('12'));
      bloc.add(const DeliveryForgotPasswordSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, equals(DeliveryForgotPasswordStatus.failure));
      bloc.close();
    }, skip: 'Requires Firebase mock for DeliveryPartnerRepository');
  });

  group('Settings BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliverySettingsBloc();
      expect(bloc.state.status, equals(DeliverySettingsStatus.initial));
      expect(bloc.state.notificationsEnabled, isTrue);
      expect(bloc.state.deliveryRadius, equals(5.0));
      bloc.close();
    });

    test('toggle notification flips state', () async {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsToggleNotificationEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.notificationsEnabled, isFalse);
      bloc.close();
    });

    test('toggle autoAccept flips state', () async {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsToggleAutoAcceptEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.autoAcceptEnabled, isFalse);
      bloc.close();
    });

    test('updateRadius clamps within bounds', () async {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsUpdateRadiusEvent(10.0));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.deliveryRadius, equals(10.0));

      bloc.add(const DeliverySettingsUpdateRadiusEvent(0.5));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.deliveryRadius, equals(1.0));
      bloc.close();
    });

    test('changeLanguage updates locale', () async {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsChangeLanguageEvent('ta'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.languageCode, equals('ta'));
      expect(bloc.state.localeCode, equals('ta'));
      bloc.close();
    });

    test('sunMode and oledMode are mutually exclusive', () async {
      final bloc = DeliverySettingsBloc();
      bloc.add(const DeliverySettingsToggleOledModeEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.oledModeEnabled, isTrue);
      expect(bloc.state.sunModeEnabled, isFalse);

      bloc.add(const DeliverySettingsToggleSunModeEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.sunModeEnabled, isTrue);
      expect(bloc.state.oledModeEnabled, isFalse);
      bloc.close();
    });
  });

  group('Dashboard BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryDashboardPageBloc();
      expect(bloc.state.status, equals(DeliveryDashboardStatus.initial));
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.partnerName, equals('Ravi Kumar'));
      bloc.close();
    });

    test('toggleOnline updates status', () async {
      final bloc = DeliveryDashboardPageBloc();
      bloc.add(const DeliveryDashboardToggleOnlineEvent(false));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isOnline, isFalse);
      bloc.close();
    });

    test('filterActivity updates selected filter', () async {
      final bloc = DeliveryDashboardPageBloc();
      bloc.add(const DeliveryDashboardFilterActivityEvent('delivered'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.selectedFilter, equals('delivered'));
      bloc.close();
    });
  });

  group('Order Details BLoC', () {
    test('initial state has defaults', () {
      final bloc = DeliveryOrderDetailsPageBloc();
      expect(bloc.state.status, equals(OrderDetailsStatus.initial));
      expect(bloc.state.order, isNull);
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
}
