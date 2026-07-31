import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

import '../../font_loader_helper.dart';

class MockDeliveryProfileRepository extends Mock
    implements DeliveryProfileRepositoryBase {}

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryProfileRepository mockProfileRepository;
  late MockDeliveryProfileService mockProfileService;
  late MockDeliveryNavigationBarRepository mockNavRepository;
  late MockDeliveryNavigationBarService mockNavService;

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mockProfileRepository = MockDeliveryProfileRepository();
    mockProfileService = MockDeliveryProfileService();
    mockNavRepository = MockDeliveryNavigationBarRepository();
    mockNavService = MockDeliveryNavigationBarService();
    registerFallbackValue(const DeliveryProfileState());

    when(() => mockProfileRepository.fetchProfile()).thenAnswer(
      (_) async =>
          DeliveryProfileRepository(prefs: prefs).buildDefaultProfile(),
    );
    when(
      () => mockProfileRepository.saveProfile(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockProfileService.chunkedUpload(any()),
    ).thenAnswer((_) => Stream.fromIterable([0.5, 1.0]));

    when(
      () => mockNavService.checkConnectivity(),
    ).thenAnswer((_) async => true);
    when(
      () => mockNavRepository.getNavItems(),
    ).thenAnswer((_) async => navItems);
    when(
      () => mockNavRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => -1);
    when(() => mockNavRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockNavRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(
      () => mockNavRepository.saveSelectedIndex(any()),
    ).thenAnswer((_) async {});
    when(() => mockNavService.checkPermission()).thenAnswer((_) async => true);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryProfilePage Integration Flow Tests', () {
    testWidgets(
      'loads profile, edits a field and sees live completion change',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DeliveryProfilePage(
                repository: mockProfileRepository,
                service: mockProfileService,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('My Profile'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('dp_profile_vehicle_number')),
          'TN 01 AB 1234',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('83%'), findsOneWidget);
      },
    );

    testWidgets('uploads a pending document and updates its status', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryProfilePage(
              repository: mockProfileRepository,
              service: mockProfileService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(
        find.byKey(const Key('dp_profile_upload_insurance')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dp_profile_upload_insurance')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Uploaded'), findsWidgets);
      expect(find.text('83%'), findsOneWidget);
    });

    testWidgets('saves the profile and confirms with a snackbar', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryProfilePage(
              repository: mockProfileRepository,
              service: mockProfileService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('dp_profile_save_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Profile saved successfully'), findsOneWidget);
    });

    testWidgets('renders the profile page when the Profile tab is selected', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(
            repository: mockNavRepository,
            service: mockNavService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_save_button')), findsOneWidget);

      await tester.tap(find.text('Dashboard'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
      expect(find.text('You are ONLINE'), findsOneWidget);

      await tester.tap(find.text('Profile'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('My Profile'), findsOneWidget);
    });
  });
}
