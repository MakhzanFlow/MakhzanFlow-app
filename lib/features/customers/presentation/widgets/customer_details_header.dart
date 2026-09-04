import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerDetailsHeader extends StatelessWidget {
  final String name;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final VoidCallback? onPressed;

  const CustomerDetailsHeader({
    super.key,
    required this.name,
    this.address,
    this.phone,
    this.imageUrl,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final white70 = isDark
        ? MFTokens.textPrimaryDark.withValues(alpha: 0.7)
        : MFTokens.textInverseLight.withValues(alpha: 0.7);

    final initial = name.isNotEmpty ? name.characters.first : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(MFTokens.sp20, MFTokens.sp8, MFTokens.sp20, MFTokens.sp10),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MFTokens.radiusXL),
          bottomRight: Radius.circular(MFTokens.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(Icons.arrow_back, onPressed: () => context.pop(), isDark: isDark),
              Text(
                AppStrings.customerDetails,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontBase,
                  color: Colors.white,
                ),
              ),
              _circleButton(
                Icons.more_horiz,
                onPressed: onPressed,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: MFTokens.sp16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontXL,
                        color: Colors.white,
                      ),
                    ),
                    if (address != null && address!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: MFTokens.sp4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              address!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: MFTokens.fontXS,
                                color: white70,
                              ),
                            ),
                            SizedBox(width: MFTokens.sp4),
                            Icon(
                              Icons.location_on_outlined,
                              size: MFTokens.sp12,
                              color: white70,
                            ),
                          ],
                        ),
                      ),
                    if (phone != null && phone!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: MFTokens.sp2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              phone!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: MFTokens.fontXS,
                                color: white70,
                              ),
                            ),
                            SizedBox(width: MFTokens.sp4),
                            Icon(
                              Icons.phone_outlined,
                              size: MFTokens.sp12,
                              color: white70,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: MFTokens.sp12),
              _buildAvatar(initial, primarySubtle, primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onPressed, required bool isDark}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MFTokens.sp32,
        height: MFTokens.sp32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: MFTokens.sp16),
      ),
    );
  }

  Widget _buildAvatar(String initial, Color bg, Color primary) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: MFTokens.sp64,
          height: MFTokens.sp64,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _avatarPlaceholder(initial, bg, primary),
        ),
      );
    }
    return _avatarPlaceholder(initial, bg, primary);
  }

  Widget _avatarPlaceholder(String initial, Color bg, Color primary) {
    return Container(
      width: MFTokens.sp64,
      height: MFTokens.sp64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: MFTokens.sp2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.font3XL,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
