import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/logo_picker.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_settings_cubit.dart';
import 'package:makhzanflow/features/companies/presentation/widgets/share_code_widget.dart';

class CompanySettingsPage extends StatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _initialized = false;
  bool _dataLoaded = false;
  String? _joinCode;
  bool _joinCodeLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final companyState = context.read<CompanyCubit>().state;
      if (companyState is CompanySelected) {
        context.read<CompanySettingsCubit>().loadFromCompany(
          companyState.company,
        );
      }
    }
  }

  void _syncControllers(Company company) {
    if (!_dataLoaded) {
      _dataLoaded = true;
      _nameController.text = company.name;
      _phoneController.text = company.phone ?? '';
      _addressController.text = company.address ?? '';
    }
  }

  Future<void> _loadJoinCode() async {
    setState(() => _joinCodeLoading = true);
    final companyState = context.read<CompanyCubit>().state;
    final companyId = companyState is CompanySelected ? companyState.company.id : null;
    if (companyId == null) {
      setState(() => _joinCodeLoading = false);
      return;
    }
    final code = await context.read<CompanySettingsCubit>().getJoinCode(companyId);
    if (mounted) {
      setState(() {
        _joinCode = code;
        _joinCodeLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyState = context.read<CompanyCubit>().state;
    final currentMembership = companyState is CompanySelected
        ? companyState.membership
        : null;
    final isOwner = currentMembership?.isOwner ?? false;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<CompanySettingsCubit, CompanySettingsState>(
        listener: (context, state) {
          if (state is CompanySettingsSuccess) {
            AppSnackbar.success(context, state.message);
            if (state.message == AppStrings.companyDeleted ||
                state.message == AppStrings.companyLeft) {
              context.go(AppRoutes.companySelect);
            } else {
              context.pop();
            }
          } else if (state is CompanySettingsError) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CompanySettingsInitial ||
              state is CompanySettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state is CompanySettingsData ? state : null;
          if (data != null) {
            _syncControllers(data.company);

            return SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.spacingMedium,
                        AppSizes.spacingSmall,
                        AppSizes.spacingMedium,
                        AppSizes.spacingMedium,
                      ),
                      child: Form(
                        key: _formKey,
                        child: _buildFormContent(
                          context,
                          data.company,
                          data.imagePath,
                          state is CompanySettingsUpdating,
                          isOwner,
                        ),
                      ),
                    ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingMedium,
        AppSizes.spacingTiny,
        AppSizes.spacingMedium,
        AppSizes.spacingSmall,
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.backButtonSize,
            height: AppSizes.backButtonSize,
            decoration: const BoxDecoration(
              color: AppColors.chipBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                size: AppSizes.backButtonSize / 2,
                color: AppColors.textDark,
              ),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: AppSizes.spacingSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.companySettings,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontXLarge,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                AppStrings.editCompanyData,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.w400,
                  color: AppColors.amountGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(
    BuildContext context,
    Company company,
    String? imagePath,
    bool isLoading,
    bool isOwner,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Company Info --
        Center(
          child: LogoPicker(
            imagePath: imagePath,
            logoUrl: company.logoUrl,
            onPickFromGallery: () =>
                context.read<CompanySettingsCubit>().pickImageFromGallery(),
            onPickFromCamera: () =>
                context.read<CompanySettingsCubit>().pickImageFromCamera(),
            onClear: () => context.read<CompanySettingsCubit>().clearImage(),
          ),
        ),
        SizedBox(height: AppSizes.formFieldTopPadding),
        _buildFormField(
          label: AppStrings.companyName,
          hint: AppStrings.companyNameHint,
          icon: Icons.store_outlined,
          controller: _nameController,
          enabled: !isLoading,
          validator: (v) => v == null || v.trim().isEmpty
              ? AppStrings.companyNameRequired
              : null,
        ),
        _buildFormField(
          label: AppStrings.phone,
          hint: AppStrings.phoneHint,
          icon: Icons.phone_outlined,
          controller: _phoneController,
          enabled: !isLoading,
          keyboardType: TextInputType.phone,
        ),
        _buildFormField(
          label: AppStrings.address,
          hint: AppStrings.addressHint,
          icon: Icons.location_on_outlined,
          controller: _addressController,
          enabled: !isLoading,
          maxLines: 2,
        ),
        SizedBox(height: AppSizes.spacingLarge),
        _buildInfoCard(company),
        SizedBox(height: AppSizes.spacingXLarge),
        _buildSaveButton(context, company.id, isLoading),

        SizedBox(height: AppSizes.spacingXLarge),
        Divider(color: AppColors.inputBorder),

        // -- Join Code Section (owner-only) --
        if (isOwner) ...[
          SizedBox(height: AppSizes.spacingLarge),
          _buildSectionTitle(AppStrings.inviteCode),
          SizedBox(height: AppSizes.spacingSmall),
          _joinCodeLoading
              ? Center(child: CircularProgressIndicator())
              : _joinCode != null
                  ? ShareCodeWidget(
                      code: _joinCode!,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: _joinCode!));
                        AppSnackbar.success(context, AppStrings.codeCopied);
                      },
                      onRegenerate: () => _confirmRegenerateCode(),
                    )
                  : ElevatedButton(
                      onPressed: _loadJoinCode,
                      child: Text(AppStrings.viewInviteCode),
                    ),
          SizedBox(height: AppSizes.spacingLarge),
          Divider(color: AppColors.inputBorder),
        ],

        // -- Team Members shortcut --
        SizedBox(height: AppSizes.spacingLarge),
        _buildSectionTitle(AppStrings.teamMembers),
        SizedBox(height: AppSizes.spacingSmall),
        _buildLinkCard(
          icon: Icons.people,
          label: AppStrings.viewTeam,
          onTap: () => context.push('/settings/members'),
        ),

        SizedBox(height: AppSizes.spacingLarge),
        Divider(color: AppColors.inputBorder),

        // -- Danger Zone (owner-only) --
        if (isOwner) ...[
          SizedBox(height: AppSizes.spacingLarge),
          _buildSectionTitle(AppStrings.dangerZone, color: AppColors.error),
          SizedBox(height: AppSizes.spacingSmall),
          _buildDangerButton(
            label: AppStrings.deleteCompany,
            icon: Icons.delete_forever,
            onTap: () => _confirmDeleteCompany(company.id),
          ),
          SizedBox(height: AppSizes.spacingSmall),
        ] else ...[
          SizedBox(height: AppSizes.spacingLarge),
          Divider(color: AppColors.inputBorder),
          SizedBox(height: AppSizes.spacingLarge),
          _buildDangerButton(
            label: AppStrings.leaveCompany,
            icon: Icons.exit_to_app,
            onTap: _confirmLeaveCompany,
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizes.fontXLarge,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.inputBorder,
          width: AppSizes.borderWidthThin,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: AppSizes.fontMedium,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: AppSizes.iconSmall,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.error),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: AppSizes.fontLarge,
            color: AppColors.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error.withAlpha(77)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
        ),
      ),
    );
  }

  void _confirmDeleteCompany(String companyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppStrings.deleteCompany,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppStrings.deleteCompanyConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CompanySettingsCubit>().deleteCompany(companyId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.deleteAction),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveCompany() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppStrings.leaveCompany,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppStrings.leaveCompanyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CompanySettingsCubit>().leaveCompany();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.leaveAction),
          ),
        ],
      ),
    );
  }

  void _confirmRegenerateCode() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.changeInviteCode),
        content: Text(AppStrings.changeInviteCodeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<CompanySettingsCubit>();
              final companyState = context.read<CompanyCubit>().state;
              final companyId = companyState is CompanySelected
                  ? companyState.company.id
                  : null;
              final newCode = companyId == null
                  ? null
                  : await cubit.regenerateJoinCode(companyId);
              if (mounted) {
                if (newCode != null) {
                  setState(() => _joinCode = newCode);
                  AppSnackbar.success(context, AppStrings.inviteCodeChanged);
                } else {
                  AppSnackbar.error(context, AppStrings.inviteCodeChangeFailed);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  // --- Original widget helpers ---

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Container(
            constraints: BoxConstraints(minHeight: AppSizes.fieldHeight),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              border: Border.all(
                color: AppColors.inputBorder,
                width: AppSizes.borderWidthThin,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontLarge,
                  color: AppColors.hintText,
                ),
                prefixIcon: Icon(
                  icon,
                  size: AppSizes.fieldIconSize,
                  color: AppColors.hintText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingSmall,
                  vertical: maxLines > 1 ? AppSizes.spacingSmall : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Company company) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.inputBorder,
          width: AppSizes.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(AppStrings.subscriptionPlan, company.subscriptionPlan),
          SizedBox(height: AppSizes.spacingSmall),
          Divider(color: AppColors.inputBorder, height: 1),
          SizedBox(height: AppSizes.spacingSmall),
          _buildInfoRow(AppStrings.status, company.status),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: AppSizes.fontMedium,
            color: AppColors.amountGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    String companyId,
    bool isLoading,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonBottomHeight,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.inputBorder,
                  width: AppSizes.borderWidthThin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: Text(
                AppStrings.cancelButton,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontLarge,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonBottomHeight,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _save(context, companyId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shadowColor: AppColors.primary.withValues(alpha: 0.25),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: AppSizes.iconMedium,
                      height: AppSizes.iconMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizes.strokeWidthMedium,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      AppStrings.save,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: AppSizes.fontLarge,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _save(BuildContext context, String companyId) {
    if (!_formKey.currentState!.validate()) return;
    context.read<CompanySettingsCubit>().updateCompany(
      companyId: companyId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );
  }
}
