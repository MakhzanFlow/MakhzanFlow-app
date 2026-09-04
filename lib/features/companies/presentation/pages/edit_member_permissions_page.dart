import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/constants/permission_labels.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_members_cubit.dart';

class EditMemberPermissionsPage extends StatefulWidget {
  final CompanyMember member;
  final String companyId;

  const EditMemberPermissionsPage({
    super.key,
    required this.member,
    required this.companyId,
  });

  @override
  State<EditMemberPermissionsPage> createState() =>
      _EditMemberPermissionsPageState();
}

class _EditMemberPermissionsPageState
    extends State<EditMemberPermissionsPage> {
  Map<String, bool> _permissions = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);

    final cubit = context.read<CompanyMembersCubit>();
    final existing = await cubit.getMemberPermissions(
      widget.companyId,
      widget.member.userId,
    );

    final flat = <String, bool>{};
    for (final section in permissionSections.values) {
      for (final key in section) {
        flat[key] = _getPermissionValue(existing, key);
      }
    }

    if (mounted) {
      setState(() {
        _permissions = flat;
        _isLoading = false;
      });
    }
  }

  bool _getPermissionValue(Map<String, dynamic>? perms, String key) {
    if (perms == null) return false;
    final parts = key.split('.');
    if (parts.length == 1) {
      return (perms[parts[0]] as bool?) ?? false;
    }
    final section = perms[parts[0]] as Map<String, dynamic>?;
    if (section == null) return false;
    return (section[parts[1]] as bool?) ?? false;
  }

  Map<String, dynamic> _buildPermissionsJson() {
    final result = <String, dynamic>{};
    for (final entry in _permissions.entries) {
      final parts = entry.key.split('.');
      if (parts.length == 1) {
        result[parts[0]] = entry.value;
      } else {
        result.putIfAbsent(parts[0], () => <String, dynamic>{});
        (result[parts[0]] as Map<String, dynamic>)[parts[1]] = entry.value;
      }
    }
    return result;
  }

  Future<void> _save() async {
    if (!mounted) return;
    setState(() => _isSaving = true);
    final permissions = _buildPermissionsJson();
    await context.read<CompanyMembersCubit>().updateMemberPermissions(
          widget.companyId,
          widget.member.userId,
          permissions,
        );
    if (!mounted) return;
    AppSnackbar.success(context, AppStrings.permissionsSaved);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          AppStrings.permissionsTitle(
              widget.member.userName ?? AppStrings.unknownUser),
        ),
        actions: [
          if (!_isLoading && !widget.member.isOwner)
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                      width: AppSizes.iconSmall,
                      height: AppSizes.iconSmall,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSaving ? null : _save,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.member.isOwner) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield,
              size: AppSizes.iconXLarge,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              AppStrings.ownerFullAccess,
              style: TextStyle(
                fontSize: AppSizes.fontXLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      children: [
        ...permissionSections.entries.map(
          (section) => _buildSectionCard(section.key, section.value),
        ),
        SizedBox(height: AppSizes.spacingLarge),
        _buildSaveButton(),
        SizedBox(height: AppSizes.spacingLarge),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<String> keys) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ...keys.map((key) => _buildPermissionTile(key)),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(String key) {
    final label = permissionLabels[key] ?? key;
    final value = _permissions[key] ?? false;

    return SwitchListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.fontMedium,
          color: AppColors.textPrimary,
        ),
      ),
      value: value,
      activeTrackColor: AppColors.primary.withAlpha(77),
      activeThumbColor: AppColors.primary,
      onChanged: (v) {
        setState(() => _permissions[key] = v);
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
        child: _isSaving
            ? SizedBox(
                width: AppSizes.iconMedium,
                height: AppSizes.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                AppStrings.save,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontLarge,
                ),
              ),
      ),
    );
  }
}
