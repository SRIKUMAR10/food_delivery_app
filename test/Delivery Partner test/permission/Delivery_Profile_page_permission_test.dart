import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryProfileBloc
    extends MockBloc<DeliveryProfileEvent, DeliveryProfileState>
    implements DeliveryProfileBloc {}

void main() {
  late MockDeliveryProfileBloc mockBloc;

  const DeliveryProfileState loadedState = DeliveryProfileState(
    status: DeliveryProfileStatus.loaded,
    completionPercentage: 75,
    verificationStatuses: DeliveryProfileRepository.defaultVerificationStatuses,
    documents: DeliveryProfileRepository.defaultDocuments,
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
    mockBloc = MockDeliveryProfileBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryProfilePage Permission Tests', () {
    test('media permission service returns granted', () async {
      final service = DeliveryProfileService();
      expect(await service.requestMediaPermission(), isTrue);
    });

    test(
      'media permission service does not require raw environment secrets',
      () {
        final service = DeliveryProfileService();
        final env = service.getEnvironmentVariables();
        for (final value in env.values) {
          expect(
            value.contains(
              RegExp(r'(token|password|passwd)', caseSensitive: false),
            ),
            isFalse,
          );
        }
      },
    );

    testWidgets('renders avatar placeholder when no photo permission granted', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_avatar')), findsOneWidget);
      expect(find.text('RK'), findsOneWidget);
    });

    testWidgets('upload photo action is reachable and tappable', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      final uploadButton = find.byKey(const Key('dp_profile_upload_photo'));
      expect(uploadButton, findsOneWidget);
      await tester.tap(uploadButton);
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryProfilePickImageEvent()),
      ).called(1);
    });
  });
}
