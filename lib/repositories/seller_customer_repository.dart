import 'dart:async';
import '../api_service/seller_customer_service.dart';
import '../features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';

class SellerCustomerRepository {
  final SellerCustomerService service;

  SellerCustomerRepository({required this.service});

  Stream<({CustomerStats stats, List<CustomerItem> customers})> watchCustomerData({
    String? sellerId,
  }) {
    return service.streamCustomerData(sellerId: sellerId).map((data) {
      final rawStats = (data['stats'] as Map<String, dynamic>?) ?? {};
      final rawCustomers = (data['customers'] as List<dynamic>?) ?? [];

      final stats = CustomerStats(
        totalCustomers: (rawStats['totalCustomers'] as num?)?.toInt() ?? 0,
        repeatCustomers: (rawStats['repeatCustomers'] as num?)?.toInt() ?? 0,
        totalRevenue: (rawStats['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        averageOrderValue: (rawStats['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      );

      final customers = rawCustomers
          .whereType<Map<String, dynamic>>()
          .map((m) => _mapToCustomerItem(m))
          .toList();

      return (stats: stats, customers: customers);
    });
  }

  Future<CustomerStats> getCustomerStats({String? sellerId}) async {
    final raw = await service.fetchCustomerStats(sellerId: sellerId);
    return CustomerStats(
      totalCustomers: (raw['totalCustomers'] as num?)?.toInt() ?? 0,
      repeatCustomers: (raw['repeatCustomers'] as num?)?.toInt() ?? 0,
      totalRevenue: (raw['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (raw['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<CustomerItem>> getCustomers({
    required int offset,
    required int limit,
    String? sellerId,
  }) async {
    final rawList = await service.fetchCustomerList(
      offset: offset,
      limit: limit,
      sellerId: sellerId,
    );
    return rawList.map((map) => _mapToCustomerItem(map)).toList();
  }

  CustomerItem _mapToCustomerItem(Map<String, dynamic> map) {
    // Map favourite products
    final rawFavs = (map['favouriteProducts'] as List<dynamic>?) ?? [];
    final favProducts = rawFavs.whereType<Map<String, dynamic>>().map((f) {
      return CustomerFavoriteProduct(
        productId: (f['productId'] ?? '').toString(),
        productName: (f['productName'] ?? 'Item').toString(),
        orderCount: (f['orderCount'] as num?)?.toInt() ?? 1,
        imageUrl: (f['imageUrl'] ?? '').toString(),
        price: (f['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    // Map order history
    final rawOrders = (map['orderHistory'] as List<dynamic>?) ?? [];
    final orderHistory = rawOrders.whereType<Map<String, dynamic>>().map((o) {
      return CustomerOrderSummary(
        orderId: (o['orderId'] ?? '').toString(),
        amount: (o['amount'] as num?)?.toDouble() ?? 0.0,
        status: (o['status'] ?? 'Completed').toString(),
        timestamp: o['timestamp'] is DateTime ? o['timestamp'] as DateTime : DateTime.now(),
        itemNames: (o['itemNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        itemsCount: (o['itemsCount'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    // Map reviews
    final rawReviews = (map['reviews'] as List<dynamic>?) ?? [];
    final reviews = rawReviews.whereType<Map<String, dynamic>>().map((r) {
      return CustomerReviewSummary(
        reviewId: (r['reviewId'] ?? '').toString(),
        rating: (r['rating'] as num?)?.toDouble() ?? 5.0,
        content: (r['content'] ?? '').toString(),
        createdAt: r['createdAt'] is DateTime ? r['createdAt'] as DateTime : DateTime.now(),
        productName: (r['productName'] ?? '').toString(),
      );
    }).toList();

    // Map last order items
    final lastItems = (map['lastOrderItems'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return CustomerItem(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      orderCount: (map['orderCount'] as num?)?.toInt() ?? 0,
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      rawPhone: (map['rawPhone'] ?? '').toString(),
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      lastOrderDate: map['lastOrderTime'] is DateTime
          ? map['lastOrderTime'] as DateTime
          : (map['lastOrderDate'] is DateTime ? map['lastOrderDate'] as DateTime : null),
      lastOrderId: map['lastOrderId'] as String?,
      lastOrderStatus: map['lastOrderStatus'] as String?,
      lastOrderAmount: (map['lastOrderAmount'] as num?)?.toDouble(),
      lastOrderItems: lastItems,
      favouriteProducts: favProducts,
      orderHistory: orderHistory,
      reviews: reviews,
      averageRating: (map['averageRating'] as num?)?.toDouble(),
    );
  }
}
