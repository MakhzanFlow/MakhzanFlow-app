import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_input.dart';

enum AddEditProductStatus { initial, loading, uploading, success, error }

class AddEditProductState extends Equatable {
  final AddEditProductStatus status;
  final ProductInput input;
  final String skuText;
  final String barcodeText;
  final String priceText;
  final String quantityText;
  final String minStockText;
  final DateTime? expirationDate;
  final String? imageLocalPath;
  final String? imageUploadUrl;
  final bool isImageUploading;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditMode;

  const AddEditProductState({
    this.status = AddEditProductStatus.initial,
    this.input = const ProductInput(
      name: '', sku: '', price: 0, quantity: 0, minStock: 0,
    ),
    this.skuText = '',
    this.barcodeText = '',
    this.priceText = '',
    this.quantityText = '',
    this.minStockText = '',
    this.expirationDate,
    this.imageLocalPath,
    this.imageUploadUrl,
    this.isImageUploading = false,
    this.errorMessage,
    this.successMessage,
    this.isEditMode = false,
  });

  AddEditProductState copyWith({
    AddEditProductStatus? status,
    ProductInput? input,
    String? skuText,
    String? barcodeText,
    String? priceText,
    String? quantityText,
    String? minStockText,
    DateTime? expirationDate,
    String? imageLocalPath,
    String? imageUploadUrl,
    bool? isImageUploading,
    String? errorMessage,
    String? successMessage,
    bool? isEditMode,
  }) {
    return AddEditProductState(
      status: status ?? this.status,
      input: input ?? this.input,
      skuText: skuText ?? this.skuText,
      barcodeText: barcodeText ?? this.barcodeText,
      priceText: priceText ?? this.priceText,
      quantityText: quantityText ?? this.quantityText,
      minStockText: minStockText ?? this.minStockText,
      expirationDate: expirationDate ?? this.expirationDate,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageUploadUrl: imageUploadUrl ?? this.imageUploadUrl,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    input,
    skuText,
    barcodeText,
    priceText,
    quantityText,
    minStockText,
    expirationDate,
    imageLocalPath,
    imageUploadUrl,
    isImageUploading,
    errorMessage,
    successMessage,
    isEditMode,
  ];
}
