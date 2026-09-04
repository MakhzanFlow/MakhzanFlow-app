import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/join_company_cubit.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String requestId;
  final String companyId;
  final String companyName;
  final String? companyLogo;

  const PendingApprovalScreen({
    super.key,
    required this.requestId,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  late final JoinCompanyCubit _cubit;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<JoinCompanyCubit>();
      _cubit.resumePolling(
        requestId: widget.requestId,
        companyId: widget.companyId,
        companyName: widget.companyName,
        companyLogo: widget.companyLogo,
      );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return BlocListener<JoinCompanyCubit, JoinCompanyState>(
      listener: (context, state) async {
        if (state is JoinCompanyApproved) {
          await context.read<CompanyCubit>().loadCompanies(
            selectCompanyId: state.companyId,
          );
          if (context.mounted) {
            context.go(AppRoutes.dashboard);
          }
        } else if (state is JoinCompanyInitial) {
          context.go(AppRoutes.welcomeJoin);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(MFTokens.sp32),
            child: BlocBuilder<JoinCompanyCubit, JoinCompanyState>(
              builder: (context, state) {
                return switch (state) {
                  JoinCompanyRejected() => _buildRejected(context, textPrimary, textSecondary),
                  JoinCompanyInitial() => _buildCancelled(textPrimary),
                  JoinCompanyRequestData() => _buildPending(context, state, textPrimary, textSecondary),
                  _ => _buildPending(context, null, textPrimary, textSecondary),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPending(BuildContext context, JoinCompanyRequestData? data, Color textPrimary, Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hourglass_empty_outlined,
          size: 80,
          color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
        ),
        const SizedBox(height: MFTokens.sp32),
        Text(
          AppStrings.pendingTitle,
          style: TextStyle(
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: MFTokens.sp16),
        Text(
          AppStrings.pendingSubtitle,
          style: TextStyle(
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        CircularProgressIndicator(color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary),
        const SizedBox(height: MFTokens.sp16),
        Text(
          AppStrings.pendingChecking,
          style: TextStyle(
            fontSize: MFTokens.fontXS,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _cubit.cancelJoinRequest(data?.requestId ?? widget.requestId);
            },
            icon: const Icon(Icons.close, size: MFTokens.sp24),
            label: Text(AppStrings.cancelButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
              side: BorderSide(color: isDark ? MFTokens.errorTextDark : MFTokens.errorText),
              padding: const EdgeInsets.all(MFTokens.sp16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejected(BuildContext context, Color textPrimary, Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cancel_outlined,
          size: 80,
          color: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
        ),
        const SizedBox(height: MFTokens.sp32),
        Text(
          AppStrings.requestRejected,
          style: TextStyle(
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: MFTokens.sp16),
        Text(
          AppStrings.joinRequestNotApprovedDesc,
          style: TextStyle(
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go(AppRoutes.welcomeJoin);
            },
            icon: const Icon(Icons.refresh, size: MFTokens.sp24),
            label: Text(AppStrings.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
              foregroundColor: MFTokens.textOnPrimary,
              padding: const EdgeInsets.all(MFTokens.sp16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelled(Color textPrimary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 80,
          color: MFTokens.textSecondaryLight,
        ),
        const SizedBox(height: MFTokens.sp32),
        Text(
          AppStrings.requestCancelled,
          style: TextStyle(
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
