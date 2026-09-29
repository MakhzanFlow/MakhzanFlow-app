import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/activity_entry.dart';
import 'package:makhzanflow/shared/widgets/mf_button.dart';
import 'package:makhzanflow/shared/widgets/mf_entrance.dart';

/// Polished "Recent invoices" card for the dashboard.
///
/// Design brief (ui-skills: interface-design / baseline-ui / better-ui):
/// ```text
/// Intent:     Shop owner (AR, RTL) glancing between customers — who paid,
///             how much, how long ago. Must scan in seconds, feel calm.
/// Hierarchy:  Amount (hero, tabular bold) > customer name > invoice # + time.
///             One accent only (status pill); structure from space, not lines.
/// Palette:    MFTokens only — emerald primary, warm/cool semantic tints.
/// Depth:      Borders-only (no heavy shadow); whisper-quiet dividers.
/// Surfaces:   FCard outer → avatar circle → status pill (radius + padding).
/// Typography: Cairo; 16/bold title · 14/600 name · 11/muted meta · tabular amounts.
/// Spacing:    4px base; dense 12px rows; 16px card padding; 68px min hit area.
/// ```
///
/// Test contract (do not break):
/// - Title text is exactly `آخر الفواتير` / `Recent Invoices` (one widget).
/// - Empty state contains exactly `لا توجد فواتير` / `No invoices yet`.
/// - Each row renders ONE [Text] containing the currency (`ج.م` / `EGP`),
///   so `find.textContaining('ج.م')` == number of rows. Header/footer must
///   NOT contain currency text.
class RecentInvoicesCard extends StatelessWidget {
  const RecentInvoicesCard({
    super.key,
    required this.activities,
    required this.isArabic,
    required this.isDark,
    this.onViewAll,
    this.onCreateInvoice,
    this.onInvoiceTap,
  });

  final List<ActivityEntry> activities;
  final bool isArabic;
  final bool isDark;
  final VoidCallback? onViewAll;
  final VoidCallback? onCreateInvoice;
  final ValueChanged<ActivityEntry>? onInvoiceTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? MFTokens.textPrimaryDark
        : MFTokens.textPrimaryLight;
    final textSecondary = isDark
        ? MFTokens.textSecondaryDark
        : MFTokens.textSecondaryLight;
    final textMuted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final visible = activities.take(5).toList();
    final totalCount = activities.length;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MFTokens.sp16,
          MFTokens.sp12,
          MFTokens.sp16,
          MFTokens.sp12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              isArabic: isArabic,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              totalCount: totalCount,
              onViewAll: onViewAll,
            ),
            const SizedBox(height: MFTokens.sp8),
            Divider(color: border, height: 1),
            if (visible.isEmpty)
              _EmptyState(
                isArabic: isArabic,
                isDark: isDark,
                textSecondary: textSecondary,
                textMuted: textMuted,
                onCreateInvoice: onCreateInvoice,
              )
            else ...[
              const SizedBox(height: MFTokens.sp4),
              for (var i = 0; i < visible.length; i++)
                MFEntrance(
                  index: i,
                  child: _InvoiceTile(
                    activity: visible[i],
                    isArabic: isArabic,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textMuted: textMuted,
                    border: border,
                    isLast: i == visible.length - 1,
                    onTap: onInvoiceTap == null
                        ? null
                        : () => onInvoiceTap!(visible[i]),
                  ),
                ),
              if (totalCount > visible.length && onViewAll != null) ...[
                const SizedBox(height: MFTokens.sp8),
                MFButton(
                  label: isArabic
                      ? 'عرض كل الفواتير ($totalCount)'
                      : 'View all ($totalCount)',
                  variant: MFButtonVariant.outline,
                  icon: Icons.receipt_long_outlined,
                  onPressed: onViewAll,
                ),
              ] else
                const SizedBox(height: MFTokens.sp4),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Header: icon + title/count … view-all ───────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.isArabic,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.totalCount,
    required this.onViewAll,
  });

  final bool isArabic;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final int totalCount;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final iconBg = isDark
        ? MFTokens.primaryDarkModeSubtle
        : MFTokens.primarySubtle;

    return Row(
      children: [
        // 40px icon tile (concentric: 12 outer ≈ 8 inner + padding)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(MFTokens.radiusSM),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 20,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: MFTokens.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      isArabic ? 'آخر الفواتير' : 'Recent Invoices',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: MFTokens.fontLG,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(width: MFTokens.sp8),
                    _CountPill(
                      count: totalCount > 99 ? '99+' : '$totalCount',
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isArabic
                    ? 'أحدث عمليات البيع والتحصيل'
                    : 'Latest sales activity',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: MFTokens.fontXS,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onViewAll != null && totalCount > 0) ...[
          const SizedBox(width: MFTokens.sp8),
          _ViewAllButton(isArabic: isArabic, onTap: onViewAll!),
        ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.isDark});

  final String count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MFTokens.sp8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MFTokens.radiusFull),
      ),
      child: Text(
        count,
        style: TextStyle(
          color: primary,
          fontSize: MFTokens.fontXS,
          fontWeight: FontWeight.w700,
          fontFamily: 'Cairo',
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// 44px-min hit area, icon-only affordance with semantic label (baseline-ui).
class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.isArabic, required this.onTap});

  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MFTokens.sp8,
            vertical: MFTokens.sp10, // ≥44px tall hit area
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'عرض الكل' : 'View all',
                style: TextStyle(
                  color: primary,
                  fontSize: MFTokens.fontSM,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(width: MFTokens.sp2),
              Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: primary,
                semanticLabel: isArabic ? 'عرض الكل' : 'View all',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state: one clear next action (baseline-ui) ────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isArabic,
    required this.isDark,
    required this.textSecondary,
    required this.textMuted,
    required this.onCreateInvoice,
  });

  final bool isArabic;
  final bool isDark;
  final Color textSecondary;
  final Color textMuted;
  final VoidCallback? onCreateInvoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MFTokens.sp8,
        vertical: MFTokens.sp24,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? MFTokens.surfaceMutedDark
                    : MFTokens.surfaceMutedLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 28,
                color: textMuted,
              ),
            ),
            const SizedBox(height: MFTokens.sp12),
            Text(
              isArabic ? 'لا توجد فواتير' : 'No invoices yet',
              style: TextStyle(
                color: textSecondary,
                fontSize: MFTokens.fontMD,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: MFTokens.sp4),
            Text(
              isArabic
                  ? 'ستظهر أحدث فواتيرك هنا فور إنشائها'
                  : 'Your latest invoices will appear here',
              style: TextStyle(
                color: textMuted,
                fontSize: MFTokens.fontSM,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            if (onCreateInvoice != null) ...[
              const SizedBox(height: MFTokens.sp16),
              MFButton(
                label: isArabic ? 'إنشاء فاتورة جديدة' : 'Create invoice',
                icon: Icons.add_rounded,
                fullWidth: false,
                onPressed: onCreateInvoice,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Invoice row ─────────────────────────────────────────────────────────────
class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({
    required this.activity,
    required this.isArabic,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.isLast,
    this.onTap,
  });

  final ActivityEntry activity;
  final bool isArabic;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final amount = (activity.details?['amount'] as num?)?.toDouble() ?? 0.0;
    final currency = isArabic ? 'ج.م' : 'EGP';
    final invoiceNo = (activity.entityId?.isNotEmpty ?? false)
        ? '#${activity.entityId}'
        : (isArabic ? '#—' : '#—');
    final status = _StatusStyle.fromAction(activity.action, isDark);
    final avatar = _AvatarStyle.forName(activity.userName, isDark);
    final timeLabel = _relativeTime(activity.createdAt, isArabic);

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MFTokens.sp8,
        vertical: MFTokens.sp10,
      ),
      child: Row(
        children: [
          // Avatar — 44px circle, initials, deterministic tint
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatar.bg,
              shape: BoxShape.circle,
              // 1px image-outline rule, never tinted near-black
              border: Border.all(
                color: isDark
                    ? const Color(0x1AFFFFFF)
                    : const Color(0x1A000000),
                width: 1,
              ),
            ),
            child: Text(
              _initials(activity.userName),
              style: TextStyle(
                color: avatar.fg,
                fontSize: MFTokens.fontMD,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: MFTokens.sp12),
          // Middle: name + invoice # · time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.userName.isNotEmpty
                      ? activity.userName
                      : (isArabic ? 'عميل' : 'Customer'),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: MFTokens.fontMD,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        invoiceNo,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: MFTokens.fontXS,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          fontFeatures: const [ui.FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MFTokens.sp6,
                      ),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: textMuted.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        timeLabel,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: MFTokens.fontXS,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
          // Trailing: amount (single Text w/ currency for test contract) + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatAmount(amount)} $currency',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: MFTokens.fontMD,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                  fontFeatures: const [ui.FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                textDirection: ui.TextDirection.rtl,
              ),
              const SizedBox(height: MFTokens.sp4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MFTokens.sp8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(MFTokens.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: MFTokens.sp4),
                    Text(
                      isArabic ? status.labelAr : status.labelEn,
                      style: TextStyle(
                        color: status.fg,
                        fontSize: MFTokens.fontXS,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Forward affordance (optical: 16px chevron, muted)
          // Padding(
          //   padding: const EdgeInsetsDirectional.only(start: MFTokens.sp8),
          //   child: Icon(
          //     isArabic
          //         ? Icons.chevron_left_rounded
          //         : Icons.chevron_right_rounded,
          //     size: 18,
          //     color: textMuted.withValues(alpha: 0.7),
          //   ),
          // ),
        ],
      ),
    );

    // ≥56px rows give a comfortable 44px+ hit area; press feedback via InkWell.
    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: row,
        ),
      ),
    );

    if (isLast) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Divider(
          color: border.withValues(alpha: 0.6),
          height: 1,
          indent: 64, // optical: starts after avatar
          endIndent: MFTokens.sp8,
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) {
      final runes = parts.first.runes.toList();
      return String.fromCharCodes(runes.take(2));
    }
    return '${String.fromCharCode(parts[0].runes.first)}'
        '${String.fromCharCode(parts[1].runes.first)}';
  }

  static String _formatAmount(double v) {
    if (v >= 1000000) {
      return NumberFormat('#,##0.0', 'ar').format(v / 1000000) +
          NumberFormat.compact(locale: 'en').format(1000000).substring(1);
    }
    return NumberFormat('#,##0', 'ar').format(v);
  }

  static String _relativeTime(DateTime createdAt, bool isArabic) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.isNegative || diff.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Now';
    }
    if (diff.inMinutes < 60) {
      return isArabic ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return isArabic ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      if (!isArabic) return d == 1 ? 'Yesterday' : '$d days ago';
      if (d == 1) return 'أمس';
      if (d == 2) return 'منذ يومين';
      return 'منذ $d أيام';
    }
    return DateFormat('dd/MM/yyyy', isArabic ? 'ar' : 'en').format(createdAt);
  }
}

// ─── Status + avatar tints (token-only, one accent per row) ──────────────────
class _StatusStyle {
  const _StatusStyle({
    required this.labelAr,
    required this.labelEn,
    required this.bg,
    required this.fg,
    required this.dot,
  });

  final String labelAr;
  final String labelEn;
  final Color bg;
  final Color fg;
  final Color dot;

  factory _StatusStyle.fromAction(String action, bool isDark) {
    switch (action.toLowerCase()) {
      case 'payment':
      case 'pay':
      case 'paid':
        return _StatusStyle(
          labelAr: 'مدفوعة',
          labelEn: 'Paid',
          bg: isDark ? MFTokens.successBgDark : MFTokens.successBg,
          fg: isDark ? MFTokens.successTextDark : MFTokens.successText,
          dot: isDark ? MFTokens.successTextDark : MFTokens.successText,
        );
      case 'update':
        return _StatusStyle(
          labelAr: 'محدثة',
          labelEn: 'Updated',
          bg: isDark ? MFTokens.infoBgDark : MFTokens.infoSubtle,
          fg: MFTokens.info,
          dot: MFTokens.info,
        );
      case 'delete':
      case 'cancel':
        return _StatusStyle(
          labelAr: 'ملغاة',
          labelEn: 'Cancelled',
          bg: isDark ? MFTokens.errorBgDark : MFTokens.errorBg,
          fg: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
          dot: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
        );
      case 'create':
      default:
        return _StatusStyle(
          labelAr: 'جديدة',
          labelEn: 'New',
          bg: isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle,
          fg: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
          dot: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
        );
    }
  }
}

class _AvatarStyle {
  const _AvatarStyle({required this.bg, required this.fg});

  final Color bg;
  final Color fg;

  factory _AvatarStyle.forName(String name, bool isDark) {
    const light = [
      (MFTokens.primarySubtle, MFTokens.primary),
      (MFTokens.infoSubtle, MFTokens.info),
      (MFTokens.warningBg, MFTokens.warningText),
      (MFTokens.successBg, MFTokens.successText),
      (MFTokens.accentSubtle, MFTokens.accent),
    ];
    const dark = [
      (MFTokens.primaryDarkModeSubtle, MFTokens.primaryDarkMode),
      (MFTokens.infoBgDark, Color(0xFF60A5FA)),
      (MFTokens.warningBgDark, MFTokens.warningTextDark),
      (MFTokens.successBgDark, MFTokens.successTextDark),
      (MFTokens.errorBgDark, MFTokens.errorTextDark),
    ];
    final palette = isDark ? dark : light;
    final idx = (name.hashCode.abs()) % palette.length;
    return _AvatarStyle(bg: palette[idx].$1, fg: palette[idx].$2);
  }
}
