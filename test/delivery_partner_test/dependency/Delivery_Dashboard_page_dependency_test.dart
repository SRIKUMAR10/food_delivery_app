import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;
  late MockDeliveryDashboardRepository mockRepository;
  late MockDeliveryDashboardService mockService;

  const DeliveryDashboardState loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    partnerStatus: DeliveryPartnerStatusType.online,
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
    mockBloc = MockDeliveryDashboardPageBloc();
    mockRepository = MockDeliveryDashboardRepository();
    mockService = MockDeliveryDashboardService();
    registerFallbackValue(const DeliveryDashboardState());

    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryDashboardPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryDashboardRepository();
      final service = DeliveryDashboardService();

      expect(repository, isA<DeliveryDashboardRepositoryBase>());
      expect(service, isA<DeliveryDashboardServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryDashboardPageBloc(
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
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});

      when(
        () => mockRepository.loadDashboardData(),
      ).thenAnswer((_) async => loadedState);
      when(
        () => mockRepository.getOnlineStatus(),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryDashboardPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
    });
  });
}
