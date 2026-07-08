import 'package:equatable/equatable.dart';

abstract class SellerDashboardPageEvent extends Equatable {
  const SellerDashboardPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends SellerDashboardPageEvent {}

class RefreshDashboardData extends SellerDashboardPageEvent {}
