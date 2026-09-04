import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/add_edit_customer/add_edit_customer_cubit.dart';
import '../widgets/customer_text_input.dart';
import '../widgets/customer_image_uploader.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_debt_display.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final String? customerId;

  const AddEditCustomerScreen({super.key, this.customerId});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen>
    with CompanyAwareState<AddEditCustomerScreen> {
  late final AddEditCustomerCubit _cubit;
  final _nameController = TextEditingController();
  final _nameOfficialController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _debtController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool _initialized = false;

  bool get _isEditMode => widget.customerId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<AddEditCustomerCubit>();
      if (_isEditMode) {
        _cubit.loadForEdit(widget.customerId!, companyId);
      }
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    if (_isEditMode) {
      _cubit.loadForEdit(widget.customerId!, companyId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameOfficialController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  void _syncControllersFromState(AddEditCustomerState state) {
    if (_nameController.text != state.name) _nameController.text = state.name;
    if (_nameOfficialController.text != state.nameOfficial) _nameOfficialController.text = state.nameOfficial;
    if (_phoneController.text != state.phone) _phoneController.text = state.phone;
    if (_addressController.text != state.address) _addressController.text = state.address;
    if (_debtController.text != state.debtText) _debtController.text = state.debtText;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) _cubit.setImagePath(picked.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _cubit.updateName(_nameController.text);
    _cubit.updateNameOfficial(_nameOfficialController.text);
    _cubit.updatePhone(_phoneController.text);
    _cubit.updateAddress(_addressController.text);
    _cubit.updateDebt(_debtController.text);
    await _cubit.save(companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? AppStrings.customerEdit : AppStrings.customerAdd),
      ),
      body: BlocConsumer<AddEditCustomerCubit, AddEditCustomerState>(
        listener: (context, state) {
          if (state.status == AddEditCustomerStatus.success) {
            AppSnackbar.success(context, state.successMessage ?? AppStrings.customerSaveSuccess);
            context.pop(true);
          }
          if (state.status == AddEditCustomerStatus.error && state.failure != null) {
            AppSnackbar.error(context, state.failure?.message ?? AppStrings.unexpectedError);
            _cubit.resetStatus();
          }
          if (state.status == AddEditCustomerStatus.initial && state.isEditMode) {
            _syncControllersFromState(state);
          }
        },
        builder: (context, state) {
          if (state.status == AddEditCustomerStatus.loading && _isEditMode) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(MFTokens.sp16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomerImageUploader(
                    imageUrl: state.imageUploadUrl,
                    localPath: state.imageLocalPath,
                    isUploading: state.isImageUploading,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: MFTokens.sp24),
                  CustomerTextInput(
                    controller: _nameController,
                    label: AppStrings.customerNameLabel,
                    hintText: AppStrings.customerNameHint,
                    iconData: Icons.store_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return AppStrings.customerNameRequired;
                      return null;
                    },
                    onChanged: (value) => _cubit.updateName(value),
                  ),
                  const SizedBox(height: MFTokens.sp16),
                  CustomerTextInput(
                    controller: _nameOfficialController,
                    label: AppStrings.customerOfficialNameLabel,
                    hintText: AppStrings.customerOfficialNameHint,
                    iconData: Icons.person_outline,
                    onChanged: (value) => _cubit.updateNameOfficial(value),
                  ),
                  const SizedBox(height: MFTokens.sp16),
                  CustomerTextInput(
                    controller: _phoneController,
                    label: AppStrings.customerPhoneLabel,
                    hintText: AppStrings.customerPhoneHint,
                    iconData: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _cubit.updatePhone(value),
                  ),
                  const SizedBox(height: MFTokens.sp16),
                  CustomerTextInput(
                    controller: _addressController,
                    label: AppStrings.customerAddressLabel,
                    hintText: AppStrings.customerAddressHint,
                    iconData: Icons.location_on_outlined,
                    onChanged: (value) => _cubit.updateAddress(value),
                  ),
                  const SizedBox(height: MFTokens.sp16),
                  if (!_isEditMode)
                    CustomerTextInput(
                      controller: _debtController,
                      label: AppStrings.customerDebtLabel,
                      hintText: AppStrings.customerDebtHint,
                      iconData: Icons.currency_exchange,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _cubit.updateDebt(value),
                    )
                  else
                    CustomerDebtDisplay(debtText: state.debtText),
                  const SizedBox(height: MFTokens.sp16),
                  const SizedBox(height: MFTokens.sp32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomerActionButton(
                        text: AppStrings.customerCancel,
                        isPrimary: false,
                        onPressed: () => context.pop(),
                      ),
                      CustomerActionButton(
                        text: _isEditMode ? AppStrings.customerSave : AppStrings.customerAddButton,
                        isLoading: state.status == AddEditCustomerStatus.loading,
                        onPressed: _save,
                      ),
                    ],
                  ),
                  const SizedBox(height: MFTokens.sp24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
