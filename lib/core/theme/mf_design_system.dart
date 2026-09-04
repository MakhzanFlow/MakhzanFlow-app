// MakhzanFlow Design System — ForUI + MFTokens
//
// Quiet · Professional · SaaS — single source, no hardcoded hex in UI code.
//
// Usage:
//   import 'package:makhzanflow/core/theme/mf_design_system.dart';
//   // Tokens
//   MFTokens.primary, MFTokens.sp16, MFTokens.radiusLG, MFTokens.shadowSM
//   // Theme
//   MFForUITheme.light / dark / materialLight / materialDark
//   // Cubits (persisted)
//   AppLocaleCubit
//   // Shared widgets (ForUI-based)
//   MFButton, MFCard, MFInput, showMFDialog
//
// Rules:
// • DO NOT use `Color(0xFF...)` directly in widgets — use MFTokens.
// • DO NOT use `AppColors`/`AppSizes` for new code — use MFTokens.
// • Use ForUI via FTheme (configured in main.dart) for Buttons/Inputs/Cards.

export 'mf_tokens.dart';
export 'mf_forui_theme.dart';
export 'app_locale_cubit.dart';
