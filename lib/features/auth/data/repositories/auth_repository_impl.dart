import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/verify_email_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges.cast<UserEntity?>();

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String name,
  ) {
    return _remoteDataSource.register(
      RegisterRequestDto(name: name, email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> verifyEmail(
    String email,
    String token,
  ) {
    return _remoteDataSource.verifyEmail(
      VerifyEmailRequestDto(email: email, token: token),
    );
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) {
    return _remoteDataSource.resendVerificationEmail(email);
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _remoteDataSource.login(
      LoginRequestDto(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      return _remoteDataSource.signInWithGoogle();
    } catch (e) {
      // Backend /auth/google is not ready yet — surface a controlled failure
      // instead of letting the stub crash the UI.
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return _remoteDataSource.signOut();
  }
}