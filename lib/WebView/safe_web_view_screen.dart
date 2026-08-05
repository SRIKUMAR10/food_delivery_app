import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// flutter_inappwebview is only imported on non-Web platforms.
// On Web, its JS plugin is not available, so we guard with kIsWeb.
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    if (dart.library.html) 'stub_inappwebview.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PAYMENT WEBVIEW RESULT
// ─────────────────────────────────────────────────────────────────────────────

/// Status returned by [SafeWebViewScreen] after the user finishes (or
/// dismisses) a Razorpay Payment Link page.
enum PaymentWebViewStatus { success, failed, cancelled }

/// Returned via `Navigator.pop<PaymentWebViewResult>(...)` when the WebView
/// detects a Razorpay payment outcome URL.
///
/// If the user simply presses back without completing payment, the route
/// returns `null` (handled by the caller as [PaymentWebViewStatus.cancelled]).
class PaymentWebViewResult {
  final PaymentWebViewStatus status;

  /// Present only when [status] == [PaymentWebViewStatus.success].
  final String? paymentId;

  /// Present only when [status] == [PaymentWebViewStatus.failed].
  final String? errorMessage;

  const PaymentWebViewResult({
    required this.status,
    this.paymentId,
    this.errorMessage,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  SAFE WEB VIEW SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// A cross-platform WebView widget with built-in Razorpay payment-result detection.
///
/// - **Web**: Shows a loading indicator and immediately opens [url] in a new
///   browser tab via `url_launcher`. No `InAppWebView` is constructed.
/// - **Mobile / Desktop**: Embeds an [InAppWebView] inside the scaffold.
///
/// ### Razorpay Payment Link detection
/// When [detectRazorpayResult] is `true` (default), the WebView inspects every
/// URL that the page navigates to. If the URL contains Razorpay payment-link
/// query parameters, the route pops with a [PaymentWebViewResult]:
///   - `razorpay_payment_link_status=paid`  → [PaymentWebViewStatus.success]
///   - `razorpay_payment_link_status=cancelled` → [PaymentWebViewStatus.cancelled]
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<PaymentWebViewResult>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => SafeWebViewScreen(
///       url: paymentLink,
///       title: 'Complete Payment',
///     ),
///   ),
/// );
/// if (result?.status == PaymentWebViewStatus.success) { ... }
/// ```
class SafeWebViewScreen extends StatefulWidget {
  /// The URL to load.
  final String url;

  /// Optional title displayed in the [AppBar].
  final String title;

  /// When true, URL changes are inspected for Razorpay payment outcomes.
  final bool detectRazorpayResult;

  const SafeWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Browser',
    this.detectRazorpayResult = true,
  });

  @override
  State<SafeWebViewScreen> createState() => _SafeWebViewScreenState();
}

class _SafeWebViewScreenState extends State<SafeWebViewScreen> {
  // ---------- shared state ----------
  bool _isLoading = true;
  String? _errorMessage;

  // ---------- mobile-only state ----------
  InAppWebViewController? _webViewController;
  double _progress = 0;

  // Guard: prevent popping twice if both onLoadStart and
  // shouldOverrideUrlLoading fire for the same redirect URL.
  bool _resultPopped = false;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // On Web: open the URL externally right after the first frame.
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchUrlExternally();
      });
    }
  }

  @override
  void dispose() {
    // Do NOT access context here – the widget may already be deactivated.
    // We also do NOT call Navigator from dispose().
    _webViewController = null;
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Razorpay payment result detection
  // ------------------------------------------------------------------

  /// Inspects [url] for Razorpay Payment Link outcome query parameters.
  ///
  /// Returns `true` and pops the route if a result is detected.
  bool _detectPaymentResult(String url) {
    if (!widget.detectRazorpayResult || _resultPopped) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final params = uri.queryParameters;
    final status = params['razorpay_payment_link_status'];
    final paymentId = params['razorpay_payment_id'];

    PaymentWebViewResult? result;

    if (status == 'paid') {
      result = PaymentWebViewResult(
        status: PaymentWebViewStatus.success,
        paymentId: paymentId,
      );
    } else if (status == 'cancelled') {
      result = const PaymentWebViewResult(
        status: PaymentWebViewStatus.cancelled,
      );
    }

    if (result != null) {
      _resultPopped = true;
      // Defer pop to avoid calling Navigator during a build/callback.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(result);
        }
      });
      return true;
    }

    return false;
  }

  // ------------------------------------------------------------------
  // Web path: open in external browser
  // ------------------------------------------------------------------

  Future<void> _launchUrlExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      _setError('Invalid URL: ${widget.url}');
      return;
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      _setError('Could not launch ${widget.url}');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _setError('Failed to open ${widget.url}');
      return;
    }

    // URL opened successfully – pop the route if the widget is still mounted.
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    }
  }

  // ------------------------------------------------------------------
  // Mobile path: InAppWebView callbacks
  // ------------------------------------------------------------------

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    if (url != null) {
      // Check for payment result before rendering the redirect page.
      if (_detectPaymentResult(url.toString())) return;
    }
    if (mounted) setState(() => _isLoading = true);
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) {
    if (url != null) _detectPaymentResult(url.toString());
    if (mounted) setState(() => _isLoading = false);
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    if (mounted) setState(() => _progress = progress / 100.0);
  }

  void _onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    if (request.isForMainFrame ?? false) {
      _setError('Error ${error.type}: ${error.description}');
    }
  }

  Future<NavigationActionPolicy> _onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url?.toString() ?? '';
    if (_detectPaymentResult(url)) {
      // Block the navigation — we've already handled the result.
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: (!kIsWeb && _isLoading && _progress > 0 && _progress < 1)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Web ──────────────────────────────────────────────────────────
    if (kIsWeb) {
      if (_errorMessage != null) {
        return _WebErrorView(
          message: _errorMessage!,
          url: widget.url,
          onRetry: _launchUrlExternally,
        );
      }
      return const _WebLoadingView();
    }

    // ── Mobile / Desktop ─────────────────────────────────────────────
    if (_errorMessage != null) {
      return _WebErrorView(
        message: _errorMessage!,
        url: widget.url,
        onRetry: () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
              _isLoading = true;
            });
            _webViewController?.reload();
          }
        },
      );
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            useShouldOverrideUrlLoading: true,
          ),
          onWebViewCreated: _onWebViewCreated,
          onLoadStart: _onLoadStart,
          onLoadStop: _onLoadStop,
          onProgressChanged: _onProgressChanged,
          onReceivedError: _onReceivedError,
          shouldOverrideUrlLoading: _onShouldOverrideUrlLoading,
        ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Shown on Web while the external browser is being opened.
class _WebLoadingView extends StatelessWidget {
  const _WebLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Opening in your browser…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Shown when a URL cannot be launched or a mobile page load fails.
class _WebErrorView extends StatelessWidget {
  final String message;
  final String url;
  final VoidCallback onRetry;

  const _WebErrorView({
    required this.message,
    required this.url,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Could not load page',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
