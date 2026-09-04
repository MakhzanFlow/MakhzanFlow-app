import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'dashed_border_painter.dart';

class ProductImagePickerField extends StatelessWidget {
  final String? imageLocalPath;
  final String? imageUploadUrl;
  final bool isUploading;
  final ValueChanged<String> onImagePicked;
  final VoidCallback? onRemove;

  const ProductImagePickerField({
    super.key,
    this.imageLocalPath,
    this.imageUploadUrl,
    this.isUploading = false,
    required this.onImagePicked,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final hasImage = imageLocalPath != null || imageUploadUrl != null;

    if (isUploading) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: MFTokens.sp8),
              Text(
                AppStrings.productImageUploading,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        child: SizedBox(
          height: 160,
          child: Stack(
            children: [
              if (imageLocalPath != null)
                Image.file(
                  File(imageLocalPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                AppNetworkImage(
                  imageUrl: imageUploadUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholder(isDark, primary, primarySubtle),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: MFTokens.errorText,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: _placeholder(isDark, primary, primarySubtle),
    );
  }

  Widget _placeholder(bool isDark, Color primary, Color primarySubtle) {
    return Center(
      child: Container(
        width: 249,
        height: 160,
        decoration: BoxDecoration(
          color: primarySubtle,
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(color: primary),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: primary, width: 2.17),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.productImagePicker,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontXS,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MFTokens.radiusXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MFTokens.sp24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: MFTokens.sp20),
              Text(
                AppStrings.productImagePicker,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MFTokens.sp16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: primary),
                ),
                title: Text(
                  AppStrings.productImageGallery,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: primary),
                ),
                title: Text(
                  AppStrings.productImageCamera,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      onImagePicked(pickedFile.path);
    }
  }
}
