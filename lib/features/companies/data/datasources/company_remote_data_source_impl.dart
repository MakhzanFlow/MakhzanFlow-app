import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/data/datasources/company_remote_data_source.dart';
import 'package:makhzanflow/features/companies/data/models/add_member_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/company_member_model.dart';
import 'package:makhzanflow/features/companies/data/models/company_model.dart';
import 'package:makhzanflow/features/companies/data/models/create_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/join_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/join_request_model.dart';
import 'package:makhzanflow/features/companies/data/models/member_permissions_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_company_request_dto.dart';
import 'package:makhzanflow/features/companies/data/models/update_member_request_dto.dart';

/// Full REST implementation of [CompanyRemoteDataSource] backed by Dio.
class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiClient _apiClient;

  CompanyRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ======================= Company CRUD =======================

  @override
  Future<Either<Failure, List<CompanyModel>>> getUserCompanies() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.companies);
      final data = _dataList(response);
      return Right(data.map(CompanyModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyModel>> createCompany(
    CreateCompanyRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.companies,
        data: dto.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return Right(CompanyModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyModel>> getCompany(String companyId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companyById(companyId),
      );
      return Right(CompanyModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyModel>> updateCompany(
    String companyId,
    UpdateCompanyRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.companyById(companyId),
        data: dto.toJson(),
      );
      return Right(CompanyModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompany(String companyId) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.companyById(companyId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyModel>> lookupCompanyByCode(String code) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companiesLookup,
        queryParameters: {'code': code},
      );
      return Right(CompanyModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ======================= Members & permissions =======================

  @override
  Future<Either<Failure, List<CompanyMemberModel>>> getCompanyMembers(
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companyMembers(companyId),
      );
      final data = _dataList(response);
      return Right(data.map(CompanyMemberModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyMemberModel>> addMember(
    String companyId,
    AddMemberRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.companyMembers(companyId),
        data: dto.toJson(),
      );
      return Right(CompanyMemberModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyMemberModel>> updateMember(
    String companyId,
    String userId,
    UpdateMemberRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.companyMember(companyId, userId),
        data: dto.toJson(),
      );
      return Right(CompanyMemberModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
    String companyId,
    String userId,
  ) async {
    try {
      await _apiClient.dio.delete(
        ApiEndpoints.companyMember(companyId, userId),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberPermissionsDto>> getMemberPermissions(
    String companyId,
    String userId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companyMemberPermissions(companyId, userId),
      );
      return Right(MemberPermissionsDto.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ======================= Join flow =======================

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinCompanyByCode(
    JoinCompanyRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.companiesJoin,
        data: dto.toJson(),
      );
      final joined = _dataOrThrow(response);
      final companyId = joined['company_id'] as String?;
      if (companyId == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      // The join endpoint does not return the request id — fetch it from the
      // user's join requests so polling/cancelling can work.
      final requests = await getMyJoinRequests();
      return requests.fold((failure) => Left(failure), (list) {
        for (final request in list) {
          if (request.companyId == companyId) {
            return Right({
              'request_id': request.id,
              'company_id': companyId,
              'company_name': request.companyName,
              'company_logo': request.companyLogo,
              'status': request.status,
            });
          }
        }
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      });
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestModel>>> getJoinRequests(
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companyJoinRequests(companyId),
      );
      final data = _dataList(response);
      return Right(data.map(JoinRequestModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveJoinRequest(
    String companyId,
    String requestId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.companyJoinRequestAction(companyId, requestId, 'approve'),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectJoinRequest(
    String companyId,
    String requestId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.companyJoinRequestAction(companyId, requestId, 'reject'),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getJoinRequestStatus(
    String requestId,
  ) async {
    try {
      final requests = await getMyJoinRequests();
      return requests.fold((failure) => Left(failure), (list) {
        for (final request in list) {
          if (request.id == requestId) {
            return Right({
              'request_id': request.id,
              'company_id': request.companyId,
              'status': request.status,
            });
          }
        }
        return Left(NotFoundFailure(ErrorMessages.notFound));
      });
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestModel>>> getMyJoinRequests() async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companiesMyJoinRequests,
      );
      final data = _dataList(response);
      return Right(data.map(JoinRequestModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ======================= Invite code =======================

  @override
  Future<Either<Failure, String>> getCompanyJoinCode(String companyId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.companyById(companyId),
      );
      final data = _dataOrThrow(response);
      final code = data['invite_code'] as String?;
      if (code == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(code);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> regenerateCompanyJoinCode(
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.companyInviteCodeRegenerate(companyId),
      );
      final data = _dataOrThrow(response);
      final code = data['invite_code'] as String?;
      if (code == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(code);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========= Operations the REST backend does not expose yet =========

  @override
  Future<Either<Failure, void>> inviteMember(
    String companyId,
    String userEmail,
  ) async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  @override
  Future<Either<Failure, void>> cancelJoinRequest(String requestId) async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  @override
  Future<Either<Failure, void>> deactivateMember(String memberId) async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  @override
  Future<Either<Failure, void>> reactivateMember(String memberId) async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  @override
  Future<Either<Failure, void>> removeCompanyMemberRpc(String memberId) async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  @override
  Future<Either<Failure, void>> promoteMemberToOwner(
    String companyId,
    String userId,
  ) async {
    return updateMember(
      companyId,
      userId,
      const UpdateMemberRequestDto(role: 'owner'),
    ).then(
      // ignore: avoid_returning_null_for_void
      (result) => result.map((_) => null),
    );
  }

  @override
  Future<Either<Failure, void>> demoteOwnerToMember(
    String companyId,
    String userId,
    Map<String, dynamic> permissions,
  ) async {
    return updateMember(
      companyId,
      userId,
      UpdateMemberRequestDto(role: 'member', permissions: permissions),
    ).then(
      // ignore: avoid_returning_null_for_void
      (result) => result.map((_) => null),
    );
  }

  @override
  Future<Either<Failure, void>> leaveCompany() async {
    return Left(ServerFailure(ErrorMessages.unsupportedOperation));
  }

  // ======================= Helpers =======================

  Map<String, dynamic> _dataOrThrow(Response<dynamic> response) {
    final data = _data(response);
    if (data == null) {
      throw StateError(ErrorMessages.unexpectedError);
    }
    return data;
  }

  Map<String, dynamic>? _data(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  List<Map<String, dynamic>> _dataList(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    throw StateError(ErrorMessages.unexpectedError);
  }
}
