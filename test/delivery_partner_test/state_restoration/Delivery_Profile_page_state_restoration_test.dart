import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';
import '../helpers/delivery_test_utils.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  const int profileIndex = 11;

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();
  });

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();

    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getNavItems()).thenAnswer((_) async => navItems);
    when(
      () => mockRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => profileIndex);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(
      () => mockRepository.saveSelectedIndex(any()),
    ).thenAnswer((_) async {});
    when(() => mockService.checkPermission()).thenAnswer((_) async => true);

    SharedPreferences.setMockInitialValues({
      'delivery_profile_name': 'Ravi Kumar',
      'delivery_profile_phone': '+91 98765 43210',
      'delivery_profile_email': 'ravi.kumar@speedyfood.com',
      'delivery_profile_dob': '01/01/1995',
      'delivery_profile_address': '123 Cross Road, Chennai',
      'delivery_profile_vehicle_type': 'Bike',
      'delivery_profile_vehicle_number': 'TN 01 AB 1234',
      'delivery_profile_license': 'DL-0123456789',
      'delivery_profile_license_valid': '31/12/2030',
    });
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpNavBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryNavigationBarPage(
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> switchToDashboard(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('dp_nav_dashboard')),
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey('dp_nav_dashboard')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DeliveryDashboardPage), findsOneWidget);
  }

  Future<void> switchToProfile(WidgetTester tester) async {
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'View Profile',
      ),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  String fieldText(WidgetTester tester, String key) {
    final editable = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      ),
    );
    return editable.controller.text;
  }

  group('DeliveryProfilePage State Restoration Tests', () {
    testWidgets('preserves edited field values across widget rebuilds', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('dp_profile_vehicle_number')),
        50,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(
        find.byKey(const Key('dp_profile_vehicle_number')),
        'TN 01 AB 1234',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('69%'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(
            repository: mockRepository,
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.byKey(const Key('dp_profile_vehicle_number')),
        50,
        scrollable: find.byType(Scrollable).last,
      );
      expect(fieldText(tester, 'dp_profile_vehicle_number'), 'TN 01 AB 1234');
      expect(find.text('69%'), findsOneWidget);
    });

    testWidgets('preserves profile state when switching tabs away and back', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('dp_profile_vehicle_number')),
        50,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(
        find.byKey(const Key('dp_profile_vehicle_number')),
        'TN 09 CD 4321',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('69%'), findsOneWidget);

      await switchToDashboard(tester);

      await switchToProfile(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('dp_profile_vehicle_number')),
        50,
        scrollable: find.byType(Scrollable).last,
      );
      expect(fieldText(tester, 'dp_profile_vehicle_number'), 'TN 09 CD 4321');
      expect(find.text('69%'), findsOneWidget);
    });

    testWidgets('completion ring reflects saved state after switching back', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      expect(find.text('69%'), findsOneWidget);

      await switchToDashboard(tester);

      await switchToProfile(tester);

      expect(find.text('69%'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
    });
  });
}