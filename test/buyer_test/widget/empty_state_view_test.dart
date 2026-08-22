import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/widgets/empty_state_view.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_UI.dart';

class MockCartBloc extends Mock implements CartBloc {}

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

void main() {
  group('EmptyStateView Shared Widget', () {
    testWidgets('renders icon, title, subtitle and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.inbox_outlined,
              title: 'Nothing here',
              subtitle: 'Check back later',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Check back later'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders icon inside a circular container when provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders',
              iconContainerColor: Colors.red.withValues(alpha: 0.08),
              iconContainerSize: 110,
              iconColor: Colors.red,
              iconSize: 52,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.receipt_long_outlined),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.shape, BoxShape.circle);
      expect(container.constraints?.maxWidth, 110);
    });
  });

  group('Empty State Consolidation', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('cart empty state uses shared EmptyStateView', (tester) async {
      when(() => mockCartBloc.state)
          .thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>.value(
            value: mockCartBloc,
            child: const CartPageUI(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('Your cart is empty!'), findsOneWidget);
    });

    testWidgets('favorites empty state uses shared EmptyStateView',
        (tester) async {
      final mockBloc = MockFavoritesBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(
        () => mockBloc.state,
      ).thenReturn(const FavoritesLoaded(items: [], favoriteIds: {}));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>.value(
            value: mockBloc,
            child: const FavoritesPageUI(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('No favorites yet!'), findsOneWidget);
    });
  });
}