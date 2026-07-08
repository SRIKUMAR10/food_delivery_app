import 'package:equatable/equatable.dart';

abstract class SellerOnboardPageEvent extends Equatable {
  const SellerOnboardPageEvent();

  @override
  List<Object?> get props => [];
}

class SellerOnboardGetStartedPressed extends SellerOnboardPageEvent {}
