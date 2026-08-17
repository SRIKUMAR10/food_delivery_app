import 'package:equatable/equatable.dart';

enum DeliveryOrderHistoryPageStatus { initial, loading, loaded, empty, error }

enum DeliveryOrderHistoryStatus { completed, pending, cancelled }

enum DeliveryOrderHistoryStatusFilter { all, completed, pending, cancelled }

enum DeliveryOrderHistoryPaymentFilter { all, cod, online }

enum DeliveryOrderHistoryDatePreset {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  custom,
}

class DeliveryOrderHistoryModel extends Equatable {
  final String orderId;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerArea;
  final String phoneNumber;
  final String pickupAddress;
  final String dropAddress;
  final String deliveryDate;
  final String deliveryTime;
  final String dateLabel;
  final int epochSeconds;
  final double distanceKm;
  final double amount;
  final DeliveryOrderHistoryStatus status;
  final String paymentType;

  const DeliveryOrderHistoryModel({
    required this.orderId,
    String? restaurantName,
    String? restaurantAddress,
    required this.customerName,
    String? customerArea,
    required this.phoneNumber,
    required this.pickupAddress,
    required this.dropAddress,
    String? deliveryDate,
    String? deliveryTime,
    required this.dateLabel,
    required this.epochSeconds,
    required this.distanceKm,
    required this.amount,
    required this.status,
    this.paymentType = 'COD',
  })  : restaurantName = restaurantName ?? pickupAddress,
        restaurantAddress = restaurantAddress ?? pickupAddress,
        customerArea = customerArea ?? dropAddress,
        deliveryDate = deliveryDate ?? dateLabel,
        deliveryTime = deliveryTime ?? '';

  DeliveryOrderHistoryModel copyWith({
    String? orderId,
    String? restaurantName,
    String? restaurantAddress,
    String? customerName,
    String? customerArea,
    String? phoneNumber,
    String? pickupAddress,
    String? dropAddress,
    String? deliveryDate,
    String? deliveryTime,
    String? dateLabel,
    int? epochSeconds,
    double? distanceKm,
    double? amount,
    DeliveryOrderHistoryStatus? status,
    String? paymentType,
  }) {
    return DeliveryOrderHistoryModel(
      orderId: orderId ?? this.orderId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      customerName: customerName ?? this.customerName,
      customerArea: customerArea ?? this.customerArea,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      dateLabel: dateLabel ?? this.dateLabel,
      epochSeconds: epochSeconds ?? this.epochSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        restaurantName,
        restaurantAddress,
        customerName,
        customerArea,
        phoneNumber,
        pickupAddress,
        dropAddress,
        deliveryDate,
        deliveryTime,
        dateLabel,
        epochSeconds,
        distanceKm,
        amount,
        status,
        paymentType,
      ];
}

class DeliveryOrderHistoryStats extends Equatable {
  final int totalOrders;
  final int completedCount;
  final int cancelledCount;
  final int pendingCount;
  final double totalEarnings;
  final double totalOrdersDelta;
  final double earningsDelta;

  const DeliveryOrderHistoryStats({
    required this.totalOrders,
    required this.completedCount,
    required this.cancelledCount,
    required this.pendingCount,
    required this.totalEarnings,
    this.totalOrdersDelta = 0.0,
    this.earningsDelta = 0.0,
  });

  double get completedPercent =>
      totalOrders == 0 ? 0 : (completedCount / totalOrders * 100);

  double get cancelledPercent =>
      totalOrders == 0 ? 0 : (cancelledCount / totalOrders * 100);

  double get pendingPercent =>
      totalOrders == 0 ? 0 : (pendingCount / totalOrders * 100);

  @override
  List<Object?> get props => [
        totalOrders,
        completedCount,
        cancelledCount,
        pendingCount,
        totalEarnings,
        totalOrdersDelta,
        earningsDelta,
      ];
}

class DeliveryOrderHistoryPageState extends Equatable {
  final DeliveryOrderHistoryPageStatus status;
  final List<DeliveryOrderHistoryModel> orders;
  final List<DeliveryOrderHistoryModel> filteredOrders;
  final List<DeliveryOrderHistoryModel> pageOrders;
  final DeliveryOrderHistoryStats stats;
  final String searchQuery;
  final DeliveryOrderHistoryStatusFilter statusFilter;
  final DeliveryOrderHistoryPaymentFilter paymentFilter;
  final DeliveryOrderHistoryDatePreset datePreset;
  final int? startEpoch;
  final int? endEpoch;
  final String dateLabel;
  final int page;
  final int pageSize;
  final bool sidebarOpen;
  final String? errorMessage;
  final String localeCode;

  const DeliveryOrderHistoryPageState({
    this.status = DeliveryOrderHistoryPageStatus.initial,
    this.orders = const [],
    this.filteredOrders = const [],
    this.pageOrders = const [],
    this.stats = const DeliveryOrderHistoryStats(
      totalOrders: 0,
      completedCount: 0,
      cancelledCount: 0,
      pendingCount: 0,
      totalEarnings: 0,
    ),
    this.searchQuery = '',
    this.statusFilter = DeliveryOrderHistoryStatusFilter.all,
    this.paymentFilter = DeliveryOrderHistoryPaymentFilter.all,
    this.datePreset = DeliveryOrderHistoryDatePreset.all,
    this.startEpoch,
    this.endEpoch,
    this.dateLabel = '',
    this.page = 1,
    this.pageSize = 10,
    this.sidebarOpen = true,
    this.errorMessage,
    this.localeCode = 'en',
  });

  int get totalPages {
    if (filteredOrders.isEmpty) return 1;
    return (filteredOrders.length / pageSize).ceil();
  }

  int get totalFiltered => filteredOrders.length;

  int get visibleStart {
    if (filteredOrders.isEmpty) return 0;
    return (page - 1) * pageSize + 1;
  }

  int get visibleEnd {
    final end = page * pageSize;
    return end > filteredOrders.length ? filteredOrders.length : end;
  }

  bool get isEmpty => filteredOrders.isEmpty;

  DeliveryOrderHistoryPageState copyWith({
    DeliveryOrderHistoryPageStatus? status,
    List<DeliveryOrderHistoryModel>? orders,
    List<DeliveryOrderHistoryModel>? filteredOrders,
    List<DeliveryOrderHistoryModel>? pageOrders,
    DeliveryOrderHistoryStats? stats,
    String? searchQuery,
    DeliveryOrderHistoryStatusFilter? statusFilter,
    DeliveryOrderHistoryPaymentFilter? paymentFilter,
    DeliveryOrderHistoryDatePreset? datePreset,
    int? startEpoch,
    int? endEpoch,
    bool clearDateRange = false,
    String? dateLabel,
    int? page,
    int? pageSize,
    bool? sidebarOpen,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
  }) {
    return DeliveryOrderHistoryPageState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      pageOrders: pageOrders ?? this.pageOrders,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      datePreset: datePreset ?? this.datePreset,
      startEpoch: clearDateRange ? null : (startEpoch ?? this.startEpoch),
      endEpoch: clearDateRange ? null : (endEpoch ?? this.endEpoch),
      dateLabel: dateLabel ?? this.dateLabel,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sidebarOpen: sidebarOpen ?? this.sidebarOpen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        filteredOrders,
        pageOrders,
        stats,
        searchQuery,
        statusFilter,
        paymentFilter,
        datePreset,
        startEpoch,
        endEpoch,
        dateLabel,
        page,
        pageSize,
        sidebarOpen,
        errorMessage,
        localeCode,
      ];
}
