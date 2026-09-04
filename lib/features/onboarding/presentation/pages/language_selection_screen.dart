import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_locale_cubit.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(String code) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('mf_locale_code', code);
    // Mark onboarding as complete
    await sp.setBool('onboarding_complete', true);
    // Update the live cubit so the UI reflects the choice immediately
    if (code == 'ar') {
      context.read<AppLocaleCubit>().setArabic();
    } else {
      context.read<AppLocaleCubit>().setEnglish();
    }
    if (mounted) {
      // Check session so router redirects properly
      context.read<AuthCubit>().checkSession();
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: MFTokens.sp24,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.83,
                        ),
                        borderRadius: BorderRadius.circular(MFTokens.radiusXL),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              height: 36,
                              width: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp32),

                    // Title
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: MFTokens.fontDisplay,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp8),

                    // Subtitle
                    Text(
                      '${AppStrings.selectBusiness} / Choose your language',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: MFTokens.fontLG,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // Language Cards
                    _LanguageCard(
                      flag: '🇪🇬',
                      titleAr: 'العربية',
                      titleEn: 'العربية',
                      subtitle: 'RTL',
                      onTap: () => _selectLanguage('ar'),
                    ),
                    const SizedBox(height: MFTokens.sp16),
                    _LanguageCard(
                      flag: '🇺🇸',
                      titleAr: 'English',
                      titleEn: 'English',
                      subtitle: 'LTR',
                      onTap: () => _selectLanguage('en'),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String titleAr;
  final String titleEn;
  final String subtitle;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.titleAr,
    required this.titleEn,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: MFTokens.sp24,
          vertical: MFTokens.sp20,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: MFTokens.sp16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: MFTokens.fontXL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: MFTokens.sp2),
                  Text(
                    '$titleEn • $subtitle',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: MFTokens.fontSM,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
