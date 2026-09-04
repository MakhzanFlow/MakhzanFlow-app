import 'package:flutter/material.dart';
import '../theme/mf_tokens.dart';

/// A tappable row with a coloured icon container and a label, used inside
/// the company-switcher bottom‑sheet for actions (create, join, sign out).
class ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;
  final bool showTopPadding;
  final bool isLoading;

  const ActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
    this.showTopPadding = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: EdgeInsets.only(top: showTopPadding ? MFTokens.sp4 : 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp4, vertical: MFTokens.sp10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: iconColor,
                          ),
                        ),
                      )
                    : Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: MFTokens.sp12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontBase,
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
