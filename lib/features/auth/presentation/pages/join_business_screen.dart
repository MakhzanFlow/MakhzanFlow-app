import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/join_company_cubit.dart';

class JoinBusinessScreen extends StatefulWidget {
  const JoinBusinessScreen({super.key});

  @override
  State<JoinBusinessScreen> createState() => _JoinBusinessScreenState();
}

class _JoinBusinessScreenState extends State<JoinBusinessScreen> {
  late final JoinCompanyCubit _cubit;
  final _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<JoinCompanyCubit>();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinByCode() async {
    if (!_formKey.currentState!.validate()) return;
    _cubit.joinByCode(_inviteCodeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return BlocListener<JoinCompanyCubit, JoinCompanyState>(
      listener: (context, state) {
        if (state is JoinCompanyCodeSent) {
          context.go(
            AppRoutes.welcomePending,
            extra: {
              'requestId': state.requestId,
              'companyId': state.companyId,
              'companyName': state.companyName,
              'companyLogo': state.companyLogo,
            },
          );
        } else if (state is JoinCompanyError) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
          foregroundColor: MFTokens.textOnPrimary,
          title: Text(AppStrings.joinCompany),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(MFTokens.sp32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: MFTokens.sp24),
                Icon(
                  Icons.vpn_key_outlined,
                  size: 64,
                  color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                ),
                const SizedBox(height: MFTokens.sp24),
                Text(
                  AppStrings.inviteCodeTitle,
                  style: TextStyle(
                    fontSize: MFTokens.fontLG,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: MFTokens.sp8),
                Text(
                  AppStrings.inviteCodeSubtitle,
                  style: TextStyle(
                    fontSize: MFTokens.fontSM,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: MFTokens.sp24),
                TextFormField(
                  controller: _inviteCodeController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: MFTokens.fontLG,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.inviteCodeHint,
                    hintStyle: TextStyle(
                      letterSpacing: 4,
                      color: textSecondary,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.inviteCodeRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: MFTokens.sp32),
                BlocBuilder<JoinCompanyCubit, JoinCompanyState>(
                  builder: (context, state) {
                    final isLoading = state is JoinCompanyLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _joinByCode,
                        child: isLoading
                            ? const SizedBox(
                                height: MFTokens.sp24,
                                width: MFTokens.sp24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: MFTokens.textOnPrimary,
                                ),
                              )
                            : Text(AppStrings.joinButton),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
