import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_ui.dart';

class MockMenuCategoryManagementBloc extends Mock implements MenuCategoryManagementBloc {}

void main() {
  group('MenuCategoryManagementPage UI Tests', () {
    late MockMenuCategoryManagementBloc mockBloc;

    setUp(() {
      mockBloc = MockMenuCategoryManagementBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(MenuCategoryManagementLoading());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MenuCategoryManagementBloc>.value(
            value: mockBloc,
            child: const MenuCategoryManagementView(sellerId: 'test'), 
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
