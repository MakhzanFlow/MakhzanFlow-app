import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/company/company_cubit.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_bottom_link.dart';
import '../widgets/google_auth_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.surfaceLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<CompanyCubit>().loadCompanies();
          } else if (state is AuthError) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AuthHeader(
                              title: AppStrings.welcomeBack,
                              subtitle: AppStrings.loginToContinue,
                            ),
                            const SizedBox(height: MFTokens.sp32),
                            AuthTextField(
                              controller: _emailController,
                              label: AppStrings.emailLabel,
                              hintText: AppStrings.emailHint,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.emailRequired;
                                }
                                if (!value.contains('@')) {
                                  return AppStrings.emailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: MFTokens.sp16),
                            AuthTextField(
                              controller: _passwordController,
                              label: AppStrings.passwordLabel,
                              hintText: AppStrings.passwordHint,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return AppStrings.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: MFTokens.sp16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MFTokens.sp24,
                                      height: MFTokens.sp24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _rememberMe = value ?? true;
                                                });
                                              },
                                      ),
                                    ),
                                    const SizedBox(width: MFTokens.sp8),
                                    Text(
                                      AppStrings.rememberMe,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: MFTokens.fontMD,
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: isLoading ? null : () {},
                                  child: Text(
                                    AppStrings.forgotPassword,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: MFTokens.fontSM,
                                      color: isDark ? MFTokens.primaryDarkMode : MFTokens.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: MFTokens.sp32),
                            AuthButton(
                              label: AppStrings.loginButton,
                              isLoading: isLoading,
                              onPressed: _onLogin,
                            ),
                            const SizedBox(height: MFTokens.sp24),
                            GoogleAuthSection(
                              label: AppStrings.signInWithGoogle,
                              isLoading: isLoading,
                              onPressed: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                            ),
                            const SizedBox(height: MFTokens.sp24),
                            AuthBottomLink(
                              label: AppStrings.dontHaveAccount,
                              actionLabel: AppStrings.registerNow,
                              route: AppRoutes.register,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
