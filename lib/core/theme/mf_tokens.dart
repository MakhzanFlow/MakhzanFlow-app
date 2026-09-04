import 'package:flutter/material.dart';

/// MakhzanFlow Design System — Single source of truth
///
/// Quiet · Professional · SaaS
/// All colors, typography, spacing, radius & shadows flow from here
/// into [MFForUITheme] (ForUI) and [ThemeData] (Material).
///
/// DO NOT use [AppColors]/[AppSizes] for new code — use these tokens instead.
/// Legacy constants remain for backward-compat but delegate here where possible.
abstract final class MFTokens {
  // ─── Brand — Quiet SaaS (deep emerald + warm amber accent) ─────────────
  /// Primary — calm emerald, low saturation, high trust
  static const Color primary = Color(0xFF0F5132);
  static const Color primaryHover = Color(0xFF144A2E);
  static const Color primaryPressed = Color(0xFF0B3A24);
  static const Color primarySubtle = Color(0xFFE8F1EC);
  /// Dark-mode primary (mint) — used when [Brightness.dark]
  static const Color primaryDarkMode = Color(0xFF34D399);
  static const Color primaryDarkModeSubtle = Color(0xFF1B4332);

  /// Deep heading / sidebar
  static const Color primaryDark = Color(0xFF0B3A24);
  static const Color primaryDarker = Color(0xFF082A1A);

  /// Accent — warm amber for FAB / highlights (used sparingly)
  static const Color accent = Color(0xFFF97316);
  static const Color accentHover = Color(0xFFEA6D0E);
  static const Color accentSubtle = Color(0xFFFFF1E6);

  /// Informational blue & neutral
  static const Color info = Color(0xFF2563EB);
  static const Color infoSubtle = Color(0xFFEFF6FF);

  // ─── Semantic — Light (calm, low-contrast surfaces) ───────────────────────
  static const Color backgroundLight = Color(0xFFF5F7F5); // app canvas
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMutedLight = Color(0xFFF9FAFB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderStrongLight = Color(0xFFD1D5DB);
  static const Color inputBgLight = Color(0xFFFAFAFA);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF9CA3AF);
  static const Color textInverseLight = Color(0xFFFFFFFF);
  /// White text on primary/accent/gradient backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Semantic — Dark ───────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color surfaceMutedDark = Color(0xFF1F2937);
  static const Color cardDark = Color(0xFF1F2937);
  static const Color borderDark = Color(0xFF374151);
  static const Color borderStrongDark = Color(0xFF4B5563);
  static const Color inputBgDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF6B7280);
  /// Dark overlay for image badges (clear button, etc.)
  static const Color overlayDark = Color(0x80000000);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successBgDark = Color(0xFF1B4332);
  static const Color successText = Color(0xFF1B5E20);
  static const Color successTextDark = Color(0xFF6EE7B7);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color warningBgDark = Color(0xFF3B1F0A);
  static const Color warningText = Color(0xFFE65100);
  static const Color warningTextDark = Color(0xFFFBBF24);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color errorBgDark = Color(0xFF3B0A0A);
  static const Color errorText = Color(0xFFB71C1C);
  static const Color errorTextDark = Color(0xFFF87171);
  static const Color infoBgDark = Color(0xFF0F2138);

  // ─── Sidebar — calm depth ─────────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0B3A24);
  static const Color sidebarBgDark = Color(0xFF0A1628);
  static const Color sidebarActiveItem = Color(0xFF1A7A4A);
  static const Color sidebarHoverItem = Color(0xFF144A2E);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarTextInactive = Color(0xFF9DC9B2);
  static const Color sidebarTextMuted = Color(0xFF6FA18A);
  static const Color sidebarBorder = Color(0xFF1A5C38);
  static const Color sidebarBorderDark = Color(0xFF1E3A4A);

  // ─── Spacing ───────────────────────────────────────────────────────────────
  static const double sp2 = 2.0;
  static const double sp4 = 4.0;
  static const double sp6 = 6.0;
  static const double sp8 = 8.0;
  static const double sp10 = 10.0;
  static const double sp12 = 12.0;
  static const double sp16 = 16.0;
  static const double sp20 = 20.0;
  static const double sp24 = 24.0;
  static const double sp32 = 32.0;
  static const double sp40 = 40.0;
  static const double sp48 = 48.0;
  static const double sp64 = 64.0;

  // ─── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // ─── Typography Scale (quiet SaaS — restrained hierarchy) ─────────────────
  // Font family: Cairo (AR) / Inter fallback via GoogleFonts.cairo()
  static const double fontXS = 11.0;
  static const double fontSM = 12.0;
  static const double fontBase = 13.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double font2XL = 20.0;
  static const double font3XL = 24.0;
  static const double fontDisplay = 30.0;

  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.65;

  // ─── Layout ────────────────────────────────────────────────────────────────
  static const double sidebarWidth = 268.0; // slightly wider for calm breathing room
  static const double sidebarCollapsedWidth = 64.0;
  static const double contentMaxWidth = 1280.0; // center content on ultra-wide
  static const double contentPaddingMobile = 16.0;
  static const double contentPaddingTablet = 24.0;
  static const double contentPaddingDesktop = 32.0;

  // ─── Breakpoints — mobile-first ──────────────────────────────────────────
  /// < 640  → compact phone (1 col)
  /// 640–767 → large phone / small tablet (2 col)
  /// 768–1023 → tablet (sidebar appears)
  /// 1024–1279 → desktop
  /// ≥1280 → wide desktop
  static const double bpSM = 640.0;
  static const double bpMD = 768.0; // sidebar threshold
  static const double breakpointSidebar = bpMD; // legacy alias
  static const double bpLG = 1024.0;
  static const double bpXL = 1280.0;

  static bool isMobile(double w) => w < bpMD;
  static bool isTablet(double w) => w >= bpMD && w < bpLG;
  static bool isDesktop(double w) => w >= bpLG;
  static bool isWide(double w) => w >= bpXL;

  // ─── Control Sizes ─────────────────────────────────────────────────────────
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;
  static const double inputHeight = 44.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;

  // ─── Decorative overlays (on gradients / images) ─────────────────────────
  static const Color gradientOverlaySubtle = Color(0x0DFFFFFF); // white 5%
  static const Color gradientOverlayLight = Color(0x1FFFFFFF); // white 12%
  static const Color gradientOverlayMedium = Color(0x33FFFFFF); // white 20%
  static const Color gradientOverlayStrong = Color(0x4DFFFFFF); // white 30%
  static const Color gradientOverlayText = Color(0xCCFFFFFF); // white 80%
  static const Color gradientOverlayMuted = Color(0x99FFFFFF); // white 60%
  static const Color gradientOverlayFaint = Color(0x66FFFFFF); // white 40%

  // ─── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
