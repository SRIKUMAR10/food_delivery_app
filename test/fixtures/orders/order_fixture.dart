/// Order Fixture Data
class OrderFixture {
  static Map<String, dynamic> sampleOrder({
    String orderId = 'order_001',
    String buyerId = 'buyer_001',
    String sellerId = 'seller_001',
    String? deliveryPartnerId,
    String status = 'pending',
  }) => {
    'orderId': orderId,
    'buyerId': buyerId,
    'sellerId': sellerId,
    'deliveryPartnerId': deliveryPartnerId,
    'status': status,
    'items': [
      {
        'productId': 'prod_001',
        'name': 'Cheeseburger',
        'price': 149.0,
        'quantity': 2,
      }
    ],
    'totalAmount': 298.0,
    'paymentStatus': 'paid',
    'deliveryAddress': '123 Test Street, Anna Nagar, Chennai',
    'createdAt': '2026-08-18T10:00:00.000Z',
  };
}
