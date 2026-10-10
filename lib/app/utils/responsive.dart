import 'package:flutter/material.dart';

/// Responsive utility class for managing responsive design across all devices
class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late bool isMobilePortrait;
  static late bool isMobileLandscape;
  static late bool isTabletPortrait;
  static late bool isTabletLandscape;
  static late bool isDesktop;

  /// Initialize responsive design based on device screen size
  static void init(BoxConstraints constraints) {
    screenWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
        ? constraints.maxWidth
        : 400.0;
    screenHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
        ? constraints.maxHeight
        : 800.0;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    textMultiplier = blockSizeHorizontal;
    imageSizeMultiplier = blockSizeVertical;

    // Device type detection
    isMobilePortrait = screenWidth < 450 && screenHeight >= screenWidth;
    isMobileLandscape = screenWidth >= 450 && screenHeight < screenWidth;
    isTabletPortrait =
        screenWidth < 850 && screenWidth >= 450 && screenHeight >= screenWidth;
    isTabletLandscape = screenWidth >= 850 && screenHeight < screenWidth;
    isDesktop = screenWidth >= 1000;
  }

  /// Get responsive padding based on device type
  static EdgeInsets get responsivePadding {
    if (isDesktop) return const EdgeInsets.all(32);
    if (isTabletPortrait || isTabletLandscape) return const EdgeInsets.all(24);
    return const EdgeInsets.all(20);
  }

  /// Get responsive padding horizontal only
  static EdgeInsets get responsivePaddingHorizontal {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 48);
    if (isTabletPortrait || isTabletLandscape) {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
    return const EdgeInsets.symmetric(horizontal: 20);
  }

  /// Get responsive padding vertical only
  static EdgeInsets get responsivePaddingVertical {
    if (isDesktop) return const EdgeInsets.symmetric(vertical: 32);
    if (isTabletPortrait || isTabletLandscape) {
      return const EdgeInsets.symmetric(vertical: 24);
    }
    return const EdgeInsets.symmetric(vertical: 18);
  }

  /// Get responsive font size
  static double responsiveFontSize(double mobileSize) {
    if (isDesktop) return mobileSize * 1.4;
    if (isTabletPortrait || isTabletLandscape) return mobileSize * 1.2;
    return mobileSize;
  }

  /// Get responsive height for buttons
  static double get buttonHeight {
    if (isDesktop) return 56;
    if (isTabletPortrait || isTabletLandscape) return 54;
    return 52;
  }

  /// Get responsive border radius
  static double get responsiveBorderRadius {
    if (isDesktop) return 28;
    if (isTabletPortrait || isTabletLandscape) return 26;
    return 24;
  }

  /// Get grid cross axis count based on device
  static int get gridCrossAxisCount {
    if (isDesktop) return 4;
    if (isTabletLandscape) return 3;
    if (isTabletPortrait) return 2;
    return 1;
  }

  /// Get max width for centered containers on desktop
  static double get maxContentWidth {
    if (isDesktop) return 900;
    return screenWidth;
  }

  /// Get safe screen height (excluding keyboard and status bar)
  static double getSafeHeight(BuildContext context) {
    return screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
  }

  /// Check if device is in landscape mode
  static bool get isLandscape => screenWidth > screenHeight;

  /// Check if device is in portrait mode
  static bool get isPortrait => screenHeight > screenWidth;
}
