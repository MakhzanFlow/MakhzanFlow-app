import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_item_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_create_dto.dart';
import 'package:makhzanflow/features/invoice/domain/constants/invoice_constants.dart';

/// Single Responsibility: mapping raw item maps → typed DTOs + validation.
abstract class InvoiceMapper {
  Either<Failure, List<InvoiceItemDto>> toItemDtos(List<Map<String, dynamic>> raw);
  Either<Failure, InvoiceInitialPaymentDto?> toPayment({
    required double paidNow,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  });
}

class InvoiceMapperImpl implements InvoiceMapper {
  @override
  Either<Failure, List<InvoiceItemDto>> toItemDtos(List<Map<String, dynamic>> raw) {
    if (raw.isEmpty) return Left(ValidationFailure(ErrorMessages.addAtLeastOneProduct));
    final dtos = <InvoiceItemDto>[];
    for (final m in raw) {
      final pid = (m['product_id'] as String?) ?? (m['productId'] as String?) ?? '';
      if (pid.trim().isEmpty) return Left(ValidationFailure(ErrorMessages.validationFailed));
      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      if (qty < 1) return Left(ValidationFailure(ErrorMessages.invalidAmount));
      dtos.add(InvoiceItemDto(productId: pid, quantity: qty));
    }
    return Right(dtos);
  }

  @override
  Either<Failure, InvoiceInitialPaymentDto?> toPayment({
    required double paidNow,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) {
    if (paidNow <= 0) return const Right(null);
    if (paidNow < 0) return Left(ValidationFailure(ErrorMessages.invalidAmount));
    return Right(InvoiceInitialPaymentDto(
      amount: paidNow,
      method: _toBackendMethod(paymentMethod),
      referenceNumber: referenceNumber,
      notes: notes,
    ));
  }

  String _toBackendMethod(String uiMethod) {
    return InvoiceConstants.methodCash;
  }
}
