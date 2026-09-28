import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../constants/app_constants.dart';
import '../constants/error_messages.dart';
import '../error/failures.dart';

/// Shared image upload service — SRP: isolates file handling from Cubits.
/// Presentation layer no longer imports `dart:io` directly for conversion.
/// Optionally uses [ApiClient] for multipart uploads; for company logos it
/// converts to `data:` URI (backend's `uploadImageBase64` expects base64).
class FileUploadService {
  final ApiClient? _apiClient;

  const FileUploadService({ApiClient? apiClient}) : _apiClient = apiClient;

  /// Converts a local image file to a `data:` URI for `logo_url`.
  /// Validates max size ([maxBytes], defaults to [AppConstants.maxImageSizeBytes]).
  /// Company logos travel as base64 JSON and the backend rejects images over
  /// ~2MB — pass [AppConstants.maxLogoSizeBytes] for logo uploads.
  /// Returns `Left(Failure)` on I/O or validation error.
  Future<Either<Failure, String>> toDataUri(
    String filePath, {
    int? maxBytes,
  }) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      if (!exists) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > (maxBytes ?? AppConstants.maxImageSizeBytes)) {
        return Left(ValidationFailure(ErrorMessages.fileTooLarge));
      }
      final mime = _mimeFromExtension(filePath);
      final base64 = base64Encode(bytes);
      return Right('data:$mime;base64,$base64');
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.failedToUploadLogo));
    }
  }

  /// Multipart upload via REST: `POST <endpoint>` with `image` field.
  /// Returns the remote `image_url` on success.
  /// [endpoint] should be an [ApiEndpoints] value, e.g. `ApiEndpoints.productImage(id)`.
  Future<Either<Failure, String>> uploadImage({
    required String filePath,
    required String endpoint,
  }) async {
    if (_apiClient == null) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
    try {
      final file = File(filePath);
      final exists = await file.exists();
      if (!exists) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      final length = await file.length();
      if (length > AppConstants.maxImageSizeBytes) {
        return Left(ValidationFailure(ErrorMessages.fileTooLarge));
      }
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: '${DateTime.now().millisecondsSinceEpoch}_${filePath.split(Platform.pathSeparator).last}',
        ),
      });
      final response = await _apiClient.dio.post(endpoint, data: formData);
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final url = data['image_url'] as String?;
          if (url != null && url.isNotEmpty) return Right(url);
        }
        // Fallback: top-level image_url
        final direct = body['image_url'] as String?;
        if (direct != null && direct.isNotEmpty) return Right(direct);
      }
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    } on DioException catch (e) {
      // Central mapper preserves the server message (e.g. stricter
      // jpg/png/webp content checks) and the standardized errors[] body.
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  String _mimeFromExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => AppConstants.imageContentType,
    };
  }
}
