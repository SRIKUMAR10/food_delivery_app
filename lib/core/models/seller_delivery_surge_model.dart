import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DeliverySurgeSettingsModel extends Equatable {
  final bool isSurgeActive;
  final String surgeReason; // 'heavy_rain', 'festival_rush', 'traffic', 'manual'
  final double surgeDeliveryMultiplier;
  final int extraPrepTimeMinutes;
  final DateTime? autoDisableAt;
  final DateTime? updatedAt;

  const DeliverySurgeSettingsModel({
    this.isSurgeActive = false,
    this.surgeReason = 'manual',
    this.surgeDeliveryMultiplier = 1.0,
    this.extraPrepTimeMinutes = 0,
    this.autoDisableAt,
    this.updatedAt,
  });

  factory DeliverySurgeSettingsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const DeliverySurgeSettingsModel();

    DateTime? parsedAutoDisableAt;
    final rawDisable = data['autoDisableAt'];
    if (rawDisable is Timestamp) {
      parsedAutoDisableAt = rawDisable.toDate();
    } else if (rawDisable is String) {
      parsedAutoDisableAt = DateTime.tryParse(rawDisable);
    }

    DateTime? parsedUpdatedAt;
    final rawDate = data['updatedAt'];
    if (rawDate is Timestamp) {
      parsedUpdatedAt = rawDate.toDate();
    } else if (rawDate is String) {
      parsedUpdatedAt = DateTime.tryParse(rawDate);
    }

    return DeliverySurgeSettingsModel(
      isSurgeActive: data['isSurgeActive'] as bool? ?? false,
      surgeReason: data['surgeReason'] as String? ?? 'manual',
      surgeDeliveryMultiplier:
          (data['surgeDeliveryMultiplier'] as num?)?.toDouble() ?? 1.0,
      extraPrepTimeMinutes:
          (data['extraPrepTimeMinutes'] as num?)?.toInt() ?? 0,
      autoDisableAt: parsedAutoDisableAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSurgeActive': isSurgeActive,
      'surgeReason': surgeReason,
      'surgeDeliveryMultiplier': surgeDeliveryMultiplier,
      'extraPrepTimeMinutes': extraPrepTimeMinutes,
      if (autoDisableAt != null)
        'autoDisableAt': Timestamp.fromDate(autoDisableAt!),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  DeliverySurgeSettingsModel copyWith({
    bool? isSurgeActive,
    String? surgeReason,
    double? surgeDeliveryMultiplier,
    int? extraPrepTimeMinutes,
    DateTime? autoDisableAt,
    DateTime? updatedAt,
  }) {
    return DeliverySurgeSettingsModel(
      isSurgeActive: isSurgeActive ?? this.isSurgeActive,
      surgeReason: surgeReason ?? this.surgeReason,
      surgeDeliveryMultiplier:
          surgeDeliveryMultiplier ?? this.surgeDeliveryMultiplier,
      extraPrepTimeMinutes:
          extraPrepTimeMinutes ?? this.extraPrepTimeMinutes,
      autoDisableAt: autoDisableAt ?? this.autoDisableAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        isSurgeActive,
        surgeReason,
        surgeDeliveryMultiplier,
        extraPrepTimeMinutes,
        autoDisableAt,
        updatedAt,
      ];
}
