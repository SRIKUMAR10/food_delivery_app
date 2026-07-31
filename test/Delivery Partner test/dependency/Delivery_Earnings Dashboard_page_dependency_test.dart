import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
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

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

void main() {
  late MockDeliveryEarningsDashboardPageBloc mockBloc;
  late MockDeliveryEarningsDashboardRepository mockRepository;
  late MockDeliveryEarningsDashboardService mockService;

  const loadedState = DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
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
    mockRepository = MockDeliveryEarningsDashboardRepository();
    mockService = MockDeliveryEarningsDashboardService();
    registerFallbackValue(const DeliveryEarningsDashboardState());

    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryEarningsDashboardPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryEarningsDashboardRepository();
      final service = DeliveryEarningsDashboardService();

      expect(repository, isA<DeliveryEarningsDashboardRepositoryBase>());
      expect(service, isA<DeliveryEarningsDashboardServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryEarningsDashboardPageBloc(
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
          home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_page')), findsOneWidget);
      expect(find.text('Earnings Overview'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});

      when(
        () => mockRepository.loadEarningsData(),
      ).thenAnswer((_) async => loadedState);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryEarningsDashboardPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_page')), findsOneWidget);
    });
  });
}
