import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

@JS('Razorpay')
extension type _RazorpayJS._(JSObject _) implements JSObject {
  external _RazorpayJS(JSAny options);
  external void open();
}

/// Opens Razorpay Standard Checkout in Flutter Web via checkout.js.
void openRazorpayWeb({
  required Map<String, dynamic> options,
  required Function(PaymentSuccessResponse) onSuccess,
  required Function(PaymentFailureResponse) onFailure,
  Function(ExternalWalletResponse)? onExternalWallet,
}) {
  try {
    final jsOptions = JSObject();

    if (options['key'] != null) {
      jsOptions.setProperty('key'.toJS, (options['key'] as String).toJS);
    }
    if (options['amount'] != null) {
      jsOptions.setProperty('amount'.toJS, (options['amount'] as num).toJS);
    }
    if (options['name'] != null) {
      jsOptions.setProperty('name'.toJS, (options['name'] as String).toJS);
    }
    if (options['description'] != null) {
      jsOptions.setProperty('description'.toJS, (options['description'] as String).toJS);
    }
    if (options['order_id'] != null) {
      jsOptions.setProperty('order_id'.toJS, (options['order_id'] as String).toJS);
    }

    if (options['prefill'] is Map<String, dynamic>) {
      final prefillMap = options['prefill'] as Map<String, dynamic>;
      final prefillObj = JSObject();
      if (prefillMap['email'] != null) {
        prefillObj.setProperty('email'.toJS, (prefillMap['email'] as String).toJS);
      }
      if (prefillMap['contact'] != null) {
        prefillObj.setProperty('contact'.toJS, (prefillMap['contact'] as String).toJS);
      }
      jsOptions.setProperty('prefill'.toJS, prefillObj);
    }

    if (options['theme'] is Map<String, dynamic>) {
      final themeMap = options['theme'] as Map<String, dynamic>;
      final themeObj = JSObject();
      if (themeMap['color'] != null) {
        themeObj.setProperty('color'.toJS, (themeMap['color'] as String).toJS);
      }
      jsOptions.setProperty('theme'.toJS, themeObj);
    }

    // Success handler
    final handlerCallback = ((JSObject response) {
      final paymentId = response.getProperty<JSString?>('razorpay_payment_id'.toJS)?.toDart;
      final orderId = response.getProperty<JSString?>('razorpay_order_id'.toJS)?.toDart;
      final signature = response.getProperty<JSString?>('razorpay_signature'.toJS)?.toDart;

      final data = <dynamic, dynamic>{
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
      };

      onSuccess(PaymentSuccessResponse(
        paymentId,
        orderId,
        signature,
        data,
      ));
    }).toJS;
    jsOptions.setProperty('handler'.toJS, handlerCallback);

    // Modal dismiss (cancellation)
    final modalObj = JSObject();
    final onDismissCallback = (() {
      onFailure(PaymentFailureResponse(
        Razorpay.PAYMENT_CANCELLED,
        'Payment cancelled by user',
        null,
      ));
    }).toJS;
    modalObj.setProperty('ondismiss'.toJS, onDismissCallback);
    jsOptions.setProperty('modal'.toJS, modalObj);

    final rzp = _RazorpayJS(jsOptions);
    rzp.open();
  } catch (e) {
    debugPrint('Error opening Razorpay Web checkout: $e');
    onFailure(PaymentFailureResponse(
      Razorpay.UNKNOWN_ERROR,
      'Failed to launch Razorpay Web: $e',
      null,
    ));
  }
}
