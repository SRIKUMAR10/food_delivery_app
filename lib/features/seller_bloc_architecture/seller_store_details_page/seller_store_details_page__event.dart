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

class ToggleStoreStatusEvent extends SellerStoreDetailsPageEvent {
  final bool isOnline;

  const ToggleStoreStatusEvent(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}

class UpdateFieldEvent extends SellerStoreDetailsPageEvent {
  final String field;
  final dynamic value;

  const UpdateFieldEvent(this.field, this.value);

  @override
  List<Object> get props => [field, value];
}
