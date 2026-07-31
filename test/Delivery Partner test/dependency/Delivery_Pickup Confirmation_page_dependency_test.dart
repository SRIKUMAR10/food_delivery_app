import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

import '../../font_loader_helper.dart';

class MockPickupConfirmationBloc
    extends
        MockBloc<
          DeliveryPickupConfirmationPageEvent,
          DeliveryPickupConfirmationPageState
        >
    implements DeliveryPickupConfirmationPageBloc {}

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

const mockModel = PickupConfirmationModel(
  orderId: '#ORD12345',
  pickupLocationName: 'Green Mart',
  pickupAddress: '24, Anna Salai, Chennai - 600002',
  pickupContactName: 'Priya Sharma',
  pickupContactPhone: '+919876543210',
  pickupInstructions: 'Show the order code at the counter.',
  customerName: 'Mike Johnson',
  customerAddress: '12, Beach Road, Chennai - 600001',
  customerPhone: '+919876543211',
  pickupTime: '12:05 PM',
  paymentType: 'Cash on Delivery',
  orderAmount: 486.50,
  walletBalance: 2450.00,
);

const loadedState = DeliveryPickupConfirmationPageState(
  status: PickupConfirmationStatus.success,
  model: mockModel,
);

void main() {
  late MockPickupConfirmationBloc mockBloc;
  late MockPickupConfirmationRepository mockRepository;
  late MockPickupConfirmationService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockPickupConfirmationBloc();
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');

    when(() => mockBloc.state).thenReturn(loadedState);
    when(
      () => mockRepository.fetchPickupConfirmationDetails(any()),
    ).thenAnswer((_) async => mockModel);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryPickupConfirmationPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryPickupConfirmationRepository();
      final service = DeliveryPickupConfirmationService();

      expect(repository, isA<DeliveryPickupConfirmationRepositoryBase>());
      expect(service, isA<DeliveryPickupConfirmationServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryPickupConfirmationPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.repository, same(mockRepository));
      expect(bloc.service, same(mockService));
      bloc.close();
    });

    testWidgets('page renders with an injected bloc instance', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryPickupConfirmationPage(
              orderId: '#ORD12345',
              bloc: mockBloc,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryPickupConfirmationPage(
              orderId: '#ORD12345',
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byKey(const Key('dp_pickup_page')), findsOneWidget);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
    });
  });
}
