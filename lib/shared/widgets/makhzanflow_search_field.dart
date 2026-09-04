import 'package:flutter/material.dart';
import '../../core/theme/mf_tokens.dart';

class MakhzanFlowSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  const MakhzanFlowSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          autofocus: autofocus,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontMD,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MFTokens.sp12,
              vertical: MFTokens.sp12,
            ),
          ),
        );
      },
    );
  }
}
