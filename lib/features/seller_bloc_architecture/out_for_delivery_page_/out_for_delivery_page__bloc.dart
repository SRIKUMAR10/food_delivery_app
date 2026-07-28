import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'out_for_delivery_page__event.dart';
import 'out_for_delivery_page__state.dart';

class OutForDeliveryRepository {
  final FirebaseFirestore _firestore;

  OutForDeliveryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<OutForDeliveryPageData> streamDeliveryDetails(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().asyncMap((orderDoc) async {
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final riderId = orderData['riderId'] as String?;

      if (riderId == null) {
        throw Exception('No rider assigned yet');
      }

      final riderDoc = await _firestore.collection('riders').doc(riderId).get();
      if (!riderDoc.exists) {
        throw Exception('Rider not found');
      }
      final riderData = riderDoc.data() as Map<String, dynamic>;

      final statusStr = orderData['status'] as String? ?? 'OutForDelivery';
      DeliveryStatus status;
      switch (statusStr) {
        case 'Accepted':
          status = DeliveryStatus.orderAccepted;
          break;
        case 'Preparing':
          status = DeliveryStatus.preparing;
          break;
        case 'Ready':
          status = DeliveryStatus.readyForPickup;
          break;
        case 'OutForDelivery':
          status = DeliveryStatus.outForDelivery;
          break;
        case 'Delivered':
          status = DeliveryStatus.delivered;
          break;
        default:
          status = DeliveryStatus.outForDelivery;
      }

      final rider = RiderDetails(
        id: riderDoc.id,
        name: riderData['name'] as String? ?? 'Unknown Rider',
        phone: riderData['phone'] as String? ?? '',
        imageUrl: riderData['imageUrl'] as String? ?? '',
        rating: (riderData['rating'] as num?)?.toDouble() ?? 0.0,
      );

      final currentLocation = riderData['currentLocation'] as Map<String, dynamic>?;
      double? riderLat;
      double? riderLng;
      if (currentLocation != null) {
        riderLat = (currentLocation['lat'] as num?)?.toDouble();
        riderLng = (currentLocation['lng'] as num?)?.toDouble();
      }

      return OutForDeliveryPageData(
        orderId: orderDoc.id,
        rider: rider,
        currentStatus: status,
        riderLat: riderLat,
        riderLng: riderLng,
      );
    });
  }

  Future<RiderDetails> fetchRiderDetails(String riderId) async {
    final riderDoc = await _firestore.collection('riders').doc(riderId).get();
    if (!riderDoc.exists) {
      throw Exception('Rider not found');
    }
    final data = riderDoc.data() as Map<String, dynamic>;
    return RiderDetails(
      id: riderDoc.id,
      name: data['name'] as String? ?? 'Unknown Rider',
      phone: data['phone'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OutForDeliveryPageBloc extends Bloc<OutForDeliveryPageEvent, OutForDeliveryPageState> {
  final OutForDeliveryRepository repository;
  StreamSubscription? _deliverySubscription;

  OutForDeliveryPageBloc({required this.repository}) : super(OutForDeliveryPageInitial()) {
    on<FetchDeliveryDetails>(_onFetchDeliveryDetails);
    on<CallRider>(_onCallRider);
    on<MessageRider>(_onMessageRider);
  }

  Future<void> _onFetchDeliveryDetails(
      FetchDeliveryDetails event, Emitter<OutForDeliveryPageState> emit) async {
    emit(OutForDeliveryPageLoading());
    try {
      _deliverySubscription?.cancel();
      _deliverySubscription = repository.streamDeliveryDetails(event.orderId).listen(
        (data) {
          final isLive = data.riderLat != null && data.riderLng != null;
          emit(OutForDeliveryPageLoaded(
            orderId: data.orderId,
            rider: data.rider,
            currentStatus: data.currentStatus,
            estimatedTime: isLive ? 'Live' : 'Tracking',
            distance: isLive
                ? '${data.riderLat!.toStringAsFixed(4)}, ${data.riderLng!.toStringAsFixed(4)}'
                : 'Location available',
          ));
        },
        onError: (error) {
          emit(OutForDeliveryPageError(message: 'Failed to load delivery details.'));
        },
      );
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

  @override
  Future<void> close() {
    _deliverySubscription?.cancel();
    return super.close();
  }
}

class OutForDeliveryPageData {
  final String orderId;
  final RiderDetails rider;
  final DeliveryStatus currentStatus;
  final double? riderLat;
  final double? riderLng;

  OutForDeliveryPageData({
    required this.orderId,
    required this.rider,
    required this.currentStatus,
    this.riderLat,
    this.riderLng,
  });
}
