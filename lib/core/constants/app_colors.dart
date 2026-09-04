import 'package:flutter/material.dart';
import '../theme/mf_tokens.dart';

/// @deprecated Use [MFTokens] directly for new code. This class now delegates
/// to [MFTokens] so there is a single source of truth and no duplicated hardcode.
/// Kept for backward-compat during migration.
class AppColors {
  static const Color primary = MFTokens.primary;
  static const Color secondary = MFTokens.primaryDark;
  static const Color accent = MFTokens.accent;
  static const Color background = MFTokens.backgroundDark;
  static const Color surface = MFTokens.surfaceLight;
  static const Color textPrimary = MFTokens.textPrimaryLight;
  static const Color textSecondary = MFTokens.textSecondaryLight;
  static const Color inputBackground = MFTokens.inputBgLight;
  static const Color inputBorder = MFTokens.borderLight;
  static const Color white = MFTokens.textInverseLight;
  static const Color grey = MFTokens.textMutedLight;
  static const Color error = MFTokens.errorText;
  static const Color transparent = Colors.transparent;

  // Dashboard specific
  static const Color appBackground = MFTokens.backgroundLight;
  static const Color cardBackground = MFTokens.cardLight;
  static const Color trendUp = MFTokens.successText;
  static const Color trendDown = MFTokens.errorText;
  static const Color inactiveNav = MFTokens.textMutedLight;

  // Tones for cards / badges
  static const Color lightGreen = MFTokens.primarySubtle;
  static const Color lightOrange = MFTokens.warningBg;
  static const Color lightRed = MFTokens.errorBg;

  // Welcome gradient — still unique, but token-adjacent
  static const Color welcomeGradientStart = MFTokens.sidebarActiveItem;
  static const Color welcomeGradientEnd = MFTokens.primaryDarker;

  // Customer specific
  static const Color lightPrimaryBg = MFTokens.primarySubtle;
  static const Color debtAmberBg = Color(0xFFFEF3C7); // keep distinct amber
  static const Color debtRedBg = MFTokens.errorBg;
  static const Color debtGreenBg = MFTokens.successBg;
  static const Color darkGrey = Color(0xFF404040);
  static const Color semiTransparent = Color(0x42000000);

  // Grays
  static const Color textDark = MFTokens.textPrimaryLight;
  static const Color labelSecondary = Color(0xFF525252);
  static const Color hintText = MFTokens.textMutedLight;
  static const Color amountGrey = MFTokens.textSecondaryLight;
  static const Color chipBg = MFTokens.surfaceMutedLight;
  static const Color searchBg = MFTokens.surfaceMutedLight;
  static const Color unselectedCardBg = MFTokens.surfaceMutedLight;
  static const Color redDark = MFTokens.errorText;
  static const Color blueLight = MFTokens.infoSubtle;
  static const Color bluePrimary = MFTokens.info;
  static const Color greyMedium = MFTokens.textSecondaryLight;

  static const Color gripColor = Color(0xFFD4D4D4);
}
