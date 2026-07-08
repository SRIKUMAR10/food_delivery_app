import 'package:equatable/equatable.dart';

abstract class SellerPaymentPageEvent extends Equatable {
  const SellerPaymentPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentData extends SellerPaymentPageEvent {}

class RefreshPaymentData extends SellerPaymentPageEvent {}
