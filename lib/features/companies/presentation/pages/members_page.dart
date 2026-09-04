import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/features/companies/presentation/pages/edit_member_permissions_page.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/entities/join_request.dart';
import 'package:makhzanflow/features/companies/domain/usecases/approve_join_request_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_join_requests_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/reject_join_request_usecase.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_members_cubit.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_settings_cubit.dart';
import 'package:makhzanflow/features/companies/presentation/widgets/member_card.dart';
import 'package:makhzanflow/features/companies/presentation/widgets/share_code_widget.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage>
    with CompanyAwareState<MembersPage> {
  late final CompanyMembersCubit _cubit;
  List<JoinRequest>? _joinRequests;
  bool _joinRequestActionInProgress = false;
  bool _joinRequestsExpanded = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<CompanyMembersCubit>();
      _cubit.loadMembers(companyId);
      _loadJoinRequests();
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadMembers(companyId);
    _loadJoinRequests();
  }

  Future<void> _loadJoinRequests() async {
    if (!mounted || companyId.isEmpty) return;
    final useCase = sl<GetJoinRequestsUseCase>();
    final result = await useCase.call(companyId);
    if (!mounted) return;
    result.fold(
      (_) {},
      (requests) => setState(() => _joinRequests = requests),
    );
  }

  Future<void> _approveRequest(String requestId) async {
    if (!mounted) return;
    setState(() => _joinRequestActionInProgress = true);
    final result = await sl<ApproveJoinRequestUseCase>().call(
      companyId,
      requestId,
    );
    if (!mounted) return;
    result.fold(
      (_) => AppSnackbar.error(context, AppStrings.unexpectedError),
      (_) {
        if (!mounted) return;
        AppSnackbar.success(context, AppStrings.requestApproved);
        _loadJoinRequests();
        _cubit.loadMembers(companyId);
      },
    );
    if (mounted) setState(() => _joinRequestActionInProgress = false);
  }

  Future<void> _rejectRequest(String requestId) async {
    if (!mounted) return;
    setState(() => _joinRequestActionInProgress = true);
    final result = await sl<RejectJoinRequestUseCase>().call(
      companyId,
      requestId,
    );
    if (!mounted) return;
    result.fold(
      (_) => AppSnackbar.error(context, AppStrings.unexpectedError),
      (_) {
        if (!mounted) return;
        AppSnackbar.success(context, AppStrings.requestRejected);
        _loadJoinRequests();
      },
    );
    if (mounted) setState(() => _joinRequestActionInProgress = false);
  }

  void _showShareCodeSheet() async {
    final settingsCubit = context.read<CompanySettingsCubit>();
    final code = await settingsCubit.getJoinCode(companyId);
    if (!mounted) return;
    if (code == null) {
      AppSnackbar.error(context, AppStrings.inviteCodeLoadFailed);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXLarge),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.inviteCode,
              style: TextStyle(
                fontSize: AppSizes.fontXLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            ShareCodeWidget(
              code: code,
              onCopy: () {
                AppSnackbar.success(context, AppStrings.codeCopied);
                Navigator.pop(context);
              },
              onRegenerate: () async {
                Navigator.pop(context);
                _confirmRegenerateCode();
              },
            ),
            SizedBox(height: AppSizes.spacingMedium),
          ],
        ),
      ),
    );
  }

  void _confirmRegenerateCode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.changeInviteCode),
        content: Text(AppStrings.changeInviteCodeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final settingsCubit = context.read<CompanySettingsCubit>();
      final newCode = await settingsCubit.regenerateJoinCode(companyId);
      if (mounted) {
        if (newCode != null) {
          AppSnackbar.success(context, AppStrings.inviteCodeChanged);
        } else {
          AppSnackbar.error(context, AppStrings.inviteCodeChangeFailed);
        }
      }
    }
  }

  // --- Confirmation dialogs ---

  void _confirmApprove(String requestId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.approve),
        content: Text(AppStrings.approveJoinConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveRequest(requestId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.trendUp,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.approve),
          ),
        ],
      ),
    );
  }

  void _confirmReject(String requestId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.rejectJoinTitle),
        content: Text(AppStrings.rejectJoinConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest(requestId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.reject),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(CompanyMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.deactivateMemberTitle),
        content: Text(
          AppStrings.deactivateConfirm(member.userName ?? member.userId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deactivateMember(companyId, member.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.deactivateAction),
          ),
        ],
      ),
    );
  }

  void _confirmReactivate(CompanyMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.reactivateMemberTitle),
        content: Text(
          AppStrings.reactivateConfirm(member.userName ?? member.userId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.reactivateMember(companyId, member.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.trendUp,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.reactivateAction),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(CompanyMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppStrings.removeMember,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${AppStrings.removeMemberConfirm} ${member.userName ?? member.userId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.removeMember(companyId, member.userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.remove),
          ),
        ],
      ),
    );
  }

  void _confirmPromote(CompanyMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.promoteToOwnerTitle),
        content: Text(
          AppStrings.promoteConfirm(member.userName ?? member.userId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.promoteToOwner(companyId, member.userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.trendUp,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.promoteAction),
          ),
        ],
      ),
    );
  }

  void _confirmDemote(CompanyMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.demoteToMemberTitle),
        content: Text(
          AppStrings.demoteConfirm(member.userName ?? member.userId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.demoteToMember(companyId, member.userId, {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.demoteAction),
          ),
        ],
      ),
    );
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final companyState = context.read<CompanyCubit>().state;
    final currentMembership = companyState is CompanySelected
        ? companyState.membership
        : null;
    final isOwner = currentMembership?.isOwner ?? false;

    return BlocConsumer<CompanyMembersCubit, CompanyMembersState>(
      listener: (context, state) {
        if (state is CompanyMembersError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.appBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            title: Text(AppStrings.teamMembers),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: _showShareCodeSheet,
              ),
            ],
          ),
          body: _buildBody(state, isOwner),
        );
      },
    );
  }

  Widget _buildBody(CompanyMembersState state, bool isOwner) {
    if (state is CompanyMembersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CompanyMembersLoaded) {
      final owners = state.members.where((m) => m.isOwner).toList();
      final activeEmployees = state.members
          .where((m) => !m.isOwner && m.isActive)
          .toList();
      final inactiveMembers = state.members.where((m) => !m.isActive).toList();
      final hasJoinRequests =
          _joinRequests != null && _joinRequests!.isNotEmpty;

      if (state.members.isEmpty && !hasJoinRequests) {
        return Center(
          child: Text(
            AppStrings.noMembersYet,
            style: TextStyle(
              fontSize: AppSizes.fontLarge,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _cubit.loadMembers(companyId);
          await _loadJoinRequests();
        },
        child: ListView(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          children: [
            // Join Requests
            if (isOwner && hasJoinRequests) ...[
              _buildCollapsibleSection(
                title: '${AppStrings.joinRequests} (${_joinRequests!.length})',
                expanded: _joinRequestsExpanded,
                onToggle: () => setState(
                  () => _joinRequestsExpanded = !_joinRequestsExpanded,
                ),
                children: _joinRequests!.map(_buildJoinRequestCard).toList(),
              ),
              SizedBox(height: AppSizes.spacingMedium),
            ],

            // Owners
            if (owners.isNotEmpty) ...[
              SectionHeader(title: AppStrings.ownersTitle),
              ...owners.map(
                (m) => MemberCard(
                  member: m,
                  isLastOwner: owners.length == 1,
                  onDemote: owners.length > 1 ? () => _confirmDemote(m) : null,
                ),
              ),
              SizedBox(height: AppSizes.spacingMedium),
            ],

            // Active Employees
            if (activeEmployees.isNotEmpty) ...[
              SectionHeader(title: AppStrings.employeesTitle),
              ...activeEmployees.map(
                (m) => MemberCard(
                  member: m,
                  onEditPermissions: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: _cubit,
                          child: EditMemberPermissionsPage(
                            member: m,
                            companyId: companyId,
                          ),
                        ),
                      ),
                    );
                  },
                  onDeactivate: () => _confirmDeactivate(m),
                  onRemove: () => _confirmRemove(m),
                  onPromote: () => _confirmPromote(m),
                ),
              ),
              SizedBox(height: AppSizes.spacingMedium),
            ],

            // Inactive Members
            if (inactiveMembers.isNotEmpty) ...[
              SectionHeader(title: AppStrings.inactiveMembersTitle),
              ...inactiveMembers.map(
                (m) => MemberCard(
                  member: m,
                  onReactivate: () => _confirmReactivate(m),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Row(
            children: [
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: AppSizes.spacingTiny),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (expanded) ...[SizedBox(height: AppSizes.spacingSmall), ...children],
      ],
    );
  }

  Widget _buildJoinRequestCard(JoinRequest request) {
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
                request.userName.isNotEmpty
                    ? request.userName[0].toUpperCase()
                    : '?',
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
                  Text(
                    request.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontMedium,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (request.userEmail.isNotEmpty)
                    Text(
                      request.userEmail,
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            TextButton(
              onPressed: _joinRequestActionInProgress
                  ? null
                  : () => _confirmApprove(request.id),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.trendUp,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingSmall,
                ),
              ),
              child: Text(AppStrings.approve),
            ),
            SizedBox(width: 4),
            TextButton(
              onPressed: _joinRequestActionInProgress
                  ? null
                  : () => _confirmReject(request.id),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingSmall,
                ),
              ),
              child: Text(AppStrings.reject),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} ${AppStrings.activityMinutes}';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ${AppStrings.activityHours}';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ${AppStrings.activityDays}';
    return '${local.year}/${local.month}/${local.day}';
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.fontLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
