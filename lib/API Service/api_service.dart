import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET Request failed: $e');
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST Request failed: $e');
    }
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT Request failed: $e');
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await http.delete(Uri.parse(url));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE Request failed: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }
}
