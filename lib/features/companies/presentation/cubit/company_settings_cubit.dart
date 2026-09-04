import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/storage/file_upload_service.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_join_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/regenerate_company_join_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/leave_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/delete_company_usecase.dart';

sealed class CompanySettingsState extends Equatable {
  const CompanySettingsState();

  @override
  List<Object?> get props => [];
}

final class CompanySettingsInitial extends CompanySettingsState {
  const CompanySettingsInitial();
}

final class CompanySettingsLoading extends CompanySettingsState {
  const CompanySettingsLoading();
}

sealed class CompanySettingsData extends CompanySettingsState {
  final Company company;
  final String? imagePath;

  const CompanySettingsData({required this.company, this.imagePath});

  @override
  List<Object?> get props => [company, imagePath];
}

final class CompanySettingsLoaded extends CompanySettingsData {
  const CompanySettingsLoaded({required super.company, super.imagePath});
}

final class CompanySettingsUpdating extends CompanySettingsData {
  const CompanySettingsUpdating({required super.company, super.imagePath});
}

final class CompanySettingsSuccess extends CompanySettingsState {
  final String message;

  const CompanySettingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class CompanySettingsError extends CompanySettingsState {
  final String message;

  const CompanySettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanySettingsCubit extends Cubit<CompanySettingsState> {
  final UpdateCompanyUseCase _updateCompanyUseCase;
  final GetCompanyJoinCodeUseCase _getCompanyJoinCodeUseCase;
  final RegenerateCompanyJoinCodeUseCase _regenerateCompanyJoinCodeUseCase;
  final LeaveCompanyUseCase _leaveCompanyUseCase;
  final DeleteCompanyUseCase _deleteCompanyUseCase;
  final ImagePicker _picker;
  final FileUploadService _fileUploadService;

  CompanySettingsCubit({
    required UpdateCompanyUseCase updateCompanyUseCase,
    required GetCompanyJoinCodeUseCase getCompanyJoinCodeUseCase,
    required RegenerateCompanyJoinCodeUseCase regenerateCompanyJoinCodeUseCase,
    required LeaveCompanyUseCase leaveCompanyUseCase,
    required DeleteCompanyUseCase deleteCompanyUseCase,
    ImagePicker? picker,
    FileUploadService? fileUploadService,
  })  : _updateCompanyUseCase = updateCompanyUseCase,
        _getCompanyJoinCodeUseCase = getCompanyJoinCodeUseCase,
        _regenerateCompanyJoinCodeUseCase = regenerateCompanyJoinCodeUseCase,
        _leaveCompanyUseCase = leaveCompanyUseCase,
        _deleteCompanyUseCase = deleteCompanyUseCase,
        _picker = picker ?? ImagePicker(),
        _fileUploadService = fileUploadService ?? const FileUploadService(),
        super(const CompanySettingsInitial());

  void loadFromCompany(Company company) {
    emit(CompanySettingsLoaded(company: company));
  }

  Future<void> pickImageFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null && state is CompanySettingsData) {
      final data = state as CompanySettingsData;
      emit(CompanySettingsLoaded(company: data.company, imagePath: file.path));
    }
  }

  Future<void> pickImageFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null && state is CompanySettingsData) {
      final data = state as CompanySettingsData;
      emit(CompanySettingsLoaded(company: data.company, imagePath: file.path));
    }
  }

  void clearImage() {
    if (state is CompanySettingsData) {
      final data = state as CompanySettingsData;
      emit(CompanySettingsLoaded(company: data.company, imagePath: null));
    }
  }

  Future<String?> getJoinCode(String companyId) async {
    final result = await _getCompanyJoinCodeUseCase.call(companyId);
    return result.fold(
      (failure) => null,
      (code) => code,
    );
  }

  Future<String?> regenerateJoinCode(String companyId) async {
    final result = await _regenerateCompanyJoinCodeUseCase.call(companyId);
    return result.fold(
      (failure) => null,
      (code) => code,
    );
  }

  Future<bool> leaveCompany() async {
    final result = await _leaveCompanyUseCase.call();
    final success = result.fold(
      (failure) => false,
      (_) => true,
    );
    if (success) emit(CompanySettingsSuccess(AppStrings.companyLeft));
    return success;
  }

  Future<bool> deleteCompany(String companyId) async {
    final result = await _deleteCompanyUseCase.call(companyId);
    final success = result.fold(
      (failure) => false,
      (_) => true,
    );
    if (success) emit(CompanySettingsSuccess(AppStrings.companyDeleted));
    return success;
  }

  Future<void> updateCompany({
    required String companyId,
    required String name,
    String? address,
    String? phone,
  }) async {
    final currentState = state;
    if (currentState is! CompanySettingsData) return;

    final company = currentState.company;
    final imagePath = currentState.imagePath;

    emit(CompanySettingsUpdating(company: company, imagePath: imagePath));

    String? logoUrl;
    if (imagePath != null) {
      final uploadResult = await _fileUploadService.toDataUri(imagePath);
      final shouldAbort = uploadResult.fold(
        (failure) {
          emit(CompanySettingsError(failure.message));
          return true;
        },
        (uri) {
          logoUrl = uri;
          return false;
        },
      );
      if (shouldAbort) return;
    }

    final result = await _updateCompanyUseCase.call(
      companyId,
      name: name,
      address: address,
      phone: phone,
      logoUrl: logoUrl,
    );

    result.fold(
      (failure) => emit(CompanySettingsError(failure.message)),
      (_) => emit(CompanySettingsSuccess(AppStrings.companyUpdated)),
    );
  }
}
