import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// ForUI-style Input — token-only, calm focus ring.
class MFInput extends StatelessWidget {
  const MFInput({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final bg = isDark ? MFTokens.inputBgDark : MFTokens.inputBgLight;
    final hint = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontSM,
                fontWeight: FontWeight.w600,
                color: isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight,
              )),
          const SizedBox(height: MFTokens.sp6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontMD,
            color: isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: hint),
            filled: true,
            fillColor: bg,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: isDark ? MFTokens.errorTextDark : MFTokens.errorText)),
          ),
        ),
      ],
    );
  }
}

/// Search field — quiet, token-driven
class MFSearchField extends StatelessWidget {
  const MFSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final hint = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: hint),
        filled: true,
        fillColor: bg,
        prefixIcon: Icon(Icons.search, size: 20, color: hint),
        suffixIcon: controller.text.isEmpty ? null : IconButton(onPressed: onClear, icon: Icon(Icons.close, size: 18, color: hint)),
        contentPadding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusFull), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusFull), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MFTokens.radiusFull),
            borderSide: BorderSide(color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary, width: 1.2)),
      ),
    );
  }
}
