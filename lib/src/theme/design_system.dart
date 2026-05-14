import 'package:flutter/material.dart';

class GatherColors {
  const GatherColors._();

  static const background = Color(0xFFF0F3FA);
  static const softBlue = Color(0xFFD5DEEF);
  static const lightBlue = Color(0xFFB1C9EF);
  static const midBlue = Color(0xFF8AAEE0);
  static const coolBlue = Color(0xFF628ECB);
  static const primary = Color(0xFF395886);
  static const primaryLight = lightBlue;
  static const primaryDark = midBlue;
  static const dark = Color(0xFF171D35);
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF171D35);
  static const textSecondary = Color(0xFF6B7280);
  static const error = Color(0xFFEB445A);
  static const success = Color(0xFF2DD36F);

  // Helper to create a color with opacity without using deprecated withOpacity
  static Color withOpacity(Color color, double opacity) {
    final a = (opacity * 255).round().clamp(0, 255);
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    return Color.fromARGB(a, r, g, b);
  }
}

class GatherGradients {
  const GatherGradients._();

  static const primaryGradient = LinearGradient(
    colors: [GatherColors.primaryLight, GatherColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const buttonGradient = LinearGradient(
    colors: [GatherColors.primary, GatherColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class GatherTheme {
  const GatherTheme._();

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: GatherColors.primary,
      scaffoldBackgroundColor: GatherColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: GatherColors.primary,
        surface: GatherColors.surface,
        error: GatherColors.error,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GatherColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GatherColors.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: GatherColors.white,
          backgroundColor: GatherColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: GatherColors.primary,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: base.colorScheme.copyWith(
        primary: GatherColors.primary,
        surface: const Color(0xFF1E1E1E),
        error: GatherColors.error,
        onPrimary: GatherColors.white,
      ),
      textTheme: _buildDarkTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GatherColors.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: GatherColors.white,
          backgroundColor: GatherColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.textSecondary,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.white,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.white,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.white,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Poppins',
        color: GatherColors.withOpacity(GatherColors.textSecondary, 0.85),
      ),
    );
  }
}
