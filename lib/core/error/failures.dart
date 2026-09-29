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

/// Connectivity was lost (timeouts / connection errors). Mutations failing
/// with this type are eligible for the offline queue (see enqueue_guard).
class ConnectionLostFailure extends NetworkFailure {
  const ConnectionLostFailure([super.message]);
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

/// 409 with `code == VERSION_CONFLICT`: the record moved on server-side.
/// [current] is the fresh server copy, [attempted] what we tried to save.
/// Produced ONLY by the central Dio mapper — never constructed in UI code.
class VersionConflictFailure extends Failure {
  final String entity;
  final String id;
  final Map<String, dynamic>? current;
  final Map<String, dynamic>? attempted;

  const VersionConflictFailure(
    super.message, {
    this.entity = 'record',
    this.id = '',
    this.current,
    this.attempted,
  });

  @override
  List<Object> get props => [message, entity, id, current ?? {}, attempted ?? {}];
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

