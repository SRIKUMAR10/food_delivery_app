import 'package:equatable/equatable.dart';

abstract class SellerStoreDetailsPageEvent extends Equatable {
  const SellerStoreDetailsPageEvent();

  @override
  List<Object> get props => [];
}

class LoadStoreDetailsEvent extends SellerStoreDetailsPageEvent {}

class EditStoreDetailsEvent extends SellerStoreDetailsPageEvent {
  // Add fields to be edited here in the future
  const EditStoreDetailsEvent();

  @override
  List<Object> get props => [];
}
