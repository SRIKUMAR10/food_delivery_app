import 'package:equatable/equatable.dart';

enum PaymentMethodsStatus { initial, loading, loaded, saving, error }

class PaymentMethodModel extends Equatable {
  final String id;
  final String type;
  final String maskedNumber;
  final String lastFourDigits;
  final String? expiryDate;
  final String? cardholderName;
  final String? upiId;
  final String? billingAddress;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.maskedNumber,
    required this.lastFourDigits,
    this.expiryDate,
    this.cardholderName,
    this.upiId,
    this.billingAddress,
    this.isDefault = false,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? type,
    String? maskedNumber,
    String? lastFourDigits,
    String? expiryDate,
    String? cardholderName,
    String? upiId,
    String? billingAddress,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryDate: expiryDate ?? this.expiryDate,
      cardholderName: cardholderName ?? this.cardholderName,
      upiId: upiId ?? this.upiId,
      billingAddress: billingAddress ?? this.billingAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory PaymentMethodModel.fromMap(String id, Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: id,
      type: map['type'] as String? ?? '',
      maskedNumber: map['maskedNumber'] as String? ?? '',
      lastFourDigits: map['lastFourDigits'] as String? ?? '',
      expiryDate: map['expiryDate'] as String?,
      cardholderName: map['cardholderName'] as String?,
      upiId: map['upiId'] as String?,
      billingAddress: map['billingAddress'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'maskedNumber': maskedNumber,
      'lastFourDigits': lastFourDigits,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (cardholderName != null) 'cardholderName': cardholderName,
      if (upiId != null) 'upiId': upiId,
      if (billingAddress != null) 'billingAddress': billingAddress,
      'isDefault': isDefault,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'upi':
        return 'UPI';
      case 'wallet':
        return 'Wallet';
      case 'net_banking':
        return 'Net Banking';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        maskedNumber,
        lastFourDigits,
        expiryDate,
        cardholderName,
        upiId,
        billingAddress,
        isDefault,
      ];
}

class PaymentMethodsState extends Equatable {
  final PaymentMethodsStatus status;
  final List<PaymentMethodModel> methods;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaving;

  bool get isLoading => status == PaymentMethodsStatus.loading;
  bool get hasDefault => methods.any((m) => m.isDefault);

  const PaymentMethodsState({
    this.status = PaymentMethodsStatus.initial,
    this.methods = const [],
    this.errorMessage,
    this.successMessage,
    this.isSaving = false,
  });

  PaymentMethodsState copyWith({
    PaymentMethodsStatus? status,
    List<PaymentMethodModel>? methods,
    String? errorMessage,
    String? successMessage,
    bool? isSaving,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PaymentMethodsState(
      status: status ?? this.status,
      methods: methods ?? this.methods,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        status,
        methods,
        errorMessage,
        successMessage,
        isSaving,
      ];
}
