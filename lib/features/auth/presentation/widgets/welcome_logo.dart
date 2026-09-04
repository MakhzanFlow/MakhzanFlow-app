import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/welcome_painters.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: MFTokens.gradientOverlayLight,
            border: Border.all(
              color: MFTokens.gradientOverlayMedium,
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(MFTokens.radiusXL),
          ),
          child: Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: const CustomPaint(painter: StockIconPainter()),
            ),
          ),
        ),
        const SizedBox(height: MFTokens.sp8),
        Text(
          AppStrings.appName,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: MFTokens.textOnPrimary,
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: MFTokens.sp4),
        Text(
          AppStrings.welcomeAppSubtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: MFTokens.gradientOverlayMuted,
            fontSize: MFTokens.fontSM,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
