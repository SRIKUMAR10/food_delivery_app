import 'package:equatable/equatable.dart';

abstract class SellerNavigationBarViewPageState extends Equatable {
  const SellerNavigationBarViewPageState();
  
  int get currentTabIndex => 0;

  @override
  List<Object> get props => [];
}

class SellerNavigationBarViewPageInitial extends SellerNavigationBarViewPageState {
  final int tabIndex;

  const SellerNavigationBarViewPageInitial({this.tabIndex = 0});

  @override
  int get currentTabIndex => tabIndex;

  @override
  List<Object> get props => [tabIndex];
}

class SellerNavigationBarViewPageUpdated extends SellerNavigationBarViewPageState {
  final int tabIndex;

  const SellerNavigationBarViewPageUpdated(this.tabIndex);

  @override
  int get currentTabIndex => tabIndex;

  @override
  List<Object> get props => [tabIndex];
}

