import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/data/models/add_member_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/company_member_model.dart';
import 'package:makhzanflow/features/companies/data/models/company_model.dart';
import 'package:makhzanflow/features/companies/data/models/create_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/join_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/join_request_model.dart';
import 'package:makhzanflow/features/companies/data/models/member_permissions_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_member_request_dto.dart';

abstract class CompanyRemoteDataSource {
  // Company CRUD
  Future<Either<Failure, List<CompanyModel>>> getUserCompanies();
  Future<Either<Failure, CompanyModel>> createCompany(
    CreateCompanyRequestDto dto,
  );
  Future<Either<Failure, CompanyModel>> getCompany(String companyId);
  Future<Either<Failure, CompanyModel>> updateCompany(
    String companyId,
    UpdateCompanyRequestDto dto,
  );
  Future<Either<Failure, void>> deleteCompany(String companyId);
  Future<Either<Failure, CompanyModel>> lookupCompanyByCode(String code);

  // Members & permissions
  Future<Either<Failure, List<CompanyMemberModel>>> getCompanyMembers(
    String companyId,
  );
  Future<Either<Failure, CompanyMemberModel>> addMember(
    String companyId,
    AddMemberRequestDto dto,
  );
  Future<Either<Failure, CompanyMemberModel>> updateMember(
    String companyId,
    String userId,
    UpdateMemberRequestDto dto,
  );
  Future<Either<Failure, void>> removeMember(String companyId, String userId);
  Future<Either<Failure, MemberPermissionsDto>> getMemberPermissions(
    String companyId,
    String userId,
  );

  // Join flow
  Future<Either<Failure, Map<String, dynamic>>> joinCompanyByCode(
    JoinCompanyRequestDto dto,
  );
  Future<Either<Failure, List<JoinRequestModel>>> getJoinRequests(
    String companyId,
  );
  Future<Either<Failure, void>> approveJoinRequest(
    String companyId,
    String requestId,
  );
  Future<Either<Failure, void>> rejectJoinRequest(
    String companyId,
    String requestId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getJoinRequestStatus(
    String requestId,
  );
  Future<Either<Failure, List<JoinRequestModel>>> getMyJoinRequests();

  // Invite code
  Future<Either<Failure, String>> getCompanyJoinCode(String companyId);
  Future<Either<Failure, String>> regenerateCompanyJoinCode(String companyId);

  // Operations the REST backend does not expose yet — return controlled
  // failures so the UI never crashes.
  Future<Either<Failure, void>> inviteMember(String companyId, String userEmail);
  Future<Either<Failure, void>> cancelJoinRequest(String requestId);
  Future<Either<Failure, void>> deactivateMember(String memberId);
  Future<Either<Failure, void>> reactivateMember(String memberId);
  Future<Either<Failure, void>> removeCompanyMemberRpc(String memberId);
  Future<Either<Failure, void>> promoteMemberToOwner(
    String companyId,
    String userId,
  );
  Future<Either<Failure, void>> demoteOwnerToMember(
    String companyId,
    String userId,
    Map<String, dynamic> permissions,
  );
  Future<Either<Failure, void>> leaveCompany();
}