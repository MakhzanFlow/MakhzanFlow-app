import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MFTokens.buttonHeightMD,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: MFTokens.sp24,
                height: MFTokens.sp24,
                child: CircularProgressIndicator(
                  color: MFTokens.textOnPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
