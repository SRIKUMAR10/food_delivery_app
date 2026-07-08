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

class StatusChangedEvent extends AddProductPageEvent {
  final bool isActive;
  const StatusChangedEvent(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class SubmitProductEvent extends AddProductPageEvent {
  final String name;
  final double price;
  final String description;

  const SubmitProductEvent({
    required this.name,
    required this.price,
    required this.description,
  });

  @override
  List<Object?> get props => [name, price, description];
}
