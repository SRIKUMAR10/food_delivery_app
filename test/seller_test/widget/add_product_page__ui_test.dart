import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__ui.dart';

class MockAddProductPageBloc extends Mock implements AddProductPageBloc {}

void main() {
  group('AddProductPage UI', () {
    late MockAddProductPageBloc mockBloc;

    setUp(() {
      mockBloc = MockAddProductPageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.state).thenReturn(const AddProductPageState());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('renders all form fields and categories correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AddProductPageBloc>.value(
            value: mockBloc,
            child: const AddProductView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the title
      expect(find.text('Add Product'), findsOneWidget);

      // Verify the presence of form fields
      expect(find.byType(TextFormField), findsWidgets);

      // Verify Fast Food / QSR categories are present
      expect(find.text('Fried Chicken'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Desserts'), findsOneWidget);
      expect(find.text('Beverages'), findsOneWidget);
    });
  });
}
