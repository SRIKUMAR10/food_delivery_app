import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// [RazorpayApiService] handles all direct communication with the Razorpay REST API.
class RazorpayApiService {
  static const String _baseUrl = "https://api.razorpay.com/v1";

  // Razorpay Test Key ID
  static const String apiKey = "rzp_test_Spi5WU6ETE2VVp";

  // Do NOT keep apiSecret inside Flutter app.
  // Keep apiSecret only in backend / Firebase Cloud Functions.
  final String? apiSecret;

  late Razorpay _razorpay;

  RazorpayApiService({this.apiSecret}) {
    _razorpay = Razorpay();
  }

  /// Razorpay event listeners-ஐத் தொடங்குவதற்கான முறை
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
  }

  /// Payment-ஐத் தொடங்குவதற்கான centralized method
  void startPayment({
    required double amount,
    required String email,
    String name = 'Food Delivery App',
    String description = 'Wallet Top-up',
  }) {
    var options = {
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': name,
      'description': description,
      'prefill': {'email': email},
    };

    _razorpay.open(options);
  }

  /// Resources-ஐ விடுவிப்பதற்கான முறை
  void dispose() {
    _razorpay.clear();
  }

  /// Creates a new Order on Razorpay.
  Future<Map<String, dynamic>> createOrder({
    required int amount,
    String currency = "INR",
    required String receipt,
  }) async {
    if (apiSecret == null) {
      throw Exception(
        "API Secret is required for order creation via REST API.",
      );
    }

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode({
          "amount": amount,
          "currency": currency,
          "receipt": receipt,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Network or Connection Error: $e");
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMessage = data['error'] != null
          ? data['error']['description']
          : "Unknown API Error";

      throw Exception(
        "Razorpay API Error (${response.statusCode}): $errorMessage",
      );
    }
  }
}
