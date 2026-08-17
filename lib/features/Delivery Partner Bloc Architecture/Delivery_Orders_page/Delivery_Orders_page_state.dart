import 'package:equatable/equatable.dart';

enum DeliveryOrdersPageStatus { initial, loading, loaded, error, empty }

enum DeliveryOrdersTab { all, active, pending, completed }

enum DeliveryOrderStatus { pending, active, completed, cancelled }

enum DeliveryOrdersSort { time, distance, amountHigh }

enum DeliveryOrdersPaymentFilter { all, cash, card, online }

class DeliveryOrderCardModel extends Equatable {
  final String orderId;
  final String customerName;
  final String restaurantName;
  final String pickupAddress;
  final String deliveryAddress;
  final double amount;
  final int itemsCount;
  final DeliveryOrderStatus status;
  final double distance;
  final String time;
  final String paymentType;
  final String phoneNumber;
  final int etaMins;
  final int lateMins;
  final bool priority;
  final double restaurantRating;
  final double expectedTip;
  final int preparationTimeMins;
  final double deliveryBonus;

  final String restaurantLocation;
  final String customerArea;
  final double estimatedEarnings;
  final double pickupDistance;
  final double deliveryDistance;
  final String sellerId;
  final String customerId;
  final String assignedTime;
  final String acceptedTime;
  final String assignmentStatus;
  final List<String> rejectedBy;
  final bool isAvailable;

  const DeliveryOrderCardModel({
    required this.orderId,
    required this.customerName,
    required this.restaurantName,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.amount,
    required this.itemsCount,
    required this.status,
    required this.distance,
    required this.time,
    required this.paymentType,
    this.phoneNumber = '',
    this.etaMins = 0,
    this.lateMins = 0,
    this.priority = false,
    this.restaurantRating = 0.0,
    this.expectedTip = 0.0,
    this.preparationTimeMins = 0,
    this.deliveryBonus = 0.0,
    this.restaurantLocation = '',
    this.customerArea = '',
    this.estimatedEarnings = 0.0,
    this.pickupDistance = 0.0,
    this.deliveryDistance = 0.0,
    this.sellerId = '',
    this.customerId = '',
    this.assignedTime = '',
    this.acceptedTime = '',
    this.assignmentStatus = '',
    this.rejectedBy = const [],
    this.isAvailable = false,
  });

  bool get isAvailableOrder =>
      isAvailable || assignmentStatus == 'available';

  String get displayRestaurantLocation =>
      restaurantLocation.isNotEmpty ? restaurantLocation : pickupAddress;

  String get displayCustomerArea =>
      customerArea.isNotEmpty ? customerArea : deliveryAddress;

  DeliveryOrderCardModel copyWith({
    DeliveryOrderStatus? status,
    String? restaurantLocation,
    String? customerArea,
    double? estimatedEarnings,
    double? pickupDistance,
    double? deliveryDistance,
    String? sellerId,
    String? customerId,
    String? assignedTime,
    String? acceptedTime,
    String? assignmentStatus,
    List<String>? rejectedBy,
    bool? isAvailable,
  }) {
    return DeliveryOrderCardModel(
      orderId: orderId,
      customerName: customerName,
      restaurantName: restaurantName,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      amount: amount,
      itemsCount: itemsCount,
      status: status ?? this.status,
      distance: distance,
      time: time,
      paymentType: paymentType,
      phoneNumber: phoneNumber,
      etaMins: etaMins,
      lateMins: lateMins,
      priority: priority,
      restaurantRating: restaurantRating,
      expectedTip: expectedTip,
      preparationTimeMins: preparationTimeMins,
      deliveryBonus: deliveryBonus,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      customerArea: customerArea ?? this.customerArea,
      estimatedEarnings: estimatedEarnings ?? this.estimatedEarnings,
      pickupDistance: pickupDistance ?? this.pickupDistance,
      deliveryDistance: deliveryDistance ?? this.deliveryDistance,
      sellerId: sellerId ?? this.sellerId,
      customerId: customerId ?? this.customerId,
      assignedTime: assignedTime ?? this.assignedTime,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      assignmentStatus: assignmentStatus ?? this.assignmentStatus,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        customerName,
        restaurantName,
        pickupAddress,
        deliveryAddress,
        amount,
        itemsCount,
        status,
        distance,
        time,
        paymentType,
        phoneNumber,
        etaMins,
        lateMins,
        priority,
        restaurantRating,
        expectedTip,
        preparationTimeMins,
        deliveryBonus,
        restaurantLocation,
        customerArea,
        estimatedEarnings,
        pickupDistance,
        deliveryDistance,
        sellerId,
        customerId,
        assignedTime,
        acceptedTime,
        assignmentStatus,
        rejectedBy,
        isAvailable,
      ];
}

class DeliveryOrdersPageState extends Equatable {
  static const double earningRate = 0.18;

  final DeliveryOrdersPageStatus status;
  final DeliveryOrdersTab activeTab;
  final String searchQuery;
  final DeliveryOrdersSort sortBy;
  final DeliveryOrdersPaymentFilter paymentFilter;
  final bool autoRefresh;
  final List<DeliveryOrderCardModel> orders;
  final List<DeliveryOrderCardModel> filteredOrders;
  final String? errorMessage;
  final String? notificationMessage;
  final String? acceptingOrderId;
  final String localeCode;

  const DeliveryOrdersPageState({
    this.status = DeliveryOrdersPageStatus.initial,
    this.activeTab = DeliveryOrdersTab.all,
    this.searchQuery = '',
    this.sortBy = DeliveryOrdersSort.time,
    this.paymentFilter = DeliveryOrdersPaymentFilter.all,
    this.autoRefresh = false,
    this.orders = const [],
    this.filteredOrders = const [],
    this.errorMessage,
    this.notificationMessage,
    this.acceptingOrderId,
    this.localeCode = 'en',
  });

  int get totalCount => orders.length;

  int get todayCount => totalCount;

  int get activeCount =>
      orders.where((o) => o.status == DeliveryOrderStatus.active).length;

  int get availableCount =>
      orders.where((o) => o.isAvailableOrder).length;

  int get pendingCount =>
      orders.where((o) => o.status == DeliveryOrderStatus.pending).length;

  int get completedCount =>
      orders.where((o) => o.status == DeliveryOrderStatus.completed).length;

  int get cancelledCount =>
      orders.where((o) => o.status == DeliveryOrderStatus.cancelled).length;

  int get acceptanceRate {
    final nonCancelled = totalCount - cancelledCount;
    if (totalCount == 0) return 0;
    return ((nonCancelled / totalCount) * 100).round();
  }

  int get averageDeliveryTimeMins {
    if (orders.isEmpty) return 0;
    final total =
        orders.fold<int>(0, (sum, o) => sum + (o.etaMins < 0 ? 0 : o.etaMins));
    return (total / orders.length).round();
  }

  double get averageRating {
    if (orders.isEmpty) return 0;
    final total = orders.fold<double>(
      0,
      (sum, o) => sum + (o.restaurantRating < 0 ? 0 : o.restaurantRating),
    );
    return (total / orders.length * 10).roundToDouble() / 10;
  }

  double get totalEarnings =>
      orders.fold<double>(0, (sum, o) => sum + o.amount * earningRate);

  bool get isEmpty => filteredOrders.isEmpty;

  DeliveryOrderCardModel? get activeOrder {
    for (final order in orders) {
      if (order.status == DeliveryOrderStatus.active) return order;
    }
    return null;
  }

  DeliveryOrdersPageState copyWith({
    DeliveryOrdersPageStatus? status,
    DeliveryOrdersTab? activeTab,
    String? searchQuery,
    DeliveryOrdersSort? sortBy,
    DeliveryOrdersPaymentFilter? paymentFilter,
    bool? autoRefresh,
    List<DeliveryOrderCardModel>? orders,
    List<DeliveryOrderCardModel>? filteredOrders,
    String? errorMessage,
    bool clearError = false,
    String? notificationMessage,
    bool clearNotification = false,
    String? acceptingOrderId,
    bool clearAcceptingOrderId = false,
    String? localeCode,
  }) {
    return DeliveryOrdersPageState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notificationMessage: clearNotification
          ? null
          : (notificationMessage ?? this.notificationMessage),
      acceptingOrderId: clearAcceptingOrderId
          ? null
          : (acceptingOrderId ?? this.acceptingOrderId),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        searchQuery,
        sortBy,
        paymentFilter,
        autoRefresh,
        orders,
        filteredOrders,
        errorMessage,
        notificationMessage,
        acceptingOrderId,
        localeCode,
      ];
}
