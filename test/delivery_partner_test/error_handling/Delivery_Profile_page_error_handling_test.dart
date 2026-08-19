import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryProfileRepository extends Mock
    implements DeliveryProfileRepositoryBase {}

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

void main() {
  late MockDeliveryProfileRepository mockRepository;
  late MockDeliveryProfileService mockService;

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

    mockRepository = MockDeliveryProfileRepository();
    mockService = MockDeliveryProfileService();

    when(() => mockRepository.fetchProfile()).thenAnswer(
      (_) async =>
          DeliveryProfileRepository(prefs: prefs).buildDefaultProfile(),
    );
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryProfilePage(
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliveryProfilePage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchProfile(),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_profile_error')), findsOneWidget);
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the profile', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.fetchProfile()).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return DeliveryProfileRepository().buildDefaultProfile();
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_profile_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_profile_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_profile_error')), findsNothing);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('shows empty state and refresh recovers profile', (
      tester,
    ) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.fetchProfile()).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          return const DeliveryProfileState(
            status: DeliveryProfileStatus.loaded,
            fullName: '',
            phone: '',
            email: '',
          );
        }
        return DeliveryProfileRepository().buildDefaultProfile();
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_profile_empty')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_profile_refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_profile_empty')), findsNothing);
      expect(find.text('My Profile'), findsOneWidget);
    });
  });
}
