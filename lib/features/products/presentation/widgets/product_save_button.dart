import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductSaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditMode;
  final VoidCallback? onPressed;

  const ProductSaveButton({
    super.key,
    required this.isLoading,
    required this.isEditMode,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MFTokens.buttonHeightMD,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditMode ? AppStrings.productSave : AppStrings.productsAdd,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                ),
              ),
      ),
    );
  }
}
