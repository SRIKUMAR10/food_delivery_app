import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class SellerProductEvent extends Equatable {
  const SellerProductEvent();

  @override
  List<Object> get props => [];
}

class ProductNameChanged extends SellerProductEvent {
  final String name;
  const ProductNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

class ProductPriceChanged extends SellerProductEvent {
  final String price;
  const ProductPriceChanged(this.price);

  @override
  List<Object> get props => [price];
}

class ProductDescriptionChanged extends SellerProductEvent {
  final String description;
  const ProductDescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class ProductCategoryChanged extends SellerProductEvent {
  final String category;
  const ProductCategoryChanged(this.category);

  @override
  List<Object> get props => [category];
}

class ProductImagePicked extends SellerProductEvent {
  final XFile? image;
  const ProductImagePicked(this.image);

  @override
  List<Object> get props => [image ?? ''];
}

class AddProductSubmitted extends SellerProductEvent {
  const AddProductSubmitted();

  @override
  List<Object> get props => [];
}

class AddProductReset extends SellerProductEvent {
  const AddProductReset();

  @override
  List<Object> get props => [];
}
