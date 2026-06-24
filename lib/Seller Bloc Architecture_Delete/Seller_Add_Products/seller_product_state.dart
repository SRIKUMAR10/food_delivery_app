import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

enum AddProductStatus { initial, loading, success, error }

class SellerProductState extends Equatable {
  final String productName;
  final String productPrice;
  final String productDescription;
  final String productCategory;
  final XFile? productImage;
  final AddProductStatus status;
  final String? errorMessage;

  const SellerProductState({
    this.productName = '',
    this.productPrice = '',
    this.productDescription = '',
    this.productCategory = 'Pizza', // Default category
    this.productImage,
    this.status = AddProductStatus.initial,
    this.errorMessage,
  });

  SellerProductState copyWith({
    String? productName,
    String? productPrice,
    String? productDescription,
    String? productCategory,
    XFile? productImage,
    bool clearProductImage = false,
    AddProductStatus? status,
    String? errorMessage,
  }) {
    return SellerProductState(
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productDescription: productDescription ?? this.productDescription,
      productCategory: productCategory ?? this.productCategory,
      productImage: clearProductImage
          ? null
          : productImage ?? this.productImage,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    productName,
    productPrice,
    productDescription,
    productCategory,
    productImage,
    status,
    errorMessage,
  ];
}
