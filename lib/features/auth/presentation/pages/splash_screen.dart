import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.4, -0.6),
            radius: 1.5,
            colors: [MFTokens.primary, MFTokens.primaryDarker],
          ),
        ),
        child: Stack(
          children: [
            // Decorative shapes
            Positioned(
              left: -80,
              top: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: MFTokens.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 80,
              top: 288 * 1.5,
              child: Container(
                width: 288,
                height: 288,
                decoration: BoxDecoration(
                  color: MFTokens.gradientOverlaySubtle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Logo Placeholder
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: MFTokens.gradientOverlayLight,
                    border: Border.all(
                      color: MFTokens.gradientOverlayMedium,
                      width: 0.83,
                    ),
                    borderRadius: BorderRadius.circular(MFTokens.radiusXL),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: MFTokens.textOnPrimary,
                        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        height: 40,
                        width: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MFTokens.sp24),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: MFTokens.textOnPrimary,
                    fontSize: MFTokens.fontDisplay,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.75,
                  ),
                ),
                const SizedBox(height: MFTokens.sp4),
                Text(
                  AppStrings.appNameArabic,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: MFTokens.gradientOverlayText,
                    fontSize: MFTokens.fontLG,
                  ),
                ),
                const SizedBox(height: MFTokens.sp8),
                Text(
                  AppStrings.appSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: MFTokens.gradientOverlayMuted,
                    fontSize: MFTokens.fontSM,
                  ),
                ),
                const Spacer(flex: 2),
                // Loading Indicator
                SpinKitRing(
                  color: MFTokens.gradientOverlayText,
                  size: MFTokens.sp24,
                  lineWidth: 2,
                ),
                const SizedBox(height: MFTokens.sp16),
                Text(
                  AppStrings.loading,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: MFTokens.gradientOverlayMuted,
                    fontSize: MFTokens.fontSM,
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.appVersion,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: MFTokens.gradientOverlayFaint,
                    fontSize: MFTokens.fontXS,
                  ),
                ),
                const SizedBox(height: MFTokens.sp24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
