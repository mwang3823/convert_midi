import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

class AppColors {
  // Surface
  static const surface = Color(0xFF0D1515);
  static const surfaceDim = Color(0xFF0D1515);
  static const surfaceBright = Color(0xFF333B3B);
  static const surfaceContainerLowest = Color(0xFF080F10);
  static const surfaceContainerLow = Color(0xFF151D1E);
  static const surfaceContainer = Color(0xFF192122);
  static const surfaceContainerHigh = Color(0xFF232B2C);
  static const surfaceContainerHighest = Color(0xFF2E3637);
  static const surfaceVariant = Color(0xFF2E3637);
  static const surfaceTint = Color(0xFF00DBE7);

  static const amber = Color(0xFFFFB300);
  static const amberSoft = Color(0xFFFFC947);
  static const amberDark = Color(0xFFCC8A00);

  static const amberGlow = Color(0x33FFB300);
  static const amberSurface = Color(0xFF1F1A12);

  // On-surface
  static const onSurface = Color(0xFFDCE4E4);
  static const onSurfaceVariant = Color(0xFFB9CACB);
  static const inverseSurface = Color(0xFFDCE4E4);
  static const inverseOnSurface = Color(0xFF2A3232);

  // Outline
  static const outline = Color(0xFF849495);
  static const outlineVariant = Color(0xFF3A494B);

  // Primary — Neon Cyan
  static const primary = Color(0xFFE1FDFF);
  static const onPrimary = Color(0xFF00363A);
  static const primaryContainer = Color(0xFF00F2FF);
  static const onPrimaryContainer = Color(0xFF006A71);
  static const inversePrimary = Color(0xFF00696F);
  static const primaryFixed = Color(0xFF74F5FF);
  static const primaryFixedDim = Color(0xFF00DBE7);
  static const onPrimaryFixed = Color(0xFF002022);
  static const onPrimaryFixedVariant = Color(0xFF004F54);

  // Secondary — Magenta
  static const secondary = Color(0xFFFFACE8);
  static const onSecondary = Color(0xFF5E0053);
  static const secondaryContainer = Color(0xFFFF24E4);
  static const onSecondaryContainer = Color(0xFF520049);
  static const secondaryFixed = Color(0xFFFFD7F0);
  static const secondaryFixedDim = Color(0xFFFFACE8);
  static const onSecondaryFixed = Color(0xFF3A0033);
  static const onSecondaryFixedVariant = Color(0xFF840076);

  // Tertiary — Emerald Green
  static const tertiary = Color(0xFFE0FFE4);
  static const onTertiary = Color(0xFF00391D);
  static const tertiaryContainer = Color(0xFF00FA91);
  static const onTertiaryContainer = Color(0xFF006E3D);
  static const tertiaryFixed = Color(0xFF5BFFA1);
  static const tertiaryFixedDim = Color(0xFF00E383);
  static const onTertiaryFixed = Color(0xFF00210E);
  static const onTertiaryFixedVariant = Color(0xFF00522C);

  // Error
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Background
  static const background = Color(0xFF0D1515);
  static const onBackground = Color(0xFFDCE4E4);

  // Semantic shortcuts
  static const neonCyan = primaryContainer; // 0xFF00F2FF
  static const magenta = secondaryContainer; // 0xFFFF24E4
  static const emerald = tertiaryContainer; // 0xFF00FA91
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  // Glass effect helper (3% white)
  static const glassOverlay = Color(0x08FFFFFF); // ~3% white
}

// ─── Fonts ───────────────────────────────────────────────────────────────────

class AppFonts {
  static const spaceGrotesk = 'SpaceGrotesk';
  static const geist = 'Geist';
  static const jetBrainsMono = 'JetBrainsMono';
}

// ─── Sizes & Spacing ─────────────────────────────────────────────────────────

class AppSpacing {
  static const double unit = 4;
  static const double s1 = 4; // 1× unit
  static const double s2 = 8; // 2× unit
  static const double s3 = 12;
  static const double s4 = 16; // gutter
  static const double s5 = 20; // margin-mobile
  static const double s8 = 32;
  static const double s16 = 64;
  static const double gutter = 16;
  static const double marginMobile = 20;
  static const double marginDesktop = 40;
}

class AppRadius {
  static const double sm = 2; // 0.125rem
  static const double base = 4; // 0.25rem
  static const double md = 6; // 0.375rem
  static const double lg = 8; // 0.5rem  — cards
  static const double xl = 12; // 0.75rem — buttons
  static const double full = 9999; // pill
}

// ─── Typography ──────────────────────────────────────────────────────────────

class AppTextStyle {
  // Display — Space Grotesk 700 / 48px
  static TextStyle displayLg({Color color = AppColors.onSurface}) => TextStyle(
    fontFamily: AppFonts.spaceGrotesk,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.02 * 48,
    color: color,
  );

  // Headline LG — Space Grotesk 600 / 32px
  static TextStyle headlineLg({Color color = AppColors.onSurface}) => TextStyle(
    fontFamily: AppFonts.spaceGrotesk,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: color,
  );

  // Headline LG Mobile — Space Grotesk 600 / 24px
  static TextStyle headlineMd({Color color = AppColors.onSurface}) => TextStyle(
    fontFamily: AppFonts.spaceGrotesk,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: color,
  );

  // Body MD — Geist 400 / 16px
  static TextStyle bodyMd({Color color = AppColors.onSurface}) => TextStyle(
    fontFamily: AppFonts.geist,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: color,
  );

  // Body SM — Geist 400 / 14px
  static TextStyle bodySm({Color color = AppColors.onSurface}) => TextStyle(
    fontFamily: AppFonts.geist,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  // Label Mono — JetBrains Mono 500 / 12px
  static TextStyle labelMono({Color color = AppColors.primaryFixed}) =>
      TextStyle(
        fontFamily: AppFonts.jetBrainsMono,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0.1 * 12,
        color: color,
      );

  // Label SM — Geist 500 / 12px
  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      TextStyle(
        fontFamily: AppFonts.geist,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Shortcuts matching original API (keep for backward compat)
  static TextStyle bold({
    double size = 14,
    Color color = AppColors.onSurface,
  }) => TextStyle(
    fontFamily: AppFonts.spaceGrotesk,
    fontWeight: FontWeight.w700,
    fontSize: size,
    color: color,
  );

  static TextStyle medium({
    double size = 14,
    Color color = AppColors.onSurface,
  }) => TextStyle(
    fontFamily: AppFonts.geist,
    fontWeight: FontWeight.w500,
    fontSize: size,
    color: color,
  );

  static TextStyle regular({
    double size = 14,
    Color color = AppColors.onSurface,
  }) => TextStyle(
    fontFamily: AppFonts.geist,
    fontWeight: FontWeight.w400,
    fontSize: size,
    color: color,
  );

  static TextStyle mono({
    double size = 12,
    Color color = AppColors.primaryFixed,
  }) => TextStyle(
    fontFamily: AppFonts.jetBrainsMono,
    fontWeight: FontWeight.w500,
    fontSize: size,
    color: color,
  );
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    fontFamily: AppFonts.geist,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryContainer,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondary,
      tertiary: AppColors.tertiaryContainer,
      onTertiary: AppColors.onTertiary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surfaceContainer,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceContainerLow,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.spaceGrotesk,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.spaceGrotesk,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.spaceGrotesk,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.spaceGrotesk,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.geist,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.geist,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.geist,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.jetBrainsMono,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryFixed,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: const TextStyle(
          fontFamily: AppFonts.spaceGrotesk,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
