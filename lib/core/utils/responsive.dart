import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static const double _mobileMax = 600;
  static const double _tabletMax = 1024;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _mobileMax) return ScreenSize.mobile;
    if (width < _tabletMax) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  /// Maximum content width for auth pages
  static double authCardWidth(BuildContext context) {
    final size = of(context);
    switch (size) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 520;
      case ScreenSize.desktop:
        return 480;
    }
  }

  /// Horizontal padding for auth pages
  static double authPadding(BuildContext context) {
    final size = of(context);
    switch (size) {
      case ScreenSize.mobile:
        return 24;
      case ScreenSize.tablet:
        return 40;
      case ScreenSize.desktop:
        return 40;
    }
  }
}
