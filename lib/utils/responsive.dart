import 'package:flutter/material.dart';

/// Utility class for responsive design scaling.
/// Based on a design draft size (e.g., iPhone 13 Pro: 390x844).
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static late double devicePixelRatio;
  static late double textScaleFactor;

  // Design dimensions (Draft size)
  static const double draftWidth = 390.0;
  static const double draftHeight = 844.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    textScaleFactor = _mediaQueryData.textScaler.scale(1.0);

    _blockSizeHorizontal = screenWidth / 100;
    _blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  /// Scales width based on design draft width.
  static double w(double width) {
    return (width / draftWidth) * screenWidth;
  }

  /// Scales height based on design draft height.
  static double h(double height) {
    return (height / draftHeight) * screenHeight;
  }

  /// Scales font size based on width scaling (common practice)
  /// or a combination of both to maintain aspect ratio as much as possible.
  static double sp(double fontSize) {
    // Scaling font based on width to ensure it fits in containers
    // We also consider the textScaleFactor from system settings
    return (fontSize / draftWidth) * screenWidth;
  }

  /// Returns a responsive value based on a percentage of screen width.
  static double wp(double percent) {
    return _blockSizeHorizontal * percent;
  }

  /// Returns a responsive value based on a percentage of screen height.
  static double hp(double percent) {
    return _blockSizeVertical * percent;
  }
}

/// Extension for convenient usage of responsive scaling on double.
extension ResponsiveDouble on double {
  double get w => Responsive.w(this);
  double get h => Responsive.h(this);
  double get sp => Responsive.sp(this);
  double get wp => Responsive.wp(this);
  double get hp => Responsive.hp(this);
}

/// Extension for convenient usage of responsive scaling on int.
extension ResponsiveInt on int {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
  double get wp => Responsive.wp(toDouble());
  double get hp => Responsive.hp(toDouble());
}
