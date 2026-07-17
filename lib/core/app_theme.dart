import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Palette ──────────────────────────────────────────────────────────────

  // Light
  static const _lightBrand = Color(0xFF2563EB);
  static const _lightBrandStrong = Color(0xFF1D4ED8);
  static const _lightBg = Color(0xFFF1F5F9);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurfaceSoft = Color(0xFFF8FAFC);
  static const _lightBorder = Color(0xFFE2E8F0);
  static const _lightText = Color(0xFF0F172A);
  static const _lightMuted = Color(0xFF64748B);

  // Dark
  static const _darkBrand = Color(0xFF00C2FF);
  static const _darkBrandStrong = Color(0xFF0EA5E9);
  static const _darkBg = Color(0xFF020C13);
  static const _darkSurface = Color(0xFF0D1F2D);
  static const _darkSurfaceSoft = Color(0xFF112030);
  static const _darkBorder = Color(0xFF1E3448);
  static const _darkText = Color(0xFFE2EEF7);
  static const _darkMuted = Color(0xFF678090);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightBrand,
        brightness: Brightness.light,
        primary: _lightBrand,
        onPrimary: Colors.white,
        surface: _lightSurface,
        onSurface: _lightText,
      ),
      scaffoldBackgroundColor: _lightBg,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightBrand, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightMuted),
        hintStyle: const TextStyle(color: _lightMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightBrand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _lightBrand),
      ),
      dividerColor: _lightBorder,
      extensions: const [
        AppColors(
          brand: _lightBrand,
          brandStrong: _lightBrandStrong,
          surface: _lightSurface,
          surfaceSoft: _lightSurfaceSoft,
          border: _lightBorder,
          text: _lightText,
          muted: _lightMuted,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0284C7)],
          ),
        ),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkBrand,
        brightness: Brightness.dark,
        primary: _darkBrand,
        onPrimary: const Color(0xFF041421),
        surface: _darkSurface,
        onSurface: _darkText,
      ),
      scaffoldBackgroundColor: _darkBg,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _darkBrand, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkMuted),
        hintStyle: const TextStyle(color: _darkMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkBrand,
          foregroundColor: const Color(0xFF041421),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _darkBrand),
      ),
      dividerColor: _darkBorder,
      extensions: const [
        AppColors(
          brand: _darkBrand,
          brandStrong: _darkBrandStrong,
          surface: _darkSurface,
          surfaceSoft: _darkSurfaceSoft,
          border: _darkBorder,
          text: _darkText,
          muted: _darkMuted,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03101A), Color(0xFF0A2236), Color(0xFF134B68)],
          ),
        ),
      ],
    );
  }
}

/// ThemeExtension so we can access custom colors via Theme.of(context)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.brandStrong,
    required this.surface,
    required this.surfaceSoft,
    required this.border,
    required this.text,
    required this.muted,
    required this.gradient,
  });

  final Color brand;
  final Color brandStrong;
  final Color surface;
  final Color surfaceSoft;
  final Color border;
  final Color text;
  final Color muted;
  final LinearGradient gradient;

  @override
  AppColors copyWith({
    Color? brand,
    Color? brandStrong,
    Color? surface,
    Color? surfaceSoft,
    Color? border,
    Color? text,
    Color? muted,
    LinearGradient? gradient,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      gradient: gradient,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>()!;
}
