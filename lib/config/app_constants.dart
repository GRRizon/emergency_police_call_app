import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double circle = 999.0;
}

class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> smallList = [small];
  static const List<BoxShadow> mediumList = [medium];
  static const List<BoxShadow> largeList = [large];
}

class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration shortest = Duration(milliseconds: 150);
  static const Duration shorter = Duration(milliseconds: 200);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
  static const Duration longer = Duration(milliseconds: 1200);
  static const Duration longest = Duration(milliseconds: 2000);
}
