import 'package:flutter_bloc/flutter_bloc.dart';
import 'out_for_delivery_page__event.dart';
import 'out_for_delivery_page__state.dart';

class OutForDeliveryPageBloc extends Bloc<OutForDeliveryPageEvent, OutForDeliveryPageState> {
  OutForDeliveryPageBloc() : super(OutForDeliveryPageInitial()) {
    on<FetchDeliveryDetails>(_onFetchDeliveryDetails);
    on<CallRider>(_onCallRider);
    on<MessageRider>(_onMessageRider);
  }

  Future<void> _onFetchDeliveryDetails(
      FetchDeliveryDetails event, Emitter<OutForDeliveryPageState> emit) async {
    emit(OutForDeliveryPageLoading());
    try {
      // Simulate API call for fetching delivery details
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data based on the UI
      final rider = RiderDetails(
        id: 'r123',
        name: 'John Rider',
        phone: '+91 12345 67890',
        imageUrl: 'https://i.pravatar.cc/150?u=john',
      );

      emit(OutForDeliveryPageLoaded(
        orderId: event.orderId,
        rider: rider,
        currentStatus: DeliveryStatus.outForDelivery,
        estimatedTime: '15 min',
        distance: '2.1 km from you',
      ));
    } catch (e) {
      emit(OutForDeliveryPageError(message: 'Failed to load delivery details.'));
    }
  }

  Future<void> _onCallRider(CallRider event, Emitter<OutForDeliveryPageState> emit) async {
    // Implement phone call logic (e.g., using url_launcher)
  }

  Future<void> _onMessageRider(MessageRider event, Emitter<OutForDeliveryPageState> emit) async {
    // Implement messaging logic
  }
}
