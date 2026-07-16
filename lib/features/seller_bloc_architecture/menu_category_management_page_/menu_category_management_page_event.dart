abstract class MenuCategoryManagementEvent {}

class LoadMenuCategoriesEvent extends MenuCategoryManagementEvent {
  final String sellerId;
  LoadMenuCategoriesEvent(this.sellerId);
}

class ToggleCategorySelectionEvent extends MenuCategoryManagementEvent {
  final String categoryId;
  final bool isSelected;
  ToggleCategorySelectionEvent(this.categoryId, this.isSelected);
}

class ReorderCategoriesEvent extends MenuCategoryManagementEvent {
  final int oldIndex;
  final int newIndex;
  ReorderCategoriesEvent(this.oldIndex, this.newIndex);
}

class SaveCategoryPreferencesEvent extends MenuCategoryManagementEvent {
  final String sellerId;
  SaveCategoryPreferencesEvent(this.sellerId);
}
