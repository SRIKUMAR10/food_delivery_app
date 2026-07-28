import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddProductPageEvent extends Equatable {
  const AddProductPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductEvent extends AddProductPageEvent {
  final String productId;
  const LoadProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AddImageEvent extends AddProductPageEvent {
  final XFile image;
  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class RemoveImageEvent extends AddProductPageEvent {
  final int index;
  const RemoveImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class RemoveExistingImageEvent extends AddProductPageEvent {
  final int index;
  const RemoveExistingImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CategoryChangedEvent extends AddProductPageEvent {
  final String category;
  const CategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class StatusChangedEvent extends AddProductPageEvent {
  final bool isActive;
  const StatusChangedEvent(this.isActive);

  @override
  List<Object?> get props => [isActive];
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

class FieldChangedEvent extends AddProductPageEvent {
  final String field;
  final dynamic value;
  const FieldChangedEvent(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class SubmitProductEvent extends AddProductPageEvent {
  final String name;
  final double price;
  final double? discountPrice;
  final String description;
  final String? prepTime;
  final String? portionSize;
  final String? addons;
  final String? calories;
  final int? availableStock;
  final int? minimumAlert;

  const SubmitProductEvent({
    required this.name,
    required this.price,
    this.discountPrice,
    required this.description,
    this.prepTime,
    this.portionSize,
    this.addons,
    this.calories,
    this.availableStock,
    this.minimumAlert,
  });

  @override
  List<Object?> get props => [name, price, discountPrice, description, prepTime, portionSize, addons, calories, availableStock, minimumAlert];
}

class ResetFormEvent extends AddProductPageEvent {}

class FetchGstPercentageEvent extends AddProductPageEvent {}
