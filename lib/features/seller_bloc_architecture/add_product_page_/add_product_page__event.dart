import 'package:equatable/equatable.dart';

abstract class AddProductPageEvent extends Equatable {
  const AddProductPageEvent();

  @override
  List<Object?> get props => [];
}

class AddImageEvent extends AddProductPageEvent {
  final String imagePath;
  const AddImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class RemoveImageEvent extends AddProductPageEvent {
  final int index;
  const RemoveImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CategoryChangedEvent extends AddProductPageEvent {
  final String category;
  const CategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class FoodTypeChangedEvent extends AddProductPageEvent {
  final String foodType;
  const FoodTypeChangedEvent(this.foodType);

  @override
  List<Object?> get props => [foodType];
}

class SpicyLevelChangedEvent extends AddProductPageEvent {
  final String spicyLevel;
  const SpicyLevelChangedEvent(this.spicyLevel);

  @override
  List<Object?> get props => [spicyLevel];
}

class StatusChangedEvent extends AddProductPageEvent {
  final bool isActive;
  const StatusChangedEvent(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class SubmitProductEvent extends AddProductPageEvent {
  final String name;
  final double price;
  final double discountPrice;
  final String description;
  final String prepTime;
  final String portionSize;
  final String addons;

  const SubmitProductEvent({
    required this.name,
    required this.price,
    this.discountPrice = 0.0,
    required this.description,
    this.prepTime = '',
    this.portionSize = '',
    this.addons = '',
  });

  @override
  List<Object?> get props => [name, price, discountPrice, description, prepTime, portionSize, addons];
}

class StepChangedEvent extends AddProductPageEvent {
  final int stepIndex;
  const StepChangedEvent(this.stepIndex);

  @override
  List<Object?> get props => [stepIndex];
}

class FieldChangedEvent extends AddProductPageEvent {
  final String fieldName;
  final dynamic value;
  const FieldChangedEvent(this.fieldName, this.value);

  @override
  List<Object?> get props => [fieldName, value];
}
