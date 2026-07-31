import 'dart:async';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersServiceBase {
  Future<Map<String, dynamic>> fetchOrdersData();
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  });
  String formatCurrency(double amount, String localeCode);
  String formatDistance(double distance);
  double calculateEarnings(double orderAmount);
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status);
  int getAcceptanceRate();
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
}

class DeliveryOrdersService implements DeliveryOrdersServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'ORDERS_URL': 'https://api.fooddelivery.example/v1/delivery/orders',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  static const double _earningRate = 0.18;

  @override
  Future<Map<String, dynamic>> fetchOrdersData() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return {
      'orders': [
        {
          'orderId': 'ORD12345',
          'customerName': 'Priya Sharma',
          'restaurantName': 'Green Bowl Kitchen',
          'pickupAddress': '42 Anna Salai, Chennai',
          'deliveryAddress': '21 MG Road, Velachery',
          'amount': 486.50,
          'itemsCount': 3,
          'status': 'pending',
          'distance': 2.4,
          'time': '10:30 AM',
          'paymentType': 'Cash',
          'phoneNumber': '9840112233',
          'etaMins': 18,
          'lateMins': 0,
          'priority': false,
          'restaurantRating': 4.5,
          'expectedTip': 20.0,
          'preparationTimeMins': 12,
          'deliveryBonus': 10.0,
        },
        {
          'orderId': 'ORD12346',
          'customerName': 'Arun Prakash',
          'restaurantName': 'Spice Route',
          'pickupAddress': '108 Greams Road, Nungambakkam',
          'deliveryAddress': '7 Lake View Road, Adyar',
          'amount': 732.00,
          'itemsCount': 4,
          'status': 'active',
          'distance': 4.1,
          'time': '10:42 AM',
          'paymentType': 'Card',
          'phoneNumber': '9884499001',
          'etaMins': 12,
          'lateMins': 0,
          'priority': true,
          'restaurantRating': 4.7,
          'expectedTip': 30.0,
          'preparationTimeMins': 15,
          'deliveryBonus': 15.0,
        },
        {
          'orderId': 'ORD12347',
          'customerName': 'Meena Krishnan',
          'restaurantName': 'The Pasta Lab',
          'pickupAddress': '15 Cathedral Road',
          'deliveryAddress': '33 Besant Nagar Main Road',
          'amount': 1204.75,
          'itemsCount': 6,
          'status': 'active',
          'distance': 5.8,
          'time': '11:05 AM',
          'paymentType': 'Online',
          'phoneNumber': '9790933445',
          'etaMins': 20,
          'lateMins': 3,
          'priority': false,
          'restaurantRating': 4.2,
          'expectedTip': 25.0,
          'preparationTimeMins': 20,
          'deliveryBonus': 0.0,
        },
        {
          'orderId': 'ORD12348',
          'customerName': 'Karthik Raja',
          'restaurantName': 'Sunrise Tiffins',
          'pickupAddress': '2 T Nagar 3rd Main Road',
          'deliveryAddress': '19 Ashok Nagar 1st Avenue',
          'amount': 245.00,
          'itemsCount': 2,
          'status': 'pending',
          'distance': 1.2,
          'time': '11:20 AM',
          'paymentType': 'Cash',
          'phoneNumber': '9003112220',
          'etaMins': 10,
          'lateMins': 0,
          'priority': false,
          'restaurantRating': 4.4,
          'expectedTip': 10.0,
          'preparationTimeMins': 8,
          'deliveryBonus': 5.0,
        },
        {
          'orderId': 'ORD12349',
          'customerName': 'Divya Nair',
          'restaurantName': 'Coastal Bites',
          'pickupAddress': '77 EC Road, Sholinganallur',
          'deliveryAddress': '5 Old Mahabalipuram Road',
          'amount': 1890.00,
          'itemsCount': 5,
          'status': 'completed',
          'distance': 6.4,
          'time': '09:15 AM',
          'paymentType': 'Card',
          'phoneNumber': '9677008812',
          'etaMins': 0,
          'lateMins': 0,
          'priority': false,
          'restaurantRating': 4.8,
          'expectedTip': 50.0,
          'preparationTimeMins': 18,
          'deliveryBonus': 20.0,
        },
        {
          'orderId': 'ORD12350',
          'customerName': 'Suresh Babu',
          'restaurantName': 'Urban Dosa Co.',
          'pickupAddress': '11 Ranganathan Street',
          'deliveryAddress': '44 West Mambalam Main Road',
          'amount': 318.00,
          'itemsCount': 2,
          'status': 'completed',
          'distance': 3.0,
          'time': '08:50 AM',
          'paymentType': 'Online',
          'phoneNumber': '9444003322',
          'etaMins': 0,
          'lateMins': 0,
          'priority': false,
          'restaurantRating': 4.1,
          'expectedTip': 15.0,
          'preparationTimeMins': 10,
          'deliveryBonus': 5.0,
        },
        {
          'orderId': 'ORD12351',
          'customerName': 'Lakshmi Menon',
          'restaurantName': 'Burger Junction',
          'pickupAddress': '90 Nungambakkam High Road',
          'deliveryAddress': '12 Royapettah 2nd Cross Street',
          'amount': 540.25,
          'itemsCount': 3,
          'status': 'completed',
          'distance': 2.7,
          'time': '08:25 AM',
          'paymentType': 'Card',
          'phoneNumber': '9092765152',
          'etaMins': 0,
          'lateMins': 0,
          'priority': true,
          'restaurantRating': 4.6,
          'expectedTip': 20.0,
          'preparationTimeMins': 14,
          'deliveryBonus': 10.0,
        },
        {
          'orderId': 'ORD12352',
          'customerName': 'Vikram Seth',
          'restaurantName': 'Biryani House',
          'pickupAddress': '5 Velachery Bypass Road',
          'deliveryAddress': '28 Perungudi Main Road',
          'amount': 869.00,
          'itemsCount': 4,
          'status': 'pending',
          'distance': 3.9,
          'time': '11:35 AM',
          'paymentType': 'Cash',
          'phoneNumber': '9445556677',
          'etaMins': 25,
          'lateMins': 0,
          'priority': false,
          'restaurantRating': 4.3,
          'expectedTip': 35.0,
          'preparationTimeMins': 22,
          'deliveryBonus': 15.0,
        },
      ],
    };
  }

  @override
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  }) {
    final List<DeliveryOrderCardModel> tabFiltered;
    switch (tab) {
      case DeliveryOrdersTab.active:
        tabFiltered = orders
            .where((o) => o.status == DeliveryOrderStatus.active)
            .toList();
      case DeliveryOrdersTab.pending:
        tabFiltered = orders
            .where((o) => o.status == DeliveryOrderStatus.pending)
            .toList();
      case DeliveryOrdersTab.completed:
        tabFiltered = orders
            .where((o) => o.status == DeliveryOrderStatus.completed)
            .toList();
      case DeliveryOrdersTab.all:
        tabFiltered = List<DeliveryOrderCardModel>.of(orders);
    }

    final List<DeliveryOrderCardModel> paymentFiltered;
    switch (paymentFilter) {
      case DeliveryOrdersPaymentFilter.all:
        paymentFiltered = tabFiltered;
      case DeliveryOrdersPaymentFilter.cash:
        paymentFiltered = tabFiltered
            .where((o) => o.paymentType.toLowerCase() == 'cash')
            .toList();
      case DeliveryOrdersPaymentFilter.card:
        paymentFiltered = tabFiltered
            .where((o) => o.paymentType.toLowerCase() == 'card')
            .toList();
      case DeliveryOrdersPaymentFilter.online:
        paymentFiltered = tabFiltered
            .where((o) => o.paymentType.toLowerCase() == 'online')
            .toList();
    }

    final trimmed = query.trim().toLowerCase();
    List<DeliveryOrderCardModel> queryFiltered;
    if (trimmed.isEmpty) {
      queryFiltered = paymentFiltered;
    } else {
      queryFiltered = paymentFiltered.where((o) {
        return o.orderId.toLowerCase().contains(trimmed) ||
            o.customerName.toLowerCase().contains(trimmed) ||
            o.restaurantName.toLowerCase().contains(trimmed) ||
            o.phoneNumber.toLowerCase().contains(trimmed);
      }).toList();
    }

    switch (sortBy) {
      case DeliveryOrdersSort.time:
        return queryFiltered;
      case DeliveryOrdersSort.distance:
        return List<DeliveryOrderCardModel>.of(queryFiltered)
          ..sort((a, b) => a.distance.compareTo(b.distance));
      case DeliveryOrdersSort.amountHigh:
        return List<DeliveryOrderCardModel>.of(queryFiltered)
          ..sort((a, b) => b.amount.compareTo(a.amount));
    }
  }

  @override
  String formatCurrency(double amount, String localeCode) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }

  @override
  double calculateEarnings(double orderAmount) {
    return orderAmount * _earningRate;
  }

  @override
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return DeliveryOrderStatus.active;
      case DeliveryOrderStatus.active:
        return DeliveryOrderStatus.completed;
      default:
        return null;
    }
  }

  @override
  int getAcceptanceRate() => 92;

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
