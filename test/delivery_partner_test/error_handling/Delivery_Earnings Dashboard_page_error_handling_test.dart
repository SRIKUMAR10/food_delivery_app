import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

DeliveryEarningsDashboardState buildLoadedState() {
  return DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    walletBalance: 12850.00,
    totalEarnings: 12850.00,
    totalWithdrawn: 0.00,
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(
          label: '6AM',
          value: 180.0,
          date: DateTime(2026, 7, 31),
        ),
      ],
    },
  );
}

void main() {
  late MockDeliveryEarningsDashboardRepository mockRepository;
  late MockDeliveryEarningsDashboardService mockService;

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockRepository = MockDeliveryEarningsDashboardRepository();
    mockService = MockDeliveryEarningsDashboardService();

    when(
      () => mockRepository.loadEarningsData(),
    ).thenAnswer((_) async => buildLoadedState());
    when(
      () => mockRepository.withdraw(any()),
    ).thenAnswer((_) async => buildLoadedState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
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
    );
  }

  group('DeliveryEarningsDashboardPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.loadEarningsData(),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_earnings_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_earnings_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the dashboard', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.loadEarningsData()).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return buildLoadedState();
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_earnings_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_earnings_error')), findsNothing);
      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);
    });

    testWidgets('shows cached dashboard when offline data is restored', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.loadEarningsData(),
      ).thenAnswer((_) async => buildLoadedState().copyWith(isFromCache: true));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_earnings_error')), findsNothing);
      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);
    });

    testWidgets('shows error snackbar when withdrawal fails', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.withdraw(500.0),
      ).thenThrow(Exception('gateway timeout'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Withdrawal failed. Please try again.'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);
    });

    testWidgets('shows validation error when withdrawal exceeds balance', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '999999',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('Please enter a valid amount.'),
        findsOneWidget,
      );
      expect(find.text('Withdraw Funds'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);
    });
  });
}
