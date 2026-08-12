// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_category_management_page_event.dart';
import 'menu_category_management_page_state.dart';
import 'menu_category_management_page_model.dart';
import 'menu_category_management_page_repository.dart';

class _CategoriesUpdatedEvent extends MenuCategoryManagementEvent {
  final List<MenuCategoryModel> categories;
  const _CategoriesUpdatedEvent(this.categories);

  @override
  List<Object?> get props => [categories];
}

class MenuCategoryManagementBloc extends Bloc<MenuCategoryManagementEvent, MenuCategoryManagementState> {
  final MenuCategoryManagementRepository repository;
  StreamSubscription? _categoriesSub;

  MenuCategoryManagementBloc({required this.repository}) : super(const MenuCategoryManagementInitial()) {
    on<LoadMenuCategoriesEvent>(_onLoadMenuCategories);
    on<_CategoriesUpdatedEvent>(_onCategoriesUpdated);
    on<ToggleCategorySelectionEvent>(_onToggleCategorySelection);
    on<ReorderCategoriesEvent>(_onReorderCategories);
    on<SaveCategoryPreferencesEvent>(_onSaveCategoryPreferences);
  }

  @override
  Future<void> close() {
    _categoriesSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadMenuCategories(LoadMenuCategoriesEvent event, Emitter<MenuCategoryManagementState> emit) async {
    emit(const MenuCategoryManagementLoading());
    try {
      await _categoriesSub?.cancel();
      final categories = await repository.getMenuCategories(event.sellerId);
      emit(MenuCategoryManagementLoaded(categories: categories));

      _categoriesSub = repository.streamMenuCategories(event.sellerId).listen((liveCategories) {
        final currentState = state;
        if (currentState is MenuCategoryManagementLoaded && !currentState.hasUnsavedChanges) {
          add(_CategoriesUpdatedEvent(liveCategories));
        }
      });
    } catch (e) {
      emit(MenuCategoryManagementError('Failed to load categories: $e'));
    }
  }

  void _onCategoriesUpdated(_CategoriesUpdatedEvent event, Emitter<MenuCategoryManagementState> emit) {
    final currentState = state;
    if (currentState is MenuCategoryManagementLoaded) {
      if (!currentState.hasUnsavedChanges) {
        emit(currentState.copyWith(categories: event.categories));
      }
    } else {
      emit(MenuCategoryManagementLoaded(categories: event.categories));
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
    
    final mutable = List<MenuCategoryModel>.from(currentState.categories);
    final item = mutable.removeAt(event.oldIndex);
    mutable.insert(newIndex, item);

    final updated = mutable.map((cat) {
      return cat.copyWith(sortOrder: mutable.indexOf(cat));
    }).toList();

    emit(currentState.copyWith(
      categories: updated,
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
