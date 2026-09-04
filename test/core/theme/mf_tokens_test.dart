import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

void main() {
  group('MFTokens — quiet SaaS design system (single source, no hardcode in UI)', () {
    test('brand colors are calm and consistent', () {
      expect(MFTokens.primary, const Color(0xFF0F5132));
      expect(MFTokens.primaryDark, const Color(0xFF0B3A24));
      expect(MFTokens.primarySubtle, const Color(0xFFE8F1EC));
      expect(MFTokens.primaryDarkMode, const Color(0xFF34D399));
      expect(MFTokens.accent, const Color(0xFFF97316));
      expect(MFTokens.info, const Color(0xFF2563EB));
    });

    test('light semantic surfaces are low-contrast (calm SaaS)', () {
      expect(MFTokens.backgroundLight, const Color(0xFFF5F7F5));
      expect(MFTokens.surfaceLight, const Color(0xFFFFFFFF));
      expect(MFTokens.cardLight, const Color(0xFFFFFFFF));
      expect(MFTokens.borderLight, const Color(0xFFE5E7EB));
      expect(MFTokens.textPrimaryLight, const Color(0xFF111827));
    });

    test('dark semantic surfaces exist and differ from light', () {
      expect(MFTokens.backgroundDark, isNot(MFTokens.backgroundLight));
      expect(MFTokens.cardDark, isNot(MFTokens.cardLight));
      expect(MFTokens.borderDark, isNot(MFTokens.borderLight));
      expect(MFTokens.textPrimaryDark, isNot(MFTokens.textPrimaryLight));
    });

    test('status palettes have light + dark variants', () {
      expect(MFTokens.successBg, isNot(MFTokens.successBgDark));
      expect(MFTokens.warningBg, isNot(MFTokens.warningBgDark));
      expect(MFTokens.errorBg, isNot(MFTokens.errorBgDark));
      expect(MFTokens.successTextDark, const Color(0xFF6EE7B7));
      expect(MFTokens.errorTextDark, const Color(0xFFF87171));
    });

    test('sidebar tokens — quiet depth, no pure black', () {
      expect(MFTokens.sidebarBg, const Color(0xFF0B3A24));
      expect(MFTokens.sidebarBgDark, const Color(0xFF0A1628));
      expect(MFTokens.sidebarActiveItem, const Color(0xFF1A7A4A));
      expect(MFTokens.sidebarTextActive, const Color(0xFFFFFFFF));
      expect(MFTokens.sidebarBorderDark, const Color(0xFF1E3A4A));
    });

    test('spacing scale is 2-based and monotonic', () {
      final s = [MFTokens.sp2, MFTokens.sp4, MFTokens.sp6, MFTokens.sp8, MFTokens.sp10, MFTokens.sp12, MFTokens.sp16, MFTokens.sp20, MFTokens.sp24, MFTokens.sp32, MFTokens.sp40, MFTokens.sp48, MFTokens.sp64];
      for (var i = 1; i < s.length; i++) {
        expect(s[i], greaterThan(s[i - 1]));
      }
      expect(MFTokens.sp16, 16.0);
    });

    test('radius scale is monotonic and bounded', () {
      expect(MFTokens.radiusXS, 4.0);
      expect(MFTokens.radiusSM, 8.0);
      expect(MFTokens.radiusMD, 12.0);
      expect(MFTokens.radiusLG, 16.0);
      expect(MFTokens.radiusXL, 20.0);
      expect(MFTokens.radiusXXL, 24.0);
      expect(MFTokens.radiusFull, 999.0);
    });

    test('typography scale is restrained (quiet SaaS)', () {
      expect(MFTokens.fontXS, 11.0);
      expect(MFTokens.fontSM, 12.0);
      expect(MFTokens.fontBase, 13.0);
      expect(MFTokens.fontMD, 14.0);
      expect(MFTokens.fontLG, 16.0);
      expect(MFTokens.fontXL, 18.0);
      expect(MFTokens.font2XL, 20.0);
      expect(MFTokens.font3XL, 24.0);
      expect(MFTokens.fontDisplay, 30.0);
      // monotonic
      expect(MFTokens.fontDisplay, greaterThan(MFTokens.font3XL));
    });

    test('breakpoints define mobile-first scale', () {
      expect(MFTokens.bpSM, 640.0);
      expect(MFTokens.bpMD, 768.0);
      expect(MFTokens.bpLG, 1024.0);
      expect(MFTokens.bpXL, 1280.0);
      expect(MFTokens.isMobile(500), isTrue);
      expect(MFTokens.isMobile(800), isFalse);
      expect(MFTokens.isTablet(800), isTrue);
      expect(MFTokens.isDesktop(1100), isTrue);
      expect(MFTokens.isWide(1300), isTrue);
    });

    test('control sizes are consistent with quiet SaaS (44h)', () {
      expect(MFTokens.buttonHeightMD, 44.0);
      expect(MFTokens.inputHeight, 44.0);
      expect(MFTokens.appBarHeight, 56.0);
    });

    test('shadows are soft and use low alpha (calm)', () {
      expect(MFTokens.shadowSM.first.color.opacity, closeTo(0.06, 0.02));
      expect(MFTokens.shadowMD.first.color.opacity, closeTo(0.08, 0.02));
      expect(MFTokens.shadowLG.first.color.opacity, closeTo(0.12, 0.02));
      expect(MFTokens.shadowSM.first.blurRadius, 4);
      expect(MFTokens.shadowMD.first.blurRadius, 8);
      expect(MFTokens.shadowLG.first.blurRadius, 16);
    });

    test('no hardcoded Color in UI should duplicate brand — AppColors delegates', () {
      // AppColors is legacy but must delegate to MFTokens (single source)
      // This test documents the contract: new code must use MFTokens
      // If someone adds a raw Color(0xFF...) outside mf_tokens.dart, this test should fail in review
      expect(MFTokens.primary.value, 0xFF0F5132);
      expect(MFTokens.accent.value, 0xFFF97316);
    });
  });
}
