import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__state.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__ui.dart';

class MockAddProductPageBloc extends Mock implements AddProductPageBloc {}
class FakeAddProductPageEvent extends Fake implements AddProductPageEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAddProductPageEvent());
  });

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

    testWidgets('renders unified inventory engine with single item price and stock inputs', (tester) async {
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

      // Verify segmented mode buttons
      expect(find.text('Single Item (Standard)'), findsOneWidget);
      expect(find.text('Multiple Sizes / Variants'), findsOneWidget);

      // Verify Single Item inputs
      expect(find.text('Base Price (₹)'), findsWidgets);
      expect(find.text('Discount (%)'), findsWidgets);
      expect(find.text('Available Stock'), findsWidgets);
    });

    testWidgets('Add Customization Group dialog dynamically adds another option row below', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AddProductPageBloc>.value(
            value: mockBloc,
            child: const AddProductView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap "Add Group" button
      final addGroupBtn = find.widgetWithText(OutlinedButton, 'Add Group');
      expect(addGroupBtn, findsOneWidget);
      await tester.ensureVisible(addGroupBtn);
      await tester.pumpAndSettle();
      await tester.tap(addGroupBtn);
      await tester.pumpAndSettle();

      // Verify dialog is opened
      expect(find.text('Add Customization Group'), findsOneWidget);
      expect(find.text('Group Name'), findsOneWidget);
      expect(find.text('Option 1 Name'), findsOneWidget);
      expect(find.text('Base (₹)'), findsOneWidget);
      expect(find.text('Disc %'), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('GST Slab')), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('HSN Code')), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('Tax Type')), findsOneWidget);

      // Verify row add icon exists
      final addRowIconBtn = find.byTooltip('Add option below');
      expect(addRowIconBtn, findsOneWidget);

      // Tap row add icon to add another option row below
      await tester.tap(addRowIconBtn);
      await tester.pumpAndSettle();

      // Verify Option 2 Name now appears below!
      expect(find.text('Option 2 Name'), findsOneWidget);
    });

    testWidgets('renders Edit icon for variants and opens Edit Variant dialog', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const AddProductPageState(
          hasVariants: true,
          variants: [
            ProductVariant(id: 'var_1', name: 'Large', basePrice: 1500, stock: 80, gstPercentage: 5),
          ],
        ),
      );

      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AddProductPageBloc>.value(
            value: mockBloc,
            child: const AddProductView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify variant card is displayed
      expect(find.text('Large'), findsOneWidget);
      expect(find.textContaining('MRP: ₹1575'), findsOneWidget);

      // Verify Edit Variant button is present
      final editVariantBtn = find.byTooltip('Edit Variant');
      expect(editVariantBtn, findsOneWidget);

      // Tap Edit Variant button
      await tester.ensureVisible(editVariantBtn);
      await tester.pumpAndSettle();
      await tester.tap(editVariantBtn);
      await tester.pumpAndSettle();

      // Verify Edit Variant dialog opens with pre-filled title and values
      expect(find.text('Edit Product Variant'), findsOneWidget);
      expect(find.text('Update Variant'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Large'), findsOneWidget);

      // Verify HSN Code field exists in Variant dialog
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('HSN Code')), findsOneWidget);

      // Verify Live Price & Statutory Tax Card and its metrics are displayed
      expect(find.textContaining('Live Price & Statutory Tax'), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('Base Price')), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('Taxable Price')), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('Round Off')), findsOneWidget);
      expect(find.descendant(of: find.byType(Dialog), matching: find.text('Final MRP')), findsOneWidget);

      // Verify Auto Generate Variant SKU button exists
      final autoGenSkuBtn = find.byTooltip('Auto Generate Variant SKU');
      expect(autoGenSkuBtn, findsOneWidget);

      // Tap Auto Generate Variant SKU button
      await tester.tap(autoGenSkuBtn);
      await tester.pumpAndSettle();

      // Verify Variant SKU field is populated
      expect(find.textContaining('LARGE'), findsOneWidget);
    });

    testWidgets('auto-generating parent SKU dispatches SkuChangedEvent and cascades to variants', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const AddProductPageState(
          hasVariants: true,
          sku: 'SKU-FRI-29',
          variants: [
            ProductVariant(id: 'var_1', name: 'Regular', sku: 'SKU-FRI-29-REG', basePrice: 1000, stock: 50),
            ProductVariant(id: 'var_2', name: 'Large', sku: 'SKU-FRI-29-LRG', basePrice: 1500, stock: 50),
          ],
        ),
      );

      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AddProductPageBloc>.value(
            value: mockBloc,
            child: const AddProductView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final autoGenParentSkuBtn = find.byTooltip('Auto Generate SKU');
      expect(autoGenParentSkuBtn, findsOneWidget);

      await tester.tap(autoGenParentSkuBtn);
      await tester.pumpAndSettle();

      // Verify SkuChangedEvent was added
      verify(() => mockBloc.add(any(that: isA<SkuChangedEvent>()))).called(1);
      // Verify VariantsUpdatedEvent was added with cascaded new prefix
      verify(() => mockBloc.add(any(that: isA<VariantsUpdatedEvent>()))).called(1);
    });
  });
}

