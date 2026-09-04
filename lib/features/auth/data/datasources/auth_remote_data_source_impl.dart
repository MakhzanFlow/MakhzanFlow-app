import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_response_dto.dart';
import '../models/login_request_dto.dart';
import '../models/refresh_token_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/user_model.dart';
import '../models/verify_email_request_dto.dart';
import 'auth_remote_data_source.dart';

/// REST implementation of [AuthRemoteDataSource] backed by Dio.
///
/// Register, verify-email, resend, login, logout and session restore are
/// wired to the Express backend. Google sign-in is stubbed and will be
/// implemented when the backend `/auth/google` endpoint is ready.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<Either<Failure, UserModel>> register(RegisterRequestDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(UserModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmail(
    VerifyEmailRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyEmail,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      // The verify-email endpoint issues the first session tokens.
      return Right(_saveSession(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.verifyEmailResend,
        data: {'email': email},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(LoginRequestDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(_saveSession(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() {
    throw UnimplementedError('Wired when backend /auth/google is ready');
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    Failure? failure;
    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiEndpoints.logout,
          data: RefreshTokenRequestDto(refreshToken: refreshToken).toJson(),
        );
      }
    } on DioException catch (e) {
      failure = mapDioExceptionToFailure(e);
    } catch (e) {
      failure = ServerFailure(e.toString());
    }
    // Always clear local tokens so the app never stays signed in when the
    // server session is gone.
    await _tokenStorage.clearAll();
    return failure == null ? const Right(null) : Left(failure);
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(UserModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  Map<String, dynamic>? _data(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  UserModel _saveSession(Map<String, dynamic> data) {
    final auth = AuthResponseDto.fromJson(data);
    _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    return auth.user;
  }
}