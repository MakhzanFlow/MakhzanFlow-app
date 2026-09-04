import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MakhzanFlowTheme {
  static const Color darkGreen = Color(0xFF0B3A24);
  static const Color mainGreen = Color(0xFF0F5132);
  static const Color orange = Color(0xFFF97316);

  static const Color softGreen = Color(0xFFE8F1EC);
  static const Color lightOrange = Color(0xFFFFF1E6);
  static const Color softRed = Color(0xFFFEE2E2);
  static const Color grayBorder = Color(0xFFE5E5E5);

  static const Color primaryText = darkGreen;
  static const Color secondaryText = Color(0xFF737373);
  static const Color mutedText = Color(0xFF64748B);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: mainGreen,
      primary: mainGreen,
      secondary: orange,
      surface: Colors.white,
      error: const Color(0xFFB91C1C),
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: primaryText,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryText,
      ),
    );

    const rCard = 24.0;
    const rControl = 16.0;

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F8F7),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: mainGreen.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelSmall?.copyWith(color: primaryText),
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rControl),
          borderSide: const BorderSide(color: grayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rControl),
          borderSide: const BorderSide(color: mainGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rControl),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rControl),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: mutedText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rControl),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mainGreen,
          minimumSize: const Size(0, 56),
          side: const BorderSide(color: mainGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rControl),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: mainGreen,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: grayBorder,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: mainGreen,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        MakhzanFlowStatusColors(
          paidBg: softGreen,
          paidText: mainGreen,
          partialBg: lightOrange,
          partialText: orange,
          debtBg: softRed,
          debtText: Color(0xFFB91C1C),
        ),
      ],
    );
  }
}

@immutable
class MakhzanFlowStatusColors extends ThemeExtension<MakhzanFlowStatusColors> {
  const MakhzanFlowStatusColors({
    required this.paidBg,
    required this.paidText,
    required this.partialBg,
    required this.partialText,
    required this.debtBg,
    required this.debtText,
  });

  final Color paidBg;
  final Color paidText;
  final Color partialBg;
  final Color partialText;
  final Color debtBg;
  final Color debtText;

  @override
  MakhzanFlowStatusColors copyWith({
    Color? paidBg,
    Color? paidText,
    Color? partialBg,
    Color? partialText,
    Color? debtBg,
    Color? debtText,
  }) {
    return MakhzanFlowStatusColors(
      paidBg: paidBg ?? this.paidBg,
      paidText: paidText ?? this.paidText,
      partialBg: partialBg ?? this.partialBg,
      partialText: partialText ?? this.partialText,
      debtBg: debtBg ?? this.debtBg,
      debtText: debtText ?? this.debtText,
    );
  }

  @override
  MakhzanFlowStatusColors lerp(
    ThemeExtension<MakhzanFlowStatusColors>? other,
    double t,
  ) {
    if (other is! MakhzanFlowStatusColors) return this;
    return MakhzanFlowStatusColors(
      paidBg: Color.lerp(paidBg, other.paidBg, t)!,
      paidText: Color.lerp(paidText, other.paidText, t)!,
      partialBg: Color.lerp(partialBg, other.partialBg, t)!,
      partialText: Color.lerp(partialText, other.partialText, t)!,
      debtBg: Color.lerp(debtBg, other.debtBg, t)!,
      debtText: Color.lerp(debtText, other.debtText, t)!,
    );
  }
}
