import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/seller_model.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';
import '../../../repositories/seller_repository.dart';

class _StoreDetailsStreamUpdatedEvent extends SellerStoreDetailsPageEvent {
  final Seller seller;
  const _StoreDetailsStreamUpdatedEvent(this.seller);

  @override
  List<Object> get props => [seller];
}

class SellerStoreDetailsBloc
    extends Bloc<SellerStoreDetailsPageEvent, SellerStoreDetailsPageState> {
  final SellerRepository _repository;
  StreamSubscription<Seller>? _sellerSubscription;

  SellerStoreDetailsBloc({SellerRepository? repository})
      : _repository = repository ?? SellerRepository(),
        super(SellerStoreDetailsInitial()) {
    on<LoadStoreDetailsEvent>(_onLoadStoreDetails);
    on<_StoreDetailsStreamUpdatedEvent>(_onStoreDetailsStreamUpdated);
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
        emit(const SellerStoreDetailsError('User not authenticated'));
        return;
      }

      await _sellerSubscription?.cancel();

      // First fetch directly if available
      try {
        final seller = await _repository.fetchSeller(user.uid);
        emit(_mapSellerToLoadedState(seller));
      } catch (_) {}

      // Then bind continuous real-time stream listener
      _sellerSubscription = _repository.getSellerById(user.uid).listen(
        (seller) {
          if (!isClosed) {
            add(_StoreDetailsStreamUpdatedEvent(seller));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(SellerStoreDetailsError(error.toString()));
          }
        },
      );
    } catch (e) {
      emit(SellerStoreDetailsError(e.toString()));
    }
  }

  void _onStoreDetailsStreamUpdated(
    _StoreDetailsStreamUpdatedEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) {
    emit(_mapSellerToLoadedState(event.seller));
  }

  SellerStoreDetailsLoaded _mapSellerToLoadedState(Seller seller) {
    return SellerStoreDetailsLoaded(
      restaurantName: seller.shopName.isNotEmpty
          ? seller.shopName
          : (seller.name.isNotEmpty
              ? seller.name
              : "Zolo Family Restaurant - Fried Chicken's / Burgers / Pizza's / Milkshake's / Ice Creams"),
      address: seller.businessDetails.isNotEmpty
          ? seller.businessDetails
          : (seller.fullAddress.isNotEmpty
              ? seller.fullAddress
              : '8/1223, Salem Kovai, NH-47 Bye Pass Road, Lakshmi Nagar, Bhavani, Tamil Nadu 638316'),
      phone: seller.phoneNumber.isNotEmpty ? seller.phoneNumber : '+91 98420 12345',
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
      fssaiExpiryDate: seller.fssaiExpiryDate,
      isTaxIncludedInPrice: seller.isTaxIncludedInPrice,
      invoicePrefix: seller.invoicePrefix,
      autoAcceptOrders: seller.autoAcceptOrders,
      prepBufferTimeMinutes: seller.prepBufferTimeMinutes,
      maxActiveOrdersLimit: seller.maxActiveOrdersLimit,
      allowScheduledOrders: seller.allowScheduledOrders,
      allowSpecialInstructions: seller.allowSpecialInstructions,
      cancellationWindowMinutes: seller.cancellationWindowMinutes,
    );
  }

  Future<void> _onEditStoreDetails(
    EditStoreDetailsEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    // Handled via individual update events
  }

  Future<void> _onToggleStoreStatus(
    ToggleStoreStatusEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    if (state is SellerStoreDetailsLoaded) {
      try {
        final user = _repository.currentUser;
        if (user != null) {
          await _repository.updateSellerData(user.uid, {'isOnline': event.isOnline});
        }
      } catch (e) {
        emit(SellerStoreDetailsError('Failed to update status: $e'));
      }
    }
  }

  Future<void> _onUpdateField(
    UpdateFieldEvent event,
    Emitter<SellerStoreDetailsPageState> emit,
  ) async {
    if (state is SellerStoreDetailsLoaded) {
      try {
        final user = _repository.currentUser;
        if (user != null) {
          await _repository.updateSellerData(user.uid, {event.field: event.value});
        }
      } catch (e) {
        emit(SellerStoreDetailsError('Failed to update ${event.field}: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _sellerSubscription?.cancel();
    return super.close();
  }
}
