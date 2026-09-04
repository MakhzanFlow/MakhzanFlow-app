import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: MFTokens.sp8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
