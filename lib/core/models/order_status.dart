enum OrderStatus {
  newOrder('New'),
  accepted('Accepted'),
  rejected('Rejected'),
  preparing('Preparing'),
  ready('Ready'),
  outForDelivery('OutForDelivery'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String value) {
    final clean = value.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    if (clean == 'pending' || clean == 'new' || clean == 'neworder') {
      return OrderStatus.newOrder;
    }
    if (clean == 'ready' || clean == 'readyforpickup') {
      return OrderStatus.ready;
    }
    if (clean == 'outfordelivery' || clean == 'pickedup') {
      return OrderStatus.outForDelivery;
    }
    return OrderStatus.values.firstWhere(
      (e) => e.value.toLowerCase().replaceAll('_', '').replaceAll(' ', '') == clean,
      orElse: () => OrderStatus.newOrder, // Default fallback
    );
  }

  @override
  String toString() => value;
}
