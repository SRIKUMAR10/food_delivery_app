import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';
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

void main() {
  setUpAll(() {
    overrideFontAssetLoading();

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
        await tester.pumpWidget(
          const MaterialApp(
            home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
          ),
        );

        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Customer Details'), findsOneWidget);
        expect(find.text('PENDING'), findsOneWidget);

        // Transition 1: Reached Pickup
        await tester.ensureVisible(find.text('REACHED PICKUP'));
        await tester.tap(find.text('REACHED PICKUP'));
        await tester.pump(const Duration(milliseconds: 400));

        // Transition 2: Start Delivery
        await tester.ensureVisible(find.text('START DELIVERY'));
        await tester.tap(find.text('START DELIVERY'));
        await tester.pump(const Duration(milliseconds: 400));

        // Transition 3: Complete Order
        await tester.ensureVisible(find.text('COMPLETE ORDER'));
        await tester.tap(find.text('COMPLETE ORDER'));
        await tester.pump(const Duration(milliseconds: 400));

        // Final State: Order Completed
        expect(find.text('ORDER COMPLETED'), findsOneWidget);
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

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(
            repository: mockRepository,
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);

      // Open the Delivery Navigation Screen from the sidebar.
      await tester.tap(find.text('Navigate'), warnIfMissed: false);
      await tester.pump();
      // Allow the real connectivity probe to time out and the dashboard to load.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Live Navigation'), findsOneWidget);
      expect(find.textContaining('#ORD-789456'), findsOneWidget);

      // Start Navigation -> Follow Route
      await tester.tap(
        find.byKey(const Key('dp_navscreen_start_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Follow Route'), findsOneWidget);

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

      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryPickupConfirmationPage(orderId: '#ORD12345'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

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

      await tester.pumpWidget(
        const MaterialApp(home: DeliveryCompletedPage(orderId: '#ORD12345')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

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

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D131E),
          ),
          home: const Scaffold(body: DeliveryEarningsDashboardPage()),
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

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: DeliveryWalletPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('My Wallet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_button')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('dp_wallet_withdraw_amount')),
        '1000',
      );
      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('₹23580.50'), findsWidgets);
      await tester.tap(
        find.byKey(const Key('dp_wallet_transaction_filter_withdrawals')),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Withdrawal to Bank'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
