import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// Animated skeleton for the full dashboard loading state.
///
/// ui-skills: mirrors the loaded layout 1:1 (header w/ avatar → 4 metrics →
/// chart → invoice rows) so content doesn't jump on resolve; token-only
/// colors with dark-mode support; structural boxes (baseline-ui).
class DashboardLoadingShimmer extends StatefulWidget {
  const DashboardLoadingShimmer({super.key});

  @override
  State<DashboardLoadingShimmer> createState() =>
      _DashboardLoadingShimmerState();
}

class _DashboardLoadingShimmerState extends State<DashboardLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Token-derived shimmer ramp — whisper-quiet in both modes.
    final base = isDark
        ? MFTokens.surfaceMutedDark
        : MFTokens.borderLight;
    final highlight = isDark ? MFTokens.borderDark : MFTokens.surfaceMutedLight;
    final onHeaderBase = MFTokens.textInverseLight.withValues(alpha: 0.14);
    final onHeaderHighlight =
        MFTokens.textInverseLight.withValues(alpha: 0.26);
    final headerBg =
        isDark ? MFTokens.sidebarBgDark : MFTokens.sidebarBg;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final baseColor =
            Color.lerp(base, highlight, _shimmer.value)!;
        final headerBoxBase = Color.lerp(
          onHeaderBase,
          onHeaderHighlight,
          _shimmer.value,
        )!;
        return ListView(
          padding: const EdgeInsets.only(bottom: MFTokens.sp32),
          children: [
            // ① Header skeleton (greeting + avatar + company row)
            Container(
              padding: const EdgeInsets.fromLTRB(
                MFTokens.sp20,
                MFTokens.sp20,
                MFTokens.sp20,
                MFTokens.sp24,
              ),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(MFTokens.radiusXL),
                  bottomRight: Radius.circular(MFTokens.radiusXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBox(
                              base: headerBoxBase,
                              width: 160,
                              height: 22,
                              radius: MFTokens.radiusSM,
                            ),
                            const SizedBox(height: MFTokens.sp8),
                            _ShimmerBox(
                              base: headerBoxBase,
                              width: 120,
                              height: 14,
                              radius: MFTokens.radiusSM,
                            ),
                            const SizedBox(height: MFTokens.sp8),
                            _ShimmerBox(
                              base: headerBoxBase,
                              width: 110,
                              height: 12,
                              radius: MFTokens.radiusSM,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: MFTokens.sp12),
                      _ShimmerBox(
                        base: headerBoxBase,
                        width: 52,
                        height: 52,
                        radius: MFTokens.radiusFull,
                      ),
                    ],
                  ),
                  const SizedBox(height: MFTokens.sp12),
                  _ShimmerBox(
                    base: headerBoxBase,
                    width: 140,
                    height: 14,
                    radius: MFTokens.radiusSM,
                  ),
                ],
              ),
            ),
            const SizedBox(height: MFTokens.sp20),
            // ② Metrics grid skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.contentPaddingMobile,
              ),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: MFTokens.sp12,
                crossAxisSpacing: MFTokens.sp12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                children: List.generate(
                  4,
                  (_) => _ShimmerBox(
                    base: baseColor,
                    radius: MFTokens.radiusMD,
                  ),
                ),
              ),
            ),
            const SizedBox(height: MFTokens.sp20),
            // ③ Chart skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.contentPaddingMobile,
              ),
              child: _ShimmerBox(
                base: baseColor,
                height: 300,
                radius: MFTokens.radiusMD,
              ),
            ),
            const SizedBox(height: MFTokens.sp20),
            // ④ Invoice rows skeleton (avatar + lines + amount)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.contentPaddingMobile,
              ),
              child: _ShimmerBox(
                base: baseColor,
                radius: MFTokens.radiusMD,
                child: Column(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MFTokens.sp16,
                        vertical: MFTokens.sp12,
                      ),
                      child: Row(
                        children: [
                          _ShimmerBox(
                            base: base,
                            width: 44,
                            height: 44,
                            radius: MFTokens.radiusFull,
                          ),
                          const SizedBox(width: MFTokens.sp12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ShimmerBox(
                                  base: base,
                                  width: 110,
                                  height: 14,
                                  radius: MFTokens.radiusXS,
                                ),
                                const SizedBox(height: MFTokens.sp6),
                                _ShimmerBox(
                                  base: base,
                                  width: 80,
                                  height: 11,
                                  radius: MFTokens.radiusXS,
                                ),
                              ],
                            ),
                          ),
                          _ShimmerBox(
                            base: base,
                            width: 64,
                            height: 14,
                            radius: MFTokens.radiusXS,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Generic shimmer box ──────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.base,
    this.width,
    this.height,
    required this.radius,
    this.child,
  });

  final Color base;
  final double? width;
  final double? height;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: child != null ? null : (height ?? 110),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
