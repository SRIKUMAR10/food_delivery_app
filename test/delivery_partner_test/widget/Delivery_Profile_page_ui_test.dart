import 'dart:async';
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
    fullName: 'Ravi Kumar',
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
      DeliveryProfileChecklistItem(
        id: 'drivingLicense',
        label: 'Driving license uploaded',
        isComplete: true,
      ),
      DeliveryProfileChecklistItem(
        id: 'vehicleRc',
        label: 'Vehicle RC uploaded',
        isComplete: true,
      ),
      DeliveryProfileChecklistItem(
        id: 'insurance',
        label: 'Insurance uploaded',
        isComplete: false,
      ),
      DeliveryProfileChecklistItem(
        id: 'panCard',
        label: 'PAN card uploaded',
        isComplete: true,
      ),
      DeliveryProfileChecklistItem(
        id: 'documentVerification',
        label: 'Document verification approved',
        isComplete: true,
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

    registerFallbackValue(const DeliveryProfileInitEvent());
    registerFallbackValue(
      const DeliveryProfileUpdateFieldEvent(field: '', value: ''),
    );
    registerFallbackValue(const DeliveryProfilePickImageEvent());
    registerFallbackValue(const DeliveryProfileUploadDocumentEvent(''));
    registerFallbackValue(const DeliveryProfileSaveEvent());
    registerFallbackValue(const DeliveryProfileRetryEvent());
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

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
    );
  }

  group('DeliveryProfilePage Widget Tests', () {
    testWidgets('renders profile sections, completion ring, and save button', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_page')), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_avatar')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_upload_photo')), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Upload Documents'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_profile_completion_card')),
        findsOneWidget,
      );
      expect(find.text('75%'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_profile_verification_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_profile_checklist_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_profile_save_button')), findsOneWidget);
      expect(find.text('Save & Continue'), findsOneWidget);
    });

    testWidgets('renders document cards with upload actions for pending docs', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_profile_doc_drivingLicense')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_profile_doc_vehicleRc')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_doc_insurance')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_doc_panCard')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_profile_upload_insurance')),
        findsOneWidget,
      );
    });

    testWidgets('dispatches UpdateFieldEvent when a form field is typed', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_profile_vehicle_number')),
        'TN 01 AB 1234',
      );
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryProfileUpdateFieldEvent(
            field: 'vehicleNumber',
            value: 'TN 01 AB 1234',
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches PickImageEvent when upload photo is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_profile_upload_photo')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryProfilePickImageEvent()),
      ).called(1);
    });

    testWidgets('dispatches UploadDocumentEvent when a document is uploaded', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('dp_profile_upload_insurance')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dp_profile_upload_insurance')));
      await tester.pump();

      verify(
        () =>
            mockBloc.add(const DeliveryProfileUploadDocumentEvent('insurance')),
      ).called(1);
    });

    testWidgets('dispatches SaveEvent when save button is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_profile_save_button')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryProfileSaveEvent())).called(1);
    });

    testWidgets('shows skeleton loader during loading state', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_skeleton')), findsOneWidget);
    });

    testWidgets('shows error state with retry action', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryProfileState(
          status: DeliveryProfileStatus.error,
          errorMessage: 'Network down',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_error')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dp_profile_retry')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryProfileRetryEvent())).called(1);
    });

    testWidgets('shows empty state with refresh action', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryProfileState(status: DeliveryProfileStatus.empty),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_empty')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dp_profile_refresh')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryProfileRetryEvent())).called(1);
    });

    testWidgets('lays out single column on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('My Profile'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_profile_completion_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_profile_save_button')), findsOneWidget);
    });

    testWidgets('address field shows GPS and map picker actions and dispatches events', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_profile_address')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_address_gps')), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_address_map')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('dp_profile_address')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('dp_profile_address')),
        '45 Anna Nagar, Chennai',
      );
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryProfileUpdateFieldEvent(
            field: 'address',
            value: '45 Anna Nagar, Chennai',
          ),
        ),
      ).called(1);
    });

    testWidgets('tapping map action opens the delivery address picker dialog', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('dp_profile_address')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dp_profile_address_map')));
      await tester.pumpAndSettle();

      expect(find.text('Set Home Address'), findsOneWidget);
      expect(find.text('Search Address'), findsOneWidget);
      expect(find.text('Pick on Map'), findsOneWidget);
      expect(find.byKey(const Key('dp_profile_address_map')), findsOneWidget);
    });

    testWidgets('renders licenseValidTill in vehicle info card with populated date', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(
          vehicleType: 'Scooter',
          vehicleNumber: 'TN-36-8888',
          licenseNumber: 'TN43Z20210000478',
          licenseValidTill: '31/12/2030',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('dp_profile_vehicle_info')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_profile_vehicle_info')), findsOneWidget);
      expect(find.text('31/12/2030'), findsOneWidget);
      expect(find.text('TN-36-8888'), findsOneWidget);
      expect(find.text('TN43Z20210000478'), findsOneWidget);
    });

    testWidgets('dynamically updates licenseValidTill text field when state changes from empty to populated', (
      tester,
    ) async {
      setDesktopSize(tester);
      final streamController = StreamController<DeliveryProfileState>.broadcast();
      addTearDown(streamController.close);

      whenListen(
        mockBloc,
        streamController.stream,
        initialState: loadedState.copyWith(licenseValidTill: ''),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      expect(find.text('31/12/2030'), findsNothing);

      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(licenseValidTill: '31/12/2030'),
      );
      streamController.add(loadedState.copyWith(licenseValidTill: '31/12/2030'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('31/12/2030'), findsOneWidget);
    });
  });
}
