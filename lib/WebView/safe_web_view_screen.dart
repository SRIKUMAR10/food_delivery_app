import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// flutter_inappwebview is only imported on non-Web platforms.
// On Web, its JS plugin is not available, so we guard with kIsWeb.
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    if (dart.library.html) 'stub_inappwebview.dart';

/// A cross-platform WebView widget.
///
/// - **Web**: Shows a loading indicator and immediately opens [url] in a new
///   browser tab via `url_launcher`. No `InAppWebView` is constructed.
/// - **Mobile / Desktop**: Embeds an [InAppWebView] inside the scaffold.
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => SafeWebViewScreen(
///       url: 'https://example.com',
///       title: 'Example',
///     ),
///   ),
/// );
/// ```
class SafeWebViewScreen extends StatefulWidget {
  /// The URL to load.
  final String url;

  /// Optional title displayed in the [AppBar].
  final String title;

  const SafeWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Browser',
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
    if (mounted) {
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
    if (mounted) setState(() => _isLoading = true);
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) {
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
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
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
