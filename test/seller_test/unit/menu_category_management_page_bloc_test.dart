import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_repository.dart';

class MockMenuCategoryManagementRepository extends Mock implements MenuCategoryManagementRepository {}

void main() {
  group('MenuCategoryManagementBloc', () {
    late MenuCategoryManagementBloc bloc;
    late MockMenuCategoryManagementRepository mockRepository;

    setUp(() {
      mockRepository = MockMenuCategoryManagementRepository();
      bloc = MenuCategoryManagementBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is MenuCategoryManagementInitial', () {
      expect(bloc.state, isA<MenuCategoryManagementInitial>());
    });

    blocTest<MenuCategoryManagementBloc, MenuCategoryManagementState>(
      'emits [Loading, Loaded] when LoadMenuCategoriesEvent is added',
      build: () {
        when(() => mockRepository.getMenuCategories(any())).thenAnswer((_) async => []);
        when(() => mockRepository.streamMenuCategories(any())).thenAnswer((_) => const Stream.empty());
        return bloc;
      },
      act: (bloc) => bloc.add(LoadMenuCategoriesEvent('seller1')),
      expect: () => [
        isA<MenuCategoryManagementLoading>(),
        isA<MenuCategoryManagementLoaded>(),
      ],
    );
  });
}
