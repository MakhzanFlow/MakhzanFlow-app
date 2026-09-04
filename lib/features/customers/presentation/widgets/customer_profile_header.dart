import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/mf_tokens.dart';

class CustomerProfileHeader extends StatelessWidget {
  final String name;
  final String? nameOfficial;
  final String? imageUrl;

  const CustomerProfileHeader({
    super.key,
    required this.name,
    this.nameOfficial,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;

    return Column(
      children: [
        _buildProfileImage(primarySubtle, primary),
        SizedBox(height: MFTokens.sp24),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        if (nameOfficial != null && nameOfficial!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: MFTokens.sp4),
            child: Text(
              nameOfficial!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(Color bg, Color primary) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MFTokens.radiusFull),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: MFTokens.sp64 * 1.5,
          height: MFTokens.sp64 * 1.5,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildImagePlaceholder(bg, primary),
          errorWidget: (_, __, ___) => _buildImagePlaceholder(bg, primary),
        ),
      );
    }
    return _buildImagePlaceholder(bg, primary);
  }

  Widget _buildImagePlaceholder(Color bg, Color primary) {
    return Container(
      width: MFTokens.sp64 * 1.5,
      height: MFTokens.sp64 * 1.5,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MFTokens.radiusFull),
      ),
      child: Icon(
        Icons.store_outlined,
        size: MFTokens.sp48,
        color: primary,
      ),
    );
  }
}
