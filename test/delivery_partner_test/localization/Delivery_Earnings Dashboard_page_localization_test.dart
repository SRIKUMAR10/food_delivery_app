import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryEarningsDashboardPageBloc
    extends
        MockBloc<
          DeliveryEarningsDashboardPageEvent,
          DeliveryEarningsDashboardState
        >
    implements DeliveryEarningsDashboardPageBloc {}

DeliveryEarningsDashboardState buildState({String localeCode = 'en'}) {
  return DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    walletBalance: 12850.00,
    localeCode: localeCode,
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(
          label: '6AM',
          value: 180.0,
          date: DateTime(2026, 7, 31),
        ),
      ],
    },
    transactions: [
      DeliveryEarningsTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: DateTime(2026, 7, 31),
        amount: 240.00,
        type: EarningsTransactionType.credit,
        status: 'completed',
      ),
    ],
  );
}

void main() {
  late MockDeliveryEarningsDashboardPageBloc mockBloc;

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
    when(() => mockBloc.state).thenReturn(buildState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryEarningsDashboardPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.text('Total Earnings'), findsWidgets);
      expect(find.text('Wallet Balance'), findsWidgets);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Upload Delivery Proof'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Withdrawals'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(buildState(localeCode: 'ta'));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('வருமான கண்ணோட்டம்'), findsOneWidget);
      expect(find.text('மொத்த வருமானம்'), findsWidgets);
      expect(find.text('வாலட் இருப்பு'), findsWidgets);
      expect(find.text('பணம் எடுக்க'), findsOneWidget);
      expect(find.text('கண்ணோட்டம்'), findsOneWidget);
      expect(find.text('பரிவர்த்தனைகள்'), findsOneWidget);
      expect(find.text('எடுப்புகள்'), findsOneWidget);
    });

    testWidgets('keeps transaction titles from data regardless of locale', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        buildState(
          localeCode: 'ta',
        ).copyWith(selectedTab: EarningsTab.transactions),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('Recent Transactions'), findsNothing);
      expect(find.text('சமீபத்திய பரிவர்த்தனைகள்'), findsOneWidget);
      expect(find.text('Delivery Earnings'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(
        DeliveryEarningsDashboardStrings.of('earningsOverview', 'fr'),
        'Earnings Overview',
      );
      expect(
        DeliveryEarningsDashboardStrings.of('walletBalance', 'hi'),
        'Wallet Balance',
      );
      expect(
        DeliveryEarningsDashboardStrings.of('transactions', 'es'),
        'Transactions',
      );
    });
  });
}
