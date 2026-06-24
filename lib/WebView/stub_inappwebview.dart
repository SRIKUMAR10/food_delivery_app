// This file is used ONLY on the Web platform via a conditional import.
// It provides stub types so that safe_web_view_screen.dart compiles on Web
// without referencing the real flutter_inappwebview plugin, which requires
// native platform channels that are not available in a browser.
//
// On Android / iOS, the real 'package:flutter_inappwebview/flutter_inappwebview.dart'
// is imported instead.

import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Stub: InAppWebView
// ---------------------------------------------------------------------------
class InAppWebView extends StatelessWidget {
  final URLRequest? initialUrlRequest;
  final InAppWebViewSettings? initialSettings;
  final void Function(InAppWebViewController)? onWebViewCreated;
  final void Function(InAppWebViewController, WebUri?)? onLoadStart;
  final void Function(InAppWebViewController, WebUri?)? onLoadStop;
  final void Function(InAppWebViewController, int)? onProgressChanged;
  final void Function(
    InAppWebViewController,
    WebResourceRequest,
    WebResourceError,
  )? onReceivedError;
  final Future<NavigationActionPolicy> Function(
    InAppWebViewController,
    NavigationAction,
  )? shouldOverrideUrlLoading;

  const InAppWebView({
    super.key,
    this.initialUrlRequest,
    this.initialSettings,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onProgressChanged,
    this.onReceivedError,
    this.shouldOverrideUrlLoading,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Stub: InAppWebViewController
// ---------------------------------------------------------------------------
class InAppWebViewController {
  Future<void> reload() async {}
  Future<void> loadUrl({required URLRequest urlRequest}) async {}
}

// ---------------------------------------------------------------------------
// Stub: URLRequest
// ---------------------------------------------------------------------------
class URLRequest {
  final WebUri? url;
  const URLRequest({this.url});
}

// ---------------------------------------------------------------------------
// Stub: WebUri
// ---------------------------------------------------------------------------
class WebUri {
  final String rawValue;
  const WebUri(this.rawValue);

  @override
  String toString() => rawValue;
}

// ---------------------------------------------------------------------------
// Stub: InAppWebViewSettings
// ---------------------------------------------------------------------------
class InAppWebViewSettings {
  final bool javaScriptEnabled;
  final bool domStorageEnabled;
  final bool useShouldOverrideUrlLoading;

  const InAppWebViewSettings({
    this.javaScriptEnabled = true,
    this.domStorageEnabled = true,
    this.useShouldOverrideUrlLoading = false,
  });
}

// ---------------------------------------------------------------------------
// Stub: WebResourceRequest
// ---------------------------------------------------------------------------
class WebResourceRequest {
  final bool? isForMainFrame;
  const WebResourceRequest({this.isForMainFrame});
}

// ---------------------------------------------------------------------------
// Stub: WebResourceError
// ---------------------------------------------------------------------------
class WebResourceError {
  final String type;
  final String description;
  const WebResourceError({this.type = '', this.description = ''});
}

// ---------------------------------------------------------------------------
// Stub: NavigationActionPolicy
// ---------------------------------------------------------------------------
enum NavigationActionPolicy {
  CANCEL,
  ALLOW,
}

// ---------------------------------------------------------------------------
// Stub: NavigationAction
// ---------------------------------------------------------------------------
class NavigationAction {
  final URLRequest request;
  const NavigationAction({required this.request});
}
