import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerImageUploader extends StatelessWidget {
  final String? imageUrl;
  final String? localPath;
  final bool isUploading;
  final VoidCallback onTap;

  const CustomerImageUploader({
    super.key,
    this.imageUrl,
    this.localPath,
    this.isUploading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final semiTransparent = Color(0x42000000);
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MFTokens.sp64 * 1.5,
        height: MFTokens.sp64 * 1.5,
        decoration: BoxDecoration(
          color: primarySubtle,
          borderRadius: BorderRadius.circular(MFTokens.radiusFull),
          border: Border.all(
            color: primary,
            width: MFTokens.sp2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MFTokens.radiusFull),
          child: Stack(
            children: [
              if (localPath != null)
                Image.file(
                  File(localPath!),
                  width: MFTokens.sp64 * 1.5,
                  height: MFTokens.sp64 * 1.5,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(primarySubtle, primary, textSecondary),
                )
              else if (imageUrl != null && imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: MFTokens.sp64 * 1.5,
                  height: MFTokens.sp64 * 1.5,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildPlaceholder(primarySubtle, primary, textSecondary),
                  errorWidget: (_, __, ___) => _buildPlaceholder(primarySubtle, primary, textSecondary),
                )
              else
                _buildPlaceholder(primarySubtle, primary, textSecondary),
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    color: semiTransparent,
                    child: Center(
                      child: SizedBox(
                        width: MFTokens.sp24,
                        height: MFTokens.sp24,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              if (imageUrl != null || localPath != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: MFTokens.sp24 + MFTokens.sp4,
                    height: MFTokens.sp24 + MFTokens.sp4,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: MFTokens.sp16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color bg, Color primary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: MFTokens.sp24,
            color: primary,
          ),
          SizedBox(height: MFTokens.sp2),
          Text(
            AppStrings.customerAddImage,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
