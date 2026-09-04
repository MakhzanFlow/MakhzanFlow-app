import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';

class MemberCard extends StatelessWidget {
  final CompanyMember member;
  final VoidCallback? onEditPermissions;
  final VoidCallback? onDeactivate;
  final VoidCallback? onReactivate;
  final VoidCallback? onRemove;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final bool isLastOwner;

  const MemberCard({
    super.key,
    required this.member,
    this.onEditPermissions,
    this.onDeactivate,
    this.onReactivate,
    this.onRemove,
    this.onPromote,
    this.onDemote,
    this.isLastOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = (member.userName ?? member.userId).isNotEmpty
        ? (member.userName ?? member.userId)[0].toUpperCase()
        : '?';

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(color: AppColors.inputBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withAlpha(25),
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.userName ?? AppStrings.unknownUser,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppSizes.fontLarge,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (member.isOwner) ...[
                        SizedBox(width: AppSizes.spacingTiny),
                        _buildBadge(
                          AppStrings.ownerRole,
                          AppColors.primary,
                        ),
                      ],
                      if (!member.isActive) ...[
                        SizedBox(width: AppSizes.spacingTiny),
                        _buildBadge(
                          AppStrings.inactiveBadge,
                          AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  if (member.userEmail != null)
                    Text(
                      member.userEmail!,
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (member.isOwner)
                    Text(
                      AppStrings.fullAccess,
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.primary,
                      ),
                    ),
                  if (!member.isOwner && member.isActive)
                    Text(
                      AppStrings.employeeRole,
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            _buildPopupMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.spacingSmall,
        vertical: AppSizes.spacingTiny,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) {
        switch (value) {
          case 'edit_permissions':
            onEditPermissions?.call();
            break;
          case 'deactivate':
            onDeactivate?.call();
            break;
          case 'reactivate':
            onReactivate?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
          case 'promote':
            onPromote?.call();
            break;
          case 'demote':
            onDemote?.call();
            break;
        }
      },
      itemBuilder: (_) {
        final items = <PopupMenuEntry<String>>[];

        if (member.isOwner) {
          if (!isLastOwner) {
            items.add(
              PopupMenuItem(
                value: 'demote',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(AppStrings.demoteToEmployeeLabel),
                  ],
                ),
              ),
            );
          }
        } else if (member.isActive) {
          items.addAll([
            PopupMenuItem(
              value: 'edit_permissions',
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(AppStrings.permissionsLabel),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'deactivate',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(AppStrings.deactivateLabel),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(AppStrings.remove),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'promote',
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, size: 20, color: AppColors.trendUp),
                  SizedBox(width: 8),
                  Text(AppStrings.promoteToOwnerLabel),
                ],
              ),
            ),
          ]);
        } else {
          items.add(
            PopupMenuItem(
              value: 'reactivate',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20, color: AppColors.trendUp),
                  SizedBox(width: 8),
                  Text(AppStrings.reactivateLabel),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}
