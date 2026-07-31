import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
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

const enState = DeliveryCompletedPageState(
  status: DeliveryCompletedStatus.success,
  model: mockModel,
);

const taState = DeliveryCompletedPageState(
  status: DeliveryCompletedStatus.success,
  model: mockModel,
  localeCode: 'ta',
);

void main() {
  late MockDeliveryCompletedBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliveryCompletedBloc();
    when(() => mockBloc.state).thenReturn(enState);
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

  group('DeliveryCompletedPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      await pumpPage(tester);

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('Order Completed'), findsWidgets);
      expect(find.text('Delivery Summary'), findsOneWidget);
      expect(find.text('Customer Rating'), findsOneWidget);
      expect(find.text('Excellent (5.0/5)'), findsOneWidget);
      expect(find.text('Complete Order'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      when(() => mockBloc.state).thenReturn(taState);
      await pumpPage(tester);

      expect(find.text('டெலிவரி பார்ட்னர்'), findsOneWidget);
      expect(find.text('வெற்றிகரமாக டெலிவரி! 🎉'), findsOneWidget);
      expect(find.text('ஆர்டர் முடிந்தது'), findsWidgets);
      expect(find.text('டெலிவரி சுருக்கம்'), findsOneWidget);
      expect(find.text('வாடிக்கையாளர் மதிப்பீடு'), findsOneWidget);
      expect(find.text('சிறப்பு (5.0/5)'), findsOneWidget);
      expect(find.text('ஆர்டரை முடிக்கவும்'), findsOneWidget);
    });

    testWidgets('keeps data values from the model regardless of locale', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(taState);
      await pumpPage(tester);

      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('#ORD12345'), findsWidgets);
      expect(find.text('UPI • Google Pay'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(
        DeliveryCompletedStrings.of('deliveredSuccessfully', 'fr'),
        'Delivered Successfully! 🎉',
      );
      expect(
        DeliveryCompletedStrings.of('completeOrder', 'hi'),
        'Complete Order',
      );
    });
  });
}
