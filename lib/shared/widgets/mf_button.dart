import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// MakhzanFlow Button — thin wrapper over ForUI [FButton] for a minimal, clear UX.
/// Uses ForUI theme (lib/theme/ via `dart run forui init`) + [MFTokens] for spacing.
/// Quiet SaaS: 12px radius, 44h touch, subtle borders, Cairo, no hardcoded colors.
enum MFButtonVariant { primary, secondary, outline, ghost, destructive }

class MFButton extends StatelessWidget {
  const MFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MFButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.size = MFTokens.buttonHeightMD,
  });

  final String label;
  final VoidCallback? onPressed;
  final MFButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final double size;

  FButtonVariant get _fVariant => switch (variant) {
        MFButtonVariant.primary => FButtonVariant.primary,
        MFButtonVariant.secondary => FButtonVariant.secondary,
        MFButtonVariant.outline => FButtonVariant.outline,
        MFButtonVariant.ghost => FButtonVariant.ghost,
        MFButtonVariant.destructive => FButtonVariant.destructive,
      };

  @override
  Widget build(BuildContext context) {
    // ForUI handles colors/borders/shadows via theme (lib/theme/ + MFTokens) — minimal, consistent.
    // Loading state shows a small spinner instead of label; icon is rendered as prefix.
    final textStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: MFTokens.fontMD,
      fontWeight: FontWeight.w600,
    );

    final content = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: context.theme.colors.foreground),
          )
        : Text(label, style: textStyle, overflow: TextOverflow.ellipsis);

    final iconWidget = (icon != null && !loading) ? Icon(icon, size: 18) : null;

    return FButton(
      variant: _fVariant,
      size: FButtonSizeVariant.md,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      onPress: loading ? null : onPressed,
      prefix: iconWidget,
      child: content,
    );
  }
}
