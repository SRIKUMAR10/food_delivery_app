import 'package:equatable/equatable.dart';

abstract class DeliveryProfileEvent extends Equatable {
  const DeliveryProfileEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryProfileInitEvent extends DeliveryProfileEvent {
  const DeliveryProfileInitEvent();
}

class DeliveryProfileUpdateFieldEvent extends DeliveryProfileEvent {
  final String field;
  final String value;

  const DeliveryProfileUpdateFieldEvent({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

class DeliveryProfilePickImageEvent extends DeliveryProfileEvent {
  const DeliveryProfilePickImageEvent();
}

class DeliveryProfileUploadDocumentEvent extends DeliveryProfileEvent {
  final String documentId;
  final String? filePath;

  const DeliveryProfileUploadDocumentEvent(this.documentId, {this.filePath});

  @override
  List<Object?> get props => [documentId, filePath];
}

class DeliveryProfileSaveEvent extends DeliveryProfileEvent {
  const DeliveryProfileSaveEvent();
}

class DeliveryProfileRetryEvent extends DeliveryProfileEvent {
  const DeliveryProfileRetryEvent();
}

class DeliveryProfileUpdateAddressEvent extends DeliveryProfileEvent {
  final String address;
  const DeliveryProfileUpdateAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class DeliveryProfileUpdateVehicleEvent extends DeliveryProfileEvent {
  final String vehicleType;
  final String vehicleNumber;

  const DeliveryProfileUpdateVehicleEvent({
    required this.vehicleType,
    required this.vehicleNumber,
  });

  @override
  List<Object?> get props => [vehicleType, vehicleNumber];
}

class DeliveryProfileUpdatePhoneEvent extends DeliveryProfileEvent {
  final String phone;
  const DeliveryProfileUpdatePhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DeliveryProfileUpdateEmailEvent extends DeliveryProfileEvent {
  final String email;
  const DeliveryProfileUpdateEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class DeliveryProfileChangePasswordEvent extends DeliveryProfileEvent {
  final String currentPassword;
  final String newPassword;

  const DeliveryProfileChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class DeliveryProfileLogoutEvent extends DeliveryProfileEvent {
  const DeliveryProfileLogoutEvent();
}

class DeliveryProfileDeactivateAccountEvent extends DeliveryProfileEvent {
  const DeliveryProfileDeactivateAccountEvent();
}

class DeliveryProfileLocaleChangedEvent extends DeliveryProfileEvent {
  final String localeCode;
  const DeliveryProfileLocaleChangedEvent(this.localeCode);

  @override
  List<Object?> get props => [localeCode];
}
