import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/sync/sync_cubit.dart';

/// Reactive dashboard tile mirroring [QuickActionCard] styling (tokens only,
/// no hardcoded colors): shows the pending-ops count and triggers a manual
/// sync on tap. Hidden badge when the queue is empty.
class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final pending = switch (state) {
          SyncIdle(:final pendingCount) => pendingCount,
          Syncing(:final total, :final processed) => total - processed,
          SyncDone() => 0,
        };
        final reviewCount = switch (state) {
          SyncIdle(:final reviewCount) => reviewCount,
          _ => 0,
        };
        final syncing = state is Syncing;
        final label = pending > 0
            ? '${AppStrings.syncTitle} ($pending)'
            : AppStrings.syncTitle;
        return GestureDetector(
          onTap: syncing
              ? null
              : () {
                  // Conflicts waiting → open the review list; else manual sync.
                  if (reviewCount > 0) {
                    context.push(AppRoutes.syncReview);
                  } else {
                    context.read<SyncCubit>().syncNow();
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.spacingSmall,
              horizontal: AppSizes.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.sync_outlined,
                          color: AppColors.accent,
                          size: 18.w,
                        ),
                ),
                SizedBox(height: AppSizes.spacingSmall),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
