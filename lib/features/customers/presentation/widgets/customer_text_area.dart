import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class CustomerTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;

  const CustomerTextArea({super.key, required this.controller, required this.label, required this.hintText, this.validator});

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
          maxLines: 3,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          validator: validator,
          style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintTextDirection: TextDirection.rtl,
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
