import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryEarningsDashboardPageBloc
    extends
        MockBloc<
          DeliveryEarningsDashboardPageEvent,
          DeliveryEarningsDashboardState
        >
    implements DeliveryEarningsDashboardPageBloc {}

void main() {
  late MockDeliveryEarningsDashboardPageBloc mockBloc;

  final loadedState = DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    walletBalance: 12850.00,
    totalEarnings: 12850.00,
    totalWithdrawn: 48250.00,
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

  setUp(() {
    mockBloc = MockDeliveryEarningsDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryEarningsDashboardPage Permission Tests', () {
    test(
      'service earnings payload does not expose raw environment secrets',
      () async {
        final service = DeliveryEarningsDashboardService();
        final data = await service.fetchEarningsData();
        final raw = data.toString();

        expect(
          raw.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      },
    );

    test(
      'service API base URL falls back without leaking credentials',
      () async {
        final service = DeliveryEarningsDashboardService();
        final url = service.apiBaseUrl;

        expect(url, isNotEmpty);
        expect(
          url.contains(
            RegExp(r'(token|password|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      },
    );

    testWidgets('renders wallet card and withdraw action when running', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D131E),
          ),
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_wallet_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_withdraw_button')),
        findsOneWidget,
      );
      expect(find.text('₹12850.00'), findsWidgets);
    });

    testWidgets('withdraw action is reachable and opens the withdraw dialog', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D131E),
          ),
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      final withdrawButton = find.byKey(
        const Key('dp_earnings_withdraw_button'),
      );
      expect(withdrawButton, findsOneWidget);
      await tester.tap(withdrawButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_earnings_withdraw_confirm')),
        findsOneWidget,
      );
    });
  });
}
