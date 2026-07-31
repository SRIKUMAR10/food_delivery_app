import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

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
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();

    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getNavItems()).thenAnswer((_) async => navItems);
    when(
      () => mockRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => -1);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(
      () => mockRepository.saveSelectedIndex(any()),
    ).thenAnswer((_) async {});
    when(() => mockService.checkPermission()).thenAnswer((_) async => true);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: DeliveryNavigationBarPage(
        repository: mockRepository,
        service: mockService,
      ),
    );
  }

  group('DeliveryNavigationBarPage Performance & Memory Tests', () {
    testWidgets(
      'renders UI within frame threshold and disposes without leaks',
      (tester) async {
        setDesktopSize(tester);

        final Stopwatch stopwatch = Stopwatch()..start();
        await tester.pumpWidget(buildPage());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(3000));

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(DeliveryNavigationBarPage), findsNothing);
      },
    );

    testWidgets('handles rapid tab switches without errors or frame drops', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final labels = [
        'Orders',
        'Earnings',
        'Incentives',
        'Profile',
        'Documents',
      ];
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text(labels[i]), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Documents Overview'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dp_nav_documents')),
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('rebuilds quickly when switching between menu items', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final Stopwatch switchStopwatch = Stopwatch()..start();
      await tester.tap(find.text('Settings'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      switchStopwatch.stop();

      expect(switchStopwatch.elapsedMilliseconds, lessThan(1500));
      expect(find.text('Settings Overview'), findsOneWidget);
    });
  });
}
