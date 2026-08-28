import 'dart:async';
import 'package:flutter/material.dart';

/// Thread-safe navigation helper with double-tap debouncing and context safety.
class NavigationHelper {
  NavigationHelper._();

  static DateTime? _lastNavigationTime;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  /// Checks whether navigation is allowed (debounced)
  static bool canNavigate() {
    final now = DateTime.now();
    if (_lastNavigationTime != null &&
        now.difference(_lastNavigationTime!) < _debounceDuration) {
      return false;
    }
    _lastNavigationTime = now;
    return true;
  }

  /// Pushes a named route safely with debouncing and context.mounted check.
  static Future<T?> pushNamedSafe<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (!canNavigate()) return null;
    if (!context.mounted) return null;
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Pushes replacement for a named route safely.
  static Future<T?> pushReplacementNamedSafe<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (!canNavigate()) return null;
    if (!context.mounted) return null;
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pushes a named route and removes all until predicate.
  static Future<T?> pushNamedAndRemoveUntilSafe<T extends Object?>(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    if (!canNavigate()) return null;
    if (!context.mounted) return null;
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Safely pops the current route if possible and context is mounted.
  static bool popSafe<T extends Object?>(BuildContext context, [T? result]) {
    if (!context.mounted) return false;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop<T>(result);
      return true;
    }
    return false;
  }
}
