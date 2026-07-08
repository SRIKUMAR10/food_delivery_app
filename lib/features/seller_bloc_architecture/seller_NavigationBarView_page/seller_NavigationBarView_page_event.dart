import 'package:equatable/equatable.dart';

abstract class SellerNavigationBarViewPageEvent extends Equatable {
  const SellerNavigationBarViewPageEvent();

  @override
  List<Object> get props => [];
}

class TabChangedEvent extends SellerNavigationBarViewPageEvent {
  final int tabIndex;

  const TabChangedEvent(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}
