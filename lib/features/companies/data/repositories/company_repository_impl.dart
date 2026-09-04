import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/data/datasources/company_remote_data_source.dart';
import 'package:makhzanflow/features/companies/data/models/create_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/join_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_member_request_dto.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/entities/join_request.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource _dataSource;

  CompanyRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Company>>> getUserCompanies() {
    return _dataSource.getUserCompanies();
  }

  @override
  Future<Either<Failure, Company>> createCompany(
    String name, {
    String? address,
    String? phone,
  }) {
    return _dataSource.createCompany(
      CreateCompanyRequestDto(name: name, phone: phone, address: address),
    );
  }

  @override
  Future<Either<Failure, Company>> getCompany(String companyId) {
    return _dataSource.getCompany(companyId);
  }

  @override
  Future<Either<Failure, void>> updateCompany(
    String companyId, {
    String? name,
    String? address,
    String? phone,
    String? logoUrl,
  }) {
    // The REST API supports name + logo_url only; address/phone are dropped.
    return _dataSource.updateCompany(
      companyId,
      UpdateCompanyRequestDto(name: name, logoUrl: logoUrl),
    );
  }

  @override
  Future<Either<Failure, Company>> createCompanyFull({
    required String name,
    String? businessType,
    String? phone,
    String? address,
    String? logoUrl,
  }) {
    return _dataSource.createCompany(
      CreateCompanyRequestDto(
        name: name,
        logoUrl: logoUrl,
        businessType: businessType,
        phone: phone,
        address: address,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteCompany(String companyId) {
    return _dataSource.deleteCompany(companyId);
  }

  @override
  Future<Either<Failure, List<CompanyMember>>> getCompanyMembers(
    String companyId,
  ) {
    return _dataSource.getCompanyMembers(companyId);
  }

  @override
  Future<Either<Failure, void>> inviteMember(
    String companyId,
    String userEmail,
  ) {
    return _dataSource.inviteMember(companyId, userEmail);
  }

  @override
  Future<Either<Failure, void>> updateMemberPermissions(
    String companyId,
    String userId,
    Map<String, dynamic> permissions,
  ) {
    return _dataSource.updateMember(
      companyId,
      userId,
      UpdateMemberRequestDto(permissions: permissions),
    );
  }

  @override
  Future<Either<Failure, void>> removeMember(
    String companyId,
    String userId,
  ) {
    return _dataSource.removeMember(companyId, userId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinCompanyByCode(
    String inviteCode,
  ) {
    return _dataSource.joinCompanyByCode(
      JoinCompanyRequestDto(inviteCode: inviteCode),
    );
  }

  @override
  Future<Either<Failure, List<JoinRequest>>> getJoinRequests(
    String companyId,
  ) {
    return _dataSource.getJoinRequests(companyId);
  }

  @override
  Future<Either<Failure, void>> approveJoinRequest(
    String companyId,
    String requestId,
  ) {
    return _dataSource.approveJoinRequest(companyId, requestId);
  }

  @override
  Future<Either<Failure, void>> rejectJoinRequest(
    String companyId,
    String requestId,
  ) {
    return _dataSource.rejectJoinRequest(companyId, requestId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getJoinRequestStatus(
    String requestId,
  ) {
    return _dataSource.getJoinRequestStatus(requestId);
  }

  @override
  Future<Either<Failure, void>> cancelJoinRequest(String requestId) {
    return _dataSource.cancelJoinRequest(requestId);
  }

  @override
  Future<Either<Failure, String>> getCompanyJoinCode(String companyId) {
    return _dataSource.getCompanyJoinCode(companyId);
  }

  @override
  Future<Either<Failure, String>> regenerateCompanyJoinCode(
    String companyId,
  ) {
    return _dataSource.regenerateCompanyJoinCode(companyId);
  }

  @override
  Future<Either<Failure, void>> deactivateMember(String memberId) {
    return _dataSource.deactivateMember(memberId);
  }

  @override
  Future<Either<Failure, void>> reactivateMember(String memberId) {
    return _dataSource.reactivateMember(memberId);
  }

  @override
  Future<Either<Failure, void>> removeCompanyMemberRpc(String memberId) {
    return _dataSource.removeCompanyMemberRpc(memberId);
  }

  @override
  Future<Either<Failure, void>> promoteMemberToOwner(
    String companyId,
    String userId,
  ) {
    return _dataSource.promoteMemberToOwner(companyId, userId);
  }

  @override
  Future<Either<Failure, void>> demoteOwnerToMember(
    String companyId,
    String userId,
    Map<String, dynamic> permissions,
  ) {
    return _dataSource.demoteOwnerToMember(companyId, userId, permissions);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMemberPermissions(
    String companyId,
    String userId,
  ) {
    return _dataSource
        .getMemberPermissions(companyId, userId)
        .then((result) => result.map((dto) => dto.toPermissionMap()));
  }

  @override
  Future<Either<Failure, void>> leaveCompany() {
    return _dataSource.leaveCompany();
  }
}