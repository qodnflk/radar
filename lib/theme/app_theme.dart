import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Professional Navy Theme
  static const Color primaryNavy = Color(0xFF1A237E); // Deep Navy
  static const Color primaryNavyLight = Color(0xFF3F51B5); // Lighter Navy
  static const Color primaryNavyDark = Color(0xFF0D1B6B); // Darker Navy

  // Secondary Colors - Premium Gold Accent
  static const Color secondaryGold = Color(0xFFFFB300); // Gold
  static const Color secondaryGoldLight = Color(0xFFFFD54F); // Light Gold
  static const Color secondaryGoldDark = Color(0xFFFF8F00); // Dark Gold

  // Functional Colors
  static const Color successGreen = Color(0xFF2E7D32); // Forest Green
  static const Color warningOrange = Color(0xFFF57C00); // Orange
  static const Color errorRed = Color(0xFFD32F2F); // Red
  static const Color infoBlue = Color(0xFF1976D2); // Info Blue

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Light Gray
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceGray = Color(0xFFF5F5F5); // Light Surface
  static const Color dividerGray = Color(0xFFE0E0E0); // Divider

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark Text
  static const Color textSecondary = Color(0xFF757575); // Gray Text
  static const Color textHint = Color(0xFFBDBDBD); // Hint Text
  static const Color textOnDark = Color(0xFFFFFFFF); // White Text

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFFFFB300), // Gold
    Color(0xFF1A237E), // Navy
    Color(0xFF2E7D32), // Green
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF00796B), // Teal
    Color(0xFFD32F2F), // Red
    Color(0xFF1976D2), // Blue
    Color(0xFFAFB42B), // Lime
    Color(0xFF795548), // Brown
  ];

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        brightness: Brightness.light,
        primary: primaryNavy,
        onPrimary: textOnDark,
        secondary: secondaryGold,
        onSecondary: textPrimary,
        surface: surfaceWhite,
        onSurface: textPrimary,
        error: errorRed,
        onError: textOnDark,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: textOnDark,
        elevation: 4,
        shadowColor: Color(0x40000000),
        titleTextStyle: TextStyle(
          color: textOnDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: textOnDark,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: surfaceWhite,
        elevation: 8,
        shadowColor: Color(0x20000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),

        // Titles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),

        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textHint,
          fontFamily: 'Roboto',
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: textOnDark,
          elevation: 4,
          shadowColor: const Color(0x40000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerGray,
        thickness: 1,
        space: 1,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  // Dark Theme (for future use)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        brightness: Brightness.dark,
      ),
      // Dark theme implementation can be added later
    );
  }
}

// Custom Text Styles for Financial Data
class FinancialTextStyles {
  // Currency Amounts
  static const TextStyle currencyLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    fontFamily: 'RobotoMono',
  );

  static const TextStyle currencyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
    fontFamily: 'RobotoMono',
  );

  static const TextStyle currencySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
    fontFamily: 'RobotoMono',
  );

  // Percentage Changes
  static const TextStyle percentagePositive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.successGreen,
    fontFamily: 'RobotoMono',
  );

  static const TextStyle percentageNegative = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.errorRed,
    fontFamily: 'RobotoMono',
  );

  // Stock Symbols
  static const TextStyle stockSymbol = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryNavy,
    fontFamily: 'RobotoMono',
    letterSpacing: 0.5,
  );

  // Chart Labels
  static const TextStyle chartLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
    fontFamily: 'Roboto',
  );
}

// Custom Colors for specific use cases
class AppColors {
  static const Color portfolioProfit = AppTheme.successGreen;
  static const Color portfolioLoss = AppTheme.errorRed;
  static const Color dividendIncome = AppTheme.secondaryGold;
  static const Color nextDividend = AppTheme.infoBlue;
  static const Color portfolioValue = AppTheme.primaryNavy;

  // Chart gradient colors
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.secondaryGoldLight,
      AppTheme.secondaryGold,
    ],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.primaryNavyLight,
      AppTheme.primaryNavy,
    ],
  );
}
