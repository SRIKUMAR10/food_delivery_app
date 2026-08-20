import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'out_for_delivery_page__event.dart';
import 'out_for_delivery_page__state.dart';

class OutForDeliveryRepository {
  final FirebaseFirestore _firestore;

  OutForDeliveryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Haversine distance calculation in kilometers.
  static double calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(math.max(0.0, a))); // 2 * R; R = 6371 km
  }

  /// Calculates dynamic estimated arrival time string.
  static String calculateDynamicEta(
      double? distanceKm, DeliveryStatus currentStatus) {
    if (currentStatus == DeliveryStatus.delivered) {
      return 'Delivered';
    }
    if (distanceKm == null || distanceKm <= 0) {
      return currentStatus == DeliveryStatus.outForDelivery ? '~5-10 mins' : 'Live';
    }
    // Estimated at ~25 km/h urban speed with traffic buffer
    final mins = math.max(2, (distanceKm / 0.35 + 2).round());
    return '~$mins mins';
  }

  /// Calculates expected delivery time clock string (e.g. 03:45 PM).
  static String calculateExpectedDeliveryTime(
      double? distanceKm, DeliveryStatus currentStatus) {
    if (currentStatus == DeliveryStatus.delivered) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
    int mins = 20;
    if (distanceKm != null && distanceKm > 0) {
      mins = math.max(3, (distanceKm / 0.35 + 2).round());
    }
    return DateFormat('hh:mm a').format(DateTime.now().add(Duration(minutes: mins)));
  }

  /// Formats distance in km or meters cleanly.
  static String formatDistance(double? distanceKm) {
    if (distanceKm == null) {
      return 'Location available';
    }
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  /// Calculates delivery progress ratio between 0.0 and 1.0.
  static double calculateProgressRatio(DeliveryStatus status, double? distanceKm) {
    switch (status) {
      case DeliveryStatus.orderAccepted:
        return 0.15;
      case DeliveryStatus.paymentReceived:
        return 0.30;
      case DeliveryStatus.preparing:
        return 0.50;
      case DeliveryStatus.readyForPickup:
        return 0.70;
      case DeliveryStatus.outForDelivery:
        if (distanceKm == null) return 0.85;
        if (distanceKm < 0.3) return 0.95;
        if (distanceKm < 1.0) return 0.90;
        return 0.82;
      case DeliveryStatus.delivered:
        return 1.0;
    }
  }

  /// Streams real-time order and driver GPS coordinates seamlessly.
  Stream<OutForDeliveryPageData> streamDeliveryDetails(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .switchMap((orderDoc) {
      if (!orderDoc.exists || orderDoc.data() == null) {
        return Stream.value(OutForDeliveryPageData(
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
        ));
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final riderId = orderData['riderId'] as String? ??
          orderData['deliveryPartnerId'] as String? ??
          orderData['driverId'] as String?;

      if (riderId == null || riderId.isEmpty) {
        return Stream.value(_parseOrderData(orderDoc.id, orderData, null));
      }

      // Stream delivery partner GPS updates in real-time
      return _firestore
          .collection('delivery_partners')
          .doc(riderId)
          .snapshots()
          .map((partnerDoc) {
        final pData = partnerDoc.exists ? partnerDoc.data() : null;
        return _parseOrderData(orderDoc.id, orderData, pData, riderId: riderId);
      }).onErrorResume((error, stackTrace) {
        // Fallback to riders collection
        return _firestore
            .collection('riders')
            .doc(riderId)
            .snapshots()
            .map((riderDoc) {
          final rData = riderDoc.exists ? riderDoc.data() : null;
          return _parseOrderData(orderDoc.id, orderData, rData, riderId: riderId);
        }).onErrorReturn(
          _parseOrderData(orderDoc.id, orderData, null, riderId: riderId),
        );
      });
    });
  }

  OutForDeliveryPageData _parseOrderData(
    String docId,
    Map<String, dynamic> orderData,
    Map<String, dynamic>? partnerData, {
    String? riderId,
  }) {
    RiderDetails rider = const RiderDetails(
      id: '',
      name: 'Delivery Partner',
      phone: '',
      imageUrl: '',
      rating: 4.8,
      vehicleType: 'two_wheeler',
      vehicleNumber: '',
    );

    double? driverSpeed;

    if (partnerData != null) {
      rider = RiderDetails(
        id: riderId ?? '',
        name: partnerData['displayName'] as String? ??
            partnerData['fullName'] as String? ??
            partnerData['name'] as String? ??
            'Delivery Partner',
        phone: partnerData['phoneNumber'] as String? ??
            partnerData['phone'] as String? ??
            partnerData['mobile'] as String? ??
            '',
        imageUrl: partnerData['photoUrl'] as String? ??
            partnerData['profilePicUrl'] as String? ??
            partnerData['imageUrl'] as String? ??
            '',
        rating: (partnerData['rating'] as num?)?.toDouble() ??
            (partnerData['averageRating'] as num?)?.toDouble() ??
            4.8,
        vehicleType: partnerData['vehicleType'] as String? ??
            partnerData['vehicle'] as String? ??
            'two_wheeler',
        vehicleNumber: partnerData['vehicleNumber'] as String? ??
            partnerData['vehicleNo'] as String? ??
            partnerData['bikeNumber'] as String? ??
            '',
      );

      driverSpeed = (partnerData['speed'] as num?)?.toDouble() ??
          (partnerData['currentSpeed'] as num?)?.toDouble();
    } else {
      final name = orderData['deliveryPartnerName'] as String? ??
          orderData['riderName'] as String? ??
          '';
      final phone = orderData['deliveryPartnerPhone'] as String? ??
          orderData['riderPhone'] as String? ??
          '';
      if (name.isNotEmpty || phone.isNotEmpty || (riderId != null && riderId.isNotEmpty)) {
        rider = RiderDetails(
          id: riderId ?? '',
          name: name.isNotEmpty ? name : 'Delivery Partner',
          phone: phone,
          imageUrl: orderData['deliveryPartnerImageUrl'] as String? ?? '',
          rating: 4.8,
          vehicleType: orderData['vehicleType'] as String? ?? 'two_wheeler',
          vehicleNumber: orderData['vehicleNumber'] as String? ?? '',
        );
      }
    }

    final statusStr = orderData['status'] as String? ?? 'OutForDelivery';
    DeliveryStatus status;
    switch (statusStr.toLowerCase().replaceAll('_', '')) {
      case 'accepted':
      case 'orderaccepted':
        status = DeliveryStatus.orderAccepted;
        break;
      case 'paymentreceived':
      case 'paid':
        status = DeliveryStatus.paymentReceived;
        break;
      case 'preparing':
      case 'preparingfood':
        status = DeliveryStatus.preparing;
        break;
      case 'ready':
      case 'readyforpickup':
        status = DeliveryStatus.readyForPickup;
        break;
      case 'outfordelivery':
      case 'active':
      case 'ontheway':
        status = DeliveryStatus.outForDelivery;
        break;
      case 'delivered':
      case 'completed':
        status = DeliveryStatus.delivered;
        break;
      default:
        status = DeliveryStatus.outForDelivery;
    }

    double? riderLat = (orderData['driverLat'] as num?)?.toDouble() ??
        (orderData['riderLat'] as num?)?.toDouble();
    double? riderLng = (orderData['driverLng'] as num?)?.toDouble() ??
        (orderData['riderLng'] as num?)?.toDouble();
    double riderHeading =
        (orderData['driverHeading'] as num?)?.toDouble() ??
            (orderData['riderHeading'] as num?)?.toDouble() ??
            0.0;

    final currentLocation =
        orderData['currentLocation'] as Map<String, dynamic>?;
    if (currentLocation != null) {
      riderLat ??= (currentLocation['lat'] as num?)?.toDouble();
      riderLng ??= (currentLocation['lng'] as num?)?.toDouble();
    }

    if (partnerData != null) {
      final loc = partnerData['currentLocation'];
      if (loc is Map<String, dynamic>) {
        riderLat = (loc['lat'] as num?)?.toDouble() ?? riderLat;
        riderLng = (loc['lng'] as num?)?.toDouble() ?? riderLng;
      } else if (loc is GeoPoint) {
        riderLat = loc.latitude;
        riderLng = loc.longitude;
      } else if (partnerData['latitude'] != null &&
          partnerData['longitude'] != null) {
        riderLat = (partnerData['latitude'] as num?)?.toDouble() ?? riderLat;
        riderLng = (partnerData['longitude'] as num?)?.toDouble() ?? riderLng;
      } else if (partnerData['driverLat'] != null &&
          partnerData['driverLng'] != null) {
        riderLat = (partnerData['driverLat'] as num?)?.toDouble() ?? riderLat;
        riderLng = (partnerData['driverLng'] as num?)?.toDouble() ?? riderLng;
      }
      riderHeading =
          (partnerData['heading'] as num?)?.toDouble() ??
              (partnerData['bearing'] as num?)?.toDouble() ??
              riderHeading;
    }

    final sellerLat = (orderData['sellerLat'] as num?)?.toDouble() ??
        (orderData['restaurantLat'] as num?)?.toDouble() ??
        (orderData['storeLat'] as num?)?.toDouble();
    final sellerLng = (orderData['sellerLng'] as num?)?.toDouble() ??
        (orderData['restaurantLng'] as num?)?.toDouble() ??
        (orderData['storeLng'] as num?)?.toDouble();

    final sellerName = orderData['sellerName'] as String? ??
        orderData['restaurantName'] as String? ??
        orderData['storeName'] as String? ??
        'My Kitchen';
    final sellerPhone = orderData['sellerPhone'] as String? ??
        orderData['restaurantPhone'] as String?;
    final sellerAddress = orderData['sellerAddress'] as String? ??
        orderData['restaurantAddress'] as String?;

    final customerLat = (orderData['customerLat'] as num?)?.toDouble() ??
        (orderData['deliveryLat'] as num?)?.toDouble() ??
        (orderData['lat'] as num?)?.toDouble();
    final customerLng = (orderData['customerLng'] as num?)?.toDouble() ??
        (orderData['deliveryLng'] as num?)?.toDouble() ??
        (orderData['lng'] as num?)?.toDouble();

    final customerName = orderData['customerName'] as String? ??
        orderData['buyerName'] as String? ??
        orderData['userName'] as String? ??
        'Customer';
    final customerPhone = orderData['customerPhone'] as String? ??
        orderData['buyerPhone'] as String? ??
        orderData['userPhone'] as String?;
    final customerId = orderData['customerId'] as String? ??
        orderData['buyerId'] as String? ??
        orderData['userId'] as String? ??
        orderData['uid'] as String?;
    final customerNotes = orderData['deliveryNotes'] as String? ??
        orderData['deliveryInstructions'] as String? ??
        orderData['instructions'] as String?;

    final deliveryAddress = orderData['deliveryAddress'] as String? ??
        orderData['address'] as String? ??
        orderData['fullAddress'] as String? ??
        '';
    final totalAmount = (orderData['totalAmount'] as num?)?.toDouble() ??
        (orderData['total'] as num?)?.toDouble() ??
        (orderData['amount'] as num?)?.toDouble();

    final bool isRaining = orderData['isRaining'] == true;
    final String? weatherAlert = orderData['weatherAlert'] as String?;

    return OutForDeliveryPageData(
      orderId: docId,
      rider: rider,
      currentStatus: status,
      riderLat: riderLat,
      riderLng: riderLng,
      riderHeading: riderHeading,
      driverSpeed: driverSpeed,
      sellerLat: sellerLat,
      sellerLng: sellerLng,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      sellerAddress: sellerAddress,
      customerLat: customerLat,
      customerLng: customerLng,
      customerName: customerName,
      customerPhone: customerPhone,
      customerId: customerId,
      customerNotes: customerNotes,
      deliveryAddress: deliveryAddress,
      totalAmount: totalAmount,
      isRaining: isRaining,
      weatherAlert: weatherAlert,
    );
  }

  Future<RiderDetails> fetchRiderDetails(String riderId) async {
    try {
      final pDoc =
          await _firestore.collection('delivery_partners').doc(riderId).get();
      if (pDoc.exists && pDoc.data() != null) {
        final data = pDoc.data()!;
        return RiderDetails(
          id: pDoc.id,
          name: data['displayName'] as String? ??
              data['fullName'] as String? ??
              data['name'] as String? ??
              'Delivery Partner',
          phone: data['phoneNumber'] as String? ??
              data['phone'] as String? ??
              '',
          imageUrl: data['photoUrl'] as String? ??
              data['profilePicUrl'] as String? ??
              data['imageUrl'] as String? ??
              '',
          rating: (data['rating'] as num?)?.toDouble() ??
              (data['averageRating'] as num?)?.toDouble() ??
              4.8,
          vehicleType: data['vehicleType'] as String? ?? 'two_wheeler',
          vehicleNumber: data['vehicleNumber'] as String? ??
              data['vehicleNo'] as String? ??
              '',
        );
      }
      final riderDoc =
          await _firestore.collection('riders').doc(riderId).get();
      if (riderDoc.exists && riderDoc.data() != null) {
        final data = riderDoc.data()!;
        return RiderDetails(
          id: riderDoc.id,
          name: data['name'] as String? ?? 'Delivery Partner',
          phone: data['phone'] as String? ?? '',
          imageUrl: data['imageUrl'] as String? ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
          vehicleType: data['vehicleType'] as String? ?? 'two_wheeler',
          vehicleNumber: data['vehicleNumber'] as String? ?? '',
        );
      }
    } catch (_) {}

    return const RiderDetails(
      id: '',
      name: 'Delivery Partner',
      phone: '',
      imageUrl: '',
      rating: 4.8,
      vehicleType: 'two_wheeler',
      vehicleNumber: '',
    );
  }
}

class OutForDeliveryPageBloc
    extends Bloc<OutForDeliveryPageEvent, OutForDeliveryPageState> {
  final OutForDeliveryRepository repository;

  OutForDeliveryPageBloc({required this.repository})
      : super(OutForDeliveryPageInitial()) {
    on<FetchDeliveryDetails>(_onFetchDeliveryDetails);
    on<ToggleMapFullScreen>(_onToggleMapFullScreen);
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

          double? distanceKm;
          if (isLive) {
            final targetLat = (data.currentStatus == DeliveryStatus.outForDelivery)
                ? (data.customerLat ?? data.sellerLat)
                : (data.sellerLat ?? data.customerLat);
            final targetLng = (data.currentStatus == DeliveryStatus.outForDelivery)
                ? (data.customerLng ?? data.sellerLng)
                : (data.sellerLng ?? data.customerLng);

            if (targetLat != null && targetLng != null) {
              distanceKm = OutForDeliveryRepository.calculateDistanceKm(
                data.riderLat!,
                data.riderLng!,
                targetLat,
                targetLng,
              );
            }
          } else if (data.sellerLat != null &&
              data.sellerLng != null &&
              data.customerLat != null &&
              data.customerLng != null) {
            distanceKm = OutForDeliveryRepository.calculateDistanceKm(
              data.sellerLat!,
              data.sellerLng!,
              data.customerLat!,
              data.customerLng!,
            );
          }

          final estimatedTime = OutForDeliveryRepository.calculateDynamicEta(
              distanceKm, data.currentStatus);
          final distanceStr = OutForDeliveryRepository.formatDistance(distanceKm);
          final expectedDeliveryTime =
              OutForDeliveryRepository.calculateExpectedDeliveryTime(
                  distanceKm, data.currentStatus);
          final progressRatio = OutForDeliveryRepository.calculateProgressRatio(
              data.currentStatus, distanceKm);
          final isArrivingSoon = (distanceKm != null && distanceKm <= 0.5) ||
              (data.currentStatus == DeliveryStatus.outForDelivery &&
                  distanceKm != null &&
                  distanceKm <= 0.8);

          final wasExpanded = state is OutForDeliveryPageLoaded
              ? (state as OutForDeliveryPageLoaded).isMapExpanded
              : false;

          return OutForDeliveryPageLoaded(
            orderId: data.orderId,
            rider: data.rider,
            currentStatus: data.currentStatus,
            estimatedTime: estimatedTime,
            distance: distanceStr,
            distanceKm: distanceKm,
            driverSpeed: data.driverSpeed,
            expectedDeliveryTime: expectedDeliveryTime,
            progressRatio: progressRatio,
            isArrivingSoon: isArrivingSoon,
            isRaining: data.isRaining,
            weatherAlert: data.weatherAlert,
            isMapExpanded: wasExpanded,
            riderLat: data.riderLat,
            riderLng: data.riderLng,
            riderHeading: data.riderHeading,
            sellerLat: data.sellerLat,
            sellerLng: data.sellerLng,
            sellerName: data.sellerName,
            sellerPhone: data.sellerPhone,
            sellerAddress: data.sellerAddress,
            customerLat: data.customerLat,
            customerLng: data.customerLng,
            customerName: data.customerName,
            customerPhone: data.customerPhone,
            customerId: data.customerId,
            customerNotes: data.customerNotes,
            deliveryAddress: data.deliveryAddress,
            totalAmount: data.totalAmount,
          );
        },
        onError: (error, stackTrace) {
          return const OutForDeliveryPageError(
              message: 'Failed to load delivery details.');
        },
      );
    } catch (e) {
      emit(const OutForDeliveryPageError(
          message: 'Failed to load delivery details.'));
    }
  }

  void _onToggleMapFullScreen(
      ToggleMapFullScreen event, Emitter<OutForDeliveryPageState> emit) {
    if (state is OutForDeliveryPageLoaded) {
      final loaded = state as OutForDeliveryPageLoaded;
      emit(loaded.copyWith(isMapExpanded: !loaded.isMapExpanded));
    }
  }

  Future<void> _onCallRider(
      CallRider event, Emitter<OutForDeliveryPageState> emit) async {
    final cleaned = event.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isNotEmpty) {
      final uri = Uri.parse('tel:$cleaned');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (_) {}
    }
  }

  Future<void> _onMessageRider(
      MessageRider event, Emitter<OutForDeliveryPageState> emit) async {}
}

class OutForDeliveryPageData {
  final String orderId;
  final RiderDetails rider;
  final DeliveryStatus currentStatus;
  final double? riderLat;
  final double? riderLng;
  final double riderHeading;
  final double? driverSpeed;
  final double? sellerLat;
  final double? sellerLng;
  final String sellerName;
  final String? sellerPhone;
  final String? sellerAddress;
  final double? customerLat;
  final double? customerLng;
  final String customerName;
  final String? customerPhone;
  final String? customerId;
  final String? customerNotes;
  final String deliveryAddress;
  final double? totalAmount;
  final bool isRaining;
  final String? weatherAlert;

  OutForDeliveryPageData({
    required this.orderId,
    required this.rider,
    required this.currentStatus,
    this.riderLat,
    this.riderLng,
    this.riderHeading = 0.0,
    this.driverSpeed,
    this.sellerLat,
    this.sellerLng,
    this.sellerName = 'My Kitchen',
    this.sellerPhone,
    this.sellerAddress,
    this.customerLat,
    this.customerLng,
    this.customerName = 'Customer',
    this.customerPhone,
    this.customerId,
    this.customerNotes,
    this.deliveryAddress = '',
    this.totalAmount,
    this.isRaining = false,
    this.weatherAlert,
  });
}

