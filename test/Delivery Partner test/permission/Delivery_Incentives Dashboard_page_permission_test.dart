import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDeliveryIncentivesDashboardPageBloc
    extends
        MockBloc<
          DeliveryIncentivesDashboardPageEvent,
          DeliveryIncentivesDashboardState
        >
    implements DeliveryIncentivesDashboardPageBloc {}

DeliveryIncentivesDashboardLoadedState buildLoadedState() {
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
    walletBalance: 2450.00,
    rangePoints: {
      IncentivesDateRange.thisMonth: [
        DeliveryIncentivesBonusPoint(
          label: '6AM',
          value: 40.0,
          date: DateTime(2026, 7, 31),
        ),
      ],
    },
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
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryIncentivesDashboardPage Permission Tests', () {
    test(
      'service incentives payload does not expose raw environment secrets',
      () async {
        final service = DeliveryIncentivesDashboardService(
          firestore: MockFirebaseFirestore(),
          auth: MockFirebaseAuth(),
        );
        final data = await service.fetchIncentivesData();
        final raw = data.toString();

        expect(
          raw.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      },
    );

    testWidgets('renders rewards table and export action when running', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
          ),
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_reward_history_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_incentives_export')), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('export action is reachable from the reward history card', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
          ),
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      final exportButton = find.byKey(const Key('dp_incentives_export'));
      expect(exportButton, findsOneWidget);
      await tester.ensureVisible(exportButton);
      await tester.tap(exportButton);
      await tester.pump();

      verify(() => mockBloc.add(const ExportRewardHistoryEvent())).called(1);
    });
  });
}
