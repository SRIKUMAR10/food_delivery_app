import 'menu_category_management_page_model.dart';

abstract class MenuCategoryManagementState {}

class MenuCategoryManagementInitial extends MenuCategoryManagementState {}

class MenuCategoryManagementLoading extends MenuCategoryManagementState {}

class MenuCategoryManagementLoaded extends MenuCategoryManagementState {
  final List<MenuCategoryModel> categories;
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  MenuCategoryManagementLoaded({
    required this.categories,
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
    this.hasUnsavedChanges = false,
  });

  MenuCategoryManagementLoaded copyWith({
    List<MenuCategoryModel>? categories,
    bool? isSaving,
    String? successMessage,
    String? errorMessage,
    bool? hasUnsavedChanges,
    bool clearMessages = false,
  }) {
    return MenuCategoryManagementLoaded(
      categories: categories ?? this.categories,
      isSaving: isSaving ?? this.isSaving,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class MenuCategoryManagementError extends MenuCategoryManagementState {
  final String message;
  MenuCategoryManagementError(this.message);
}
