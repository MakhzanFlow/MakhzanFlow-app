import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Revokes **all** sessions for the current user (`POST /auth/logout-all`).
/// Used by the "Log out of all devices" security action.
class SignOutEverywhereUseCase {
  final AuthRepository _repository;

  SignOutEverywhereUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.signOutEverywhere();
  }
}
