import 'package:flutter/material.dart';

/// Custom Theme Extension to provide domain-specific Sushiro plate colors.
@immutable
class SushiroPlateColors extends ThemeExtension<SushiroPlateColors> {
  final Color? redPlate;
  final Color? silverPlate;
  final Color? goldPlate;
  final Color? blackPlate;

  const SushiroPlateColors({
    required this.redPlate,
    required this.silverPlate,
    required this.goldPlate,
    required this.blackPlate,
  });

  @override
  SushiroPlateColors copyWith({
    Color? redPlate,
    Color? silverPlate,
    Color? goldPlate,
    Color? blackPlate,
  }) {
    return SushiroPlateColors(
      redPlate: redPlate ?? this.redPlate,
      silverPlate: silverPlate ?? this.silverPlate,
      goldPlate: goldPlate ?? this.goldPlate,
      blackPlate: blackPlate ?? this.blackPlate,
    );
  }

  @override
  SushiroPlateColors lerp(ThemeExtension<SushiroPlateColors>? other, double t) {
    if (other is! SushiroPlateColors) {
      return this;
    }
    return SushiroPlateColors(
      redPlate: Color.lerp(redPlate, other.redPlate, t),
      silverPlate: Color.lerp(silverPlate, other.silverPlate, t),
      goldPlate: Color.lerp(goldPlate, other.goldPlate, t),
      blackPlate: Color.lerp(blackPlate, other.blackPlate, t),
    );
  }
}

/// Definitive theme configuration for Sushiro Checkout & Split-Bill app.
class SushiroTheme {
  // Brand color: Crimson Red
  static const Color brandRed = Color(0xFFD32F2F);

  // Plate custom colors
  static const Color colorRedPlate = Color(0xFFD32F2F);
  static const Color colorSilverPlate = Color(0xFF9E9E9E);
  static const Color colorGoldPlate = Color(0xFFFFC107);
  static const Color colorBlackPlate = Color(0xFF212121);

  static final SushiroPlateColors _plateColorsLight = const SushiroPlateColors(
    redPlate: colorRedPlate,
    silverPlate: colorSilverPlate,
    goldPlate: colorGoldPlate,
    blackPlate: colorBlackPlate,
  );

  static final SushiroPlateColors _plateColorsDark = const SushiroPlateColors(
    redPlate: colorRedPlate,
    silverPlate: colorSilverPlate,
    goldPlate: colorGoldPlate,
    blackPlate: colorBlackPlate,
  );

  /// Light theme data using Material 3 and Sushiro branding.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandRed,
        brightness: Brightness.light,
        primary: brandRed,
      ),
      scaffoldBackgroundColor: const Color(0xFFFBFBFB),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[
        _plateColorsLight,
      ],
    );
  }

  /// Dark theme data using Material 3 and Sushiro branding.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandRed,
        brightness: Brightness.dark,
        primary: brandRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[
        _plateColorsDark,
      ],
    );
  }
}
