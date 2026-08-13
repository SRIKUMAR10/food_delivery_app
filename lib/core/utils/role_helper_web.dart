// Web-specific implementation using browser sessionStorage and URL location

import 'dart:html' as html;

String? getSessionRole() {
  try {
    return html.window.sessionStorage['app_role'];
  } catch (e) {
    return null;
  }
}

void setSessionRole(String role) {
  try {
    html.window.sessionStorage['app_role'] = role;
  } catch (e) {
    // ignore
  }
}

String? getUrlRole() {
  try {
    final href = html.window.location.href.toLowerCase();
    final uri = Uri.parse(html.window.location.href);

    // 1. Check query parameters e.g. ?role=seller|buyer|delivery or ?appRole=...
    final roleParam = uri.queryParameters['role']?.toLowerCase() ??
        uri.queryParameters['approle']?.toLowerCase();
    if (roleParam != null && roleParam.isNotEmpty) {
      return roleParam;
    }

    // 2. Check hash fragment e.g. #/?role=seller or #/seller
    final fragment = uri.fragment.toLowerCase();
    if (fragment.contains('role=seller') || fragment.contains('/seller')) {
      return 'seller';
    }
    if (fragment.contains('role=delivery') || fragment.contains('/delivery')) {
      return 'delivery';
    }
    if (fragment.contains('role=buyer') || fragment.contains('/buyer')) {
      return 'buyer';
    }

    // 3. Check path e.g. /seller, /delivery, /buyer
    if (href.contains('/seller')) return 'seller';
    if (href.contains('/delivery')) return 'delivery';
    if (href.contains('/buyer')) return 'buyer';
  } catch (e) {
    // ignore
  }
  return null;
}
