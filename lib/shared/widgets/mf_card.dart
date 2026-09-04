import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// Quiet SaaS Card — ForUI-inspired, token-only.
class MFCard extends StatelessWidget {
  const MFCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MFTokens.sp16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(color: border),
        boxShadow: MFTokens.shadowSM,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        child: InkWell(
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
          onTap: onTap,
          child: card,
        ),
      );
    }
    return card;
  }
}

/// Metric card — used in dashboard, quiet + calm
class MFMetricCard extends StatelessWidget {
  const MFMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.suffix,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return MFCard(
      padding: const EdgeInsets.all(MFTokens.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(MFTokens.radiusSM),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: MFTokens.sp8),
          Text(title, style: TextStyle(color: textSecondary, fontSize: MFTokens.fontXS, fontFamily: 'Cairo')),
          const SizedBox(height: MFTokens.sp2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    style: TextStyle(color: textPrimary, fontSize: MFTokens.fontLG, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    overflow: TextOverflow.ellipsis),
              ),
              if (suffix != null) ...[
                const SizedBox(width: MFTokens.sp4),
                Text(suffix!,
                    style: TextStyle(color: textSecondary, fontSize: MFTokens.fontXS, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
