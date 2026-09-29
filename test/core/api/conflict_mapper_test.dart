import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/error/failures.dart';

DioException _conflict({
  required Map<String, dynamic> body,
  int status = 409,
}) =>
    DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: status,
        data: body,
      ),
    );

void main() {
  group('409 VERSION_CONFLICT envelope', () {
    test('maps to VersionConflictFailure with current/attempted', () {
      final failure = mapDioExceptionToFailure(_conflict(body: {
        'success': false,
        'message': 'Product was modified by another user',
        'code': 'VERSION_CONFLICT',
        'errors': [
          {'entity': 'product', 'id': 'abc'}
        ],
        'data': {
          'current': {'id': 'abc', 'price': 60.0, 'version': 6},
          'attempted': {'price': 55.0},
        },
      }));

      expect(failure, isA<VersionConflictFailure>());
      final conflict = failure as VersionConflictFailure;
      expect(conflict.entity, 'product');
      expect(conflict.id, 'abc');
      expect(conflict.current?['price'], 60.0);
      expect(conflict.attempted?['price'], 55.0);
    });

    test('409 without code stays ConflictFailure', () {
      final failure = mapDioExceptionToFailure(_conflict(body: {
        'success': false,
        'message': 'Duplicate',
      }));
      expect(failure, isA<ConflictFailure>());
      expect(failure, isNot(isA<VersionConflictFailure>()));
    });
  });
}
