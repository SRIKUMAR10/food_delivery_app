import 'package:equatable/equatable.dart';

enum DeliveryOnboardingStatus { initial, loading, loaded, error }

class OnboardingFeatureItem extends Equatable {
  final String title;
  final String description;
  final String iconKey;

  const OnboardingFeatureItem({
    required this.title,
    required this.description,
    required this.iconKey,
  });

  @override
  List<Object?> get props => [title, description, iconKey];
}

class PartnerStatItem extends Equatable {
  final String value;
  final String label;
  final String iconKey;

  const PartnerStatItem({
    required this.value,
    required this.label,
    required this.iconKey,
  });

  @override
  List<Object?> get props => [value, label, iconKey];
}

class DeliveryOnboardingPageState extends Equatable {
  final DeliveryOnboardingStatus status;
  final String selectedLanguage;
  final List<OnboardingFeatureItem> features;
  final List<PartnerStatItem> partnerStats;
  final double uploadProgress;
  final String? errorMessage;
  final bool isStarted;
  final bool isNavigatingToLogin;

  const DeliveryOnboardingPageState({
    this.status = DeliveryOnboardingStatus.initial,
    this.selectedLanguage = 'English',
    this.features = const [],
    this.partnerStats = const [],
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.isStarted = false,
    this.isNavigatingToLogin = false,
  });

  DeliveryOnboardingPageState copyWith({
    DeliveryOnboardingStatus? status,
    String? selectedLanguage,
    List<OnboardingFeatureItem>? features,
    List<PartnerStatItem>? partnerStats,
    double? uploadProgress,
    String? errorMessage,
    bool? isStarted,
    bool? isNavigatingToLogin,
  }) {
    return DeliveryOnboardingPageState(
      status: status ?? this.status,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      features: features ?? this.features,
      partnerStats: partnerStats ?? this.partnerStats,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      isStarted: isStarted ?? this.isStarted,
      isNavigatingToLogin: isNavigatingToLogin ?? this.isNavigatingToLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLanguage': selectedLanguage,
      'isStarted': isStarted,
    };
  }

  factory DeliveryOnboardingPageState.fromJson(Map<String, dynamic> json) {
    return DeliveryOnboardingPageState(
      selectedLanguage: json['selectedLanguage'] as String? ?? 'English',
      isStarted: json['isStarted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedLanguage,
        features,
        partnerStats,
        uploadProgress,
        errorMessage,
        isStarted,
        isNavigatingToLogin,
      ];
}
