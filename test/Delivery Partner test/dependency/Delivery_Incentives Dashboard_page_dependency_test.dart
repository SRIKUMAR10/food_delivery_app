import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryIncentivesDashboardPageBloc
    extends
        MockBloc<
          DeliveryIncentivesDashboardPageEvent,
          DeliveryIncentivesDashboardState
        >
    implements DeliveryIncentivesDashboardPageBloc {}

class MockDeliveryIncentivesDashboardRepository extends Mock
    implements DeliveryIncentivesDashboardRepositoryBase {}

class MockDeliveryIncentivesDashboardService extends Mock
    implements DeliveryIncentivesDashboardServiceBase {}

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
  late MockDeliveryIncentivesDashboardRepository mockRepository;
  late MockDeliveryIncentivesDashboardService mockService;

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
    mockRepository = MockDeliveryIncentivesDashboardRepository();
    mockService = MockDeliveryIncentivesDashboardService();
    registerFallbackValue(const DeliveryIncentivesDashboardInitialState());

    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryIncentivesDashboardPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryIncentivesDashboardRepository();
      final service = DeliveryIncentivesDashboardService();

      expect(repository, isA<DeliveryIncentivesDashboardRepositoryBase>());
      expect(service, isA<DeliveryIncentivesDashboardServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.repository, same(mockRepository));
      expect(bloc.service, same(mockService));
      bloc.close();
    });

    testWidgets('page renders with an injected bloc instance', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_page')), findsOneWidget);
      expect(find.text('Incentives Dashboard'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});

      when(
        () => mockRepository.loadIncentivesData(),
      ).thenAnswer((_) async => buildLoadedState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryIncentivesDashboardPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('dp_incentives_page')), findsOneWidget);
    });
  });
}
