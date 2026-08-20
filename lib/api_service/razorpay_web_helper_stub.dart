import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Non-web fallback stub for Razorpay Web Checkout.
void openRazorpayWeb({
  required Map<String, dynamic> options,
  required Function(PaymentSuccessResponse) onSuccess,
  required Function(PaymentFailureResponse) onFailure,
  Function(ExternalWalletResponse)? onExternalWallet,
}) {
  // No-op on native platforms where razorpay_flutter handles checkout directly.
}
