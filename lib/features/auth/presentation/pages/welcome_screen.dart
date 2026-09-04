import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/welcome_actions.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/welcome_hero.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/welcome_logo.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/welcome_painters.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _buttonsSlide;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    _textSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
    );
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );
    _buttonsSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, -0.6),
            radius: 1.5,
            colors: [
              MFTokens.sidebarActiveItem,
              MFTokens.primaryDark,
              MFTokens.primaryDarker,
            ],
          ),
        ),
        child: CustomPaint(
          painter: const DecorativeCirclesPainter(),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) => Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: 0.6 + (0.4 * _logoScale.value),
                      child: child,
                    ),
                  ),
                  child: const WelcomeLogo(),
                ),
                const SizedBox(height: MFTokens.sp16),
                AnimatedBuilder(
                  animation: _textSlide,
                  builder: (context, child) => Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        MFTokens.sp24 * (1 - _textSlide.value),
                      ),
                      child: child,
                    ),
                  ),
                  child: const WelcomeHero(),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _buttonsSlide,
                  builder: (context, child) => Opacity(
                    opacity: _buttonsFade.value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        MFTokens.sp32 * (1 - _buttonsSlide.value),
                      ),
                      child: child,
                    ),
                  ),
                  child: WelcomeActions(
                    onCreateBusiness: () => context.push(AppRoutes.welcomeCreate),
                    onJoinBusiness: () => context.push(AppRoutes.welcomeJoin),
                  ),
                ),
                const SizedBox(height: MFTokens.sp16),
                _buildSignOut(),
                const SizedBox(height: MFTokens.sp8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOut() {
    return TextButton(
      onPressed: () async {
        sl<PermissionService>().clear();
        context.read<CompanyCubit>().clearCompany();
        await context.read<AuthCubit>().signOut();
      },
      child: Text(
        AppStrings.signOut,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: MFTokens.gradientOverlayFaint,
          fontSize: MFTokens.fontXS,
        ),
      ),
    );
  }
}
