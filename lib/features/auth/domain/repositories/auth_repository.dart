import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  Future<Either<Failure, UserEntity>> verifyEmail(String email, String token);
  Future<Either<Failure, void>> resendVerificationEmail(String email);
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
