import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryCompletedBloc
    extends MockBloc<DeliveryCompletedEvent, DeliveryCompletedPageState>
    implements DeliveryCompletedBloc {}

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

class MockDeliveryCompletedService extends Mock
    implements DeliveryCompletedServiceBase {}

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
  late MockDeliveryCompletedRepository mockRepository;
  late MockDeliveryCompletedService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliveryCompletedBloc();
    mockRepository = MockDeliveryCompletedRepository();
    mockService = MockDeliveryCompletedService();
    registerFallbackValue('#ORD12345');

    when(() => mockBloc.state).thenReturn(loadedState);
    when(
      () => mockRepository.fetchCompletedOrderDetails(any()),
    ).thenAnswer((_) async => mockModel);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryCompletedPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryCompletedRepository();
      final service = DeliveryCompletedService();

      expect(repository, isA<DeliveryCompletedRepositoryBase>());
      expect(service, isA<DeliveryCompletedServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryCompletedBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.repository, same(mockRepository));
      expect(bloc.service, same(mockService));
      bloc.close();
    });

    test('bloc falls back to concrete defaults when none are injected', () {
      final bloc = DeliveryCompletedBloc();

      expect(bloc.repository, isA<DeliveryCompletedRepository>());
      expect(bloc.service, isA<DeliveryCompletedService>());
      bloc.close();
    });

    testWidgets('page renders with an injected bloc instance', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCompletedPage(orderId: '#ORD12345', bloc: mockBloc),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCompletedPage(
              orderId: '#ORD12345',
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
    });
  });
}
