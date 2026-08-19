import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryIncentivesDashboardPageBloc
    extends
        MockBloc<
          DeliveryIncentivesDashboardPageEvent,
          DeliveryIncentivesDashboardState
        >
    implements DeliveryIncentivesDashboardPageBloc {}

DeliveryIncentivesDashboardLoadedState buildState({String localeCode = 'en'}) {
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
    walletBalance: 2450.00,
    localeCode: localeCode,
    rangePoints: {
      IncentivesDateRange.thisMonth: [
        DeliveryIncentivesBonusPoint(
          label: '6AM',
          value: 40.0,
          date: DateTime(2026, 7, 31),
        ),
      ],
    },
    rewardHistory: [
      DeliveryIncentivesRewardRecord(
        id: 'r_1',
        title: 'Peak Hour Reward',
        date: DateTime(2026, 7, 31),
        amount: 120.00,
        type: RewardFilterType.peakHour,
        status: 'completed',
        referenceId: 'REF-1040',
      ),
    ],
  );
}

void main() {
  late MockDeliveryIncentivesDashboardPageBloc mockBloc;

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
    mockBloc = MockDeliveryIncentivesDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(buildState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryIncentivesDashboardPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text("Today's Bonus"), findsOneWidget);
      expect(find.text('Weekly Bonus'), findsOneWidget);
      expect(find.text('Monthly Bonus'), findsOneWidget);
      expect(find.text('Target Progress'), findsOneWidget);
      expect(find.text('Reward History'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(buildState(localeCode: 'ta'));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('ஊக்கத்தொகை டாஷ்போர்டு'), findsOneWidget);
      expect(find.text('வாலட் இருப்பு'), findsOneWidget);
      expect(find.text('இன்றைய போனஸ்'), findsOneWidget);
      expect(find.text('வாராந்திர போனஸ்'), findsOneWidget);
      expect(find.text('மாதாந்திர போனஸ்'), findsOneWidget);
      expect(find.text('இலக்கு முன்னேற்றம்'), findsOneWidget);
      expect(find.text('வெகுமதி வரலாறு'), findsOneWidget);
      expect(find.text('ஏற்றுமதி'), findsOneWidget);
    });

    testWidgets('keeps reward titles from data regardless of locale', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(buildState(localeCode: 'ta'));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('Reward History'), findsNothing);
      expect(find.text('வெகுமதி வரலாறு'), findsOneWidget);
      expect(find.text('Peak Hour Reward'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(
        DeliveryIncentivesDashboardStrings.of('incentivesDashboard', 'fr'),
        'Incentives Dashboard',
      );
      expect(
        DeliveryIncentivesDashboardStrings.of('walletBalance', 'hi'),
        'Wallet Balance',
      );
      expect(
        DeliveryIncentivesDashboardStrings.of('rewardHistory', 'es'),
        'Reward History',
      );
    });
  });
}
