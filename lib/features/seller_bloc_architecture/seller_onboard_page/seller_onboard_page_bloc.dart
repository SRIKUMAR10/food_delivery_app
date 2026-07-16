import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_onboard_page_event.dart';
import 'seller_onboard_page_state.dart';

class SellerOnboardPageBloc extends Bloc<SellerOnboardPageEvent, SellerOnboardPageState> {
  SellerOnboardPageBloc() : super(SellerOnboardInitial()) {
    on<SellerOnboardGetStartedPressed>(_onGetStartedPressed);
  }

  Future<void> _onGetStartedPressed(
    SellerOnboardGetStartedPressed event,
    Emitter<SellerOnboardPageState> emit,
  ) async {
    emit(SellerOnboardLoading());
    try {
      // Navigate to the next screen or show success
      emit(SellerOnboardSuccess());
    } catch (e) {
      emit(SellerOnboardError(e.toString()));
    }
  }
}
