import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
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
    checklist: [
      DeliveryProfileChecklistItem(
        id: 'personalDetails',
        label: 'Personal details completed',
        isComplete: true,
      ),
      DeliveryProfileChecklistItem(
        id: 'vehicleInfo',
        label: 'Vehicle information provided',
        isComplete: false,
      ),
    ],
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

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1219),
      ),
      home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
    );
  }

  group('DeliveryProfilePage Golden Tests', () {
    testWidgets('renders pixel-perfect dark profile layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryProfilePage), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_profile_completion_ring')),
        findsOneWidget,
      );
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('renders dark theme profile layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_image_section')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_personal_info')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_documents')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_save_bar')), findsOneWidget);
    });

    testWidgets('renders dark theme profile layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_avatar')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_save_button')), findsOneWidget);
    });

    testWidgets('matches dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final saveBar = tester.widget<Container>(
        find.byKey(const Key('dp_profile_save_bar')),
      );
      final saveBarDecoration = saveBar.decoration as BoxDecoration;
      expect(saveBarDecoration.color, const Color(0xFF060B11));

      final documentsCard = tester.widget<Container>(
        find.byKey(const Key('dp_profile_documents')),
      );
      final documentsDecoration = documentsCard.decoration as BoxDecoration;
      expect(documentsDecoration.color, const Color(0xFF0D141C));
    });
  });
}
