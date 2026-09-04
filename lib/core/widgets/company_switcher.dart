import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/action_row.dart';
import 'package:makhzanflow/core/widgets/app_network_image.dart';
import 'package:makhzanflow/core/widgets/company_card.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';

class CompanySwitcher extends StatefulWidget {
  const CompanySwitcher({super.key});

  @override
  State<CompanySwitcher> createState() => _CompanySwitcherState();
}

class _CompanySwitcherState extends State<CompanySwitcher> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<CompanyCubit>().state;
    if (state is CompanyInitial) {
      context.read<CompanyCubit>().loadCompanies();
    }
  }

  Future<void> _handleLogout(BuildContext sheetContext, void Function(void Function()) setSheetState) async {
    if (_isLoggingOut) return;
    setSheetState(() => _isLoggingOut = true);
    setState(() => _isLoggingOut = true);
    final companyCubit = context.read<CompanyCubit>();
    final authCubit = context.read<AuthCubit>();
    final router = GoRouter.of(context);
    try {
      await companyCubit.clearCompany();
      sl<PermissionService>().clear();
      await authCubit.signOut();
      if (sheetContext.mounted && Navigator.canPop(sheetContext)) {
        Navigator.pop(sheetContext);
      }
      if (mounted) router.go(AppRoutes.login);
    } catch (_) {
      if (sheetContext.mounted && Navigator.canPop(sheetContext)) {
        Navigator.pop(sheetContext);
      }
      if (mounted) router.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        Company? selectedCompany;

        if (state is CompaniesLoaded) {
          selectedCompany = null;
        } else if (state is CompanySelected) {
          selectedCompany = state.company;
        }

        return GestureDetector(
          onTap: _showCompanySwitcherSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MFTokens.sp16,
              vertical: MFTokens.sp8,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(MFTokens.radiusMD),
            ),
            child: Row(
              children: [
                AppNetworkImage(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                  ),
                  imageUrl: selectedCompany?.logoUrl ?? '',
                  width: MFTokens.sp24,
                  height: MFTokens.sp24,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.business,
                    color: MFTokens.primary,
                    size: MFTokens.sp24,
                  ),
                ),
                const SizedBox(width: MFTokens.sp8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCompany?.name ?? AppStrings.selectCompany,
                        style: TextStyle(
                          fontSize: MFTokens.fontMD,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.swap_horiz, color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCompanySwitcherSheet() {
    final state = context.read<CompanyCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companies = switch (state) {
      CompaniesLoaded(:final companies) => companies,
      CompanySelected(:final allCompanies) =>
        allCompanies.isNotEmpty ? allCompanies : [state.company],
      _ => <Company>[],
    };
    final selected = switch (state) {
      CompanySelected(:final company) => company,
      _ => null,
    };
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MFTokens.radiusXL),
        ),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
        child: SizedBox(
          height: 510,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MFTokens.sp16,
              0,
              MFTokens.sp16,
              MFTokens.sp16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? MFTokens.borderDark : const Color(0xFFD4D4D4),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: MFTokens.sp4),
                  child: Text(
                    AppStrings.selectBusiness,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: MFTokens.fontMD,
                      fontWeight: FontWeight.w400,
                      color: textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: companies.isEmpty && state is! CompanyLoading
                      ? Center(
                          child: Text(
                            AppStrings.noCompanies,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: MFTokens.fontMD,
                            ),
                          ),
                        )
                      : ListView(
                          children: [
                            ...companies.asMap().entries.map((entry) {
                              final i = entry.key;
                              final company = entry.value;
                              final isSelected = selected?.id == company.id;
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: i == 0 ? 0 : MFTokens.sp10,
                                ),
                                child: CompanyCard(
                                  company: company,
                                  isSelected: isSelected,
                                  onTap: () {
                                    final router = GoRouter.of(context);
                                    context.read<CompanyCubit>().switchCompany(
                                      company,
                                    );
                                    Navigator.pop(context);
                                    Future.microtask(() {
                                      router.go(AppRoutes.dashboard);
                                    });
                                  },
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: MFTokens.sp16,
                              ),
                              child: Divider(
                                color: isDark ? MFTokens.borderDark : MFTokens.surfaceMutedLight,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: MFTokens.sp16,
                              ),
                              child: ActionRow(
                                icon: Icons.add,
                                label: AppStrings.createNewBusiness,
                                iconBg: isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle,
                                iconColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                                labelColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                                onTap: () {
                                  final router = GoRouter.of(context);
                                  Navigator.pop(context);
                                  router.push(AppRoutes.companyCreate);
                                },
                              ),
                            ),
                            ActionRow(
                              icon: Icons.person_add_alt_1,
                              label: AppStrings.joinByCode,
                              iconBg: isDark ? MFTokens.infoBgDark : MFTokens.infoSubtle,
                              iconColor: MFTokens.info,
                              labelColor: MFTokens.info,
                              onTap: () {
                                final router = GoRouter.of(context);
                                Navigator.pop(context);
                                router.push(AppRoutes.welcomeJoin);
                              },
                              showTopPadding: true,
                            ),
                            ActionRow(
                              icon: Icons.logout_rounded,
                              label: AppStrings.signOut,
                              iconBg: isDark ? MFTokens.errorBgDark : MFTokens.errorBg,
                              iconColor: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
                              labelColor: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
                              isLoading: _isLoggingOut,
                              onTap: () => _handleLogout(sheetContext, setSheetState),
                              showTopPadding: true,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
