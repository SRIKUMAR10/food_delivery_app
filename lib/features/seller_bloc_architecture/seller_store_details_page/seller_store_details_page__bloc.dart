import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';

class SellerStoreDetailsBloc
    extends Bloc<SellerStoreDetailsPageEvent, SellerStoreDetailsPageState> {
  SellerStoreDetailsBloc() : super(SellerStoreDetailsInitial()) {
    on<LoadStoreDetailsEvent>(_onLoadStoreDetails);
    on<EditStoreDetailsEvent>(_onEditStoreDetails);
  }

  Future<void> _onLoadStoreDetails(
    LoadStoreDetailsEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    emit(SellerStoreDetailsLoading());
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      // Mock data based on the UI image provided
      emit(
        const SellerStoreDetailsLoaded(
          restaurantName: 'Picarhub Restaurant',
          address: '221B Baker Street, London',
          phone: '+91 98765 43210',
          openingHours: '10:00 AM - 11:00 PM',
          deliveryTime: '30 - 45 min',
          deliveryArea: '5.0 km',
        ),
      );
    } catch (e) {
      emit(SellerStoreDetailsError(e.toString()));
    }
  }

  Future<void> _onEditStoreDetails(
    EditStoreDetailsEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    // Handle edit logic here
  }
}
