import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/create_company_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/widgets/logo_picker.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedType;
  final List<String> _businessTypes = [
    AppStrings.businessTypeWholesale,
    AppStrings.businessTypeRetail,
    AppStrings.businessTypePharmacy,
    AppStrings.businessTypeSupermarket,
    AppStrings.businessTypeRestaurant,
    AppStrings.businessTypeOther,
  ];

  late final AnimationController _animController;
  late final Animation<double> _contentFade;
  late final Animation<double> _contentSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<CreateCompanyCubit, CreateCompanyState>(
        listener: (context, state) {
          if (state.status == CreateCompanyStatus.success) {
            context.go(AppRoutes.dashboard);
          } else if (state.status == CreateCompanyStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, textPrimary, textSecondary),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      MFTokens.sp16,
                      MFTokens.sp8,
                      MFTokens.sp16,
                      MFTokens.sp16,
                    ),
                    child: AnimatedBuilder(
                      animation: _contentSlide,
                      builder: (context, child) => Opacity(
                        opacity: _contentFade.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            MFTokens.sp24 * (1 - _contentSlide.value),
                          ),
                          child: child,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: _buildFormContent(context, state, textPrimary, textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textPrimary, Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MFTokens.sp16,
        MFTokens.sp4,
        MFTokens.sp16,
        MFTokens.sp8,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.createBusiness,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontLG,
                  fontWeight: FontWeight.w400,
                  color: textPrimary,
                ),
              ),
              Text(
                AppStrings.createBusinessSubtitle,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, CreateCompanyState state, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: LogoPicker(
            imagePath: state.imagePath,
            onPickFromGallery: () =>
                context.read<CreateCompanyCubit>().pickImageFromGallery(),
            onPickFromCamera: () =>
                context.read<CreateCompanyCubit>().pickImageFromCamera(),
            onClear: () => context.read<CreateCompanyCubit>().clearImage(),
          ),
        ),
        const SizedBox(height: MFTokens.sp20),
        _buildFormField(
          label: AppStrings.businessNameLabel,
          hint: AppStrings.businessNameHint,
          icon: Icons.store_outlined,
          controller: _nameController,
          enabled: state.status != CreateCompanyStatus.loading,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          validator: (v) => v == null || v.trim().isEmpty
              ? AppStrings.businessNameRequired
              : null,
        ),
        _buildTypeLabel(textPrimary),
        const SizedBox(height: MFTokens.sp4),
        _buildTypeChips(context, textSecondary),
        _buildFormField(
          label: AppStrings.phone,
          hint: AppStrings.phoneHint,
          icon: Icons.phone_outlined,
          controller: _phoneController,
          enabled: state.status != CreateCompanyStatus.loading,
          keyboardType: TextInputType.phone,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        _buildFormField(
          label: AppStrings.address,
          hint: AppStrings.addressHint,
          icon: Icons.location_on_outlined,
          controller: _addressController,
          enabled: state.status != CreateCompanyStatus.loading,
          maxLines: 2,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: MFTokens.sp24),
        _buildBottomButtons(context, state),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color textPrimary,
    required Color textSecondary,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: MFTokens.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: MFTokens.sp8),
          Container(
            constraints: const BoxConstraints(minHeight: MFTokens.inputHeight),
            decoration: BoxDecoration(
              color: isDark ? MFTokens.inputBgDark : MFTokens.inputBgLight,
              border: Border.all(
                color: isDark ? MFTokens.borderDark : MFTokens.borderLight,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(MFTokens.radiusMD),
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
                  fontSize: MFTokens.fontMD,
                  color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight,
                ),
                prefixIcon: Icon(
                  icon,
                  size: 14,
                  color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MFTokens.sp8,
                  vertical: maxLines > 1 ? MFTokens.sp8 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeLabel(Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(top: MFTokens.sp24),
      child: Text(
        AppStrings.businessTypeLabel,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: MFTokens.fontSM,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildTypeChips(BuildContext context, Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: MFTokens.sp4),
      child: Wrap(
        spacing: MFTokens.sp4,
        runSpacing: MFTokens.sp4,
        children: _businessTypes.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.sp10,
                vertical: MFTokens.sp2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle)
                    : (isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight),
                border: isSelected
                    ? Border.all(
                        color: (isDark ? MFTokens.primaryDarkMode : MFTokens.primary).withValues(alpha: 0.19),
                        width: 0.8,
                      )
                    : null,
                borderRadius: BorderRadius.circular(MFTokens.radiusXXL),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontXS,
                  color: isSelected
                      ? (isDark ? MFTokens.primaryDarkMode : MFTokens.primary)
                      : textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, CreateCompanyState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final isLoading = state.status == CreateCompanyStatus.loading;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: MFTokens.buttonHeightMD,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: Text(
                AppStrings.cancelButton,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: MFTokens.sp8),
        Expanded(
          child: SizedBox(
            height: MFTokens.buttonHeightMD,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _submitForm(context),
              child: isLoading
                  ? const SizedBox(
                      width: MFTokens.sp24,
                      height: MFTokens.sp24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MFTokens.textOnPrimary,
                      ),
                    )
                  : Text(
                      AppStrings.createBusinessButton,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontMD,
                        fontWeight: FontWeight.w500,
                        color: MFTokens.textOnPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateCompanyCubit>().createCompany(
      name: _nameController.text,
      businessType: _selectedType,
      phone: _phoneController.text,
      address: _addressController.text,
    );
  }
}
