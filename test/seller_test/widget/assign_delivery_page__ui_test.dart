import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__repository.dart';

// Fake implementations for testing
class FakeAssignDeliveryRepository extends AssignDeliveryRepository {
  FakeAssignDeliveryRepository() : super(service: throw UnimplementedError());

  @override
  Future<List<RiderModel>> getAvailableRiders(String orderId) async {
    return [
      const RiderModel(
        id: '1',
        name: 'John Rider',
        rating: 4.8,
        distance: '2.3 km away',
        imageUrl: '',
      ),
    ];
  }
}

void main() {
  testWidgets('AssignDeliveryPage displays correctly in loading state', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeAssignDeliveryRepository();
    final bloc = AssignDeliveryBloc(repository: fakeRepo, orderId: '1025');

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const AssignDeliveryPage(orderId: '1025'),
        ),
      ),
    );

    // Initial state is usually mapped to loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AssignDeliveryPage displays header and loaded UI', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeAssignDeliveryRepository();
    final bloc = AssignDeliveryBloc(repository: fakeRepo, orderId: '1025');

    // Simulate loaded state
    // In a real widget test, we'd use mocktail to mock the bloc's state
    // Here we pump the widget and assume standard loading/loaded transitions

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const AssignDeliveryPage(orderId: '1025'),
        ),
      ),
    );

    expect(find.text('Order #1025'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
