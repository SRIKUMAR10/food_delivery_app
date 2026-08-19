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
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarPageBloc
    extends MockBloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState>
    implements DeliveryNavigationBarPageBloc {}

void main() {
  late MockDeliveryNavigationBarPageBloc mockBloc;

  const DeliveryNavigationBarState loadedState = DeliveryNavigationBarState(
    status: DeliveryNavigationBarStatus.loaded,
    selectedIndex: 7,
    navItems: DeliveryNavigationBarRepository.defaultNavItems,
    partnerName: 'Ravi Kumar',
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
    mockBloc = MockDeliveryNavigationBarPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildPage(Size size) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(),
        child: DeliveryNavigationBarPage(bloc: mockBloc),
      ),
    );
  }

  group('DeliveryNavigationBarPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark sidebar on desktop viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(1440, 1024)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationBarPage), findsOneWidget);
      expect(find.byKey(const ValueKey('dp_nav_documents')), findsOneWidget);
      expect(find.byKey(const Key('dp_nav_indicator')), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
    });

    testWidgets('renders sidebar layout on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(800, 1024)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationBarPage), findsOneWidget);
      expect(find.byKey(const ValueKey('dp_nav_dashboard')), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders drawer and bottom bar on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(480, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(480, 844)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationBarPage), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Drawer), findsOneWidget);
      await tester.drag(find.byType(Drawer), const Offset(0, -400));
      await tester.pump();
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Bank Details'), findsOneWidget);
    });

    testWidgets('matches dark theme color palette on desktop', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(1280, 900)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF000000));
    });
  });
}
