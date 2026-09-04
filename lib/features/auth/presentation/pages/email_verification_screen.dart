import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _tokenController = TextEditingController();
  bool _isResending = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      AppSnackbar.error(context, AppStrings.pleaseEnterVerificationCode);
      return;
    }
    final cubit = context.read<AuthCubit>();
    await cubit.verifyEmail(widget.email, token);
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    final cubit = context.read<AuthCubit>();
    await cubit.resendVerificationEmail(widget.email);
    if (mounted) {
      setState(() => _isResending = false);
      AppSnackbar.success(context, AppStrings.verificationCodeResent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.surfaceLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<AuthCubit>().checkSession();
            context.go(AppRoutes.dashboard);
          } else if (state is AuthError) {
            AppSnackbar.error(context, state.message);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: MFTokens.sp24,
                    vertical: MFTokens.sp32,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(MFTokens.radiusXXL),
                      topRight: Radius.circular(MFTokens.radiusXXL),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: MFTokens.sp32),
                        Icon(
                          Icons.mark_email_unread_outlined,
                          size: 80,
                          color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                        ),
                        const SizedBox(height: MFTokens.sp24),
                        Text(
                          AppStrings.emailVerificationTitle,
                          style: TextStyle(
                            fontSize: MFTokens.font2XL,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: MFTokens.sp16),
                        Text(
                          AppStrings.emailVerificationSubtitle,
                          style: TextStyle(
                            fontSize: MFTokens.fontSM,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: MFTokens.sp8),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: MFTokens.fontMD,
                            fontWeight: FontWeight.bold,
                            color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: MFTokens.sp32),
                        TextField(
                          controller: _tokenController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: MFTokens.fontLG,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '000000',
                            hintStyle: TextStyle(
                              color: textSecondary.withValues(alpha: 0.5),
                              letterSpacing: 8,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(MFTokens.radiusLG)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(MFTokens.radiusLG)),
                              borderSide: BorderSide(
                                color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: MFTokens.sp32),
                        SizedBox(
                          width: double.infinity,
                          height: MFTokens.buttonHeightMD,
                          child: ElevatedButton(
                            onPressed: _verify,
                            child: Text(
                              AppStrings.verify,
                              style: const TextStyle(
                                fontSize: MFTokens.fontMD,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: MFTokens.sp24),
                        TextButton(
                          onPressed: _isResending ? null : _resend,
                          child: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppStrings.resendCode,
                                  style: TextStyle(
                                    color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: MFTokens.sp24),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(
                            AppStrings.backToLogin,
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
