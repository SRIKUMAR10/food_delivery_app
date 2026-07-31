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

  const DeliveryProfileUploadDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class DeliveryProfileSaveEvent extends DeliveryProfileEvent {
  const DeliveryProfileSaveEvent();
}

class DeliveryProfileRetryEvent extends DeliveryProfileEvent {
  const DeliveryProfileRetryEvent();
}
