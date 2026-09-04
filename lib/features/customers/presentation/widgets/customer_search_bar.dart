import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onAdd;

  const CustomerSearchBar({super.key, required this.controller, required this.onChanged, this.onClear, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    final searchBg = isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: searchBg, borderRadius: BorderRadius.circular(MFTokens.radiusMD)),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary),
                decoration: InputDecoration(
                  hintText: AppStrings.customersSearchHint,
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: muted),
                  prefixIcon: Icon(Icons.search, color: muted),
                  suffixIcon: controller.text.isNotEmpty ? IconButton(onPressed: onClear, icon: Icon(Icons.close, color: muted)) : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
        ],
      ),
    );
  }
}
