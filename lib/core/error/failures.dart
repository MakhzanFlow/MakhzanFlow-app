import 'package:equatable/equatable.dart';
import '../constants/app_strings.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure([String? message]) : message = message ?? AppStrings.unexpectedError;
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class GoogleSignInCancelledFailure extends Failure {
  GoogleSignInCancelledFailure()
      : super(AppStrings.googleSignInCancelled);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message]);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message]);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message]);
}

class ValidationFailure extends Failure {
  /// Per-field server messages from `errors: [{ field, message }]`.
  /// Keys are backend snake_case field names; use [fieldErrorsFor] helpers
  /// in presentation to map them onto form fields.
  final Map<String, String> fieldErrors;

  const ValidationFailure([super.message, this.fieldErrors = const {}]);

  @override
  List<Object> get props => [message, fieldErrors];
}

