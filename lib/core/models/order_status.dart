enum OrderStatus {
  newOrder('New'),
  accepted('Accepted'),
  rejected('Rejected'),
  preparing('Preparing'),
  ready('Ready'),
  pickedUp('PickedUp'),
  outForDelivery('OutForDelivery'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String value) {
    final clean = value
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim();

    switch (clean) {
      case 'pending':
      case 'new':
      case 'neworder':
      case 'placed':
        return OrderStatus.newOrder;
      case 'accepted':
        return OrderStatus.accepted;
      case 'rejected':
        return OrderStatus.rejected;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
      case 'readyforpickup':
        return OrderStatus.ready;
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.newOrder;
    }
  }

  /// Whether the status is a final state that cannot transition further.
  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.rejected ||
      this == OrderStatus.cancelled;

  /// User friendly display name matching the 7 lifecycle states
  String get displayName {
    switch (this) {
      case OrderStatus.newOrder:
        return 'Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Sequential step index in the 7-stage order lifecycle (0 to 6) or -1 for cancelled/rejected
  int get stepIndex {
    switch (this) {
      case OrderStatus.newOrder:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.pickedUp:
        return 4;
      case OrderStatus.outForDelivery:
        return 5;
      case OrderStatus.delivered:
        return 6;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isCancelledOrRejected =>
      this == OrderStatus.cancelled || this == OrderStatus.rejected;

  @override
  String toString() => value;
}

enum DeliveryFlowStatus {
  assigned('ASSIGNED'),
  accepted('ACCEPTED'),
  goingToRestaurant('GOING_TO_RESTAURANT'),
  arrivedAtRestaurant('ARRIVED_AT_RESTAURANT'),
  pickedUp('PICKED_UP'),
  outForDelivery('OUT_FOR_DELIVERY'),
  arrivedAtCustomer('ARRIVED_AT_CUSTOMER'),
  delivered('DELIVERED');

  final String value;
  const DeliveryFlowStatus(this.value);

  factory DeliveryFlowStatus.fromString(String? val) {
    if (val == null) return DeliveryFlowStatus.assigned;
    final clean = val.toUpperCase().replaceAll('_', '').replaceAll(' ', '').trim();
    switch (clean) {
      case 'ASSIGNED':
        return DeliveryFlowStatus.assigned;
      case 'ACCEPTED':
        return DeliveryFlowStatus.accepted;
      case 'GOINGTORESTAURANT':
      case 'HEADINGTOSTORE':
        return DeliveryFlowStatus.goingToRestaurant;
      case 'ARRIVEDATRESTAURANT':
      case 'ARRIVEDATSTORE':
        return DeliveryFlowStatus.arrivedAtRestaurant;
      case 'PICKEDUP':
        return DeliveryFlowStatus.pickedUp;
      case 'OUTFORDELIVERY':
        return DeliveryFlowStatus.outForDelivery;
      case 'ARRIVEDATCUSTOMER':
      case 'ARRIVEDATDROP':
        return DeliveryFlowStatus.arrivedAtCustomer;
      case 'DELIVERED':
      case 'COMPLETED':
        return DeliveryFlowStatus.delivered;
      default:
        return DeliveryFlowStatus.assigned;
    }
  }

  int get stepIndex {
    switch (this) {
      case DeliveryFlowStatus.assigned:
        return 0;
      case DeliveryFlowStatus.accepted:
        return 1;
      case DeliveryFlowStatus.goingToRestaurant:
        return 2;
      case DeliveryFlowStatus.arrivedAtRestaurant:
        return 3;
      case DeliveryFlowStatus.pickedUp:
        return 4;
      case DeliveryFlowStatus.outForDelivery:
        return 5;
      case DeliveryFlowStatus.arrivedAtCustomer:
        return 6;
      case DeliveryFlowStatus.delivered:
        return 7;
    }
  }

  String get displayName {
    switch (this) {
      case DeliveryFlowStatus.assigned:
        return 'Assigned';
      case DeliveryFlowStatus.accepted:
        return 'Accepted';
      case DeliveryFlowStatus.goingToRestaurant:
        return 'Going to Restaurant';
      case DeliveryFlowStatus.arrivedAtRestaurant:
        return 'Arrived at Restaurant';
      case DeliveryFlowStatus.pickedUp:
        return 'Picked Up';
      case DeliveryFlowStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryFlowStatus.arrivedAtCustomer:
        return 'Arrived at Customer';
      case DeliveryFlowStatus.delivered:
        return 'Delivered';
    }
  }

  String get displayNameTa {
    switch (this) {
      case DeliveryFlowStatus.assigned:
        return 'ஒதுக்கப்பட்டது';
      case DeliveryFlowStatus.accepted:
        return 'ஏற்றுக்கொள்ளப்பட்டது';
      case DeliveryFlowStatus.goingToRestaurant:
        return 'உணவகம் நோக்கி செல்கிறார்';
      case DeliveryFlowStatus.arrivedAtRestaurant:
        return 'உணவகத்தை அடைந்தார்';
      case DeliveryFlowStatus.pickedUp:
        return 'உணவு பெறப்பட்டது';
      case DeliveryFlowStatus.outForDelivery:
        return 'டெலிவரிக்கு புறப்பட்டது';
      case DeliveryFlowStatus.arrivedAtCustomer:
        return 'வாடிக்கையாளர் இருப்பிடம் அடைந்தார்';
      case DeliveryFlowStatus.delivered:
        return 'டெலிவரி செய்யப்பட்டது';
    }
  }
}

