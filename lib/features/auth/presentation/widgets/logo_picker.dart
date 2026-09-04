import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../products/presentation/widgets/dashed_border_painter.dart';

class LogoPicker extends StatelessWidget {
  final String? imagePath;
  final String? logoUrl;
  final VoidCallback? onPickFromGallery;
  final VoidCallback? onPickFromCamera;
  final VoidCallback? onClear;

  const LogoPicker({
    super.key,
    this.imagePath,
    this.logoUrl,
    this.onPickFromGallery,
    this.onPickFromCamera,
    this.onClear,
  });

  void _showPickerOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MFTokens.radiusXL),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MFTokens.sp16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                ),
                title: Text(AppStrings.pickFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  onPickFromGallery?.call();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
                ),
                title: Text(AppStrings.pickFromCamera),
                onTap: () {
                  Navigator.pop(ctx);
                  onPickFromCamera?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final subtleBg = isDark
        ? MFTokens.primaryDarkModeSubtle
        : MFTokens.primarySubtle;

    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: subtleBg,
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
          child: CustomPaint(
            painter: DashedBorderPainter(color: primary, strokeWidth: 1.6),
            child: imagePath != null
                ? _buildImageContent()
                : logoUrl != null
                ? _buildNetworkContent()
                : _buildPlaceholderContent(primary),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return Stack(
      children: [
        Image.file(
          File(imagePath!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildNetworkContent() {
    return Stack(
      children: [
        AppNetworkImage(
          imageUrl: logoUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildPlaceholderContent(MFTokens.primary),
        ),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildClearButton() {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: onClear,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: MFTokens.overlayDark,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: MFTokens.textOnPrimary),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 32, color: primary),
        const SizedBox(height: 4),
        Text(
          AppStrings.logoPickerLabel,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontXS,
            color: primary,
          ),
        ),
      ],
    );
  }
}
