import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';
import '../../../repositories/seller_repository.dart';

class SellerStoreDetailsBloc
    extends Bloc<SellerStoreDetailsPageEvent, SellerStoreDetailsPageState> {
  final SellerRepository _repository = SellerRepository();

  SellerStoreDetailsBloc() : super(SellerStoreDetailsInitial()) {
    on<LoadStoreDetailsEvent>(_onLoadStoreDetails);
    on<EditStoreDetailsEvent>(_onEditStoreDetails);
    on<ToggleStoreStatusEvent>(_onToggleStoreStatus);
    on<UpdateFieldEvent>(_onUpdateField);
  }

  Future<void> _onLoadStoreDetails(
    LoadStoreDetailsEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    emit(SellerStoreDetailsLoading());
    try {
      final user = _repository.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final seller = await _repository.fetchSeller(user.uid);
      if (seller == null) {
        throw Exception('Seller data not found');
      }

      emit(
        SellerStoreDetailsLoaded(
          restaurantName: seller.shopName.isNotEmpty ? seller.shopName : seller.name,
          address: seller.businessDetails.isNotEmpty ? seller.businessDetails : 'Address not set',
          phone: seller.phoneNumber.isNotEmpty ? seller.phoneNumber : 'Phone not set',
          openingHours: seller.openingHours.isNotEmpty ? seller.openingHours : '10:00 AM - 11:00 PM',
          deliveryTime: seller.deliveryTime.isNotEmpty ? seller.deliveryTime : '30 - 45 min',
          deliveryArea: seller.deliveryArea.isNotEmpty ? seller.deliveryArea : '5.0 km',
          gstNumber: seller.gstNumber,
          fssaiNumber: seller.fssaiNumber,
          panNumber: seller.panNumber,
          isOnline: seller.isOnline,
          gstPercentage: seller.gstPercentage,
          minimumOrderValue: seller.minimumOrderValue,
          packagingCharges: seller.packagingCharges,
          bankAccountNumber: seller.bankAccountNumber,
          bankName: seller.bankName,
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
    // Handle generic edit logic if needed
  }

  Future<void> _onToggleStoreStatus(
    ToggleStoreStatusEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    if (state is SellerStoreDetailsLoaded) {
      final currentState = state as SellerStoreDetailsLoaded;
      try {
        final user = _repository.currentUser;
        if (user != null) {
          await _repository.updateSellerData(user.uid, {'isOnline': event.isOnline});
        }
        
        emit(
          SellerStoreDetailsLoaded(
            restaurantName: currentState.restaurantName,
            address: currentState.address,
            phone: currentState.phone,
            openingHours: currentState.openingHours,
            deliveryTime: currentState.deliveryTime,
            deliveryArea: currentState.deliveryArea,
            gstNumber: currentState.gstNumber,
            fssaiNumber: currentState.fssaiNumber,
            panNumber: currentState.panNumber,
            isOnline: event.isOnline,
            gstPercentage: currentState.gstPercentage,
            minimumOrderValue: currentState.minimumOrderValue,
            packagingCharges: currentState.packagingCharges,
            bankAccountNumber: currentState.bankAccountNumber,
            bankName: currentState.bankName,
          ),
        );
      } catch (e) {
        // Fallback on error if needed
      }
    }
  }

  Future<void> _onUpdateField(
    UpdateFieldEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    if (state is SellerStoreDetailsLoaded) {
      final currentState = state as SellerStoreDetailsLoaded;
      try {
        final user = _repository.currentUser;
        if (user != null) {
          await _repository.updateSellerData(user.uid, {event.field: event.value});
        }
        
        // Optimistically update the UI
        emit(
          SellerStoreDetailsLoaded(
            restaurantName: currentState.restaurantName,
            address: currentState.address,
            phone: currentState.phone,
            openingHours: event.field == 'openingHours' ? event.value as String : currentState.openingHours,
            deliveryTime: event.field == 'deliveryTime' ? event.value as String : currentState.deliveryTime,
            deliveryArea: currentState.deliveryArea,
            gstNumber: currentState.gstNumber,
            fssaiNumber: currentState.fssaiNumber,
            panNumber: currentState.panNumber,
            isOnline: currentState.isOnline,
            gstPercentage: event.field == 'gstPercentage' ? event.value as double : currentState.gstPercentage,
            minimumOrderValue: event.field == 'minimumOrderValue' ? event.value as double : currentState.minimumOrderValue,
            packagingCharges: event.field == 'packagingCharges' ? event.value as double : currentState.packagingCharges,
            bankAccountNumber: currentState.bankAccountNumber,
            bankName: currentState.bankName,
          ),
        );
      } catch (e) {
        // Emit error or re-load in a robust app
      }
    }
  }
}
