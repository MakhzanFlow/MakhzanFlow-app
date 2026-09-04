import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// Calm dropdown — ForUI FSelect equivalent, token-only.
/// Drop-in for business-type, status filters, etc.
class MFDropdown<T> extends StatelessWidget {
  const MFDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.label,
    this.itemLabel,
  });

  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? label;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.inputBgDark : MFTokens.inputBgLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final hintColor = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
          const SizedBox(height: MFTokens.sp6),
        ],
        DropdownButtonFormField<T>(
          value: value,
          hint: hint != null ? Text(hint!, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: hintColor)) : null,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(itemLabel != null ? itemLabel!(e) : e.toString(),
                        style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: isDark ? MFTokens.cardDark : MFTokens.cardLight,
          decoration: InputDecoration(
            filled: true,
            fillColor: bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                borderSide: BorderSide(color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary, width: 1.5)),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: hintColor, size: 20),
        ),
      ],
    );
  }
}
