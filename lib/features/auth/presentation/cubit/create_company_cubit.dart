import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/storage/file_upload_service.dart';
import 'package:makhzanflow/features/companies/domain/usecases/create_company_full_usecase.dart';

enum CreateCompanyStatus { initial, loading, success, error }

class CreateCompanyState extends Equatable {
  final CreateCompanyStatus status;
  final String? imagePath;
  final String? errorMessage;

  const CreateCompanyState({
    this.status = CreateCompanyStatus.initial,
    this.imagePath,
    this.errorMessage,
  });

  static const _sentinel = Object();

  CreateCompanyState copyWith({
    CreateCompanyStatus? status,
    Object? imagePath = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return CreateCompanyState(
      status: status ?? this.status,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, imagePath, errorMessage];
}

class CreateCompanyCubit extends Cubit<CreateCompanyState> {
  final CreateCompanyFullUseCase _createCompanyFullUseCase;
  final CompanyCubit _companyCubit;
  final ImagePicker _picker;
  final FileUploadService _fileUploadService;

  CreateCompanyCubit({
    required CreateCompanyFullUseCase createCompanyFullUseCase,
    required CompanyCubit companyCubit,
    required ImagePicker picker,
    FileUploadService? fileUploadService,
  })  : _createCompanyFullUseCase = createCompanyFullUseCase,
        _companyCubit = companyCubit,
        _picker = picker,
        _fileUploadService = fileUploadService ?? const FileUploadService(),
        super(const CreateCompanyState());

  Future<void> pickImageFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      emit(state.copyWith(imagePath: file.path, errorMessage: null));
    }
  }

  Future<void> pickImageFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) {
      emit(state.copyWith(imagePath: file.path, errorMessage: null));
    }
  }

  void clearImage() {
    emit(state.copyWith(imagePath: null));
  }

  Future<bool> createCompany({
    required String name,
    String? businessType,
    String? phone,
    String? address,
  }) async {
    if (name.trim().isEmpty) {
      emit(state.copyWith(
        status: CreateCompanyStatus.error,
        errorMessage: AppStrings.businessNameRequired,
      ));
      return false;
    }

    emit(state.copyWith(
      status: CreateCompanyStatus.loading,
      errorMessage: null,
    ));

    String? logoUrl;
    if (state.imagePath != null) {
      final uploadResult = await _fileUploadService.toDataUri(state.imagePath!);
      final shouldAbort = uploadResult.fold(
        (failure) {
          emit(state.copyWith(
            status: CreateCompanyStatus.error,
            errorMessage: failure.message,
          ));
          return true;
        },
        (uri) {
          logoUrl = uri;
          return false;
        },
      );
      if (shouldAbort) return false;
    }

    final result = await _createCompanyFullUseCase.call(
      name: name.trim(),
      businessType: businessType,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      address: address?.trim().isEmpty == true ? null : address?.trim(),
      logoUrl: logoUrl,
    );

    return await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: CreateCompanyStatus.error,
          errorMessage: failure.message,
        ));
        return false;
      },
      (company) async {
        try {
          await _companyCubit.switchCompany(company);
          emit(state.copyWith(status: CreateCompanyStatus.success));
          return true;
        } catch (e) {
          emit(state.copyWith(
            status: CreateCompanyStatus.error,
            errorMessage: e.toString(),
          ));
          return false;
        }
      },
    );
  }

  void resetStatus() {
    emit(const CreateCompanyState());
  }
}
