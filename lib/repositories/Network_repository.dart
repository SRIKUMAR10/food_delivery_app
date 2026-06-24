import 'package:food_delivery_app/api_service/Network_api_service.dart';

class ApiRepository {
  final Network_api_service _Network_api_service = Network_api_service();

  Future<dynamic> fetchData(String endpoint) async {
    return await _Network_api_service.get(endpoint);
  }

  Future<dynamic> submitData(String endpoint, Map<String, dynamic> data) async {
    return await _Network_api_service.post(endpoint, data);
  }

  Future<dynamic> updateData(String endpoint, Map<String, dynamic> data) async {
    return await _Network_api_service.put(endpoint, data);
  }

  Future<dynamic> removeData(String endpoint) async {
    return await _Network_api_service.delete(endpoint);
  }
}
