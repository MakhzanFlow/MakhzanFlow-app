import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_state.dart';
import '../models/navigation_destination.dart';

/// Responsive sidebar for tablet/desktop (≥ 768px).
///
/// Layout:
///  ┌─────────────────────────────┐
///  │  [M]  MakhzanFlow           │  ← brand header
///  │       فرع الإسماعيلية      │
///  ├─────────────────────────────┤
///  │  ● الرئيسية                 │  ← nav items
///  │    المنتجات                 │
///  │    الفواتير                 │
///  │    العملاء                  │
///  │    الإعدادات                │
///  ├─────────────────────────────┤
///  │  [H]  Hazem                 │  ← user footer
///  │       Owner                 │
///  │       🌙  ع / EN            │
///  └─────────────────────────────┘
class MakhzanFlowSidebar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MakhzanFlowSidebar({super.key, required this.navigationShell});

  static const List<NavigationDestinationData> destinations = [
    NavigationDestinationData(
      route: '/dashboard',
      labelAr: 'الرئيسية',
      labelEn: 'Dashboard',
      semanticLabelAr: 'الرئيسية',
      icon: Icons.dashboard_outlined,
      sortOrderRtl: 0,
    ),
    NavigationDestinationData(
      route: '/products',
      labelAr: 'المنتجات',
      labelEn: 'Products',
      semanticLabelAr: 'المنتجات',
      icon: Icons.inventory_2_outlined,
      sortOrderRtl: 1,
    ),
    NavigationDestinationData(
      route: '/invoices',
      labelAr: 'الفواتير',
      labelEn: 'Invoices',
      semanticLabelAr: 'الفواتير',
      icon: Icons.receipt_long_outlined,
      sortOrderRtl: 2,
    ),
    NavigationDestinationData(
      route: '/customers',
      labelAr: 'العملاء',
      labelEn: 'Customers',
      semanticLabelAr: 'العملاء',
      icon: Icons.people_outline,
      sortOrderRtl: 3,
    ),
    NavigationDestinationData(
      route: '/settings',
      labelAr: 'الإعدادات',
      labelEn: 'Settings',
      semanticLabelAr: 'الإعدادات',
      icon: Icons.settings_outlined,
      sortOrderRtl: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localeState = context.watch<AppLocaleCubit>().state;
    final isArabic = localeState.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.name : '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : AppStrings.defaultAvatarLetter;

    final companyState = context.watch<CompanyCubit>().state;
    final companyName = companyState is CompanySelected
        ? companyState.company.name
        : AppStrings.appName;
    final branchName = companyState is CompanySelected
        ? (companyState.company.businessType ?? '')
        : '';

    final sidebarBg = isDark ? MFTokens.sidebarBgDark : MFTokens.sidebarBg;
    final activeItemColor = MFTokens.sidebarActiveItem;
    final textActive = MFTokens.sidebarTextActive;
    final textInactive = MFTokens.sidebarTextInactive;
    final borderColor = isDark ? MFTokens.sidebarBorderDark : MFTokens.sidebarBorder;

    return Container(
      width: MFTokens.sidebarWidth,
      color: sidebarBg,
      child: Column(
        children: [
          // ── Brand Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(MFTokens.sp16, MFTokens.sp20, MFTokens.sp16, MFTokens.sp16),
            child: Row(
              children: [
                // Logo badge — token color, no hardcode
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MFTokens.sidebarActiveItem,
                    borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.defaultAvatarLetter,
                    style: TextStyle(
                      color: textActive,
                      fontSize: MFTokens.fontXL,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(width: MFTokens.sp10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: textActive,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (companyName.isNotEmpty)
                        Text(
                          companyName,
                          style: TextStyle(
                            color: textInactive,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (branchName.isNotEmpty)
                        Text(
                          branchName,
                          style: TextStyle(
                            color: textInactive.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontFamily: 'Cairo',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: borderColor, height: 1, thickness: 1),

          const SizedBox(height: MFTokens.sp8),

          // ── Navigation Items ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp8, vertical: MFTokens.sp4),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final dest = destinations[index];
                final branchIndex = AppRoutes.shellRoutes.indexOf(dest.route);
                final isActive = branchIndex == navigationShell.currentIndex;
                return _SidebarNavItem(
                  destination: dest,
                  isActive: isActive,
                  isArabic: isArabic,
                  activeColor: activeItemColor,
                  textActive: textActive,
                  textInactive: textInactive,
                  onTap: () => navigationShell.goBranch(
                    branchIndex,
                    initialLocation: branchIndex == navigationShell.currentIndex,
                  ),
                );
              },
            ),
          ),

          // ── User Footer ──────────────────────────────────────────────────
          Divider(color: borderColor, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(MFTokens.sp12),
            child: Column(
              children: [
                // User info row — Hazem / Owner footer per spec
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MFTokens.accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userInitial,
                        style: TextStyle(
                          color: MFTokens.accent,
                          fontSize: MFTokens.fontLG,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: MFTokens.sp10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isEmpty ? AppStrings.defaultUserName : userName,
                            style: TextStyle(
                              color: textActive,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isArabic ? AppStrings.ownerLabel : AppStrings.ownerLabelEn,
                            style: TextStyle(
                              color: textInactive,
                              fontSize: 11,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MFTokens.sp10),
                // Controls row: language — persisted, token-only
                Row(
                  children: [
                    // Language toggle
                    Expanded(
                      child: _SidebarIconButton(
                        icon: Icons.translate,
                        label: isArabic ? 'EN' : 'ع',
                        textColor: textInactive,
                        onTap: () => context.read<AppLocaleCubit>().toggle(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final NavigationDestinationData destination;
  final bool isActive;
  final bool isArabic;
  final Color activeColor;
  final Color textActive;
  final Color textInactive;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.destination,
    required this.isActive,
    required this.isArabic,
    required this.activeColor,
    required this.textActive,
    required this.textInactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isActive ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        child: InkWell(
          borderRadius: BorderRadius.circular(MFTokens.radiusSM),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  size: 18,
                  color: isActive ? textActive : textInactive,
                ),
                const SizedBox(width: 12),
                Text(
                  destination.label(isArabic),
                  style: TextStyle(
                    color: isActive ? textActive : textInactive,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _SidebarIconButton({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(MFTokens.radiusSM),
      child: InkWell(
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
