import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

void main() {
  group('Seller Profile State Restoration Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Royal Biryani',
        email: 'seller@royalbiryani.com',
        phone: '+91 9876543210',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ));
    });

    testWidgets('State restoration preserves profile widget rendering', (WidgetTester tester) async {
      await tester.pumpWidget(
        RootRestorationScope(
          restorationId: 'root',
          child: MaterialApp(
            home: BlocProvider<SellerProfilePageBloc>.value(
              value: mockBloc,
              child: const Scaffold(body: ProfileContent()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Restaurant Profile'), findsOneWidget);
      expect(find.text('Royal Biryani'), findsWidgets);

      // Simulate OS restoring application
      await tester.restartAndRestore();
      expect(find.text('Restaurant Profile'), findsOneWidget);
    });
  });
}
