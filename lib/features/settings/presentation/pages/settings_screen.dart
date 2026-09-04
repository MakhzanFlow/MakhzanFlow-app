import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/company/company_cubit.dart';
import '../../../../core/company/company_state.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/theme/app_locale_cubit.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/widgets/company_switcher.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleSignOut() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    final companyCubit = context.read<CompanyCubit>();
    final authCubit = context.read<AuthCubit>();
    final router = GoRouter.of(context);
    try {
      await companyCubit.clearCompany();
      sl<PermissionService>().clear();
      await authCubit.signOut();
      if (mounted) router.go(AppRoutes.login);
    } catch (_) {
      if (mounted) router.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyState = context.watch<CompanyCubit>().state;
    final isOwner = companyState is CompanySelected && companyState.membership?.isOwner == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeState = context.watch<AppLocaleCubit>().state;
    final bg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(MFTokens.sp16),
        children: [
          const CompanySwitcher(),
          const SizedBox(height: MFTokens.sp16),

          // ── Appearance — Language
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              border: Border.all(color: border),
              boxShadow: MFTokens.shadowSM,
            ),
            child: Column(
              children: [
                _AppearanceTile(
                  icon: Icons.translate_outlined,
                  title: localeState.isArabic ? 'اللغة' : 'Language',
                  subtitle: localeState.isArabic ? 'العربية' : 'English',
                  trailing: _LangSegment(
                    isArabic: localeState.isArabic,
                    onSelectArabic: () => context.read<AppLocaleCubit>().setArabic(),
                    onSelectEnglish: () => context.read<AppLocaleCubit>().setEnglish(),
                  ),
                  onTap: () => context.read<AppLocaleCubit>().toggle(),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: MFTokens.sp16),

          // ── Company section
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              border: Border.all(color: border),
              boxShadow: MFTokens.shadowSM,
            ),
            child: Column(
              children: [
                if (isOwner)
                  _SettingsTile(
                    icon: Icons.business_outlined,
                    label: AppStrings.companySettings,
                    onTap: () => context.go('${AppRoutes.settings}/company'),
                    textPrimary: textPrimary,
                    border: border,
                  ),
                if (isOwner) Divider(height: 1, color: border),
                _SettingsTile(
                  icon: Icons.people_outline,
                  label: AppStrings.teamMembers,
                  onTap: () => context.go('${AppRoutes.settings}/members'),
                  textPrimary: textPrimary,
                  border: border,
                ),
              ],
            ),
          ),

          const SizedBox(height: MFTokens.sp24),

          // Sign out — destructive, token-based
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              border: Border.all(color: border),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: isDark ? MFTokens.errorTextDark : MFTokens.errorText),
              title: Text(
                AppStrings.signOut,
                style: TextStyle(color: textPrimary, fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: FontWeight.w600),
              ),
              trailing: _isLoggingOut
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? MFTokens.errorTextDark : MFTokens.errorText),
                    )
                  : null,
              enabled: !_isLoggingOut,
              onTap: _isLoggingOut ? null : _handleSignOut,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusLG)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MFTokens.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        ),
        child: Icon(icon, size: 18, color: MFTokens.primary),
      ),
      title: Text(title, style: TextStyle(color: textPrimary, fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: textSecondary, fontFamily: 'Cairo', fontSize: MFTokens.fontSM)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _LangSegment extends StatelessWidget {
  const _LangSegment({required this.isArabic, required this.onSelectArabic, required this.onSelectEnglish});
  final bool isArabic;
  final VoidCallback onSelectArabic;
  final VoidCallback onSelectEnglish;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? MFTokens.surfaceDark : MFTokens.surfaceMutedLight,
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(label: 'ع', selected: isArabic, onTap: onSelectArabic, isDark: isDark),
          _seg(label: 'EN', selected: !isArabic, onTap: onSelectEnglish, isDark: isDark),
        ],
      ),
    );
  }

  Widget _seg({required String label, required bool selected, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp10, vertical: MFTokens.sp6),
        decoration: BoxDecoration(
          color: selected ? (isDark ? MFTokens.primaryDarkMode : MFTokens.primary) : Colors.transparent,
          borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight),
            fontSize: MFTokens.fontSM,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color border;

  const _SettingsTile({required this.icon, required this.label, required this.onTap, required this.textPrimary, required this.border});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isDark ? MFTokens.primaryDarkMode : MFTokens.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        ),
        child: Icon(icon, size: 18, color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary),
      ),
      title: Text(label, style: TextStyle(color: textPrimary, fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_left, size: 18, color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight),
      onTap: onTap,
    );
  }
}
