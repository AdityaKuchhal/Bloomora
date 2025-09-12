import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/responsive_utils.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);

    // Responsive font sizes
    final baseFontSize = _getBaseFontSize(screenType);
    final headingFontSize = _getHeadingFontSize(screenType);
    final bodyFontSize = _getBodyFontSize(screenType);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: _buildResponsiveTextTheme(
          baseFontSize, headingFontSize, bodyFontSize),
      elevatedButtonTheme: _buildResponsiveElevatedButtonTheme(screenType),
      outlinedButtonTheme: _buildResponsiveOutlinedButtonTheme(screenType),
      textButtonTheme: _buildResponsiveTextButtonTheme(screenType),
      inputDecorationTheme: _buildResponsiveInputDecorationTheme(screenType),
      cardTheme: _buildResponsiveCardTheme(screenType),
      appBarTheme: _buildResponsiveAppBarTheme(screenType),
      bottomNavigationBarTheme:
          _buildResponsiveBottomNavigationBarTheme(screenType),
    );
  }

  static ThemeData get lightThemeStatic {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.white,
        shadowColor: AppColors.shadow.withValues(alpha: 0.1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      // Dark theme implementation would go here
      // For now, using light theme as base
    );
  }

  // Helper methods for responsive theming
  static double _getBaseFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 14.0;
      case ScreenType.tablet:
        return 15.0;
      case ScreenType.desktop:
        return 16.0;
      case ScreenType.largeDesktop:
        return 17.0;
    }
  }

  static double _getHeadingFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 24.0;
      case ScreenType.tablet:
        return 28.0;
      case ScreenType.desktop:
        return 32.0;
      case ScreenType.largeDesktop:
        return 36.0;
    }
  }

  static double _getBodyFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 14.0;
      case ScreenType.tablet:
        return 15.0;
      case ScreenType.desktop:
        return 16.0;
      case ScreenType.largeDesktop:
        return 17.0;
    }
  }

  static TextTheme _buildResponsiveTextTheme(
      double baseFontSize, double headingFontSize, double bodyFontSize) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: headingFontSize + 8,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: headingFontSize + 4,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: headingFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: headingFontSize - 2,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: headingFontSize - 4,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: headingFontSize - 6,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: bodyFontSize + 2,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: bodyFontSize - 2,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: bodyFontSize + 2,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: bodyFontSize - 2,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: bodyFontSize - 2,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: bodyFontSize - 4,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  static ElevatedButtonThemeData _buildResponsiveElevatedButtonTheme(
      ScreenType screenType) {
    final padding = _getButtonPadding(screenType);
    final fontSize = _getButtonFontSize(screenType);

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius(screenType)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildResponsiveOutlinedButtonTheme(
      ScreenType screenType) {
    final padding = _getButtonPadding(screenType);
    final fontSize = _getButtonFontSize(screenType);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius(screenType)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildResponsiveTextButtonTheme(
      ScreenType screenType) {
    final padding = _getTextButtonPadding(screenType);
    final fontSize = _getButtonFontSize(screenType);

    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: padding,
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildResponsiveInputDecorationTheme(
      ScreenType screenType) {
    final padding = _getInputPadding(screenType);
    final fontSize = _getInputFontSize(screenType);
    final borderRadius = _getBorderRadius(screenType);

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: padding,
      hintStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: fontSize,
      ),
    );
  }

  static CardThemeData _buildResponsiveCardTheme(ScreenType screenType) {
    final borderRadius = _getCardBorderRadius(screenType);

    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: AppColors.white,
      shadowColor: AppColors.shadow.withValues(alpha: 0.1),
    );
  }

  static AppBarTheme _buildResponsiveAppBarTheme(ScreenType screenType) {
    final fontSize = _getAppBarFontSize(screenType);
    final height = _getAppBarHeight(screenType);

    return AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: height,
      titleTextStyle: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildResponsiveBottomNavigationBarTheme(
      ScreenType screenType) {
    final fontSize = _getBottomNavFontSize(screenType);

    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  // Helper methods for responsive values
  static EdgeInsets _getButtonPadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 18);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 36, vertical: 22);
    }
  }

  static EdgeInsets _getTextButtonPadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 14);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 22, vertical: 18);
    }
  }

  static EdgeInsets _getInputPadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 18);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 22, vertical: 22);
    }
  }

  static double _getButtonFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 17.0;
      case ScreenType.desktop:
        return 18.0;
      case ScreenType.largeDesktop:
        return 19.0;
    }
  }

  static double _getInputFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 17.0;
      case ScreenType.desktop:
        return 18.0;
      case ScreenType.largeDesktop:
        return 19.0;
    }
  }

  static double _getAppBarFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 18.0;
      case ScreenType.tablet:
        return 20.0;
      case ScreenType.desktop:
        return 22.0;
      case ScreenType.largeDesktop:
        return 24.0;
    }
  }

  static double _getBottomNavFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 12.0;
      case ScreenType.tablet:
        return 13.0;
      case ScreenType.desktop:
        return 14.0;
      case ScreenType.largeDesktop:
        return 15.0;
    }
  }

  static double _getAppBarHeight(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 56.0;
      case ScreenType.tablet:
        return 64.0;
      case ScreenType.desktop:
        return 72.0;
      case ScreenType.largeDesktop:
        return 80.0;
    }
  }

  static double _getBorderRadius(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 12.0;
      case ScreenType.tablet:
        return 14.0;
      case ScreenType.desktop:
        return 16.0;
      case ScreenType.largeDesktop:
        return 18.0;
    }
  }

  static double _getCardBorderRadius(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 18.0;
      case ScreenType.desktop:
        return 20.0;
      case ScreenType.largeDesktop:
        return 22.0;
    }
  }
}
