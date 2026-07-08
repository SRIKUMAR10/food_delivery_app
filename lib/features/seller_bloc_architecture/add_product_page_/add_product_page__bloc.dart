import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';

class AddProductPageBloc extends Bloc<AddProductPageEvent, AddProductPageState> {
  AddProductPageBloc() : super(const AddProductPageState()) {
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<CategoryChangedEvent>(_onCategoryChanged);
    on<StatusChangedEvent>(_onStatusChanged);
    on<SubmitProductEvent>(_onSubmitProduct);
  }

  void _onAddImage(AddImageEvent event, Emitter<AddProductPageState> emit) {
    if (state.images.length < 5) {
      final updatedImages = List<String>.from(state.images)..add(event.imagePath);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter<AddProductPageState> emit) {
    if (event.index >= 0 && event.index < state.images.length) {
      final updatedImages = List<String>.from(state.images)..removeAt(event.index);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onCategoryChanged(CategoryChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onStatusChanged(StatusChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(isActive: event.isActive));
  }

  Future<void> _onSubmitProduct(SubmitProductEvent event, Emitter<AddProductPageState> emit) async {
    emit(state.copyWith(status: AddProductStatus.loading));
    
    try {
      // Simulate API call for adding product
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation
      if (event.name.isEmpty || event.price <= 0 || state.category == null || state.images.isEmpty) {
         emit(state.copyWith(
           status: AddProductStatus.error, 
           errorMessage: 'Please fill all required fields and upload at least 1 image.'
         ));
         return;
      }

      emit(state.copyWith(status: AddProductStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AddProductStatus.error, errorMessage: e.toString()));
    }
  }
}
