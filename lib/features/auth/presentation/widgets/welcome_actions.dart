import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';

class WelcomeActions extends StatelessWidget {
  final VoidCallback onCreateBusiness;
  final VoidCallback onJoinBusiness;

  const WelcomeActions({
    super.key,
    required this.onCreateBusiness,
    required this.onJoinBusiness,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: MFTokens.buttonHeightLG,
            child: ElevatedButton.icon(
              onPressed: onCreateBusiness,
              icon: const Icon(
                Icons.add_rounded,
                size: MFTokens.sp24,
                color: MFTokens.textOnPrimary,
              ),
              label: Text(
                AppStrings.createBusiness,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w500,
                  color: MFTokens.textOnPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MFTokens.accent,
                foregroundColor: MFTokens.textOnPrimary,
                shadowColor: MFTokens.accent.withValues(alpha: 0.45),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                ),
              ),
            ),
          ),
          const SizedBox(height: MFTokens.sp8),
          SizedBox(
            width: double.infinity,
            height: MFTokens.buttonHeightLG,
            child: OutlinedButton.icon(
              onPressed: onJoinBusiness,
              icon: const Icon(
                Icons.group_add_outlined,
                size: MFTokens.sp24,
                color: MFTokens.textOnPrimary,
              ),
              label: Text(
                AppStrings.joinBusiness,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w500,
                  color: MFTokens.textOnPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: MFTokens.gradientOverlayLight,
                foregroundColor: MFTokens.textOnPrimary,
                side: BorderSide(
                  color: MFTokens.gradientOverlayMedium,
                  width: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
