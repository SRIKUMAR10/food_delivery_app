import 'package:equatable/equatable.dart';

abstract class MenuCategoryManagementEvent extends Equatable {
  const MenuCategoryManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuCategoriesEvent extends MenuCategoryManagementEvent {
  final String sellerId;
  const LoadMenuCategoriesEvent(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class ToggleCategorySelectionEvent extends MenuCategoryManagementEvent {
  final String categoryId;
  final bool isSelected;
  const ToggleCategorySelectionEvent(this.categoryId, this.isSelected);

  @override
  List<Object?> get props => [categoryId, isSelected];
}

class ReorderCategoriesEvent extends MenuCategoryManagementEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderCategoriesEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SaveCategoryPreferencesEvent extends MenuCategoryManagementEvent {
  final String sellerId;
  const SaveCategoryPreferencesEvent(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}
