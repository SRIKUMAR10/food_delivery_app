import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

void main() {
  group('Restaurant Profile Integration Flow Test', () {
    late MockSellerProfilePageBloc mockBloc;
    late StreamController<SellerProfilePageState> stateController;

    final initialLoadedState = ProfileLoaded(
      storeName: 'Integration Cafe',
      ownerName: 'Cafe Owner',
      email: 'cafe@integration.com',
      phone: '+91 9876543210',
      profileImageUrl: '',
      coverImageUrl: '',
      notificationsEnabled: true,
      role: 'seller',
      createdAt: DateTime(2025, 1, 1),
      isVerified: true,
      isOpen: true,
      isAcceptingOrders: true,
      deliveryRadius: 8.0,
      cuisines: const ['Fast Food'],
      deliveryFeeSettings: const DeliveryFeeSettings(),
    );

    final updatedLoadedState = ProfileLoaded(
      storeName: 'Updated Live Kitchen',
      ownerName: 'Chef Ramesh',
      email: 'cafe@integration.com',
      phone: '+91 9876543210',
      profileImageUrl: '',
      coverImageUrl: '',
      notificationsEnabled: true,
      role: 'seller',
      createdAt: DateTime(2025, 1, 1),
      isVerified: true,
      isOpen: false,
      isAcceptingOrders: false,
      deliveryRadius: 12.0,
      cuisines: const ['Fast Food', 'Desserts'],
      deliveryFeeSettings: const DeliveryFeeSettings(),
    );

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      stateController = StreamController<SellerProfilePageState>.broadcast();
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      stateController.close();
    });

    testWidgets('Full Real-Time Integration Flow: Load profile -> Stream update -> Toggle Switch', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      when(() => mockBloc.stream).thenAnswer((_) => stateController.stream);
      when(() => mockBloc.state).thenReturn(initialLoadedState);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const Scaffold(body: ProfileContent()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify real-time initial data was rendered
      expect(find.text('Integration Cafe'), findsWidgets);
      expect(find.text('Open for Customers'), findsOneWidget);
      expect(find.text('Fast Food'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));

      // 2. Stream real-time database update from Cloud Firestore
      when(() => mockBloc.state).thenReturn(updatedLoadedState);
      stateController.add(updatedLoadedState);

      await tester.pumpAndSettle();

      // 3. Verify reactive UI rebuild with new Firestore values
      expect(find.text('Updated Live Kitchen'), findsWidgets);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Desserts'), findsOneWidget);
    });
  });
}
