import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

class CreateBusinessScreen extends StatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  State<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  static final _businessTypes = [
    AppStrings.businessTypeWholesale,
    AppStrings.businessTypeRetail,
    AppStrings.businessTypePharmacy,
    AppStrings.businessTypeSupermarket,
    AppStrings.businessTypeRestaurant,
    AppStrings.businessTypeOther,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Implement company creation
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark
        ? MFTokens.primaryDarkModeSubtle
        : MFTokens.primarySubtle;
    final textPrimary = isDark
        ? MFTokens.textPrimaryDark
        : MFTokens.textPrimaryLight;
    final textSecondary = isDark
        ? MFTokens.textSecondaryDark
        : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: MFTokens.textOnPrimary,
        title: Text(AppStrings.createCompany),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MFTokens.sp24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: MFTokens.sp24),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: MFTokens.sp40,
                    backgroundColor: primarySubtle,
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: MFTokens.sp32,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MFTokens.sp24),
              Center(
                child: Text(
                  AppStrings.logoPickerHint,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: MFTokens.sp32),
              Text(
                AppStrings.businessType,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: MFTokens.sp8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  hintText: AppStrings.businessTypeHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                  ),
                ),
                items: _businessTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: MFTokens.sp24),
              Text(
                AppStrings.companyName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: MFTokens.sp8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: AppStrings.companyNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.companyNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: MFTokens.sp24),
              Text(
                AppStrings.phone,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: MFTokens.sp8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: AppStrings.phoneHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                  ),
                ),
              ),
              const SizedBox(height: MFTokens.sp24),
              Text(
                AppStrings.address,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: MFTokens.sp8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: AppStrings.addressHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                  ),
                ),
              ),
              const SizedBox(height: MFTokens.sp48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCompany,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: MFTokens.textOnPrimary,
                    padding: const EdgeInsets.all(MFTokens.sp16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MFTokens.radiusLG),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: MFTokens.sp24,
                          width: MFTokens.sp24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MFTokens.textOnPrimary,
                          ),
                        )
                      : Text(
                          AppStrings.createCompanyButton,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: MFTokens.fontMD,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
