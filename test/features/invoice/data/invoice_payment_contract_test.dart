import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/data/mappers/invoice_mapper.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_create_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_item_dto.dart';

/// Locks the backend contract from §1.2: `payment.amount` must be > 0, and a
/// zero collection must omit the `payment` object entirely (sending
/// `{ amount: 0 }` now fails validation with 400).
void main() {
  group('InvoiceMapper.toPayment zero-amount contract', () {
    final mapper = InvoiceMapperImpl();

    test('paidNow <= 0 maps to null (no payment object)', () {
      for (final amount in [0.0, -5.0]) {
        final result = mapper.toPayment(
          paidNow: amount,
          paymentMethod: 'cash',
        );
        expect(result.isRight(), isTrue, reason: 'amount=$amount');
        expect(
          result.getOrElse((_) => throw StateError('expected Right')),
          isNull,
        );
      }
    });

    test('positive paidNow maps to a payment DTO', () {
      final result = mapper.toPayment(paidNow: 250, paymentMethod: 'cash');
      final payment =
          result.getOrElse((_) => throw StateError('expected Right'));
      expect(payment, isNotNull);
      expect(payment!.amount, 250);
    });
  });

  group('InvoiceCreateDto.toJson payment omission', () {
    test('omits payment key when payment is null', () {
      final dto = InvoiceCreateDto(
        customerId: 'cust-1',
        discountAmount: 0,
        taxAmount: 0,
        items: [InvoiceItemDto(productId: 'p-1', quantity: 1)],
      );
      final json = dto.toJson();
      expect(json.containsKey('payment'), isFalse);
    });
  });

  group('mapDioExceptionToFailure error envelope', () {
    DioException badResponse(
      int status,
      Map<String, dynamic> body,
    ) {
      return DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: status,
          data: body,
        ),
      );
    }

    test('400 parses errors[] into ValidationFailure.fieldErrors', () {
      final failure = mapDioExceptionToFailure(badResponse(400, {
        'success': false,
        'message': 'Validation failed',
        'errors': [
          {'field': 'phone', 'message': 'Phone too long'},
          {'field': 'email', 'message': 'Invalid email'},
        ],
      }));

      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.fieldErrors['phone'], 'Phone too long');
      expect(validation.fieldErrors['email'], 'Invalid email');
    });

    test('400 without message falls back to first errors[] entry', () {
      final failure = mapDioExceptionToFailure(badResponse(400, {
        'success': false,
        'errors': [
          {'field': 'name', 'message': 'Name is required'},
        ],
      }));

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Name is required');
    });

    test('429 maps to RateLimitFailure with server message', () {
      final failure = mapDioExceptionToFailure(badResponse(429, {
        'success': false,
        'message': 'Too many attempts',
        'errors': [],
      }));

      expect(failure, isA<RateLimitFailure>());
      expect(failure.message, 'Too many attempts');
    });
  });
}
