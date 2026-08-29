import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StaffPermissions extends Equatable {
  final bool canAcceptRejectOrders;
  final bool canMarkOrderReady;
  final bool canEditMenuStock;
  final bool canViewFinancials;
  final bool canRequestPayout;
  final bool canModifySettings;

  const StaffPermissions({
    this.canAcceptRejectOrders = true,
    this.canMarkOrderReady = true,
    this.canEditMenuStock = true,
    this.canViewFinancials = false,
    this.canRequestPayout = false,
    this.canModifySettings = false,
  });

  factory StaffPermissions.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const StaffPermissions();
    return StaffPermissions(
      canAcceptRejectOrders: data['canAcceptRejectOrders'] as bool? ?? true,
      canMarkOrderReady: data['canMarkOrderReady'] as bool? ?? true,
      canEditMenuStock: data['canEditMenuStock'] as bool? ?? true,
      canViewFinancials: data['canViewFinancials'] as bool? ?? false,
      canRequestPayout: data['canRequestPayout'] as bool? ?? false,
      canModifySettings: data['canModifySettings'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canAcceptRejectOrders': canAcceptRejectOrders,
      'canMarkOrderReady': canMarkOrderReady,
      'canEditMenuStock': canEditMenuStock,
      'canViewFinancials': canViewFinancials,
      'canRequestPayout': canRequestPayout,
      'canModifySettings': canModifySettings,
    };
  }

  StaffPermissions copyWith({
    bool? canAcceptRejectOrders,
    bool? canMarkOrderReady,
    bool? canEditMenuStock,
    bool? canViewFinancials,
    bool? canRequestPayout,
    bool? canModifySettings,
  }) {
    return StaffPermissions(
      canAcceptRejectOrders:
          canAcceptRejectOrders ?? this.canAcceptRejectOrders,
      canMarkOrderReady: canMarkOrderReady ?? this.canMarkOrderReady,
      canEditMenuStock: canEditMenuStock ?? this.canEditMenuStock,
      canViewFinancials: canViewFinancials ?? this.canViewFinancials,
      canRequestPayout: canRequestPayout ?? this.canRequestPayout,
      canModifySettings: canModifySettings ?? this.canModifySettings,
    );
  }

  @override
  List<Object?> get props => [
        canAcceptRejectOrders,
        canMarkOrderReady,
        canEditMenuStock,
        canViewFinancials,
        canRequestPayout,
        canModifySettings,
      ];
}

class SellerStaffModel extends Equatable {
  final String staffId;
  final String name;
  final String phoneNumber;
  final String role; // 'manager', 'kitchen_staff', 'cashier', 'order_packer'
  final StaffPermissions permissions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SellerStaffModel({
    required this.staffId,
    required this.name,
    required this.phoneNumber,
    this.role = 'kitchen_staff',
    this.permissions = const StaffPermissions(),
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerStaffModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parsedCreatedAt;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreatedAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreated);
    }

    DateTime? parsedUpdatedAt;
    final rawUpdated = data['updatedAt'];
    if (rawUpdated is Timestamp) {
      parsedUpdatedAt = rawUpdated.toDate();
    } else if (rawUpdated is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdated);
    }

    return SellerStaffModel(
      staffId: id ?? (data['staffId'] as String? ?? ''),
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'kitchen_staff',
      permissions: data['permissions'] is Map<String, dynamic>
          ? StaffPermissions.fromMap(data['permissions'] as Map<String, dynamic>)
          : const StaffPermissions(),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
      'permissions': permissions.toMap(),
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  SellerStaffModel copyWith({
    String? staffId,
    String? name,
    String? phoneNumber,
    String? role,
    StaffPermissions? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerStaffModel(
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        staffId,
        name,
        phoneNumber,
        role,
        permissions,
        isActive,
        createdAt,
        updatedAt,
      ];
}
