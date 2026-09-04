import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class CustomerTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData iconData;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const CustomerTextInput({super.key, required this.controller, required this.label, required this.hintText, required this.iconData, this.keyboardType = TextInputType.text, this.validator, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final inputBg = isDark ? MFTokens.inputBgDark : MFTokens.inputBgLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: MFTokens.sp8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(iconData, color: primary, size: MFTokens.sp24),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border, width: 0.8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: border, width: 0.8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD), borderSide: BorderSide(color: primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
