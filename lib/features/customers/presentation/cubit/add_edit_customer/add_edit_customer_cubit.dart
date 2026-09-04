import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../../domain/usecases/create_customer_usecase.dart';
import '../../../domain/usecases/upload_customer_image_usecase.dart';
import '../../../domain/usecases/get_customer_usecase.dart';
import '../../../domain/usecases/update_customer_usecase.dart';
import 'add_edit_customer_state.dart';

export 'add_edit_customer_state.dart';

class AddEditCustomerCubit extends Cubit<AddEditCustomerState> {
  final CreateCustomerUseCase _createCustomerUseCase;
  final UploadCustomerImageUseCase _uploadImageUseCase;
  final GetCustomerUseCase? _getCustomerUseCase;
  final UpdateCustomerUseCase? _updateCustomerUseCase;
  String? _customerId;

  AddEditCustomerCubit({
    required CreateCustomerUseCase createCustomerUseCase,
    required UploadCustomerImageUseCase uploadImageUseCase,
    GetCustomerUseCase? getCustomerUseCase,
    UpdateCustomerUseCase? updateCustomerUseCase,
  }) : _createCustomerUseCase = createCustomerUseCase,
       _uploadImageUseCase = uploadImageUseCase,
       _getCustomerUseCase = getCustomerUseCase,
       _updateCustomerUseCase = updateCustomerUseCase,
       super(const AddEditCustomerState());

  Future<void> loadForEdit(String customerId, String companyId) async {
    _customerId = customerId;
    emit(state.copyWith(status: AddEditCustomerStatus.loading));
    final result = await _getCustomerUseCase!(customerId, companyId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: AddEditCustomerStatus.error, failure: failure),
      ),
      (customer) => emit(
        state.copyWith(
          status: AddEditCustomerStatus.initial,
          isEditMode: true,
          name: customer.name,
          nameOfficial: customer.nameOfficial ?? '',
          phone: customer.phone ?? '',
          address: customer.address ?? '',
          debtText: customer.totalDebt.toStringAsFixed(2),
          imageUploadUrl: customer.imageUrl,
        ),
      ),
    );
  }

  void updateName(String value) => emit(state.copyWith(name: value));
  void updateNameOfficial(String value) =>
      emit(state.copyWith(nameOfficial: value));
  void updatePhone(String value) => emit(state.copyWith(phone: value));
  void updateAddress(String value) => emit(state.copyWith(address: value));
  void updateDebt(String value) => emit(state.copyWith(debtText: value));

  void setImagePath(String path) {
    emit(state.copyWith(imageLocalPath: path, isImageUploading: false));
  }

  void removeImage() {
    emit(state.copyWith(imageLocalPath: null, imageUploadUrl: null));
  }

  Future<bool> save(String companyId) async {
    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: AddEditCustomerStatus.error,
          failure: ServerFailure(AppStrings.customerNameRequired),
        ),
      );
      return false;
    }

    emit(state.copyWith(status: AddEditCustomerStatus.loading));

    final debt = double.tryParse(state.debtText) ?? 0;

    if (state.isEditMode && _updateCustomerUseCase != null) {
      String? imageUrl = state.imageUploadUrl;
      final localPath = state.imageLocalPath;
      if (localPath != null) {
        emit(state.copyWith(isImageUploading: true));
        final uploadResult = await _uploadImageUseCase(localPath, _customerId!);
        final uploadError = uploadResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: AddEditCustomerStatus.error,
                failure: failure,
                isImageUploading: false,
              ),
            );
            return failure;
          },
          (url) {
            imageUrl = url;
            return null;
          },
        );
        if (uploadError != null) return false;
      }

      final result = await _updateCustomerUseCase(
        id: _customerId!,
        name: state.name,
        nameOfficial: state.nameOfficial.isNotEmpty ? state.nameOfficial : null,
        phone: state.phone.isNotEmpty ? state.phone : null,
        address: state.address.isNotEmpty ? state.address : null,
        imageUrl: imageUrl,
        companyId: companyId,
      );
      return _handleResult(result, AppStrings.customerSaveSuccess);
    } else {
      final result = await _createCustomerUseCase(
        name: state.name,
        nameOfficial: state.nameOfficial.isNotEmpty ? state.nameOfficial : null,
        phone: state.phone.isNotEmpty ? state.phone : null,
        address: state.address.isNotEmpty ? state.address : null,
        totalDebt: debt,
        companyId: companyId,
      );
      return result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: AddEditCustomerStatus.error,
              failure: failure,
            ),
          );
          return false;
        },
        (customer) async {
          _customerId = customer.id;
          final localPath = state.imageLocalPath;
          if (localPath != null) {
            emit(state.copyWith(isImageUploading: true));
            final uploadResult = await _uploadImageUseCase(
              localPath,
              customer.id,
            );
            return uploadResult.fold(
              (failure) {
                emit(
                  state.copyWith(
                    status: AddEditCustomerStatus.error,
                    failure: failure,
                    isImageUploading: false,
                  ),
                );
                return false;
              },
              (_) {
                emit(
                  state.copyWith(
                    status: AddEditCustomerStatus.success,
                    successMessage: AppStrings.customerAddSuccess,
                  ),
                );
                return true;
              },
            );
          }
          emit(
            state.copyWith(
              status: AddEditCustomerStatus.success,
              successMessage: AppStrings.customerAddSuccess,
            ),
          );
          return true;
        },
      );
    }
  }

  bool _handleResult(Either<Failure, void> result, String message) {
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AddEditCustomerStatus.error,
            failure: failure,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            status: AddEditCustomerStatus.success,
            successMessage: message,
          ),
        );
        return true;
      },
    );
  }

  void resetStatus() {
    emit(
      state.copyWith(
        status: AddEditCustomerStatus.initial,
        failure: null,
        successMessage: null,
      ),
    );
  }
}
