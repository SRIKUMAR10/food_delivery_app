import 'package:flutter/material.dart';

/// Defines standard cross-platform screen breakpoint thresholds.
class ResponsiveBreakpoints {
  static const double mobile = 650.0;
  static const double tablet = 1100.0;
  static const double desktop = 1440.0;
}

/// Helper to detect screen sizing anywhere in the widget tree.
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tablet;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.mobile;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;
}

/// Generic value provider that returns different values depending on viewport size.
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T resolve(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= ResponsiveBreakpoints.tablet) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.mobile) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// Adaptive layout builder widget that switches builders based on device width.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) mobileBody;
  final Widget Function(BuildContext context)? tabletBody;
  final Widget Function(BuildContext context)? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return desktopBody != null
              ? desktopBody!(context)
              : (tabletBody != null ? tabletBody!(context) : mobileBody(context));
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          return tabletBody != null
              ? tabletBody!(context)
              : mobileBody(context);
        } else {
          return mobileBody(context);
        }
      },
    );
  }
}

/// Adaptive max-width container for centering content on large monitors (Chrome Web, Windows, macOS, Linux).
class AdaptiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;

  const AdaptiveContentContainer({
    super.key,
    required this.child,
    this.maxContentWidth = 1200.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
