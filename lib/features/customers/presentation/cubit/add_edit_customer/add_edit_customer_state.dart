import 'package:equatable/equatable.dart';
import 'package:makhzanflow/core/error/failures.dart';

enum AddEditCustomerStatus { initial, loading, success, error }

class AddEditCustomerState extends Equatable {
  final AddEditCustomerStatus status;
  final String name;
  final String nameOfficial;
  final String phone;
  final String address;
  final String debtText;
  final String? imageLocalPath;
  final String? imageUploadUrl;
  final bool isImageUploading;
  final Failure? failure;
  final String? successMessage;
  final bool isEditMode;
  /// Server per-field errors (`errors[].field`) keyed by backend field name.
  final Map<String, String> fieldErrors;

  const AddEditCustomerState({
    this.status = AddEditCustomerStatus.initial,
    this.name = '',
    this.nameOfficial = '',
    this.phone = '',
    this.address = '',
    this.debtText = '',
    this.imageLocalPath,
    this.imageUploadUrl,
    this.isImageUploading = false,
    this.failure,
    this.successMessage,
    this.isEditMode = false,
    this.fieldErrors = const {},
  });

  AddEditCustomerState copyWith({
    AddEditCustomerStatus? status,
    String? name,
    String? nameOfficial,
    String? phone,
    String? address,
    String? debtText,
    String? imageLocalPath,
    String? imageUploadUrl,
    bool? isImageUploading,
    Failure? failure,
    String? successMessage,
    bool? isEditMode,
    Map<String, String>? fieldErrors,
  }) {
    return AddEditCustomerState(
      status: status ?? this.status,
      name: name ?? this.name,
      nameOfficial: nameOfficial ?? this.nameOfficial,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      debtText: debtText ?? this.debtText,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageUploadUrl: imageUploadUrl ?? this.imageUploadUrl,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      failure: failure ?? this.failure,
      successMessage: successMessage ?? this.successMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    nameOfficial,
    phone,
    address,
    debtText,
    imageLocalPath,
    imageUploadUrl,
    isImageUploading,
    failure,
    successMessage,
    isEditMode,
    fieldErrors,
  ];
}
