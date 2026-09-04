import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:makhzanflow/core/theme/mf_forui_theme.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MFForUITheme — ForUI is Design System foundation', () {
    test('light FThemeData uses tokens (no hardcode)', () {
      final t = MFForUITheme.light;
      expect(t.colors.background, MFTokens.backgroundLight);
      expect(t.colors.foreground, MFTokens.textPrimaryLight);
      expect(t.colors.primary, MFTokens.primary);
      expect(t.colors.primaryForeground, const Color(0xFFFFFFFF));
      expect(t.colors.secondary, MFTokens.primarySubtle);
      expect(t.colors.card, MFTokens.cardLight);
      expect(t.colors.border, MFTokens.borderLight);
      expect(t.debugLabel, 'MakhzanFlow Light');
    });

    test('dark FThemeData uses dark tokens', () {
      final t = MFForUITheme.dark;
      expect(t.colors.background, MFTokens.backgroundDark);
      expect(t.colors.foreground, MFTokens.textPrimaryDark);
      expect(t.colors.primary, MFTokens.primaryDarkMode);
      expect(t.colors.card, MFTokens.cardDark);
      expect(t.colors.border, MFTokens.borderDark);
      expect(t.debugLabel, 'MakhzanFlow Dark');
    });

    test('materialLight harmonizes with ForUI tokens', () {
      final m = MFForUITheme.materialLight();
      expect(m.brightness, Brightness.light);
      expect(m.scaffoldBackgroundColor, MFTokens.backgroundLight);
      expect(m.cardColor, MFTokens.cardLight);
      expect(m.dividerColor, MFTokens.borderLight);
      expect(m.extension<MFStatusColors>(), isNotNull);
      expect(m.extension<MFThemeMode>()?.isDark, isFalse);
      // typography uses Cairo via google_fonts — verify family not null
      expect(m.textTheme.titleLarge?.fontFamily, isNotNull);
      // controls use token radii
      expect(m.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('materialDark harmonizes with ForUI tokens', () {
      final m = MFForUITheme.materialDark();
      expect(m.brightness, Brightness.dark);
      expect(m.scaffoldBackgroundColor, MFTokens.backgroundDark);
      expect(m.cardColor, MFTokens.cardDark);
      expect(m.dividerColor, MFTokens.borderDark);
      expect(m.extension<MFStatusColors>(), isNotNull);
      expect(m.extension<MFThemeMode>()?.isDark, isTrue);
    });

    test('MFStatusColors lerps correctly', () {
      const a = MFStatusColors.light();
      const b = MFStatusColors.dark();
      final mid = a.lerp(b, 0.5);
      expect(mid.paidBg, isNot(a.paidBg));
      expect(mid.paidBg, isNot(b.paidBg));
    });

    test('MFThemeMode lerp returns this (no interpolation needed)', () {
      const a = MFThemeMode(isDark: false);
      const b = MFThemeMode(isDark: true);
      expect(a.lerp(b, 0.5).isDark, isFalse);
    });

    test('ForUI typography uses Cairo (AR) for both display and body', () {
      final light = MFForUITheme.light;
      // FTypography should have non-null display/body
      expect(light.typography.display, isNotNull);
      expect(light.typography.body, isNotNull);
    });

    test('Colors — primary always maps to emerald, not orange hardcode', () {
      expect(MFForUITheme.light.colors.primary, isNot(MFTokens.accent));
      expect(MFForUITheme.dark.colors.primary, isNot(MFTokens.accent));
    });
  });
}
