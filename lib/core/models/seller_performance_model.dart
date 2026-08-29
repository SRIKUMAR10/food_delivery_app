import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SellerPerformanceSummaryModel extends Equatable {
  final double todayRevenue;
  final int todayOrdersCount;
  final int todayCompletedCount;
  final int todayCancelledCount;
  final double thisWeekRevenue;
  final double thisMonthRevenue;
  final double thisYearRevenue;
  final double averageOrderValue;
  final int averagePrepTimeMinutes;
  final double customerRetentionRate;
  final int totalReviewsCount;
  final double averageStoreRating;
  final Map<String, int> popularHours;
  final DateTime? updatedAt;

  const SellerPerformanceSummaryModel({
    this.todayRevenue = 0.0,
    this.todayOrdersCount = 0,
    this.todayCompletedCount = 0,
    this.todayCancelledCount = 0,
    this.thisWeekRevenue = 0.0,
    this.thisMonthRevenue = 0.0,
    this.thisYearRevenue = 0.0,
    this.averageOrderValue = 0.0,
    this.averagePrepTimeMinutes = 20,
    this.customerRetentionRate = 0.0,
    this.totalReviewsCount = 0,
    this.averageStoreRating = 5.0,
    this.popularHours = const {},
    this.updatedAt,
  });

  factory SellerPerformanceSummaryModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const SellerPerformanceSummaryModel();

    DateTime? parsedUpdatedAt;
    final rawDate = data['updatedAt'];
    if (rawDate is Timestamp) {
      parsedUpdatedAt = rawDate.toDate();
    } else if (rawDate is String) {
      parsedUpdatedAt = DateTime.tryParse(rawDate);
    }

    Map<String, int> parsedPopularHours = {};
    if (data['popularHours'] is Map) {
      (data['popularHours'] as Map).forEach((key, value) {
        if (value is num) {
          parsedPopularHours[key.toString()] = value.toInt();
        }
      });
    }

    return SellerPerformanceSummaryModel(
      todayRevenue: (data['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      todayOrdersCount: (data['todayOrdersCount'] as num?)?.toInt() ?? 0,
      todayCompletedCount: (data['todayCompletedCount'] as num?)?.toInt() ?? 0,
      todayCancelledCount: (data['todayCancelledCount'] as num?)?.toInt() ?? 0,
      thisWeekRevenue: (data['thisWeekRevenue'] as num?)?.toDouble() ?? 0.0,
      thisMonthRevenue: (data['thisMonthRevenue'] as num?)?.toDouble() ?? 0.0,
      thisYearRevenue: (data['thisYearRevenue'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (data['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      averagePrepTimeMinutes:
          (data['averagePrepTimeMinutes'] as num?)?.toInt() ?? 20,
      customerRetentionRate:
          (data['customerRetentionRate'] as num?)?.toDouble() ?? 0.0,
      totalReviewsCount: (data['totalReviewsCount'] as num?)?.toInt() ?? 0,
      averageStoreRating: (data['averageStoreRating'] as num?)?.toDouble() ?? 5.0,
      popularHours: parsedPopularHours,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'todayRevenue': todayRevenue,
      'todayOrdersCount': todayOrdersCount,
      'todayCompletedCount': todayCompletedCount,
      'todayCancelledCount': todayCancelledCount,
      'thisWeekRevenue': thisWeekRevenue,
      'thisMonthRevenue': thisMonthRevenue,
      'thisYearRevenue': thisYearRevenue,
      'averageOrderValue': averageOrderValue,
      'averagePrepTimeMinutes': averagePrepTimeMinutes,
      'customerRetentionRate': customerRetentionRate,
      'totalReviewsCount': totalReviewsCount,
      'averageStoreRating': averageStoreRating,
      'popularHours': popularHours,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  SellerPerformanceSummaryModel copyWith({
    double? todayRevenue,
    int? todayOrdersCount,
    int? todayCompletedCount,
    int? todayCancelledCount,
    double? thisWeekRevenue,
    double? thisMonthRevenue,
    double? thisYearRevenue,
    double? averageOrderValue,
    int? averagePrepTimeMinutes,
    double? customerRetentionRate,
    int? totalReviewsCount,
    double? averageStoreRating,
    Map<String, int>? popularHours,
    DateTime? updatedAt,
  }) {
    return SellerPerformanceSummaryModel(
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      todayCompletedCount: todayCompletedCount ?? this.todayCompletedCount,
      todayCancelledCount: todayCancelledCount ?? this.todayCancelledCount,
      thisWeekRevenue: thisWeekRevenue ?? this.thisWeekRevenue,
      thisMonthRevenue: thisMonthRevenue ?? this.thisMonthRevenue,
      thisYearRevenue: thisYearRevenue ?? this.thisYearRevenue,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      averagePrepTimeMinutes:
          averagePrepTimeMinutes ?? this.averagePrepTimeMinutes,
      customerRetentionRate:
          customerRetentionRate ?? this.customerRetentionRate,
      totalReviewsCount: totalReviewsCount ?? this.totalReviewsCount,
      averageStoreRating: averageStoreRating ?? this.averageStoreRating,
      popularHours: popularHours ?? this.popularHours,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        todayRevenue,
        todayOrdersCount,
        todayCompletedCount,
        todayCancelledCount,
        thisWeekRevenue,
        thisMonthRevenue,
        thisYearRevenue,
        averageOrderValue,
        averagePrepTimeMinutes,
        customerRetentionRate,
        totalReviewsCount,
        averageStoreRating,
        popularHours,
        updatedAt,
      ];
}
