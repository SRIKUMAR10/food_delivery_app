import 'package:equatable/equatable.dart';

abstract class SellerOnboardPageState extends Equatable {
  const SellerOnboardPageState();
  
  @override
  List<Object?> get props => [];
}

class SellerOnboardInitial extends SellerOnboardPageState {}

class SellerOnboardLoading extends SellerOnboardPageState {}

class SellerOnboardSuccess extends SellerOnboardPageState {}

class SellerOnboardError extends SellerOnboardPageState {
  final String message;

  const SellerOnboardError(this.message);

  @override
  List<Object?> get props => [message];
}
