import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// [RazorpayApiService] handles all direct communication with the Razorpay REST API.
class RazorpayApiService {
  // Razorpay Key loaded from .env
  static String get apiKey => dotenv.env['RAZORPAY_API_KEY'] ?? "MISSING_API_KEY";

  // Do NOT keep apiSecret inside Flutter app.
  // Keep apiSecret only in backend / Firebase Cloud Functions.
  final String? apiSecret;

  late Razorpay _razorpay;

  RazorpayApiService({this.apiSecret}) {
    _razorpay = Razorpay();
  }

  /// Method to initialize Razorpay event listeners
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
  }

  /// Centralized method to start Payment
  void startPayment({
    required double amount,
    required String email,
    String? orderId,
    String name = 'Food Delivery App',
    String description = 'Wallet Top-up',
  }) {
    var options = <String, dynamic>{
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': name,
      'description': description,
      'prefill': {'email': email},
    };

    if (orderId != null) {
      options['order_id'] = orderId;
    }

    _razorpay.open(options);
  }

  /// Method to release resources
  void dispose() {
    _razorpay.clear();
  }

  /// Creates a new Order safely via Firebase Cloud Functions.
  Future<Map<String, dynamic>> createOrder({
    required int amount,
    String currency = "INR",
    required String receipt,
  }) async {
    // URL of your deployed Firebase Cloud Function
    const String cloudFunctionUrl =
        'https://us-central1-food-delivery-app-cd4ca.cloudfunctions.net/createRazorpayOrder';

    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
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
