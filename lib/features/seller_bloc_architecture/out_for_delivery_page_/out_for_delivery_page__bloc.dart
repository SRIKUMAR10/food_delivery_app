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
        return OutForDeliveryPageData(
          orderId: orderId,
          rider: const RiderDetails(
            id: '',
            name: 'Assigning Rider...',
            phone: '',
            imageUrl: '',
            rating: 5.0,
          ),
          currentStatus: DeliveryStatus.outForDelivery,
          riderLat: null,
          riderLng: null,
        );
      }
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final riderId = orderData['riderId'] as String? ??
          orderData['deliveryPartnerId'] as String? ??
          orderData['driverId'] as String?;

      RiderDetails rider = const RiderDetails(
        id: '',
        name: 'Delivery Partner',
        phone: '',
        imageUrl: '',
        rating: 4.8,
      );

      if (riderId != null && riderId.isNotEmpty) {
        try {
          final riderDoc = await _firestore.collection('riders').doc(riderId).get();
          if (riderDoc.exists) {
            final riderData = riderDoc.data()!;
            rider = RiderDetails(
              id: riderDoc.id,
              name: riderData['name'] as String? ?? 'Delivery Partner',
              phone: riderData['phone'] as String? ?? '',
              imageUrl: riderData['imageUrl'] as String? ?? '',
              rating: (riderData['rating'] as num?)?.toDouble() ?? 4.8,
            );
          } else {
            final partnerDoc = await _firestore.collection('delivery_partners').doc(riderId).get();
            if (partnerDoc.exists) {
              final pData = partnerDoc.data()!;
              rider = RiderDetails(
                id: partnerDoc.id,
                name: pData['fullName'] as String? ?? pData['name'] as String? ?? 'Delivery Partner',
                phone: pData['phoneNumber'] as String? ?? pData['phone'] as String? ?? '',
                imageUrl: pData['profilePicUrl'] as String? ?? pData['imageUrl'] as String? ?? '',
                rating: (pData['rating'] as num?)?.toDouble() ?? 4.8,
              );
            }
          }
        } catch (_) {}
      }

      final statusStr = orderData['status'] as String? ?? 'OutForDelivery';
      DeliveryStatus status;
      switch (statusStr.toLowerCase()) {
        case 'accepted':
          status = DeliveryStatus.orderAccepted;
          break;
        case 'preparing':
          status = DeliveryStatus.preparing;
          break;
        case 'ready':
        case 'readyforpickup':
        case 'ready_for_pickup':
          status = DeliveryStatus.readyForPickup;
          break;
        case 'outfordelivery':
        case 'active':
        case 'on_the_way':
          status = DeliveryStatus.outForDelivery;
          break;
        case 'delivered':
        case 'completed':
          status = DeliveryStatus.delivered;
          break;
        default:
          status = DeliveryStatus.outForDelivery;
      }

      final currentLocation = orderData['currentLocation'] as Map<String, dynamic>?;
      double? riderLat;
      double? riderLng;
      if (currentLocation != null) {
        riderLat = (currentLocation['lat'] as num?)?.toDouble();
        riderLng = (currentLocation['lng'] as num?)?.toDouble();
      }

      if ((riderLat == null || riderLng == null) && riderId != null && riderId.isNotEmpty) {
        try {
          final pDoc = await _firestore.collection('delivery_partners').doc(riderId).get();
          if (pDoc.exists && pDoc.data() != null) {
            final loc = pDoc.data()!['currentLocation'];
            if (loc is Map<String, dynamic>) {
              riderLat = (loc['lat'] as num?)?.toDouble();
              riderLng = (loc['lng'] as num?)?.toDouble();
            } else if (loc is GeoPoint) {
              riderLat = loc.latitude;
              riderLng = loc.longitude;
            }
          }
        } catch (_) {}
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
    try {
      final riderDoc = await _firestore.collection('riders').doc(riderId).get();
      if (riderDoc.exists) {
        final data = riderDoc.data()!;
        return RiderDetails(
          id: riderDoc.id,
          name: data['name'] as String? ?? 'Delivery Partner',
          phone: data['phone'] as String? ?? '',
          imageUrl: data['imageUrl'] as String? ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
        );
      }
    } catch (_) {}

    return const RiderDetails(
      id: '',
      name: 'Delivery Partner',
      phone: '',
      imageUrl: '',
      rating: 4.8,
    );
  }
}

class OutForDeliveryPageBloc extends Bloc<OutForDeliveryPageEvent, OutForDeliveryPageState> {
  final OutForDeliveryRepository repository;

  OutForDeliveryPageBloc({required this.repository}) : super(OutForDeliveryPageInitial()) {
    on<FetchDeliveryDetails>(_onFetchDeliveryDetails);
    on<CallRider>(_onCallRider);
    on<MessageRider>(_onMessageRider);
  }

  Future<void> _onFetchDeliveryDetails(
      FetchDeliveryDetails event, Emitter<OutForDeliveryPageState> emit) async {
    emit(OutForDeliveryPageLoading());
    try {
      await emit.forEach<OutForDeliveryPageData>(
        repository.streamDeliveryDetails(event.orderId),
        onData: (data) {
          final isLive = data.riderLat != null && data.riderLng != null;
          return OutForDeliveryPageLoaded(
            orderId: data.orderId,
            rider: data.rider,
            currentStatus: data.currentStatus,
            estimatedTime: isLive ? 'Live' : 'Tracking',
            distance: isLive
                ? '${data.riderLat!.toStringAsFixed(4)}, ${data.riderLng!.toStringAsFixed(4)}'
                : 'Location available',
          );
        },
        onError: (error, stackTrace) {
          return const OutForDeliveryPageError(message: 'Failed to load delivery details.');
        },
      );
    } catch (e) {
      emit(const OutForDeliveryPageError(message: 'Failed to load delivery details.'));
    }
  }

  Future<void> _onCallRider(CallRider event, Emitter<OutForDeliveryPageState> emit) async {}

  Future<void> _onMessageRider(MessageRider event, Emitter<OutForDeliveryPageState> emit) async {}
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
