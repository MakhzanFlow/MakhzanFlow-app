import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/user_model.dart';
import '../models/verify_email_request_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> register(RegisterRequestDto dto);
  Future<Either<Failure, UserModel>> verifyEmail(VerifyEmailRequestDto dto);
  Future<Either<Failure, void>> resendVerificationEmail(String email);
  Future<Either<Failure, UserModel>> login(LoginRequestDto dto);
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserModel?>> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}