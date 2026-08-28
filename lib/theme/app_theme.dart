import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeVariant { sanctum, midnight, whiteMinimal }

class AppThemeController extends ChangeNotifier {
  AppThemeVariant variant = AppThemeVariant.sanctum;

  Future<void> load() async {
    final value = (await SharedPreferences.getInstance()).getString('appTheme');
    variant = AppThemeVariant.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeVariant.sanctum,
    );
  }

  Future<void> setVariant(AppThemeVariant value) async {
    variant = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('appTheme', value.name);
  }
}

final appThemeController = AppThemeController();

class AppColors {
  static const Color primary = Color(0xFF7B1FA2);
  static const Color primaryDark = Color(0xFF4A148C);
  static const Color primaryLight = Color(0xFFE1BEE7);
  static const Color accent = Color(0xFFE91E63);
  static const Color background = Color(0xFFFFE5EC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D004B);
  static const Color textSecondary = Color(0xFF5A3D7A);
  static const Color textMuted = Color(0xFF7A6B8A);
  static const Color paid = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFF9800);
  static const Color overdue = Color(0xFFE53935);
  static const Color border = Color(0xFFF3E8FF);
  static const Color cardBg = Color(0xFFFAFAFA);
}

class AppTheme {
  static ThemeData get theme {
    return themeFor(AppThemeVariant.sanctum);
  }

  static ThemeData themeFor(AppThemeVariant variant) {
    final isMidnight = variant == AppThemeVariant.midnight;
    final isMinimal = variant == AppThemeVariant.whiteMinimal;
    final primary = isMidnight
        ? const Color(0xFF197C86)
        : isMinimal
            ? const Color(0xFF252B33)
            : AppColors.primary;
    final background = isMidnight
        ? const Color(0xFFEAF3F5)
        : isMinimal
            ? const Color(0xFFF7F8FA)
            : AppColors.background;
    final text = isMidnight
        ? const Color(0xFF12343B)
        : isMinimal
            ? const Color(0xFF20252B)
            : AppColors.textPrimary;
    final surface = isMinimal ? const Color(0xFFFFFFFF) : AppColors.surface;

    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: isMidnight ? const Color(0xFFE28B4B) : AppColors.accent,
        surface: surface,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: primary.withValues(alpha: .35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
