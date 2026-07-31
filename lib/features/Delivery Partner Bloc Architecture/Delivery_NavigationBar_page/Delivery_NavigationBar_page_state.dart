import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum DeliveryNavigationBarStatus { initial, loading, loaded, error, empty }

class DeliveryNavigationBarItem extends Equatable {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const DeliveryNavigationBarItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  @override
  List<Object?> get props => [id, label, icon, activeIcon];
}

class DeliveryNavigationBarState extends Equatable {
  final DeliveryNavigationBarStatus status;
  final int selectedIndex;
  final List<DeliveryNavigationBarItem> navItems;
  final String? errorMessage;
  final double uploadProgress;
  final bool hasPermission;
  final String localeCode;
  final String partnerName;
  final bool isOffline;

  const DeliveryNavigationBarState({
    this.status = DeliveryNavigationBarStatus.initial,
    this.selectedIndex = 4,
    this.navItems = const [],
    this.errorMessage,
    this.uploadProgress = 0.0,
    this.hasPermission = false,
    this.localeCode = 'en',
    this.partnerName = 'Delivery Partner',
    this.isOffline = false,
  });

  bool get isUploading =>
      uploadProgress > 0.0 && uploadProgress < 1.0;

  DeliveryNavigationBarState copyWith({
    DeliveryNavigationBarStatus? status,
    int? selectedIndex,
    List<DeliveryNavigationBarItem>? navItems,
    String? errorMessage,
    bool clearError = false,
    double? uploadProgress,
    bool? hasPermission,
    String? localeCode,
    String? partnerName,
    bool? isOffline,
  }) {
    return DeliveryNavigationBarState(
      status: status ?? this.status,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      navItems: navItems ?? this.navItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uploadProgress: uploadProgress ?? this.uploadProgress,
      hasPermission: hasPermission ?? this.hasPermission,
      localeCode: localeCode ?? this.localeCode,
      partnerName: partnerName ?? this.partnerName,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedIndex,
        navItems,
        errorMessage,
        uploadProgress,
        hasPermission,
        localeCode,
        partnerName,
        isOffline,
      ];
}
