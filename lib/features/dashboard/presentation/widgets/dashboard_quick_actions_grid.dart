import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/sync/sync_cubit.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/shared/widgets/sync_status_tile.dart';
import '../models/quick_action.dart';
import 'quick_action_card.dart';

class DashboardQuickActionsGrid extends StatelessWidget {
  const DashboardQuickActionsGrid({super.key, required this.actionWidth});

  final double actionWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
      child: Wrap(
        spacing: AppSizes.spacingSmall,
        runSpacing: AppSizes.spacingSmall,
        children: [
          ..._buildActions(context).map(
            (a) => SizedBox(
              width: actionWidth,
              child: QuickActionCard(action: a),
            ),
          ),
          if (sl.isRegistered<SyncCubit>())
            SizedBox(width: actionWidth, child: const SyncStatusTile()),
        ],
      ),
    );
  }

  static List<QuickAction> _buildActions(BuildContext ctx) => [
    QuickAction(
      label: AppStrings.dashboardQuickInvoice,
      icon: Icons.receipt_long_outlined,
      iconBackground: AppColors.lightOrange,
      iconColor: AppColors.accent,
      onTap: () => ctx.go(AppRoutes.invoices),
    ),
    QuickAction(
      label: AppStrings.dashboardQuickProduct,
      icon: Icons.inventory_2_outlined,
      iconBackground: AppColors.lightGreen,
      iconColor: AppColors.primary,
      onTap: () => ctx.go(AppRoutes.products),
    ),
    QuickAction(
      label: AppStrings.dashboardQuickCustomer,
      icon: Icons.person_add_outlined,
      iconBackground: AppColors.lightOrange,
      iconColor: AppColors.accent,
      onTap: () => ctx.go(AppRoutes.customers),
    ),
    QuickAction(
      label: AppStrings.dashboardQuickPayment,
      icon: Icons.payments_outlined,
      iconBackground: AppColors.lightGreen,
      iconColor: AppColors.primary,
      onTap: () => ctx.push(AppRoutes.payments),
    ),
    QuickAction(
      label: AppStrings.dashboardQuickReport,
      icon: Icons.bar_chart_outlined,
      iconBackground: AppColors.lightGreen,
      iconColor: AppColors.primary,
      onTap: () => AppSnackbar.info(ctx, AppStrings.actionComingSoon),
    ),
  ];
}
