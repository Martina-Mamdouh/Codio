import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static bool isCompactHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 700;

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return 1120;
    if (width >= tabletBreakpoint) return 920;
    return width;
  }

  static int adaptiveCount({
    required double availableWidth,
    required double minTileWidth,
    int minCount = 1,
    int? maxCount,
  }) {
    final raw = (availableWidth / minTileWidth).floor();
    final clampedMin = math.max(raw, minCount);
    if (maxCount != null) {
      return math.min(clampedMin, maxCount);
    }
    return clampedMin;
  }
}

