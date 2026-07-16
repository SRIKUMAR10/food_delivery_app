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
    return OrderStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.newOrder, // Default fallback
    );
  }

  @override
  String toString() => value;
}
