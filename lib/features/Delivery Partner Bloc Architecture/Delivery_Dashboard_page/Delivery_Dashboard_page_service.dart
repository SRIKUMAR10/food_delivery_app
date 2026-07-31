import 'dart:async';

class DeliveryDashboardServiceBase {
  Future<Map<String, dynamic>> fetchDashboardMetrics() async => {};
  Future<bool> updateOnlineStatus(bool isOnline) async => isOnline;
}

class DeliveryDashboardService implements DeliveryDashboardServiceBase {
  @override
  Future<Map<String, dynamic>> fetchDashboardMetrics() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return {
      'todayEarnings': 2450.00,
      'earningsGrowth': 18.5,
      'todayOrdersCount': 18,
      'activeOrdersCount': 2,
      'walletBalance': 2450.00,
      'incentiveEarned': 350.00,
      'incentiveTarget': 500.00,
      'workingHours': '05h 45m',
      'acceptanceRate': 92,
      'performanceScore': 4.8,
      'partnerName': 'Ravi Kumar',
      'vehicleNumber': 'TN 01 AB 1234',
      'isOnline': true,
      'activities': [
        {
          'id': 'act_1',
          'time': '10:30 AM',
          'title': 'Order Delivered',
          'subtitle': 'Order #ORD12345',
          'details': '₹120.00',
          'statusType': 'delivered',
        },
        {
          'id': 'act_2',
          'time': '10:02 AM',
          'title': 'Order Picked Up',
          'subtitle': 'Order #ORD12345',
          'details': 'Green Mart, Anna Salai',
          'statusType': 'picked_up',
        },
        {
          'id': 'act_3',
          'time': '09:45 AM',
          'title': 'New Order Received',
          'subtitle': 'Order #ORD12345',
          'details': '2.4 km away',
          'statusType': 'new_order',
        },
        {
          'id': 'act_4',
          'time': '09:40 AM',
          'title': 'Reached Restaurant',
          'subtitle': 'Green Mart, Anna Salai',
          'details': '',
          'statusType': 'reached_restaurant',
        },
        {
          'id': 'act_5',
          'time': '09:30 AM',
          'title': 'Went Online',
          'subtitle': 'You are now online and available',
          'details': '',
          'statusType': 'went_online',
        },
      ],
      'incentives': [
        {
          'id': 'inc_1',
          'title': 'Peak Hours Bonus (12 PM - 3 PM)',
          'completedDeliveries': 8,
          'targetDeliveries': 10,
          'rewardAmount': 250.0,
          'isCompleted': false,
        },
        {
          'id': 'inc_2',
          'title': 'Weekend Rush Special',
          'completedDeliveries': 15,
          'targetDeliveries': 15,
          'rewardAmount': 500.0,
          'isCompleted': true,
        },
      ],
    };
  }

  @override
  Future<bool> updateOnlineStatus(bool isOnline) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return isOnline;
  }
}
