import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String email, String token) {
    return _repository.verifyEmail(email, token);
  }
}
