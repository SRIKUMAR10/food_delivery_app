abstract class PaymentMethodsEvent {}

class LoadPaymentMethods extends PaymentMethodsEvent {}

class AddPaymentMethod extends PaymentMethodsEvent {
  final String type;
  final String cardNumber;
  final String? expiryDate;
  final String? cardholderName;
  final String? upiId;
  final String? billingAddress;
  final bool isDefault;

  AddPaymentMethod({
    required this.type,
    required this.cardNumber,
    this.expiryDate,
    this.cardholderName,
    this.upiId,
    this.billingAddress,
    this.isDefault = false,
  });
}

class UpdatePaymentMethod extends PaymentMethodsEvent {
  final String methodId;
  final String? expiryDate;
  final String? cardholderName;
  final String? billingAddress;
  final bool? isDefault;

  UpdatePaymentMethod({
    required this.methodId,
    this.expiryDate,
    this.cardholderName,
    this.billingAddress,
    this.isDefault,
  });
}

class DeletePaymentMethod extends PaymentMethodsEvent {
  final String methodId;

  DeletePaymentMethod(this.methodId);
}

class SetDefaultPaymentMethod extends PaymentMethodsEvent {
  final String methodId;

  SetDefaultPaymentMethod(this.methodId);
}

class ClearPaymentMethodsMessage extends PaymentMethodsEvent {}
