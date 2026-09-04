import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';

class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyCubit>().loadCompanies();
  }

  Future<void> _selectCompany(Company company) async {
    await context.read<CompanyCubit>().switchCompany(company);
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is CompaniesLoaded) {
            if (state.companies.isEmpty) {
              context.go(AppRoutes.welcome);
            }
          } else if (state is CompanyError) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompaniesLoaded && state.companies.isNotEmpty) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(MFTokens.sp24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      AppStrings.selectCompany,
                      style: TextStyle(
                        fontSize: MFTokens.font2XL,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp8),
                    Text(
                      AppStrings.selectCompanySubtitle,
                      style: TextStyle(
                        fontSize: MFTokens.fontMD,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp32),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.companies.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: MFTokens.sp16),
                        itemBuilder: (context, index) {
                          final company = state.companies[index];
                          return Card(
                            color: cardBg,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(MFTokens.sp16),
                              title: Text(
                                company.name,
                                style: TextStyle(
                                  fontSize: MFTokens.fontLG,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              subtitle: company.address != null
                                  ? Text(
                                      company.address!,
                                      style: TextStyle(
                                        fontSize: MFTokens.fontSM,
                                        color: textSecondary,
                                      ),
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                              ),
                              onTap: () => _selectCompany(company),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRoutes.welcomeCreate),
                        icon: const Icon(Icons.business_outlined, color: MFTokens.textOnPrimary),
                        label: Text(
                          AppStrings.createCompany,
                          style: const TextStyle(
                            fontSize: MFTokens.fontMD,
                            color: MFTokens.textOnPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                          padding: const EdgeInsets.all(MFTokens.sp16),
                        ),
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.welcomeJoin),
                        icon: Icon(Icons.group_add_outlined, color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary),
                        label: Text(
                          AppStrings.joinCompany,
                          style: TextStyle(
                            fontSize: MFTokens.fontMD,
                            color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(MFTokens.sp16),
                          side: BorderSide(color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CompanyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: MFTokens.fontMD,
                      color: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
                    ),
                  ),
                  const SizedBox(height: MFTokens.sp16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CompanyCubit>().loadCompanies(),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
