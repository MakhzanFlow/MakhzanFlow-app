import 'package:makhzanflow/core/sync/pending_op.dart';
import '../../domain/entities/customer.dart';

/// Rebuilds an optimistic [Customer] from a queued `customerCreate` body
/// (built by [CreateCustomerRequestDto.toJson]). The entity id is the op id
/// (carries the pending prefix) until replay replaces it with the server id.
Customer customerFromQueueOp(PendingOp op) {
  assert(op.opType == PendingOpType.customerCreate);
  final body = op.body;
  return Customer(
    id: op.id,
    name: (body['name'] as String?) ?? '',
    nameOfficial: body['name_official'] as String?,
    phone: body['phone'] as String?,
    email: body['email'] as String?,
    address: body['address'] as String?,
    openingBalance: (body['opening_balance'] as num?)?.toDouble() ?? 0,
  );
}
