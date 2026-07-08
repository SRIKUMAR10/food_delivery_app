import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';

class MockProductListBloc extends Mock implements ProductListBloc {}

void main() {
  late MockProductListBloc mockBloc;

  setUp(() {
    mockBloc = MockProductListBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('displays error message when ProductListError is emitted', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Network Connection Failed';
    when(() => mockBloc.state).thenReturn(const ProductListError(errorMessage));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductListBloc>.value(
          value: mockBloc,
          child: const ProductListView(),
        ),
      ),
    );

    // Verify error text is rendered
    expect(find.text('Error: $errorMessage'), findsOneWidget);
  });
}
