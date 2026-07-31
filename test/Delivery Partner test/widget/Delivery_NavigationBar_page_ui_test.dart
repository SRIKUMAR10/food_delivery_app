import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarPageBloc
    extends MockBloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState>
    implements DeliveryNavigationBarPageBloc {}

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarPageBloc mockBloc;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  const DeliveryNavigationBarState loadedState = DeliveryNavigationBarState(
    status: DeliveryNavigationBarStatus.loaded,
    selectedIndex: 4,
    navItems: navItems,
    partnerName: 'Ravi Kumar',
    localeCode: 'en',
    hasPermission: true,
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

    registerFallbackValue(const DeliveryNavigationBarTabChangedEvent(0));
    registerFallbackValue(const DeliveryNavigationBarRefreshEvent());
    registerFallbackValue(
      const DeliveryNavigationBarContactSupportClickedEvent(),
    );
  });

  setUp(() {
    mockBloc = MockDeliveryNavigationBarPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    SharedPreferences.setMockInitialValues({});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(home: DeliveryNavigationBarPage(bloc: mockBloc));
  }

  group('DeliveryNavigationBarPage Widget Tests', () {
    testWidgets('renders all sidebar menu items and branding', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('Incentives'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Bank Details'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Need Help?'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
    });

    testWidgets('shows Profile as the active tab by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final profileItem = find.byKey(const ValueKey('dp_nav_profile'));
      expect(profileItem, findsOneWidget);

      final indicatorInsideProfile = find.descendant(
        of: profileItem,
        matching: find.byKey(const Key('dp_nav_indicator')),
      );
      expect(indicatorInsideProfile, findsOneWidget);

      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('dispatches tab changed event when a menu item is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Orders'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationBarTabChangedEvent(1)),
      ).called(1);
    });

    testWidgets('moves selection indicator when tab changes', (tester) async {
      setDesktopSize(tester);

      final repository = MockDeliveryNavigationBarRepository();
      final service = MockDeliveryNavigationBarService();
      when(() => repository.getNavItems()).thenAnswer((_) async => navItems);
      when(
        () => repository.getSavedSelectedIndex(),
      ).thenAnswer((_) async => -1);
      when(() => repository.getLocaleCode()).thenAnswer((_) async => 'en');
      when(
        () => repository.getPartnerName(),
      ).thenAnswer((_) async => 'Ravi Kumar');
      when(() => repository.saveSelectedIndex(any())).thenAnswer((_) async {});
      when(() => service.checkConnectivity()).thenAnswer((_) async => true);
      when(() => service.checkPermission()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(
            repository: repository,
            service: service,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final profileItem = find.byKey(const ValueKey('dp_nav_profile'));
      expect(
        find.descendant(
          of: profileItem,
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Orders'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final ordersItem = find.byKey(const ValueKey('dp_nav_orders'));
      expect(
        find.descendant(
          of: ordersItem,
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('dispatches refresh event from error retry button', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.error,
          errorMessage: 'Network failure',
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Network failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationBarRefreshEvent()),
      ).called(1);
    });

    testWidgets('renders skeleton loaders during loading state', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_skeleton_shell')), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('renders empty state when no navigation items exist', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.empty,
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('No navigation items available'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows contact support snackbar when help card tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Contact Support'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryNavigationBarContactSupportClickedEvent(),
        ),
      ).called(1);
      expect(find.text('Contacting support...'), findsOneWidget);
    });
  });
}
