import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryCompletedBloc
    extends MockBloc<DeliveryCompletedEvent, DeliveryCompletedPageState>
    implements DeliveryCompletedBloc {}

const mockModel = DeliveryCompletedModel(
  orderId: '#ORD12345',
  walletBalance: 2450.00,
  partnerName: 'Ravi Kumar',
  partnerVehicleNo: 'TN 01 AB 1234',
  customerName: 'Arun Kumar',
  deliveryAddress: '12, Beach Road, Chennai - 600001',
  timeTaken: '32 min',
  distanceCovered: 5.6,
  paymentStatus: 'Paid Successfully',
  paymentMethod: 'UPI • Google Pay',
  customerRating: 5.0,
  deliveryEarnings: 120.00,
  completedAt: 'Today, 4:15 PM',
);

const loadedState = DeliveryCompletedPageState(
  status: DeliveryCompletedStatus.success,
  model: mockModel,
);

void main() {
  late MockDeliveryCompletedBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliveryCompletedBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpPage(WidgetTester tester) async {
    setDesktopSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryCompletedPage(orderId: '#ORD12345', bloc: mockBloc),
        ),
      ),
    );
    await tester.pump();
  }

  group('DeliveryCompletedPage Permission Tests', () {
    test('service requests media and location permissions safely', () async {
      final service = DeliveryCompletedService();

      expect(await service.requestMediaPermission(), isTrue);
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('service validates media before upload', () {
      final service = DeliveryCompletedService();

      expect(service.validateMedia('proof.jpg'), isNull);
      expect(service.validateMedia('proof.gif'), isNotNull);
      expect(service.validateMedia(null), isNotNull);
    });

    testWidgets('renders proof upload control when running', (tester) async {
      await pumpPage(tester);

      await tester.ensureVisible(
        find.byKey(const Key('dp_completed_upload_proof')),
      );
      expect(
        find.byKey(const Key('dp_completed_upload_proof')),
        findsOneWidget,
      );
      expect(find.text('Upload Proof'), findsOneWidget);
    });

    testWidgets('upload proof button dispatches UploadProofMediaEvent', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.ensureVisible(
        find.byKey(const Key('dp_completed_upload_proof')),
      );
      await tester.tap(find.byKey(const Key('dp_completed_upload_proof')));
      await tester.pump();

      verify(
        () => mockBloc.add(const UploadProofMediaEvent('proof_delivery.jpg')),
      ).called(1);
    });

    testWidgets('back button dispatches ReturnHomeRequestedEvent', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('dp_completed_back')));
      await tester.pump();

      verify(() => mockBloc.add(const ReturnHomeRequestedEvent())).called(1);
    });

    testWidgets('rating star dispatches RateCustomerEvent', (tester) async {
      await pumpPage(tester);

      await tester.ensureVisible(find.byKey(const Key('dp_completed_star_3')));
      await tester.tap(find.byKey(const Key('dp_completed_star_3')));
      await tester.pump();

      verify(() => mockBloc.add(const RateCustomerEvent(3))).called(1);
    });
  });
}
