import '../error/failures.dart';
import 'app_strings.dart';
import 'error_messages.dart';

/// Maps Failure types to localized messages — single source of truth.
/// Prefers a server-provided message when present; falls back to the
/// localized message for the failure type.
abstract class FailureToMessage {
  static String map(Failure failure) {
    final custom = failure.message;
    // Failures default to AppStrings.unexpectedError when no message is set,
    // so only treat it as a real server message when it differs.
    final hasCustom = custom.isNotEmpty && custom != AppStrings.unexpectedError;

    return switch (failure) {
      UnauthorizedFailure() => hasCustom ? custom : ErrorMessages.unauthorized,
      ForbiddenFailure() => hasCustom ? custom : ErrorMessages.forbidden,
      NotFoundFailure() => hasCustom ? custom : ErrorMessages.notFound,
      ConflictFailure() => hasCustom ? custom : ErrorMessages.duplicateData,
      RateLimitFailure() => hasCustom ? custom : ErrorMessages.rateLimited,
      ValidationFailure() => hasCustom ? custom : ErrorMessages.validationFailed,
      ServerFailure() => hasCustom ? custom : ErrorMessages.unexpectedError,
      _ => hasCustom ? custom : ErrorMessages.unexpectedError,
    };
  }
}
