import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_category_management_page_event.dart';
import 'menu_category_management_page_state.dart';
import 'menu_category_management_page_repository.dart';

class MenuCategoryManagementBloc extends Bloc<MenuCategoryManagementEvent, MenuCategoryManagementState> {
  final MenuCategoryManagementRepository repository;

  MenuCategoryManagementBloc({required this.repository}) : super(MenuCategoryManagementInitial()) {
    on<LoadMenuCategoriesEvent>(_onLoadMenuCategories);
    on<ToggleCategorySelectionEvent>(_onToggleCategorySelection);
    on<ReorderCategoriesEvent>(_onReorderCategories);
    on<SaveCategoryPreferencesEvent>(_onSaveCategoryPreferences);
  }

  Future<void> _onLoadMenuCategories(LoadMenuCategoriesEvent event, Emitter<MenuCategoryManagementState> emit) async {
    emit(MenuCategoryManagementLoading());
    try {
      final categories = await repository.getMenuCategories(event.sellerId);
      emit(MenuCategoryManagementLoaded(categories: categories));
    } catch (e) {
      emit(MenuCategoryManagementError('Failed to load categories: $e'));
    }
  }

  void _onToggleCategorySelection(ToggleCategorySelectionEvent event, Emitter<MenuCategoryManagementState> emit) {
    final currentState = state;
    if (currentState is! MenuCategoryManagementLoaded) return;

    final updatedCategories = currentState.categories.map((cat) {
      if (cat.id == event.categoryId) {
        return cat.copyWith(isSelected: event.isSelected);
      }
      return cat;
    }).toList();

    emit(currentState.copyWith(
      categories: updatedCategories,
      hasUnsavedChanges: true,
      clearMessages: true,
    ));
  }

  void _onReorderCategories(ReorderCategoriesEvent event, Emitter<MenuCategoryManagementState> emit) {
    final currentState = state;
    if (currentState is! MenuCategoryManagementLoaded) return;

    int newIndex = event.newIndex;
    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = currentState.categories.removeAt(event.oldIndex);
    currentState.categories.insert(newIndex, item);

    // Update sortOrder for all items
    for (int i = 0; i < currentState.categories.length; i++) {
      currentState.categories[i] = currentState.categories[i].copyWith(sortOrder: i);
    }

    emit(currentState.copyWith(
      categories: List.from(currentState.categories),
      hasUnsavedChanges: true,
      clearMessages: true,
    ));
  }

  Future<void> _onSaveCategoryPreferences(SaveCategoryPreferencesEvent event, Emitter<MenuCategoryManagementState> emit) async {
    final currentState = state;
    if (currentState is! MenuCategoryManagementLoaded) return;
    if (!currentState.hasUnsavedChanges) return;

    emit(currentState.copyWith(isSaving: true, clearMessages: true));

    try {
      await repository.savePreferences(event.sellerId, currentState.categories);
      emit(currentState.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        successMessage: 'Menu preferences saved successfully!',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save preferences. Try again.',
      ));
    }
  }
}
