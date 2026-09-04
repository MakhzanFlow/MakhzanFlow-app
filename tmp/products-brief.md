# Task: Migrate ALL Products Feature Files from AppColors/AppSizes/screenutil to MFTokens

## Goal
Rebrand every file in `lib/features/products/` to use the existing ForUI design system (`MFTokens`) instead of `AppColors`, `AppSizes`, and `flutter_screenutil`. This is part of a full-app ForUI rebrand.

## Files to Migrate

ALL files under `lib/features/products/presentation/` — pages and widgets (~15 files):

Pages:
1. `lib/features/products/presentation/pages/products_screen.dart`
2. `lib/features/products/presentation/pages/add_edit_product_screen.dart`
3. `lib/features/products/presentation/pages/product_details_screen.dart`

Widgets:
4. `lib/features/products/presentation/widgets/product_card.dart`
5. `lib/features/products/presentation/widgets/product_screen_header.dart`
6. `lib/features/products/presentation/widgets/product_empty_view.dart`
7. `lib/features/products/presentation/widgets/product_error_view.dart`
8. `lib/features/products/presentation/widgets/product_loading_view.dart`
9. `lib/features/products/presentation/widgets/product_form_fields.dart`
10. `lib/features/products/presentation/widgets/product_image_picker_field.dart`
11. `lib/features/products/presentation/widgets/product_save_button.dart`
12. `lib/features/products/presentation/widgets/product_quantity_adjustment.dart`
13. `lib/features/products/presentation/widgets/product_delete_dialog.dart`
14. `lib/features/products/presentation/widgets/product_details_sections.dart`
15. `lib/features/products/presentation/widgets/inventory_movement_list.dart`
16. `lib/features/products/presentation/widgets/dashed_border_painter.dart`

## Migration Pattern (apply to EVERY file)

For each file:
1. Remove old imports: `import 'package:flutter_screenutil/flutter_screenutil.dart';`, `import '...app_colors.dart';`, `import '...app_sizes.dart';`
2. Add new import: `import '../../../../core/theme/mf_tokens.dart';` (adjust relative path per file)
3. Replace all `AppColors.X` with corresponding `MFTokens.X` (see mapping)
4. Replace all `AppSizes.X` with corresponding `MFTokens.X` (see mapping)
5. Remove screenutil `.w`, `.h`, `.sp`, `.r` extensions — use raw doubles or MFTokens
6. Add dark mode support: `final isDark = Theme.of(context).brightness == Brightness.dark;` then ternary for colors

## Color Mapping
- `AppColors.primary` → `MFTokens.primary` (dark: `MFTokens.primaryDarkMode`)
- `AppColors.secondary` → `MFTokens.primaryDark`
- `AppColors.accent` → `MFTokens.accent`
- `AppColors.white` → `Colors.white`
- `AppColors.grey` → `isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight`
- `AppColors.textPrimary` → `isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight`
- `AppColors.textSecondary` → `isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight`
- `AppColors.textDark` → `isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight`
- `AppColors.redDark` → `isDark ? MFTokens.errorTextDark : MFTokens.errorText`
- `AppColors.error` → `isDark ? MFTokens.errorTextDark : MFTokens.errorText`
- `AppColors.cardBackground` → `isDark ? MFTokens.cardDark : MFTokens.cardLight`
- `AppColors.surface` → `isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight`
- `AppColors.inputBackground` → `isDark ? MFTokens.inputBgDark : MFTokens.inputBgLight`
- `AppColors.inputBorder` → `isDark ? MFTokens.borderDark : MFTokens.borderLight`
- `AppColors.appBackground` → `isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight`
- `AppColors.lightGreen` → `isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle`
- `AppColors.lightRed` → `isDark ? MFTokens.errorBgDark : MFTokens.errorBg`
- `AppColors.lightOrange` → `isDark ? MFTokens.warningBgDark : MFTokens.warningBg`
- `AppColors.trendUp` → `MFTokens.successText`
- `AppColors.trendDown` → `isDark ? MFTokens.errorTextDark : MFTokens.errorText`
- `AppColors.chipBg` → `isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight`
- `AppColors.searchBg` → `isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight`
- `AppColors.unselectedCardBg` → `isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight`
- `AppColors.hintText` → `isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight`
- `AppColors.amountGrey` → `isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight`
- `AppColors.darkGrey` → `const Color(0xFF404040)`
- `AppColors.inactiveNav` → `isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight`
- `AppColors.transparent` → `Colors.transparent`

## Size Mapping
- `AppSizes.spacingTiny` → `MFTokens.sp4`
- `AppSizes.spacingSmall` → `MFTokens.sp8`
- `AppSizes.spacingMedium` → `MFTokens.sp16`
- `AppSizes.spacingLarge` → `MFTokens.sp24`
- `AppSizes.spacingXLarge` → `MFTokens.sp32`
- `AppSizes.spacingXXLarge` → `MFTokens.sp48`
- `AppSizes.fontSmall` → `MFTokens.fontXS`
- `AppSizes.fontMedium` → `MFTokens.fontSM`
- `AppSizes.fontML` → `MFTokens.fontBase`
- `AppSizes.fontLarge` → `MFTokens.fontMD`
- `AppSizes.fontXLarge` → `MFTokens.fontLG`
- `AppSizes.fontXXLarge` → `MFTokens.font2XL`
- `AppSizes.fontXXXLarge` → `MFTokens.fontDisplay`
- `AppSizes.iconSmall` → `MFTokens.sp16`
- `AppSizes.iconMedium` → `MFTokens.sp24`
- `AppSizes.iconLarge` → `MFTokens.sp32`
- `AppSizes.iconXLarge` → `MFTokens.sp40`
- `AppSizes.radiusSmall` → `MFTokens.radiusSM`
- `AppSizes.radiusMedium` → `MFTokens.radiusMD`
- `AppSizes.radiusLarge` → `MFTokens.radiusLG`
- `AppSizes.radiusXLarge` → `MFTokens.radiusXL`
- `AppSizes.radiusXXLarge` → `MFTokens.radiusXXL`
- `AppSizes.buttonHeight` → `MFTokens.buttonHeightMD`
- `AppSizes.borderWidthThin` → `0.8` (raw)
- `AppSizes.strokeWidthThin` → `0.83` (raw)
- `AppSizes.strokeWidthMedium` → `2.0` (raw)

## screenutil Extensions
- `.w` / `.h` / `.sp` / `.r` → raw double values (e.g. `40.w` → `40.0`)
- For `.sp` font sizes: use closest MFTokens constant (fontXS=11, fontSM=12, fontBase=13, fontMD=14, fontLG=16, fontXL=18, font2XL=20)

## Critical Rules
- DO NOT modify business logic, cubits, repositories, API calls, or models
- DO NOT change function signatures or class names
- DO NOT change navigation/routing
- Keep all existing functionality intact
- Use `const` where appropriate

## Verification
After all changes run: `dart analyze lib/features/products/presentation/ 2>&1 | tail -20`
Fix any errors. Do NOT commit.
