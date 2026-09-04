import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'mf_button.dart';

/// ForUI-style Dialog — calm, rounded, token-only.
/// Use via [showMFDialog]
Future<T?> showMFDialog<T>({
  required BuildContext context,
  required String title,
  String? description,
  required String confirmLabel,
  String cancelLabel = 'إلغاء',
  VoidCallback? onConfirm,
  bool isDestructive = false,
  Widget? content,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
  final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
  final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusXL)),
      title: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontLG, fontWeight: FontWeight.w700, color: textPrimary)),
      content: content ??
          (description != null
              ? Text(description, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textSecondary, height: MFTokens.lineHeightNormal))
              : null),
      actionsPadding: const EdgeInsets.fromLTRB(MFTokens.sp16, 0, MFTokens.sp16, MFTokens.sp16),
      actions: [
        MFButton(
          label: cancelLabel,
          variant: MFButtonVariant.ghost,
          fullWidth: false,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        const SizedBox(width: MFTokens.sp8),
        MFButton(
          label: confirmLabel,
          variant: isDestructive ? MFButtonVariant.destructive : MFButtonVariant.primary,
          fullWidth: false,
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm?.call();
          },
        ),
      ],
    ),
  );
}
