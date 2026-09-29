import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// One conflicting field: [label] names it, [mine]/[server] are display strings.
class ConflictFieldRow {
  final String label;
  final String mine;
  final String server;

  const ConflictFieldRow({
    required this.label,
    required this.mine,
    required this.server,
  });
}

enum MergeChoice { mine, server }

/// Generic Merge UI (guide §5): server vs attempted values per field with
/// Keep mine / Use server. Token-only styling, Cairo font, 360dp-safe rows.
Future<MergeChoice?> showVersionConflictDialog(
  BuildContext context, {
  String? title,
  required List<ConflictFieldRow> rows,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textPrimary =
      isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
  final textSecondary =
      isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

  return showDialog<MergeChoice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(
        title ?? AppStrings.conflictTitle,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows) ...[
              Text(
                row.label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: MFTokens.fontSM,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: MFTokens.sp4),
              Row(
                children: [
                  Expanded(
                    child: _ValueCell(
                      caption: AppStrings.conflictMine,
                      value: row.mine,
                      highlight: true,
                    ),
                  ),
                  const SizedBox(width: MFTokens.sp8),
                  Expanded(
                    child: _ValueCell(
                      caption: AppStrings.conflictServer,
                      value: row.server,
                      highlight: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MFTokens.sp12),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, MergeChoice.server),
          child: Text(AppStrings.useServer),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, MergeChoice.mine),
          child: Text(AppStrings.keepMine),
        ),
      ],
    ),
  );
}

class _ValueCell extends StatelessWidget {
  final String caption;
  final String value;
  final bool highlight;

  const _ValueCell({
    required this.caption,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = highlight
        ? (isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight)
        : Colors.transparent;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(MFTokens.sp8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              color: textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
