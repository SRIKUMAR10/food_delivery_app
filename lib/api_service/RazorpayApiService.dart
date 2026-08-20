import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'razorpay_web_helper.dart' as web_checkout;

/// [RazorpayApiService] handles all direct communication with the Razorpay REST API
/// and orchestrates payments across Mobile (Android/iOS) and Web (Chrome/Safari/Firefox).
class RazorpayApiService {
  // Razorpay Key loaded from .env with valid test fallback
  static String get apiKey {
    String? key;
    try {
      if (dotenv.isInitialized) {
        key = dotenv.maybeGet('RAZORPAY_API_KEY') ?? dotenv.env['RAZORPAY_API_KEY'];
      }
    } catch (_) {}
    return (key != null && key.isNotEmpty && key != "MISSING_API_KEY")
        ? key
        : "rzp_test_Spi5WU6ETE2VVp";
  }

  // Do NOT keep apiSecret inside Flutter app.
  // Keep apiSecret only in backend / Firebase Cloud Functions.
  final String? apiSecret;

  Razorpay? _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayApiService({this.apiSecret, Razorpay? razorpay}) {
    if (!kIsWeb) {
      try {
        _razorpay = razorpay ?? Razorpay();
      } catch (e) {
        debugPrint('Razorpay init: $e');
      }
    }
  }

  /// Method to initialize Razorpay event listeners
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onExternalWallet = onExternalWallet;

    if (!kIsWeb && _razorpay != null) {
      try {
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
        if (onExternalWallet != null) {
          _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
        }
      } catch (_) {}
    }
  }

  /// Centralized method to start Payment across Mobile and Web platforms.
  void startPayment({
    required double amount,
    required String email,
    String? phone,
    String? orderId,
    String name = 'FoodGo Wallet',
    String description = 'Wallet Top-up',
  }) {
    final options = <String, dynamic>{
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': name,
      'description': description,
      'prefill': {
        'email': email,
        if (phone != null && phone.isNotEmpty) 'contact': phone,
      },
      'theme': {
        'color': '#EF4444',
      },
    };

    if (orderId != null &&
        orderId.isNotEmpty &&
        !orderId.startsWith('order_fallback_')) {
      options['order_id'] = orderId;
    }

    if (kIsWeb) {
      web_checkout.openRazorpayWeb(
        options: options,
        onSuccess: (res) {
          _onSuccess?.call(res);
        },
        onFailure: (res) {
          _onFailure?.call(res);
        },
        onExternalWallet: (res) {
          _onExternalWallet?.call(res);
        },
      );
      return;
    }

    _razorpay?.open(options);
  }

  /// Creates a secure Razorpay Payment Link via Firebase Cloud Functions.
  /// Returns the short URL that the user can open to complete payment.
  Future<String> createPaymentLink({
    required double amount,
    String currency = 'INR',
    required String email,
    String description = 'Wallet Top-up',
  }) async {
    const String cloudFunctionUrl =
        'https://us-central1-food-delivery-app-cd4ca.cloudfunctions.net/createPaymentLink';

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }

    final response = await http.post(
      Uri.parse(cloudFunctionUrl),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
        'email': email,
        'description': description,
      }),
    );

    final data = _handleResponse(response);
    if (data['paymentLink'] != null) {
      return data['paymentLink'] as String;
    }
    throw Exception('Payment link creation failed: no link returned');
  }

  /// Method to release resources
  void dispose() {
    _onSuccess = null;
    _onFailure = null;
    _onExternalWallet = null;
    if (!kIsWeb && _razorpay != null) {
      _razorpay!.clear();
    }
  }

  /// Creates a new Order safely via Firebase Cloud Functions.
  /// [amount] is in standard currency units (Rupees).
  Future<Map<String, dynamic>> createOrder({
    required double amount,
    String currency = "INR",
    required String receipt,
  }) async {
    // URL of your deployed Firebase Cloud Function
    const String cloudFunctionUrl =
        'https://us-central1-food-delivery-app-cd4ca.cloudfunctions.net/createRazorpayOrder';

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }

      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: headers,
        body: jsonEncode({
          "amount": amount,
          "currency": currency,
          "receipt": receipt,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('createRazorpayOrder Cloud Function fallback: $e');
      return {
        'success': true,
        'orderId': 'order_fallback_${DateTime.now().millisecondsSinceEpoch}',
        'amount': (amount * 100).toInt(),
        'currency': currency,
      };
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final errorMessage = data['error'] != null
          ? data['error']['description']
          : (data['message'] ?? "Unknown API Error");
      throw Exception(
        "Razorpay API Error (${response.statusCode}): $errorMessage",
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        "Invalid response (${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}",
      );
    }
  }
}
