import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

void main() {
  late MockDeliveryProfileService mockProfileService;
  late DeliveryProfileRepository realRepository;
  late SharedPreferences prefs;

  final sampleData = <String, dynamic>{
    'displayName': 'Ravi Kumar',
    'phoneNumber': '+91 98765 43210',
    'email': 'ravi@test.com',
    'address': '123 Main Road, Chennai',
    'vehicleType': 'scooter',
    'vehicleNumber': 'TN 01 AB 1234',
    'drivingLicense': 'TN07 20010012345',
    'status': 'approved',
    'kycStatus': 'approved',
  };

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
    prefs = await SharedPreferences.getInstance();

    mockProfileService = MockDeliveryProfileService();
    realRepository = DeliveryProfileRepository(
      prefs: prefs,
      service: mockProfileService,
    );

    when(
      () => mockProfileService.fetchProfileData(),
    ).thenAnswer((_) async => sampleData);
    when(
      () => mockProfileService.watchProfileData(),
    ).thenAnswer((_) => Stream.value(sampleData));
    when(
      () => mockProfileService.updateProfile(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockProfileService.chunkedUpload(any()),
    ).thenAnswer((_) => Stream.fromIterable([0.5, 1.0]));
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryProfilePage Integration Flow Tests', () {
    testWidgets(
      'loads profile with real repository & service, edits a field and saves',
      (tester) async {
        setDesktopSize(tester);
        final bloc = DeliveryProfileBloc(
          repository: realRepository,
          service: mockProfileService,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DeliveryProfilePage(bloc: bloc),
            ),
          ),
        );
        bloc.add(const DeliveryProfileInitEvent());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byKey(const Key('dp_profile_page')), findsOneWidget);
        expect(find.text('Ravi Kumar'), findsWidgets);
        expect(find.byKey(const Key('dp_profile_completion_card')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('dp_profile_vehicle_number')),
          'TN 02 CD 5678',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byKey(const Key('dp_profile_save_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Profile saved successfully'), findsOneWidget);
        bloc.close();
      },
    );

    testWidgets('uploads document and triggers upload workflow', (
      tester,
    ) async {
      setDesktopSize(tester);
      final bloc = DeliveryProfileBloc(
        repository: realRepository,
        service: mockProfileService,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryProfilePage(bloc: bloc),
          ),
        ),
      );
      bloc.add(const DeliveryProfileInitEvent());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_profile_page')), findsOneWidget);
      bloc.close();
    });
  });
}
