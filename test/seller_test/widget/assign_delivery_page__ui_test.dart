import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__event.dart';

List<RiderModel> _testRiders() => [
      const RiderModel(
        id: '1',
        name: 'John Rider',
        rating: 4.8,
        distance: '2.3 km away',
        imageUrl: '',
      ),
      const RiderModel(
        id: '2',
        name: 'Jane Courier',
        rating: 4.5,
        distance: '1.0 km away',
        imageUrl: '',
      ),
    ];

class FakeAssignDeliveryRepository extends AssignDeliveryRepository {
  final StreamController<List<RiderModel>> _controller =
      StreamController<List<RiderModel>>();

  FakeAssignDeliveryRepository()
      : super(
          service: AssignDeliveryService(firestore: FakeFirebaseFirestore()),
        );

  @override
  Stream<List<RiderModel>> watchAvailableRiders(String orderId) {
    return _controller.stream;
  }

  void addRiders(List<RiderModel> riders) {
    _controller.add(riders);
  }

  void closeController() {
    _controller.close();
  }
}

Widget buildTestApp(AssignDeliveryBloc bloc) {
  return MaterialApp(
    home: BlocProvider.value(
      value: bloc,
      child: const AssignDeliveryPage(orderId: '1025'),
    ),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('AssignDeliveryPage widget tests', () {
    testWidgets('shows loading indicator in initial state', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator while waiting for stream data', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(const LoadRidersEvent(orderId: '1025'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays header with Order ID and Ready badge', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));

      expect(find.text('Order #1025'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('shows rider cards when loaded', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      await tester.pump();

      repo.addRiders(_testRiders());
      await tester.pump();

      expect(find.text('John Rider'), findsOneWidget);
      expect(find.text('Jane Courier'), findsOneWidget);
      expect(find.text('2.3 km away'), findsOneWidget);
      expect(find.text('1.0 km away'), findsOneWidget);
    });

    testWidgets('shows empty state when no riders available', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      await tester.pump();

      repo.addRiders([]);
      await tester.pump();

      expect(find.text('No delivery partners available'), findsOneWidget);
    });

    testWidgets('selects a rider on tap', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      await tester.tap(find.text('John Rider'));
      await tester.pump();

      final loadedState = bloc.state as AssignDeliveryLoaded;
      expect(loadedState.selectedRiderId, '1');
    });

    testWidgets('displays instructions text field', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      expect(find.text('Delivery Instructions'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('types into instructions text field', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Call before arriving');
      await tester.pump();

      final loadedState = bloc.state as AssignDeliveryLoaded;
      expect(loadedState.deliveryInstructions, 'Call before arriving');
    });

    testWidgets('shows Assign Rider button', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      expect(find.text('Assign Rider'), findsOneWidget);
    });

    testWidgets('shows avatar fallback icon when imageUrl is empty', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('displays star rating for each rider', (
      WidgetTester tester,
    ) async {
      final repo = FakeAssignDeliveryRepository();
      final bloc = AssignDeliveryBloc(repository: repo, orderId: '1025');

      await tester.pumpWidget(buildTestApp(bloc));
      bloc.add(LoadRidersEvent(orderId: '1025'));
      repo.addRiders(_testRiders());
      await tester.pump();

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });
}
