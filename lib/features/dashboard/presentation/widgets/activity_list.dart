import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/activity_entry.dart';
import 'activity_item_card.dart';

/// Real-data activity list.
/// Shows up to 5 recent entries from `[get_activity_log]`.
class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.entries, this.onItemTap});

  final List<ActivityEntry> entries;
  final void Function(ActivityEntry entry)? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyActivity();
    }
    return Column(
      children: entries
          .map(
            (e) => ActivityItemCard(
              entry: e,
              onTap: onItemTap != null ? () => onItemTap!(e) : null,
            ),
          )
          .toList(),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXLarge),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 40.w,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            AppStrings.emptyActivity,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: AppSizes.fontMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
