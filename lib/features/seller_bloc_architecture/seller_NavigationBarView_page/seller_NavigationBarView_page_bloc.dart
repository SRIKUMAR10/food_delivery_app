import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_NavigationBarView_page_event.dart';
import 'seller_NavigationBarView_page_state.dart';

class SellerNavigationBarViewPageBloc extends Bloc<SellerNavigationBarViewPageEvent, SellerNavigationBarViewPageState> {
  SellerNavigationBarViewPageBloc() : super(const SellerNavigationBarViewPageInitial()) {
    on<TabChangedEvent>(_onTabChanged);
  }

  void _onTabChanged(TabChangedEvent event, Emitter<SellerNavigationBarViewPageState> emit) {
    emit(SellerNavigationBarViewPageUpdated(event.tabIndex));
  }
}
