import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationEmailUseCase {
  final AuthRepository _repository;

  ResendVerificationEmailUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.resendVerificationEmail(email);
  }
}
