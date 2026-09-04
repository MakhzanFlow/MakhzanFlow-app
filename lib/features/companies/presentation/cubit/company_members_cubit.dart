import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_members_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/invite_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/remove_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/update_member_permissions_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/remove_company_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/deactivate_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/reactivate_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/promote_member_to_owner_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/demote_owner_to_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_member_permissions_usecase.dart';

sealed class CompanyMembersState extends Equatable {
  const CompanyMembersState();

  @override
  List<Object?> get props => [];
}

final class CompanyMembersInitial extends CompanyMembersState {
  const CompanyMembersInitial();
}

final class CompanyMembersLoading extends CompanyMembersState {
  const CompanyMembersLoading();
}

final class CompanyMembersLoaded extends CompanyMembersState {
  final List<CompanyMember> members;

  const CompanyMembersLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}

final class CompanyMembersError extends CompanyMembersState {
  final String message;

  const CompanyMembersError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanyMembersCubit extends Cubit<CompanyMembersState> {
  final GetCompanyMembersUseCase _getCompanyMembersUseCase;
  final InviteMemberUseCase _inviteMemberUseCase;
  final UpdateMemberPermissionsUseCase _updateMemberPermissionsUseCase;
  final RemoveMemberUseCase _removeMemberUseCase;
  final RemoveCompanyMemberUseCase _removeCompanyMemberUseCase;
  final DeactivateMemberUseCase _deactivateMemberUseCase;
  final ReactivateMemberUseCase _reactivateMemberUseCase;
  final PromoteMemberToOwnerUseCase _promoteMemberToOwnerUseCase;
  final DemoteOwnerToMemberUseCase _demoteOwnerToMemberUseCase;
  final GetMemberPermissionsUseCase _getMemberPermissionsUseCase;

  CompanyMembersCubit({
    required GetCompanyMembersUseCase getCompanyMembersUseCase,
    required InviteMemberUseCase inviteMemberUseCase,
    required UpdateMemberPermissionsUseCase updateMemberPermissionsUseCase,
    required RemoveMemberUseCase removeMemberUseCase,
    required RemoveCompanyMemberUseCase removeCompanyMemberUseCase,
    required DeactivateMemberUseCase deactivateMemberUseCase,
    required ReactivateMemberUseCase reactivateMemberUseCase,
    required PromoteMemberToOwnerUseCase promoteMemberToOwnerUseCase,
    required DemoteOwnerToMemberUseCase demoteOwnerToMemberUseCase,
    required GetMemberPermissionsUseCase getMemberPermissionsUseCase,
  })  : _getCompanyMembersUseCase = getCompanyMembersUseCase,
        _inviteMemberUseCase = inviteMemberUseCase,
        _updateMemberPermissionsUseCase = updateMemberPermissionsUseCase,
        _removeMemberUseCase = removeMemberUseCase,
        _removeCompanyMemberUseCase = removeCompanyMemberUseCase,
        _deactivateMemberUseCase = deactivateMemberUseCase,
        _reactivateMemberUseCase = reactivateMemberUseCase,
        _promoteMemberToOwnerUseCase = promoteMemberToOwnerUseCase,
        _demoteOwnerToMemberUseCase = demoteOwnerToMemberUseCase,
        _getMemberPermissionsUseCase = getMemberPermissionsUseCase,
        super(const CompanyMembersInitial());

  Future<void> loadMembers(String companyId) async {
    emit(const CompanyMembersLoading());
    final result = await _getCompanyMembersUseCase.call(companyId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (members) => emit(CompanyMembersLoaded(members: members)),
    );
  }

  Future<void> inviteMember(String companyId, String userEmail) async {
    final result = await _inviteMemberUseCase.call(companyId, userEmail);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> updateMemberPermissions(String companyId, String userId, Map<String, dynamic> permissions) async {
    final result = await _updateMemberPermissionsUseCase.call(companyId, userId, permissions);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> removeMember(String companyId, String userId) async {
    final result = await _removeMemberUseCase.call(companyId, userId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> removeCompanyMember(String companyId, String memberId) async {
    final result = await _removeCompanyMemberUseCase.call(memberId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> deactivateMember(String companyId, String memberId) async {
    final result = await _deactivateMemberUseCase.call(memberId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> reactivateMember(String companyId, String memberId) async {
    final result = await _reactivateMemberUseCase.call(memberId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> promoteToOwner(String companyId, String userId) async {
    final result = await _promoteMemberToOwnerUseCase.call(companyId, userId);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<void> demoteToMember(String companyId, String userId, Map<String, dynamic> permissions) async {
    final result = await _demoteOwnerToMemberUseCase.call(companyId, userId, permissions);
    result.fold(
      (failure) => emit(CompanyMembersError(failure.message)),
      (_) => loadMembers(companyId),
    );
  }

  Future<Map<String, dynamic>?> getMemberPermissions(String companyId, String userId) async {
    final result = await _getMemberPermissionsUseCase.call(companyId, userId);
    return result.fold(
      (failure) => null,
      (permissions) => permissions,
    );
  }
}
