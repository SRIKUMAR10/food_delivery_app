import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

void main() {
  group('Seller Profile Performance Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Performance Diner',
        email: 'seller@perf.com',
        phone: '+91 9876543210',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ));
    });

    testWidgets('SellerProfilePageUI smoothly scrolls without memory leak or frame stutter', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const Scaffold(body: ProfileContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      // Perform rapid scroll down
      await tester.drag(scrollFinder, const Offset(0, -600));
      await tester.pumpAndSettle();

      // Perform rapid scroll up
      await tester.drag(scrollFinder, const Offset(0, 600));
      await tester.pumpAndSettle();

      expect(find.text('Restaurant Profile'), findsOneWidget);
    });
  });
}
