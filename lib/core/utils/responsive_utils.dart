import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Get screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  // Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  // Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.largeDesktop;
  }

  // Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(32.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40.0);
    }
  }

  // Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 40.0);
    }
  }

  // Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(vertical: 16.0);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(vertical: 20.0);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(vertical: 24.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(vertical: 32.0);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(
      BuildContext context, double baseIconSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.1;
      case ScreenType.desktop:
        return baseIconSize * 1.2;
      case ScreenType.largeDesktop:
        return baseIconSize * 1.3;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.2;
      case ScreenType.desktop:
        return baseSpacing * 1.4;
      case ScreenType.largeDesktop:
        return baseSpacing * 1.6;
    }
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(
      BuildContext context, double baseRadius) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseRadius;
      case ScreenType.tablet:
        return baseRadius * 1.1;
      case ScreenType.desktop:
        return baseRadius * 1.2;
      case ScreenType.largeDesktop:
        return baseRadius * 1.3;
    }
  }

  // Get responsive width percentage
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  // Get responsive height percentage
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  // Get max content width for desktop layouts
  static double getMaxContentWidth(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 800;
      case ScreenType.desktop:
        return 1200;
      case ScreenType.largeDesktop:
        return 1400;
    }
  }

  // Get responsive column count for grid layouts
  static int getResponsiveColumnCount(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  // Get responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenType = getScreenType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth - 32; // Full width minus padding
      case ScreenType.tablet:
        return (screenWidth - 48) / 2; // Half width minus padding
      case ScreenType.desktop:
        return (screenWidth - 64) / 3; // Third width minus padding
      case ScreenType.largeDesktop:
        return (screenWidth - 80) / 4; // Quarter width minus padding
    }
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

