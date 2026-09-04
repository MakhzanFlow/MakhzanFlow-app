import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/entities/join_request.dart';

abstract class CompanyRepository {
  Future<Either<Failure, List<Company>>> getUserCompanies();
  Future<Either<Failure, Company>> createCompany(String name, {String? address, String? phone});
  Future<Either<Failure, Company>> getCompany(String companyId);
  Future<Either<Failure, void>> updateCompany(String companyId, {String? name, String? address, String? phone, String? logoUrl});
  Future<Either<Failure, List<CompanyMember>>> getCompanyMembers(String companyId);
  Future<Either<Failure, void>> inviteMember(String companyId, String userEmail);
  Future<Either<Failure, void>> updateMemberPermissions(String companyId, String userId, Map<String, dynamic> permissions);
  Future<Either<Failure, void>> removeMember(String companyId, String userId);

  Future<Either<Failure, Company>> createCompanyFull({
    required String name,
    String? businessType,
    String? phone,
    String? address,
    String? logoUrl,
  });
  Future<Either<Failure, Map<String, dynamic>>> joinCompanyByCode(String inviteCode);
  Future<Either<Failure, List<JoinRequest>>> getJoinRequests(String companyId);
  Future<Either<Failure, void>> approveJoinRequest(String companyId, String requestId);
  Future<Either<Failure, void>> rejectJoinRequest(String companyId, String requestId);
  Future<Either<Failure, Map<String, dynamic>>> getJoinRequestStatus(String requestId);

  Future<Either<Failure, void>> cancelJoinRequest(String requestId);
  Future<Either<Failure, String>> getCompanyJoinCode(String companyId);
  Future<Either<Failure, String>> regenerateCompanyJoinCode(String companyId);
  Future<Either<Failure, void>> deactivateMember(String memberId);
  Future<Either<Failure, void>> reactivateMember(String memberId);
  Future<Either<Failure, void>> removeCompanyMemberRpc(String memberId);
  Future<Either<Failure, void>> promoteMemberToOwner(String companyId, String userId);
  Future<Either<Failure, void>> demoteOwnerToMember(String companyId, String userId, Map<String, dynamic> permissions);
  Future<Either<Failure, Map<String, dynamic>>> getMemberPermissions(String companyId, String userId);
  Future<Either<Failure, void>> leaveCompany();
  Future<Either<Failure, void>> deleteCompany(String companyId);
}