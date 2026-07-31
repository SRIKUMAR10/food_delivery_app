import 'package:equatable/equatable.dart';

enum DeliveryCompletedStatus { initial, loading, success, completed, error, empty }

enum DeliveryProofUploadStatus { idle, uploading, uploaded, failed }

class DeliveryCompletedModel extends Equatable {
  final String orderId;
  final double walletBalance;
  final String partnerName;
  final String partnerVehicleNo;
  final String customerName;
  final String deliveryAddress;
  final String timeTaken;
  final double distanceCovered;
  final String paymentStatus;
  final String paymentMethod;
  final double customerRating;
  final double deliveryEarnings;
  final String completedAt;

  const DeliveryCompletedModel({
    required this.orderId,
    required this.walletBalance,
    required this.partnerName,
    required this.partnerVehicleNo,
    required this.customerName,
    required this.deliveryAddress,
    required this.timeTaken,
    required this.distanceCovered,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.customerRating,
    required this.deliveryEarnings,
    required this.completedAt,
  });

  DeliveryCompletedModel copyWith({
    String? orderId,
    double? walletBalance,
    String? partnerName,
    String? partnerVehicleNo,
    String? customerName,
    String? deliveryAddress,
    String? timeTaken,
    double? distanceCovered,
    String? paymentStatus,
    String? paymentMethod,
    double? customerRating,
    double? deliveryEarnings,
    String? completedAt,
  }) {
    return DeliveryCompletedModel(
      orderId: orderId ?? this.orderId,
      walletBalance: walletBalance ?? this.walletBalance,
      partnerName: partnerName ?? this.partnerName,
      partnerVehicleNo: partnerVehicleNo ?? this.partnerVehicleNo,
      customerName: customerName ?? this.customerName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      timeTaken: timeTaken ?? this.timeTaken,
      distanceCovered: distanceCovered ?? this.distanceCovered,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerRating: customerRating ?? this.customerRating,
      deliveryEarnings: deliveryEarnings ?? this.deliveryEarnings,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        walletBalance,
        partnerName,
        partnerVehicleNo,
        customerName,
        deliveryAddress,
        timeTaken,
        distanceCovered,
        paymentStatus,
        paymentMethod,
        customerRating,
        deliveryEarnings,
        completedAt,
      ];
}

class DeliveryCompletedPageState extends Equatable {
  final DeliveryCompletedStatus status;
  final DeliveryCompletedModel? model;
  final String? errorMessage;
  final double proofUploadProgress;
  final DeliveryProofUploadStatus proofUploadStatus;
  final int? ratedScore;
  final bool ratingSubmitted;
  final bool isCompleting;
  final String localeCode;

  const DeliveryCompletedPageState({
    this.status = DeliveryCompletedStatus.initial,
    this.model,
    this.errorMessage,
    this.proofUploadProgress = 0.0,
    this.proofUploadStatus = DeliveryProofUploadStatus.idle,
    this.ratedScore,
    this.ratingSubmitted = false,
    this.isCompleting = false,
    this.localeCode = 'en',
  });

  bool get isUploading =>
      proofUploadStatus == DeliveryProofUploadStatus.uploading;

  bool get isProofUploaded =>
      proofUploadStatus == DeliveryProofUploadStatus.uploaded;

  DeliveryCompletedPageState copyWith({
    DeliveryCompletedStatus? status,
    DeliveryCompletedModel? model,
    bool clearModel = false,
    String? errorMessage,
    bool clearError = false,
    double? proofUploadProgress,
    DeliveryProofUploadStatus? proofUploadStatus,
    int? ratedScore,
    bool clearRatedScore = false,
    bool? ratingSubmitted,
    bool? isCompleting,
    String? localeCode,
  }) {
    return DeliveryCompletedPageState(
      status: status ?? this.status,
      model: clearModel ? null : (model ?? this.model),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      proofUploadProgress: proofUploadProgress ?? this.proofUploadProgress,
      proofUploadStatus: proofUploadStatus ?? this.proofUploadStatus,
      ratedScore: clearRatedScore ? null : (ratedScore ?? this.ratedScore),
      ratingSubmitted: ratingSubmitted ?? this.ratingSubmitted,
      isCompleting: isCompleting ?? this.isCompleting,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        model,
        errorMessage,
        proofUploadProgress,
        proofUploadStatus,
        ratedScore,
        ratingSubmitted,
        isCompleting,
        localeCode,
      ];
}
