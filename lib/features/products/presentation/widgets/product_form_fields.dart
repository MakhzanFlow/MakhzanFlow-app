import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductFormFields extends StatefulWidget {
  final String name;
  final String sku;
  final String barcode;
  final String price;
  final String quantity;
  final String minStock;
  final DateTime? expirationDate;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onSkuChanged;
  final ValueChanged<String> onBarcodeChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onMinStockChanged;
  final ValueChanged<DateTime?> onExpirationDateChanged;

  const ProductFormFields({
    super.key,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.quantity,
    required this.minStock,
    this.expirationDate,
    required this.onNameChanged,
    required this.onSkuChanged,
    required this.onBarcodeChanged,
    required this.onPriceChanged,
    required this.onQuantityChanged,
    required this.onMinStockChanged,
    required this.onExpirationDateChanged,
  });

  @override
  State<ProductFormFields> createState() => _ProductFormFieldsState();
}

class _ProductFormFieldsState extends State<ProductFormFields> {
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _skuController = TextEditingController(text: widget.sku);
    _barcodeController = TextEditingController(text: widget.barcode);
    _priceController = TextEditingController(text: widget.price);
    _quantityController = TextEditingController(text: widget.quantity);
    _minStockController = TextEditingController(text: widget.minStock);
  }

  @override
  void didUpdateWidget(ProductFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name && widget.name != _nameController.text) {
      _nameController.text = widget.name;
    }
    if (widget.sku != oldWidget.sku && widget.sku != _skuController.text) {
      _skuController.text = widget.sku;
    }
    if (widget.barcode != oldWidget.barcode && widget.barcode != _barcodeController.text) {
      _barcodeController.text = widget.barcode;
    }
    if (widget.price != oldWidget.price && widget.price != _priceController.text) {
      _priceController.text = widget.price;
    }
    if (widget.quantity != oldWidget.quantity && widget.quantity != _quantityController.text) {
      _quantityController.text = widget.quantity;
    }
    if (widget.minStock != oldWidget.minStock && widget.minStock != _minStockController.text) {
      _minStockController.text = widget.minStock;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.expirationDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      widget.onExpirationDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildField(
          label: AppStrings.productNameLabel,
          hint: AppStrings.productNameHint,
          controller: _nameController,
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildField(
          label: AppStrings.productSkuLabel,
          hint: AppStrings.productSkuHint,
          controller: _skuController,
          onChanged: widget.onSkuChanged,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildField(
          label: AppStrings.productBarcodeLabel,
          hint: AppStrings.productBarcodeHint,
          controller: _barcodeController,
          onChanged: widget.onBarcodeChanged,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildField(
          label: AppStrings.productPriceLabel,
          hint: AppStrings.productPriceHint,
          controller: _priceController,
          onChanged: widget.onPriceChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildField(
          label: AppStrings.productQuantityLabel,
          hint: AppStrings.productQuantityHint,
          controller: _quantityController,
          onChanged: widget.onQuantityChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildField(
          label: AppStrings.productMinStockLabel,
          hint: AppStrings.productMinStockHint,
          controller: _minStockController,
          onChanged: widget.onMinStockChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: MFTokens.sp16),
        _buildDateField(),
      ],
    );
  }

  Widget _buildDateField() {
    final text = widget.expirationDate != null
        ? '${widget.expirationDate!.year}-${widget.expirationDate!.month.toString().padLeft(2, '0')}-${widget.expirationDate!.day.toString().padLeft(2, '0')}'
        : null;

    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.productExpirationDateLabel,
          hintText: AppStrings.productExpirationDateHint,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: text != null
            ? Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textDirection == TextDirection.rtl
          ? TextAlign.right
          : TextAlign.left,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
    );
  }
}
