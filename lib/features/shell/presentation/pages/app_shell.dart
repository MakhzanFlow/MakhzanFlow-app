import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/shell/presentation/cubit/app_shell_state.dart';
import '../cubit/app_shell_cubit.dart';
import '../widgets/makhzanflow_bottom_nav.dart';
import '../widgets/makhzanflow_sidebar.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? _lastLocation;
  int? _lastIndex;
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.doubleTapToExit),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocProvider(
        create: (_) => AppShellCubit()..syncRoute(location, currentIndex),
        child: Builder(
          builder: (context) {
            _syncRoute(context, location, currentIndex);
            return BlocListener<AppShellCubit, AppShellState>(
              listenWhen: (previous, current) =>
                  previous.currentRoute != current.currentRoute ||
                  previous.selectedIndex != current.selectedIndex,
              listener: (context, state) {
                if (state.currentRoute != location) {
                  context.go(state.currentRoute);
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide =
                      constraints.maxWidth >= MFTokens.breakpointSidebar;
                  // Only dashboard keeps the shared chrome (appBar/drawer). Other tabs are full-screen
                  // to keep UX minimal and let each page own its header (if needed).
                  final isDashboard = currentIndex == 0;

                  if (isWide) {
                    // ── Tablet / Desktop: keep sidebar for navigation on all tabs (minimal chrome)
                    // If you want true full-screen on wide for non-dashboard, replace with `isDashboard` check.
                    return Scaffold(
                      backgroundColor: bg,
                      body: Row(
                        children: [
                          MakhzanFlowSidebar(
                            navigationShell: widget.navigationShell,
                          ),
                          // Thin separator line
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: isDark
                                ? MFTokens.borderDark
                                : MFTokens.borderLight,
                          ),
                          Expanded(child: widget.navigationShell),
                        ],
                      ),
                    );
                  }

                  // ── Mobile: no Drawer anywhere (per request), only Dashboard keeps AppBar
                  // Other tabs are full-screen minimal, bottomNav stays for navigation.
                  if (isDashboard) {
                    return Scaffold(
                      backgroundColor: bg,
                      appBar: _MFMobileAppBar(isDark: isDark),
                      body: widget.navigationShell,
                      bottomNavigationBar: MakhzanFlowBottomNav(
                        navigationShell: widget.navigationShell,
                      ),
                    );
                  }

                  // Non-dashboard mobile: no AppBar / Drawer — pages own their headers
                  return Scaffold(
                    backgroundColor: bg,
                    body: widget.navigationShell,
                    bottomNavigationBar: MakhzanFlowBottomNav(
                      navigationShell: widget.navigationShell,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _syncRoute(BuildContext context, String location, int index) {
    if (_lastLocation == location && _lastIndex == index) return;
    _lastLocation = location;
    _lastIndex = index;
    context.read<AppShellCubit>().syncRoute(location, index);
  }
}

/// Mobile top bar — calm, token-only, shows M + MakhzanFlow + branch (Ismailia)
/// + quick theme/locale toggles for iOS/Android. No hardcoded colors.
class _MFMobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MFMobileAppBar({required this.isDark});
  final bool isDark;

  @override
  Size get preferredSize => const Size.fromHeight(MFTokens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final companyState = context.watch<CompanyCubit>().state;
    final localeState = context.watch<AppLocaleCubit>().state;
    final isArabic = localeState.isArabic;

    final bg = isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textPrimary = isDark
        ? MFTokens.textPrimaryDark
        : MFTokens.textPrimaryLight;
    final textSecondary = isDark
        ? MFTokens.textSecondaryDark
        : MFTokens.textSecondaryLight;

    return AppBar(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 12,

      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: MFTokens.sidebarActiveItem,
              borderRadius: BorderRadius.circular(MFTokens.radiusSM),
            ),
            alignment: Alignment.center,
            child: Text(
              AppStrings.defaultAvatarLetter,
              style: TextStyle(
                color: Colors.white,
                fontSize: MFTokens.fontLG,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: MFTokens.fontMD,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: MFTokens.sp8),
          child: TextButton(
            onPressed: () => context.read<AppLocaleCubit>().toggle(),
            style: TextButton.styleFrom(
              backgroundColor: isDark
                  ? MFTokens.surfaceMutedDark
                  : MFTokens.surfaceMutedLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MFTokens.radiusSM),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.sp10,
                vertical: MFTokens.sp6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isArabic ? 'EN' : 'ع',
              style: TextStyle(
                color: textPrimary,
                fontSize: MFTokens.fontSM,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: border),
      ),
    );
  }
}
