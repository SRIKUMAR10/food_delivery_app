import '../API Service/api_service.dart';

class ApiRepository {
  final ApiService _apiService = ApiService();

  Future<dynamic> fetchData(String endpoint) async {
    return await _apiService.get(endpoint);
  }

  Future<dynamic> submitData(String endpoint, Map<String, dynamic> data) async {
    return await _apiService.post(endpoint, data);
  }

  Future<dynamic> updateData(String endpoint, Map<String, dynamic> data) async {
    return await _apiService.put(endpoint, data);
  }

  Future<dynamic> removeData(String endpoint) async {
    return await _apiService.delete(endpoint);
  }
}
