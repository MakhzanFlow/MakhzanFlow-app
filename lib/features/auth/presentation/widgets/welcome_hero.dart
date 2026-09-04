import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';

class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.welcomeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: MFTokens.textOnPrimary,
            fontSize: MFTokens.fontDisplay,
            fontWeight: FontWeight.w400,
            height: 1.38,
          ),
        ),
        const SizedBox(height: MFTokens.sp8),
        Text(
          AppStrings.welcomeSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: MFTokens.gradientOverlayMuted,
            fontSize: MFTokens.fontSM,
            fontWeight: FontWeight.w400,
            height: 1.62,
          ),
        ),
      ],
    );
  }
}
