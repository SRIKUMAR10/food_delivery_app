import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';

import '../../font_loader_helper.dart';

class _FakeSettingsService implements DeliverySettingsServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async => true;

  @override
  Map<String, String> getSecureEnvironmentConfigs() => const {};

  @override
  Stream<double> syncProgress() => const Stream.empty();

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async =>
      true;

  @override
  Future<bool> deactivateAccount({String? reason}) async => true;

  @override
  Future<bool> deleteAccount({String? reason}) async => true;

  @override
  Future<bool> clearAppCache() async => true;

  @override
  double parseDeliveryRadius(String value, {double fallback = 5.0}) =>
      double.tryParse(value.trim()) ?? fallback;
}

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

class MockDeliveryWalletRepository extends Mock
    implements DeliveryWalletPageRepositoryBase {}

class MockDeliveryWalletService extends Mock
    implements DeliveryWalletPageServiceBase {}

class MockDeliveryOrderDetailsRepository extends Mock
    implements DeliveryOrderDetailsRepositoryBase {}

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

class MockDeliveryNavigationRepository extends Mock
    implements DeliveryNavigationRepositoryBase {}

class MockDeliveryNavigationScreenService extends Mock
    implements DeliveryNavigationServiceBase {}

DeliveryWalletPageState buildWalletLoadedState({
  double walletBalance = 24580.50,
}) {
  return DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    walletBalance: walletBalance,
    availableBalance: walletBalance,
    pendingBalance: 0,
    withdrawableAmount: walletBalance,
    totalEarnings: 48250,
    totalWithdrawn: 12000,
    transactions: [
      DeliveryWalletTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: DateTime(2026, 7, 31),
        amount: 640,
        type: 'income',
        status: 'completed',
      ),
    ],
    paymentMethods: const [
      DeliveryPaymentMethod(
        id: 'pm_1',
        type: 'UPI',
        label: 'Google Pay',
        maskedIdentifier: 'ravi@okhdfcbank',
        isDefault: true,
      ),
    ],
    bankAccount: const DeliveryBankAccount(
      bankName: 'HDFC Bank',
      accountHolder: 'Ravi Kumar',
      maskedAccountNumber: 'xxxx4821',
      ifscCode: 'HDFC0001234',
      isVerified: true,
    ),
    periodEarnings: {
      DeliveryWalletPeriod.thisMonth: [
        DeliveryWalletEarningsPoint(
          label: 'W1',
          value: 22850,
          date: DateTime(2026, 7, 1),
        ),
      ],
    },
    earningsBreakdown: const [
      DeliveryWalletBreakdownSlice(
        label: 'Delivery Income',
        value: 96850,
        colorHex: '#00E676',
      ),
    ],
  );
}

DeliveryEarningsDashboardState buildEarningsLoadedState() {
  final now = DateTime(2026, 7, 31);
  return DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    totalEarnings: 12850.00,
    todayEarnings: 2450.00,
    weeklyEarnings: 12850.00,
    monthlyEarnings: 48900.00,
    earningsGrowth: 18.5,
    walletBalance: 12850.00,
    pendingWithdrawal: 1200.00,
    totalWithdrawn: 48250.00,
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(label: '6AM', value: 180.0, date: now),
        DeliveryEarningsPoint(label: '9AM', value: 220.0, date: now),
        DeliveryEarningsPoint(label: '12PM', value: 320.0, date: now),
        DeliveryEarningsPoint(label: '3PM', value: 410.0, date: now),
      ],
    },
    transactions: [
      DeliveryEarningsTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: now,
        amount: 240.00,
        type: EarningsTransactionType.credit,
        status: 'completed',
      ),
    ],
    withdrawalHistory: [
      DeliveryWithdrawalRecord(
        id: 'wd_1',
        amount: 2000.00,
        method: 'Bank Transfer',
        date: now,
        status: 'completed',
      ),
    ],
  );
}

void main() {
  setUpAll(() {
    overrideFontAssetLoading();
    registerFallbackValue(DeliveryWalletTransactionFilter.all);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  group('Delivery Partner End-to-End User Flow', () {
    testWidgets(
      'Validates the core workflow from details landing to completed state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1000, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockOrderRepo = MockDeliveryOrderDetailsRepository();
        when(() => mockOrderRepo.watchOrderDetails('#ORD12345')).thenAnswer(
          (_) => Stream.value(
            const OrderModel(
              id: '#ORD12345',
              restaurantName: 'ahbi Store',
              customerName: 'Arun Kumar',
              pickupAddress: '123 Main Street',
              dropoffAddress: '456 Cross Street',
              status: 'ASSIGNED',
              pickupStatus: 'ASSIGNED',
              items: [
                OrderItemDetail(id: '1', name: 'Dosa', quantity: 2, price: 100),
              ],
            ),
          ),
        );
        when(() => mockOrderRepo.markGoingToRestaurant('#ORD12345'))
            .thenAnswer((_) async => true);
        when(() => mockOrderRepo.markArrivedAtRestaurant('#ORD12345'))
            .thenAnswer((_) async => true);
        when(() => mockOrderRepo.confirmPickup('#ORD12345'))
            .thenAnswer((_) async => true);

        final bloc = DeliveryOrderDetailsPageBloc(repository: mockOrderRepo)
          ..add(FetchOrderDetailsEvent('#ORD12345'));

        await tester.pumpWidget(
          MaterialApp(
            home: DeliveryOrderDetailsPageUi(
              orderId: '#ORD12345',
              bloc: bloc,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('CUSTOMER INFORMATION'), findsOneWidget);
        expect(find.text('ASSIGNED'), findsWidgets);

        // Step 1: Going to Restaurant
        await tester.ensureVisible(find.text('START GOING TO RESTAURANT'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('START GOING TO RESTAURANT'));
        await tester.pumpAndSettle();

        // Step 2: Arrived at Restaurant
        await tester.ensureVisible(find.text('I HAVE ARRIVED AT RESTAURANT'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('I HAVE ARRIVED AT RESTAURANT'));
        await tester.pumpAndSettle();

        // Step 3: Confirm Pickup -> Picked Up
        await tester.ensureVisible(
          find.text('CONFIRM PICKUP & START DELIVERY'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('CONFIRM PICKUP & START DELIVERY'));
        await tester.pumpAndSettle();

        // Final State: Picked Up -> Navigate to Customer
        expect(find.text('NAVIGATE TO CUSTOMER'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Delivery Navigation End-to-End User Flow', () {
    late MockDeliveryNavigationBarRepository mockRepository;
    late MockDeliveryNavigationBarService mockService;

    const List<DeliveryNavigationBarItem> navItems =
        DeliveryNavigationBarRepository.defaultNavItems;

    setUp(() {
      mockRepository = MockDeliveryNavigationBarRepository();
      mockService = MockDeliveryNavigationBarService();

      when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
      when(
        () => mockRepository.getNavItems(),
      ).thenAnswer((_) async => navItems);
      when(
        () => mockRepository.getSavedSelectedIndex(),
      ).thenAnswer((_) async => -1);
      when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
      when(
        () => mockRepository.getPartnerName(),
      ).thenAnswer((_) async => 'Dinesh Kumar');
      when(
        () => mockRepository.saveSelectedIndex(any()),
      ).thenAnswer((_) async {});
      when(() => mockService.checkPermission()).thenAnswer((_) async => true);
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('drives full journey from navbar into live navigation screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final navRepository = MockDeliveryNavigationRepository();
      final navService = MockDeliveryNavigationScreenService();

      when(() => navService.checkConnectivity()).thenAnswer((_) async => true);
      when(() => navService.checkLocationPermission()).thenAnswer((_) async => true);
      when(() => navService.checkGpsStatus()).thenAnswer((_) async => true);
      when(() => navService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy')))
          .thenAnswer((_) => const Stream<Map<String, dynamic>>.empty());
      when(() => navService.simulateLiveLocation())
          .thenAnswer((_) => const Stream<double>.empty());
      when(
        () => navRepository.fetchOrderSummary(),
      ).thenAnswer((_) async => DeliveryNavigationRepository.defaultOrder);
      when(() => navRepository.fetchActiveOrderData()).thenAnswer(
        (_) async => {
          'orderId': '#ORD-789456',
          'status': 'assigned',
          'customerName': 'Arun Kumar',
        },
      );
      when(() => navRepository.fetchPickup()).thenAnswer(
        (_) async => DeliveryNavigationRepository.defaultPickup,
      );
      when(() => navRepository.fetchDrop()).thenAnswer(
        (_) async => DeliveryNavigationRepository.defaultDrop,
      );
      when(() => navRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
      when(() => navRepository.getAudioEnabled()).thenAnswer((_) async => false);
      when(() => navRepository.getEmergencyMode()).thenAnswer((_) async => false);
      when(() => navRepository.getLocaleCode()).thenAnswer((_) async => 'en');
      when(() => navRepository.saveAudioEnabled(any())).thenAnswer((_) async {});
      when(() => navRepository.saveEmergencyMode(any())).thenAnswer((_) async {});
      when(() => navRepository.saveHasLocationPermission(any())).thenAnswer((_) async {});
      when(() => navRepository.saveLocaleCode(any())).thenAnswer((_) async {});
      when(() => navRepository.watchActiveOrder()).thenAnswer(
        (_) => const Stream<Map<String, dynamic>?>.empty(),
      );
      when(() => navRepository.watchPartnerProfile()).thenAnswer(
        (_) => const Stream<Map<String, dynamic>?>.empty(),
      );

      final bloc = DeliveryNavigationBloc(
        repository: navRepository,
        service: navService,
      )..add(const DeliveryNavigationInitEvent());

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationScreenPage(bloc: bloc),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Live Navigation'), findsOneWidget);
      expect(find.textContaining('#ORD-789456'), findsOneWidget);

      // Start Navigation -> Complete Delivery label
      await tester.tap(
        find.byKey(const Key('dp_navscreen_start_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Complete Delivery'), findsOneWidget);

      // Trigger emergency SOS
      await tester.tap(
        find.byKey(const Key('dp_navscreen_sos_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(
        find.text('Emergency alert sent. Nearest support team notified.'),
        findsOneWidget,
      );

      // Dismiss the floating snackbar before tapping exit.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .hideCurrentSnackBar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Exit Navigation back to loaded dashboard
      await tester.tap(
        find.byKey(const Key('dp_navscreen_exit_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Start Navigation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Pickup Confirmation End-to-End User Flow', () {
    testWidgets('drives the pickup confirmation journey to delivery started', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const model = PickupConfirmationModel(
        orderId: '#ORD12345',
        pickupLocationName: 'Green Mart',
        pickupAddress: '24, Anna Salai, Chennai',
        pickupContactName: 'Priya Sharma',
        pickupContactPhone: '+919876543210',
        pickupInstructions: 'Show the order code at the counter.',
        customerName: 'Mike Johnson',
        customerAddress: '10, Greams Road, Chennai',
        customerPhone: '+919800123456',
        pickupTime: '12:05 PM',
        paymentType: 'Cash on Delivery',
        orderAmount: 2450.00,
        walletBalance: 2450.00,
      );

      final mockPickupRepo = MockPickupConfirmationRepository();
      when(
        () => mockPickupRepo.watchPickupConfirmationDetails('#ORD12345'),
      ).thenAnswer((_) => Stream.value(model));
      when(() => mockPickupRepo.startDelivery('#ORD12345'))
          .thenAnswer((_) async => model);
      when(() => mockPickupRepo.fetchPickupConfirmationDetails('#ORD12345'))
          .thenAnswer((_) async => model);
      when(() => mockPickupRepo.arrivedAtStore('#ORD12345'))
          .thenAnswer((_) async => true);

      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockPickupRepo,
      )..add(FetchPickupConfirmationDetailsEvent('#ORD12345'));

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/deliveryNavigationScreen': (context) =>
                const Scaffold(body: Center(child: Text('Nav Screen'))),
          },
          home: DeliveryPickupConfirmationPage(
            orderId: '#ORD12345',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header identity
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);

      // Confirmed pickup state
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);

      // Start the delivery
      await tester.tap(find.byKey(const Key('dp_pickup_start_delivery')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Delivery started terminal state
      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Completed End-to-End User Flow', () {
    testWidgets('drives the completed order journey to terminal state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const model = DeliveryCompletedModel(
        orderId: '#ORD12345',
        walletBalance: 2450.00,
        partnerName: 'Ravi Kumar',
        partnerVehicleNo: 'TN 01 AB 1234',
        customerName: 'Arun Kumar',
        deliveryAddress: '12, Beach Road, Chennai - 600001',
        timeTaken: '32 min',
        distanceCovered: 5.6,
        paymentStatus: 'Paid Successfully',
        paymentMethod: 'UPI • Google Pay',
        customerRating: 5.0,
        deliveryEarnings: 120.00,
        completedAt: '05:40 PM',
      );

      final mockCompletedRepo = MockDeliveryCompletedRepository();
      when(
        () => mockCompletedRepo.watchCompletedOrder('#ORD12345'),
      ).thenAnswer((_) => Stream.value(model));
      when(() => mockCompletedRepo.fetchCompletedOrderDetails('#ORD12345'))
          .thenAnswer((_) async => model);
      when(() => mockCompletedRepo.completeOrder('#ORD12345'))
          .thenAnswer((_) async => model);

      final bloc = DeliveryCompletedBloc(repository: mockCompletedRepo)
        ..add(FetchCompletedOrderDetailsEvent('#ORD12345'));

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryCompletedPage(
            orderId: '#ORD12345',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header identity
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);

      // Delivered state
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('Excellent (5.0/5)'), findsOneWidget);

      // Rate the customer
      await tester.ensureVisible(find.byKey(const Key('dp_completed_star_5')));
      await tester.tap(find.byKey(const Key('dp_completed_star_5')));
      await tester.pump();
      expect(find.text('5/5'), findsOneWidget);

      // Complete the order
      await tester.tap(find.byKey(const Key('dp_completed_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Completed terminal state
      expect(find.text('Order Completed'), findsWidgets);
      expect(
        find.byKey(const Key('dp_completed_complete_button')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Earnings Dashboard End-to-End User Flow', () {
    testWidgets('drives full journey from dashboard load to withdrawal', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});

      final mockRepository = MockDeliveryEarningsDashboardRepository();
      final mockService = MockDeliveryEarningsDashboardService();
      when(() => mockRepository.watchEarningsData()).thenAnswer(
        (_) => Stream.value(buildEarningsLoadedState()),
      );
      when(() => mockRepository.loadEarningsData()).thenAnswer(
        (_) async => buildEarningsLoadedState(),
      );
      when(() => mockRepository.withdraw(any())).thenAnswer(
        (_) async => buildEarningsLoadedState().copyWith(
          walletBalance: 12350.00,
          totalEarnings: 12350.00,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D131E),
          ),
          home: Scaffold(
            body: DeliveryEarningsDashboardPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Dashboard loaded with earnings metrics
      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);

      // Adjust the earnings date range
      await tester.tap(find.byKey(const Key('dp_earnings_range_thisWeek')));
      await tester.pump();
      expect(find.byKey(const Key('dp_earnings_chart')), findsOneWidget);

      // Review the transaction history tab
      await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
      await tester.pump();
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Delivery Earnings'), findsOneWidget);

      // Return to overview and withdraw funds
      await tester.tap(find.byKey(const Key('dp_earnings_tab_overview')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Withdraw Funds'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Withdrawal reflected in the updated wallet balance
      expect(find.text('₹12350.00'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Incentives Dashboard End-to-End User Flow', () {
    testWidgets('drives full journey from dashboard load to reward export', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
          ),
          home: const Scaffold(body: DeliveryIncentivesDashboardPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Dashboard loaded with incentives metrics
      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);

      // Adjust the incentives date range
      await tester.tap(find.byKey(const Key('dp_incentives_range_today')));
      await tester.pump();
      expect(
        find.byKey(const Key('dp_incentives_overview_chart')),
        findsOneWidget,
      );

      // Filter the reward history
      await tester.ensureVisible(
        find.byKey(const Key('dp_incentives_filter_peakhour')),
      );
      await tester.tap(find.byKey(const Key('dp_incentives_filter_peakhour')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1 to 5 of 8 rewards'), findsOneWidget);

      // Paginate through the filtered history
      await tester.ensureVisible(
        find.byKey(const Key('dp_incentives_page_next')),
      );
      await tester.tap(find.byKey(const Key('dp_incentives_page_next')));
      await tester.pump();
      expect(find.text('6 to 8 of 8 rewards'), findsOneWidget);

      // Export the reward history
      await tester.ensureVisible(find.byKey(const Key('dp_incentives_export')));
      await tester.tap(find.byKey(const Key('dp_incentives_export')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Settings End-to-End User Flow', () {
    testWidgets('drives full journey from load to saved preferences', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D131E),
          ),
          home: Scaffold(
            body: DeliverySettingsPage(service: _FakeSettingsService()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Settings loaded with default preferences
      expect(find.text('Delivery Settings'), findsOneWidget);
      expect(find.text('5.0 km'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_toggle_darkMode')),
        findsOneWidget,
      );

      // Toggle dark mode
      await tester.tap(find.byKey(const Key('dp_settings_toggle_darkMode')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Save the updated settings
      await tester.tap(find.byKey(const Key('dp_settings_save_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Settings saved successfully'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Delivery Wallet End-to-End User Flow', () {
    testWidgets('opens wallet, withdraws funds, and filters transactions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});

      final mockRepository = MockDeliveryWalletRepository();
      final mockService = MockDeliveryWalletService();
      when(() => mockRepository.loadWalletData()).thenAnswer(
        (_) async => buildWalletLoadedState(),
      );
      when(() => mockRepository.watchWalletData()).thenAnswer(
        (_) => Stream.value(buildWalletLoadedState()),
      );
      when(() => mockRepository.withdraw(any())).thenAnswer(
        (_) async => buildWalletLoadedState(walletBalance: 23580.50),
      );
      when(() => mockRepository.watchTransactions(any())).thenAnswer(
        (invocation) {
          final filter = invocation.positionalArguments.first
              as DeliveryWalletTransactionFilter;
          return Stream.value(
            filter == DeliveryWalletTransactionFilter.withdrawals
                ? [
                    DeliveryWalletTransaction(
                      id: 'tx_wd',
                      title: 'Withdrawal to Bank',
                      date: DateTime(2026, 7, 31),
                      amount: 1000,
                      type: 'withdrawal',
                      status: 'pending',
                    ),
                  ]
                : <DeliveryWalletTransaction>[],
          );
        },
      );
      when(() => mockRepository.filterTransactions(any())).thenAnswer(
        (_) async => const <DeliveryWalletTransaction>[],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: DeliveryWalletPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('My Wallet'), findsWidgets);
      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_button')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '1000',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('₹23580.50'), findsWidgets);
      await tester.ensureVisible(
        find.byKey(const Key('dp_wallet_transaction_filter_withdrawals')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('dp_wallet_transaction_filter_withdrawals')),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Withdrawal to Bank'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
