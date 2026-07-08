import 'package:equatable/equatable.dart';

abstract class SellerStoreDetailsPageState extends Equatable {
  const SellerStoreDetailsPageState();

  @override
  List<Object> get props => [];
}

class SellerStoreDetailsInitial extends SellerStoreDetailsPageState {}

class SellerStoreDetailsLoading extends SellerStoreDetailsPageState {}

class SellerStoreDetailsLoaded extends SellerStoreDetailsPageState {
  final String restaurantName;
  final String address;
  final String phone;
  final String openingHours;
  final String deliveryTime;
  final String deliveryArea;

  const SellerStoreDetailsLoaded({
    required this.restaurantName,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.deliveryTime,
    required this.deliveryArea,
  });

  @override
  List<Object> get props => [
    restaurantName,
    address,
    phone,
    openingHours,
    deliveryTime,
    deliveryArea,
  ];
}

class SellerStoreDetailsError extends SellerStoreDetailsPageState {
  final String message;

  const SellerStoreDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
