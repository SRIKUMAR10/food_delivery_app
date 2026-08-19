import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';
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
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';

class MockIncomingOrderRepository extends Mock
    implements DeliveryIncomingOrderRepositoryBase {}

class MockIncomingOrderService extends Mock
    implements DeliveryIncomingOrderServiceBase {}

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

class MockDeliveryCompletedService extends Mock
    implements DeliveryCompletedServiceBase {}

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

class MockOrderDetailsRepository extends Mock
    implements DeliveryOrderDetailsRepositoryBase {}

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
      expect(sessionRepo.currentState.walletBalance, equals(0.0));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(0.0));
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));
      expect(sessionRepo.currentState.activeOrderId, isNull);
      expect(sessionRepo.currentState.completedOrdersCount, equals(0));
      expect(sessionRepo.currentState.totalEarningsToday, equals(0.0));
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

      sessionRepo.completeDelivery(deliveryFee: 40.0);
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.deliveryCompleted));
      expect(sessionRepo.currentState.totalEarningsToday, greaterThan(prevEarnings));
      expect(sessionRepo.currentState.completedOrdersCount, equals(prevCompleted + 1));
      expect(sessionRepo.currentState.walletBalance, greaterThan(0.0));
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
      sessionRepo.completeDelivery(deliveryFee: 1000.0);

      final initial = sessionRepo.currentState.walletBalance;
      sessionRepo.processWithdrawal(500.0);
      expect(sessionRepo.currentState.walletBalance, equals(initial - 500.0));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(500.0));
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
    late MockIncomingOrderRepository mockRepository;
    late MockIncomingOrderService mockService;

    setUp(() {
      mockRepository = MockIncomingOrderRepository();
      mockService = MockIncomingOrderService();
    });

    test('initial state has empty defaults', () {
      final bloc = DeliveryIncomingOrderBloc(
        repository: mockRepository,
        service: mockService,
      );
      expect(bloc.state.status, equals(IncomingOrderStatus.initial));
      expect(bloc.state.remainingSeconds, equals(15));
      expect(bloc.state.orderId, equals(''));
      expect(bloc.state.storeName, equals(''));
      bloc.close();
    });

    test('load fetches from repository and transitions to loaded', () async {
      when(
        () => mockRepository.watchIncomingOrder(),
      ).thenAnswer((_) => Stream.value(const DeliveryIncomingOrderState(
            status: IncomingOrderStatus.loaded,
            orderId: '#ORD-IN-001',
            storeName: 'Green Mart',
            storeAddress: '24, Anna Salai, Chennai',
            customerName: 'Arun Kumar',
            customerAddress: '12, Beach Road, Chennai',
            orderAmount: 620.00,
            remainingSeconds: 15,
          )));
      when(
        () => mockRepository.fetchIncomingOrder(),
      ).thenAnswer((_) async => const DeliveryIncomingOrderState(
            status: IncomingOrderStatus.loaded,
            orderId: '#ORD-IN-001',
            storeName: 'Green Mart',
            storeAddress: '24, Anna Salai, Chennai',
            customerName: 'Arun Kumar',
            customerAddress: '12, Beach Road, Chennai',
            orderAmount: 620.00,
            remainingSeconds: 15,
          ));

      final bloc = DeliveryIncomingOrderBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const DeliveryIncomingOrderLoadEvent());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, equals(IncomingOrderStatus.loaded));
      expect(bloc.state.orderId, equals('#ORD-IN-001'));
      expect(bloc.state.storeName, equals('Green Mart'));

      bloc.close();
    });

    test('accept transitions to accepted', () async {
      when(
        () => mockRepository.acceptOrder(any()),
      ).thenAnswer((_) async => true);

      final bloc = DeliveryIncomingOrderBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const DeliveryIncomingOrderAcceptEvent());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, equals(IncomingOrderStatus.accepted));
      bloc.close();
    });

    test('decline transitions to declined', () async {
      when(
        () => mockRepository.declineOrder(any()),
      ).thenAnswer((_) async => true);

      final bloc = DeliveryIncomingOrderBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const DeliveryIncomingOrderDeclineEvent());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.status, equals(IncomingOrderStatus.declined));
      bloc.close();
    });
  });

  group('Pickup Confirmation BLoC', () {
    late MockPickupConfirmationRepository mockRepository;
    late MockPickupConfirmationService mockService;

    const pickupModel = PickupConfirmationModel(
      orderId: '#ORD-PU-001',
      pickupLocationName: 'Green Mart',
      pickupAddress: '24, Anna Salai, Chennai',
      pickupContactName: 'Priya Sharma',
      pickupContactPhone: '+919876543210',
      pickupInstructions: 'Collect sealed bags.',
      customerName: 'Mike Johnson',
      customerAddress: '12, Beach Road, Chennai',
      customerPhone: '+919876543211',
      pickupTime: '12:05 PM',
      paymentType: 'Cash on Delivery',
      orderAmount: 486.50,
      walletBalance: 2450.00,
    );

    setUp(() {
      mockRepository = MockPickupConfirmationRepository();
      mockService = MockPickupConfirmationService();
      when(
        () => mockRepository.watchPickupConfirmationDetails(any()),
      ).thenAnswer((_) => Stream.value(pickupModel));
    });

    test('initial state has defaults', () {
      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      expect(bloc.state.status, equals(PickupConfirmationStatus.initial));
      expect(bloc.state.model, isNull);
      expect(bloc.state.localeCode, equals('en'));
      bloc.close();
    });

    test('fetch details loads model', () async {
      when(
        () => mockRepository.fetchPickupConfirmationDetails('#ORD-PU-001'),
      ).thenAnswer((_) async => pickupModel);

      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-PU-001'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, equals(PickupConfirmationStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-PU-001'));
      expect(bloc.state.model!.pickupLocationName, isNotEmpty);
      expect(bloc.state.model!.customerName, isNotEmpty);

      bloc.close();
    });

    test('startDelivery transitions to deliveryStarted', () async {
      when(
        () => mockRepository.fetchPickupConfirmationDetails('#ORD-PU-002'),
      ).thenAnswer((_) async => pickupModel);
      when(
        () => mockRepository.startDelivery('#ORD-PU-002'),
      ).thenAnswer((_) async => pickupModel);

      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD-PU-002'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(PickupConfirmationStatus.success));

      bloc.add(const StartDeliveryEvent('#ORD-PU-002'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(PickupConfirmationStatus.deliveryStarted));

      bloc.close();
    });
  });

  group('Delivery Completed BLoC', () {
    late MockDeliveryCompletedRepository mockRepository;
    late MockDeliveryCompletedService mockService;

    const completedModel = DeliveryCompletedModel(
      orderId: '#ORD-CO-001',
      walletBalance: 2450.00,
      partnerName: 'Kavitha',
      partnerVehicleNo: 'TN 01 AB 1234',
      customerName: 'Arun Kumar',
      deliveryAddress: '12, Beach Road, Chennai',
      timeTaken: '32 min',
      distanceCovered: 5.6,
      paymentStatus: 'Paid',
      paymentMethod: 'UPI',
      customerRating: 5.0,
      deliveryEarnings: 120.00,
      completedAt: 'Today, 4:15 PM',
    );

    setUp(() {
      mockRepository = MockDeliveryCompletedRepository();
      mockService = MockDeliveryCompletedService();
      when(
        () => mockRepository.watchCompletedOrder(any()),
      ).thenAnswer((_) => Stream.value(completedModel));
    });

    test('initial state has defaults', () {
      final bloc = DeliveryCompletedBloc(repository: mockRepository, service: mockService);
      expect(bloc.state.status, equals(DeliveryCompletedStatus.initial));
      expect(bloc.state.model, isNull);
      expect(bloc.state.isCompleting, isFalse);
      bloc.close();
    });

    test('fetch details loads model', () async {
      when(
        () => mockRepository.fetchCompletedOrderDetails('#ORD-CO-001'),
      ).thenAnswer((_) async => completedModel);

      final bloc = DeliveryCompletedBloc(repository: mockRepository, service: mockService);
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-001'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, equals(DeliveryCompletedStatus.success));
      expect(bloc.state.model, isNotNull);
      expect(bloc.state.model!.orderId, equals('#ORD-CO-001'));

      bloc.close();
    });

    test('completeOrder transitions to completed', () async {
      when(
        () => mockRepository.fetchCompletedOrderDetails('#ORD-CO-002'),
      ).thenAnswer((_) async => completedModel);
      when(
        () => mockRepository.completeOrder('#ORD-CO-002'),
      ).thenAnswer((_) async => completedModel);

      final bloc = DeliveryCompletedBloc(repository: mockRepository, service: mockService);
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-002'));
      await Future.delayed(const Duration(milliseconds: 100));

      bloc.add(const CompleteOrderSubmittedEvent('#ORD-CO-002'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(DeliveryCompletedStatus.completed));

      bloc.close();
    });

    test('rateCustomer stores rating', () async {
      when(
        () => mockRepository.fetchCompletedOrderDetails('#ORD-CO-003'),
      ).thenAnswer((_) async => completedModel);

      final bloc = DeliveryCompletedBloc(repository: mockRepository, service: mockService);
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD-CO-003'));
      await Future.delayed(const Duration(milliseconds: 100));

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
    late MockDeliveryDashboardRepository mockRepository;
    late MockDeliveryDashboardService mockService;

    setUp(() {
      mockRepository = MockDeliveryDashboardRepository();
      mockService = MockDeliveryDashboardService();
    });

    test('initial state has empty defaults', () {
      final bloc = DeliveryDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      expect(bloc.state.status, equals(DeliveryDashboardStatus.initial));
      expect(bloc.state.isOnline, isFalse);
      expect(bloc.state.partnerName, equals(''));
      bloc.close();
    });

    test('toggleOnline updates status', () async {
      when(
        () => mockRepository.saveOnlineStatus(false),
      ).thenAnswer((_) async => false);

      final bloc = DeliveryDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const DeliveryDashboardToggleOnlineEvent(false));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isOnline, isFalse);
      bloc.close();
    });

    test('filterActivity updates selected filter', () async {
      final bloc = DeliveryDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      bloc.add(const DeliveryDashboardFilterActivityEvent('delivered'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.selectedFilter, equals('delivered'));
      bloc.close();
    });
  });

  group('Order Details BLoC', () {
    late MockOrderDetailsRepository mockRepository;

    setUp(() {
      mockRepository = MockOrderDetailsRepository();
    });

    const sampleOrder = OrderModel(
      id: '#ORD12345',
      pickupAddress: 'Green Mart, Anna Salai',
      dropoffAddress: 'Mike Residence, Beach Road',
      earnings: 120,
      distance: 2.4,
      status: 'Accepted',
      customerPhone: '+919876543210',
      merchantPhone: 'seller_1',
      orderValue: 620,
    );

    test('initial state has defaults', () {
      final bloc = DeliveryOrderDetailsPageBloc(repository: mockRepository);
      expect(bloc.state.status, equals(OrderDetailsStatus.initial));
      expect(bloc.state.order, isNull);
      bloc.close();
    });

    test('fetchOrderDetails loads order data', () async {
      when(
        () => mockRepository.watchOrderDetails('#ORD12345'),
      ).thenAnswer((_) => Stream.value(sampleOrder));
      when(
        () => mockRepository.fetchOrderDetails('#ORD12345'),
      ).thenAnswer((_) async => sampleOrder);

      final bloc = DeliveryOrderDetailsPageBloc(repository: mockRepository);
      bloc.add(const FetchOrderDetailsEvent('#ORD12345'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, equals(OrderDetailsStatus.success));
      expect(bloc.state.order, isNotNull);
      expect(bloc.state.order!.id, equals('#ORD12345'));

      bloc.close();
    });
  });
}
