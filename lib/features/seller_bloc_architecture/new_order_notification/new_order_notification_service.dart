class NewOrderNotificationService {
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'orderId': orderId,
      'customer': 'Mike Ross',
      'itemsCount': 2,
      'amount': 780.0,
      'orderType': 'Delivery',
    };
  }

  Future<bool> acceptOrder(String orderId) async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Success
  }

  Future<bool> rejectOrder(String orderId) async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Success
  }
}
