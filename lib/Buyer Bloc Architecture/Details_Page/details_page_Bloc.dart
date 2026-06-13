import 'package:flutter_bloc/flutter_bloc.dart';
import 'details_page_Event.dart';
import 'details_page_State.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  DetailsBloc() : super(const DetailsState()) {
    on<DetailsQuantityIncreased>(_onQuantityIncreased);
    on<DetailsQuantityDecreased>(_onQuantityDecreased);
    on<DetailsFavouriteToggled>(_onFavouriteToggled);
  }

  void _onQuantityIncreased(
    DetailsQuantityIncreased event,
    Emitter<DetailsState> emit,
  ) {
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onQuantityDecreased(
    DetailsQuantityDecreased event,
    Emitter<DetailsState> emit,
  ) {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }

  void _onFavouriteToggled(
    DetailsFavouriteToggled event,
    Emitter<DetailsState> emit,
  ) {
    emit(state.copyWith(isFavourite: !state.isFavourite));
  }
}
