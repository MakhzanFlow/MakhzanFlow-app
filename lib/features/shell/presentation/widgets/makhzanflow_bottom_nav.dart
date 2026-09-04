import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_locale_cubit.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../models/navigation_destination.dart';

class MakhzanFlowBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MakhzanFlowBottomNav({super.key, required this.navigationShell});

  static const List<NavigationDestinationData> destinations = [
    NavigationDestinationData(
      route: '/dashboard',
      labelAr: 'الرئيسية',
      labelEn: 'Home',
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
      labelAr: 'فاتورة',
      labelEn: 'Invoice',
      semanticLabelAr: 'فاتورة',
      icon: Icons.receipt_long_outlined,
      isCenterAction: true,
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
    final isArabic = context.watch<AppLocaleCubit>().state.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.cardDark : MFTokens.surfaceLight;
    final borderColor = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final orderedDestinations = [...destinations]
      ..sort((a, b) => a.sortOrderRtl.compareTo(b.sortOrderRtl));

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(orderedDestinations.length, (index) {
              final dest = orderedDestinations[index];
              final branchIndex = AppRoutes.shellRoutes.indexOf(dest.route);
              final isActive = branchIndex == navigationShell.currentIndex;
              return _NavItem(
                destination: dest,
                isActive: isActive,
                isArabic: isArabic,
                isDark: isDark,
                onTap: () => navigationShell.goBranch(
                  branchIndex,
                  initialLocation:
                      branchIndex == navigationShell.currentIndex,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavigationDestinationData destination;
  final bool isActive;
  final bool isArabic;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.isArabic,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final inactiveColor = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    if (destination.isCenterAction) {
      return Semantics(
        label: destination.semanticLabelAr,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, -9.h),
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: MFTokens.accent,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: MFTokens.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    destination.icon,
                    color: Colors.white,
                    size: 22.w,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -5.h),
                child: Text(
                  destination.label(isArabic),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.sp,
                    color: inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: destination.semanticLabelAr,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                ),
                child: Icon(
                  destination.icon,
                  color: isActive ? primaryColor : inactiveColor,
                  size: 20.w,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                destination.label(isArabic),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  color: isActive ? primaryColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
