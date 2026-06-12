import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/Repository/product_repository.dart';

import 'seller_product_event.dart';
import 'seller_product_state.dart';

class SellerProductBloc extends Bloc<SellerProductEvent, SellerProductState> {
  final ProductRepository _productRepository;

  SellerProductBloc({required ProductRepository productRepository})
    : _productRepository = productRepository,
      super(const SellerProductState()) {
    on<ProductNameChanged>(_onProductNameChanged);
    on<ProductPriceChanged>(_onProductPriceChanged);
    on<ProductDescriptionChanged>(_onProductDescriptionChanged);
    on<ProductCategoryChanged>(_onProductCategoryChanged);
    on<ProductImagePicked>(_onProductImagePicked);
    on<AddProductSubmitted>(_onAddProductSubmitted);
    on<AddProductReset>(_onAddProductReset);
  }

  void _onProductNameChanged(
    ProductNameChanged event,
    Emitter<SellerProductState> emit,
  ) {
    emit(state.copyWith(productName: event.name));
  }

  void _onProductPriceChanged(
    ProductPriceChanged event,
    Emitter<SellerProductState> emit,
  ) {
    emit(state.copyWith(productPrice: event.price));
  }

  void _onProductDescriptionChanged(
    ProductDescriptionChanged event,
    Emitter<SellerProductState> emit,
  ) {
    emit(state.copyWith(productDescription: event.description));
  }

  void _onProductCategoryChanged(
    ProductCategoryChanged event,
    Emitter<SellerProductState> emit,
  ) {
    emit(state.copyWith(productCategory: event.category));
  }

  void _onProductImagePicked(
    ProductImagePicked event,
    Emitter<SellerProductState> emit,
  ) {
    emit(
      state.copyWith(
        productImage: event.image,
        clearProductImage: event.image == null,
      ),
    );
  }

  Future<void> _onAddProductSubmitted(
    AddProductSubmitted event,
    Emitter<SellerProductState> emit,
  ) async {
    emit(state.copyWith(status: AddProductStatus.loading));
    try {
      // Basic validation
      if (state.productName.isEmpty ||
          state.productPrice.isEmpty ||
          state.productDescription.isEmpty ||
          state.productImage == null) {
        emit(
          state.copyWith(
            status: AddProductStatus.error,
            errorMessage: 'Please fill all fields and select an image.',
          ),
        );
        return;
      }

      await _productRepository.addProduct(
        name: state.productName,
        price: double.parse(state.productPrice),
        description: state.productDescription,
        category: state.productCategory,
        imageFile: state.productImage,
      );
      emit(state.copyWith(status: AddProductStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddProductStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onAddProductReset(
    AddProductReset event,
    Emitter<SellerProductState> emit,
  ) {
    emit(const SellerProductState()); // Reset to initial state
  }
}
