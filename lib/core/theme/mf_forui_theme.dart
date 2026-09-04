import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mf_tokens.dart';

/// MakhzanFlow ForUI theme builder.
///
/// Wraps [MFTokens] into ForUI's [FThemeData] for both light and dark modes,
/// and also produces a [ThemeData] for Material widgets that coexist with ForUI.
abstract final class MFForUITheme {
  // ─── Typography ────────────────────────────────────────────────────────────

  static FTypography _buildTypography(FColors colors, {bool touch = true}) {
    // Use literal Cairo to avoid GoogleFonts network fetch in tests.
    // In production, Cairo is loaded via google_fonts or bundled; literal works via fontFamily fallback.
    const cairoFamily = 'Cairo';
    final base = FTypeface.inherit(colors: colors, touch: touch, fontFamily: cairoFamily);
    return FTypography(display: base, body: base);
  }

  // In production, GoogleFonts will download Cairo if not bundled; in tests we use literal to avoid network.
  static String _cairoFamilyFallback() => 'Cairo';

  static TextTheme _cairoTextTheme(TextTheme base) {
    // Avoid GoogleFonts network in tests — use literal.
    // In production, you may want GoogleFonts.cairoTextTheme(base) for precise Cairo loading.
    // Keeping literal ensures tests are deterministic and offline.
    try {
      // Only attempt GoogleFonts when not in test (binding not Test)
      if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) return base;
      return GoogleFonts.cairoTextTheme(base);
    } catch (_) {
      return base;
    }
  }

  static TextStyle _cairoStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    try {
      if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
        return TextStyle(fontFamily: 'Cairo', fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
      }
      return GoogleFonts.cairo(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
    } catch (_) {
      return TextStyle(fontFamily: 'Cairo', fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
    }
  }

  // ─── Light Theme — calm SaaS ─────────────────────────────────────────────
  static FThemeData get light {
    final colors = FColors(
      brightness: Brightness.light,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      barrier: const Color(0x33000000),
      background: MFTokens.backgroundLight,
      foreground: MFTokens.textPrimaryLight,
      primary: MFTokens.primary,
      primaryForeground: const Color(0xFFFFFFFF),
      secondary: MFTokens.primarySubtle,
      secondaryForeground: MFTokens.primaryDark,
      muted: MFTokens.surfaceMutedLight,
      mutedForeground: MFTokens.textSecondaryLight,
      destructive: MFTokens.errorText,
      destructiveForeground: const Color(0xFFFFFFFF),
      error: MFTokens.errorText,
      errorForeground: const Color(0xFFFFFFFF),
      card: MFTokens.cardLight,
      border: MFTokens.borderLight,
    );
    final typography = _buildTypography(colors, touch: true);
    return FThemeData(
      colors: colors,
      typography: typography,
      touch: true,
      debugLabel: 'MakhzanFlow Light',
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static FThemeData get dark {
    final colors = FColors(
      brightness: Brightness.dark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      barrier: const Color(0x7A000000),
      background: MFTokens.backgroundDark,
      foreground: MFTokens.textPrimaryDark,
      primary: const Color(0xFF34D399),
      primaryForeground: const Color(0xFF0B3A24),
      secondary: MFTokens.surfaceMutedDark,
      secondaryForeground: MFTokens.textPrimaryDark,
      muted: const Color(0xFF1F3A2E),
      mutedForeground: MFTokens.textSecondaryDark,
      destructive: const Color(0xFFEF4444),
      destructiveForeground: const Color(0xFFFFFFFF),
      error: const Color(0xFFEF4444),
      errorForeground: const Color(0xFFFFFFFF),
      card: MFTokens.cardDark,
      border: MFTokens.borderDark,
    );
    final typography = _buildTypography(colors, touch: true);
    return FThemeData(
      colors: colors,
      typography: typography,
      touch: true,
      debugLabel: 'MakhzanFlow Dark',
    );
  }

  // ─── Companion Material Theme ──────────────────────────────────────────────
  /// A lean [ThemeData] for Material widgets (e.g. Scaffold, SnackBar,
  /// BottomNavigationBar, GoRouter transitions) that harmonises with ForUI.
  static ThemeData materialLight() {
    final cairoFamily = _cairoFamilyFallback();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MFTokens.primary,
      primary: MFTokens.primary,
      secondary: MFTokens.accent,
      surface: MFTokens.surfaceLight,
      error: MFTokens.errorText,
      brightness: Brightness.light,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: cairoFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MFTokens.backgroundLight,
      cardColor: MFTokens.cardLight,
      dividerColor: MFTokens.borderLight,
      extensions: const <ThemeExtension<dynamic>>[
        MFStatusColors.light(),
        MFThemeMode(isDark: false),
      ],
    );
    return base.copyWith(
      textTheme: _cairoTextTheme(base.textTheme).copyWith(
        displayLarge: _cairoStyle(fontSize: MFTokens.fontDisplay, fontWeight: FontWeight.w700, color: MFTokens.textPrimaryLight, height: MFTokens.lineHeightTight),
        titleLarge: _cairoStyle(fontSize: MFTokens.font3XL, fontWeight: FontWeight.w700, color: MFTokens.textPrimaryLight, height: MFTokens.lineHeightTight),
        titleMedium: _cairoStyle(fontSize: MFTokens.fontXL, fontWeight: FontWeight.w600, color: MFTokens.textPrimaryLight),
        titleSmall: _cairoStyle(fontSize: MFTokens.fontLG, fontWeight: FontWeight.w600, color: MFTokens.textPrimaryLight),
        bodyLarge: _cairoStyle(fontSize: MFTokens.fontMD, fontWeight: FontWeight.w400, color: MFTokens.textPrimaryLight, height: MFTokens.lineHeightNormal),
        bodyMedium: _cairoStyle(fontSize: MFTokens.fontBase, fontWeight: FontWeight.w400, color: MFTokens.textPrimaryLight, height: MFTokens.lineHeightNormal),
        bodySmall: _cairoStyle(fontSize: MFTokens.fontSM, fontWeight: FontWeight.w400, color: MFTokens.textSecondaryLight),
        labelLarge: _cairoStyle(fontSize: MFTokens.fontMD, fontWeight: FontWeight.w600, color: MFTokens.textPrimaryLight),
        labelMedium: _cairoStyle(fontSize: MFTokens.fontSM, fontWeight: FontWeight.w500, color: MFTokens.textSecondaryLight),
        labelSmall: _cairoStyle(fontSize: MFTokens.fontXS, fontWeight: FontWeight.w500, color: MFTokens.textMutedLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MFTokens.surfaceLight,
        foregroundColor: MFTokens.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: MFTokens.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusLG)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MFTokens.inputBgLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
        hintStyle: _cairoStyle(fontSize: MFTokens.fontMD, color: MFTokens.textMutedLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.errorText)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MFTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, MFTokens.buttonHeightMD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD)),
          elevation: 0,
          textStyle: _cairoStyle(fontWeight: FontWeight.w600, fontSize: MFTokens.fontMD),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MFTokens.primary,
          side: const BorderSide(color: MFTokens.borderLight),
          minimumSize: const Size(0, MFTokens.buttonHeightMD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD)),
          textStyle: _cairoStyle(fontWeight: FontWeight.w600, fontSize: MFTokens.fontMD),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusFull)),
        side: BorderSide.none,
        backgroundColor: MFTokens.surfaceMutedLight,
        labelStyle: _cairoStyle(fontSize: MFTokens.fontSM, color: MFTokens.textPrimaryLight),
      ),
    );
  }

  static ThemeData materialDark() {
    final cairoFamily = _cairoFamilyFallback();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF34D399),
      primary: const Color(0xFF34D399),
      secondary: MFTokens.accent,
      surface: MFTokens.surfaceDark,
      error: const Color(0xFFEF4444),
      brightness: Brightness.dark,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: cairoFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MFTokens.backgroundDark,
      cardColor: MFTokens.cardDark,
      dividerColor: MFTokens.borderDark,
      extensions: const <ThemeExtension<dynamic>>[
        MFStatusColors.dark(),
        MFThemeMode(isDark: true),
      ],
    );
    return base.copyWith(
      textTheme: _cairoTextTheme(base.textTheme).copyWith(
        displayLarge: _cairoStyle(fontSize: MFTokens.fontDisplay, fontWeight: FontWeight.w700, color: MFTokens.textPrimaryDark),
        titleLarge: _cairoStyle(fontSize: MFTokens.font3XL, fontWeight: FontWeight.w700, color: MFTokens.textPrimaryDark),
        titleMedium: _cairoStyle(fontSize: MFTokens.fontXL, fontWeight: FontWeight.w600, color: MFTokens.textPrimaryDark),
        bodyMedium: _cairoStyle(fontSize: MFTokens.fontBase, fontWeight: FontWeight.w400, color: MFTokens.textPrimaryDark),
        bodySmall: _cairoStyle(fontSize: MFTokens.fontSM, fontWeight: FontWeight.w400, color: MFTokens.textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: MFTokens.surfaceDark, foregroundColor: MFTokens.textPrimaryDark, elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(color: MFTokens.cardDark, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusLG)), margin: EdgeInsets.zero),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MFTokens.inputBgDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
        hintStyle: _cairoStyle(fontSize: MFTokens.fontMD, color: MFTokens.textMutedDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.borderDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: MFTokens.borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: const BorderSide(color: Color(0xFF34D399), width: 1.5)),
      ),
    );
  }
}

// ─── Theme Extensions ─────────────────────────────────────────────────────────

/// Status badge colors (paid / partial / debt).
@immutable
class MFStatusColors extends ThemeExtension<MFStatusColors> {
  const MFStatusColors({
    required this.paidBg,
    required this.paidText,
    required this.partialBg,
    required this.partialText,
    required this.debtBg,
    required this.debtText,
  });

  const MFStatusColors.light()
      : paidBg = MFTokens.successBg,
        paidText = MFTokens.successText,
        partialBg = MFTokens.warningBg,
        partialText = MFTokens.warningText,
        debtBg = MFTokens.errorBg,
        debtText = MFTokens.errorText;

  const MFStatusColors.dark()
      : paidBg = const Color(0xFF1B4332),
        paidText = const Color(0xFF6EE7B7),
        partialBg = const Color(0xFF3B1F0A),
        partialText = const Color(0xFFFBBF24),
        debtBg = const Color(0xFF3B0A0A),
        debtText = const Color(0xFFF87171);

  final Color paidBg;
  final Color paidText;
  final Color partialBg;
  final Color partialText;
  final Color debtBg;
  final Color debtText;

  @override
  MFStatusColors copyWith({
    Color? paidBg,
    Color? paidText,
    Color? partialBg,
    Color? partialText,
    Color? debtBg,
    Color? debtText,
  }) =>
      MFStatusColors(
        paidBg: paidBg ?? this.paidBg,
        paidText: paidText ?? this.paidText,
        partialBg: partialBg ?? this.partialBg,
        partialText: partialText ?? this.partialText,
        debtBg: debtBg ?? this.debtBg,
        debtText: debtText ?? this.debtText,
      );

  @override
  MFStatusColors lerp(ThemeExtension<MFStatusColors>? other, double t) {
    if (other is! MFStatusColors) return this;
    return MFStatusColors(
      paidBg: Color.lerp(paidBg, other.paidBg, t)!,
      paidText: Color.lerp(paidText, other.paidText, t)!,
      partialBg: Color.lerp(partialBg, other.partialBg, t)!,
      partialText: Color.lerp(partialText, other.partialText, t)!,
      debtBg: Color.lerp(debtBg, other.debtBg, t)!,
      debtText: Color.lerp(debtText, other.debtText, t)!,
    );
  }
}

/// Carries current brightness so widgets can read it without MediaQuery.
@immutable
class MFThemeMode extends ThemeExtension<MFThemeMode> {
  const MFThemeMode({required this.isDark});
  final bool isDark;

  @override
  MFThemeMode copyWith({bool? isDark}) => MFThemeMode(isDark: isDark ?? this.isDark);

  @override
  MFThemeMode lerp(ThemeExtension<MFThemeMode>? other, double t) => this;
}
