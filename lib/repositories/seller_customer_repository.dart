import '../api_service/seller_customer_service.dart';
import '../features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart';

class SellerCustomerRepository {
  final SellerCustomerService service;

  SellerCustomerRepository({required this.service});

  Future<CustomerStats> getCustomerStats() async {
    final raw = await service.fetchCustomerStats();
    return CustomerStats(
      totalCustomers: raw['totalCustomers'] ?? 0,
      repeatCustomers: raw['repeatCustomers'] ?? 0,
    );
  }

  Future<List<CustomerItem>> getCustomers({required int offset, required int limit}) async {
    final rawList = await service.fetchCustomerList(offset: offset, limit: limit);
    return rawList.map((map) {
      return CustomerItem(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        orderCount: map['orderCount'] ?? 0,
        avatarUrl: map['avatarUrl'] ?? '',
      );
    }).toList();
  }
}
