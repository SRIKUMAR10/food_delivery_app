import 'package:equatable/equatable.dart';

enum DeliveryOrderHistoryPageStatus { initial, loading, loaded, empty, error }

enum DeliveryOrderHistoryStatus { completed, pending, cancelled }

enum DeliveryOrderHistoryStatusFilter { all, completed, pending, cancelled }

enum DeliveryOrderHistoryPaymentFilter { all, cod, online }

class DeliveryOrderHistoryModel extends Equatable {
  final String orderId;
  final String customerName;
  final String phoneNumber;
  final String pickupAddress;
  final String dropAddress;
  final String dateLabel;
  final int epochSeconds;
  final double distanceKm;
  final double amount;
  final DeliveryOrderHistoryStatus status;
  final String paymentType;

  const DeliveryOrderHistoryModel({
    required this.orderId,
    required this.customerName,
    required this.phoneNumber,
    required this.pickupAddress,
    required this.dropAddress,
    required this.dateLabel,
    required this.epochSeconds,
    required this.distanceKm,
    required this.amount,
    required this.status,
    this.paymentType = 'COD',
  });

  DeliveryOrderHistoryModel copyWith({
    DeliveryOrderHistoryStatus? status,
  }) {
    return DeliveryOrderHistoryModel(
      orderId: orderId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      dateLabel: dateLabel,
      epochSeconds: epochSeconds,
      distanceKm: distanceKm,
      amount: amount,
      status: status ?? this.status,
      paymentType: paymentType,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        customerName,
        phoneNumber,
        pickupAddress,
        dropAddress,
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
    this.startEpoch,
    this.endEpoch,
    this.dateLabel = 'May 18, 2025 - May 24, 2025',
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
