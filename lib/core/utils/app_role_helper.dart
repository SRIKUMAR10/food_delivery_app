import 'package:flutter/foundation.dart';
import 'role_helper_stub.dart' if (dart.library.html) 'role_helper_web.dart';

enum AppRole { buyer, seller, delivery }

/// Resolves the effective [AppRole] for the current app execution environment.
///
/// Priority order on Web:
/// 1. URL Query Parameter / Fragment / Path (e.g. ?role=seller or /seller)
/// 2. Tab-isolated Web `sessionStorage` (so each Chrome tab keeps its own role across Hot Restarts)
/// 3. Fallback constant set in `main.dart`
AppRole getEffectiveAppRole(AppRole fallback) {
  if (kIsWeb) {
    // 1. Check URL override
    final urlRole = getUrlRole();
    if (urlRole != null) {
      final parsedRole = _parseAppRole(urlRole);
      if (parsedRole != null) {
        setSessionRole(parsedRole.name);
        return parsedRole;
      }
    }

    // 2. Check Tab Session Storage
    final sessionRoleStr = getSessionRole();
    if (sessionRoleStr != null) {
      final parsedRole = _parseAppRole(sessionRoleStr);
      if (parsedRole != null) {
        return parsedRole;
      }
    }

    // 3. Fallback to activeRole in main.dart & lock it for this tab
    setSessionRole(fallback.name);
    return fallback;
  }

  // Non-web platforms use fallback directly
  return fallback;
}

AppRole? _parseAppRole(String rawRole) {
  final lower = rawRole.toLowerCase();
  if (lower.contains('seller')) return AppRole.seller;
  if (lower.contains('delivery')) return AppRole.delivery;
  if (lower.contains('buyer')) return AppRole.buyer;
  return null;
}
