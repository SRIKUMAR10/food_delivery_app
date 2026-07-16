import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_repository.dart';

class MockMenuCategoryManagementRepository extends Mock implements MenuCategoryManagementRepository {}

void main() {
  group('MenuCategoryManagementPage Error Handling Test', () {
    late MenuCategoryManagementBloc bloc;
    late MockMenuCategoryManagementRepository mockRepository;

    setUp(() {
      mockRepository = MockMenuCategoryManagementRepository();
      bloc = MenuCategoryManagementBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<MenuCategoryManagementBloc, MenuCategoryManagementState>(
      'Handles preferences save failure gracefully',
      build: () {
        when(() => mockRepository.savePreferences(any(), any())).thenThrow(Exception('NetworkError'));
        return bloc;
      },
      seed: () => MenuCategoryManagementLoaded(categories: [], hasUnsavedChanges: true),
      act: (bloc) => bloc.add(SaveCategoryPreferencesEvent('seller1')),
      expect: () => [
        isA<MenuCategoryManagementLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<MenuCategoryManagementLoaded>()
          .having((s) => s.isSaving, 'isSaving', false)
          .having((s) => s.errorMessage, 'error', contains('Failed to save preferences')),
      ],
    );
  });
}
