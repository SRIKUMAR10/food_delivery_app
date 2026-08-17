import 'package:equatable/equatable.dart';

enum CustomerSortOption {
  mostOrders,
  highestSpending,
  recentOrder,
  nameAsc,
}

class CustomerFavoriteProduct extends Equatable {
  final String productId;
  final String productName;
  final int orderCount;
  final String imageUrl;
  final double price;

  const CustomerFavoriteProduct({
    required this.productId,
    required this.productName,
    required this.orderCount,
    this.imageUrl = '',
    this.price = 0.0,
  });

  @override
  List<Object?> get props => [productId, productName, orderCount, imageUrl, price];
}

class CustomerOrderSummary extends Equatable {
  final String orderId;
  final double amount;
  final String status;
  final DateTime timestamp;
  final List<String> itemNames;
  final int itemsCount;

  const CustomerOrderSummary({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.itemNames = const [],
    this.itemsCount = 0,
  });

  @override
  List<Object?> get props => [orderId, amount, status, timestamp, itemNames, itemsCount];
}

class CustomerReviewSummary extends Equatable {
  final String reviewId;
  final double rating;
  final String content;
  final DateTime createdAt;
  final String productName;

  const CustomerReviewSummary({
    required this.reviewId,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.productName = '',
  });

  @override
  List<Object?> get props => [reviewId, rating, content, createdAt, productName];
}

class CustomerItem extends Equatable {
  final String id;
  final String name;
  final int orderCount;
  final String avatarUrl;
  final String phone;
  final String rawPhone;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final String? lastOrderId;
  final String? lastOrderStatus;
  final double? lastOrderAmount;
  final List<String> lastOrderItems;
  final List<CustomerFavoriteProduct> favouriteProducts;
  final List<CustomerOrderSummary> orderHistory;
  final List<CustomerReviewSummary> reviews;
  final double? averageRating;

  const CustomerItem({
    required this.id,
    required this.name,
    required this.orderCount,
    required this.avatarUrl,
    this.phone = '',
    this.rawPhone = '',
    this.totalSpent = 0.0,
    this.lastOrderDate,
    this.lastOrderId,
    this.lastOrderStatus,
    this.lastOrderAmount,
    this.lastOrderItems = const [],
    this.favouriteProducts = const [],
    this.orderHistory = const [],
    this.reviews = const [],
    this.averageRating,
  });

  CustomerItem copyWith({
    String? id,
    String? name,
    int? orderCount,
    String? avatarUrl,
    String? phone,
    String? rawPhone,
    double? totalSpent,
    DateTime? lastOrderDate,
    String? lastOrderId,
    String? lastOrderStatus,
    double? lastOrderAmount,
    List<String>? lastOrderItems,
    List<CustomerFavoriteProduct>? favouriteProducts,
    List<CustomerOrderSummary>? orderHistory,
    List<CustomerReviewSummary>? reviews,
    double? averageRating,
  }) {
    return CustomerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      orderCount: orderCount ?? this.orderCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      rawPhone: rawPhone ?? this.rawPhone,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      lastOrderId: lastOrderId ?? this.lastOrderId,
      lastOrderStatus: lastOrderStatus ?? this.lastOrderStatus,
      lastOrderAmount: lastOrderAmount ?? this.lastOrderAmount,
      lastOrderItems: lastOrderItems ?? this.lastOrderItems,
      favouriteProducts: favouriteProducts ?? this.favouriteProducts,
      orderHistory: orderHistory ?? this.orderHistory,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        orderCount,
        avatarUrl,
        phone,
        rawPhone,
        totalSpent,
        lastOrderDate,
        lastOrderId,
        lastOrderStatus,
        lastOrderAmount,
        lastOrderItems,
        favouriteProducts,
        orderHistory,
        reviews,
        averageRating,
      ];
}

class CustomerStats extends Equatable {
  final int totalCustomers;
  final int repeatCustomers;
  final double totalRevenue;
  final double averageOrderValue;

  const CustomerStats({
    required this.totalCustomers,
    required this.repeatCustomers,
    this.totalRevenue = 0.0,
    this.averageOrderValue = 0.0,
  });

  @override
  List<Object?> get props => [totalCustomers, repeatCustomers, totalRevenue, averageOrderValue];
}

abstract class SellerCustomerState extends Equatable {
  const SellerCustomerState();

  @override
  List<Object?> get props => [];
}

class SellerCustomerInitial extends SellerCustomerState {
  const SellerCustomerInitial();
}

class SellerCustomerLoading extends SellerCustomerState {
  const SellerCustomerLoading();
}

class SellerCustomerLoaded extends SellerCustomerState {
  final CustomerStats stats;
  final List<CustomerItem> customers;
  final List<CustomerItem> filteredCustomers;
  final String searchQuery;
  final CustomerSortOption selectedSort;
  final CustomerItem? selectedCustomer;
  final bool hasReachedMax;
  final bool isPaginatedLoading;

  const SellerCustomerLoaded({
    required this.stats,
    required this.customers,
    List<CustomerItem>? filteredCustomers,
    this.searchQuery = '',
    this.selectedSort = CustomerSortOption.mostOrders,
    this.selectedCustomer,
    this.hasReachedMax = false,
    this.isPaginatedLoading = false,
  }) : filteredCustomers = filteredCustomers ?? customers;

  SellerCustomerLoaded copyWith({
    CustomerStats? stats,
    List<CustomerItem>? customers,
    List<CustomerItem>? filteredCustomers,
    String? searchQuery,
    CustomerSortOption? selectedSort,
    CustomerItem? selectedCustomer,
    bool clearSelectedCustomer = false,
    bool? hasReachedMax,
    bool? isPaginatedLoading,
  }) {
    return SellerCustomerLoaded(
      stats: stats ?? this.stats,
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSort: selectedSort ?? this.selectedSort,
      selectedCustomer: clearSelectedCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginatedLoading: isPaginatedLoading ?? this.isPaginatedLoading,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        customers,
        filteredCustomers,
        searchQuery,
        selectedSort,
        selectedCustomer,
        hasReachedMax,
        isPaginatedLoading,
      ];
}

class SellerCustomerError extends SellerCustomerState {
  final String message;

  const SellerCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
