import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/add_payment_usecase.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/get_invoices_usecase.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/add_payment/add_payment_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockGetInvoices extends Mock implements GetInvoicesUseCase {}

class _MockAddPayment extends Mock implements AddPaymentUseCase {}

void main() {
  test('offline payment is refused (online-only), never queued', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final addPayment = _MockAddPayment();
    when(
      () => addPayment(
        invoiceId: any(named: 'invoiceId'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        version: any(named: 'version'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = AddPaymentCubit(
      getInvoicesUseCase: _MockGetInvoices(),
      addPaymentUseCase: addPayment,
    );
    cubit.emit(AddPaymentLoaded(
      invoices: const [
        Invoice(
          id: 'inv-1',
          customerId: 'c1',
          subtotal: 100,
          totalAmount: 100,
          version: 3,
        ),
      ],
      selectedInvoiceId: 'inv-1',
      amount: '50',
      customerName: 'C',
      companyId: 'co-1',
    ));

    await cubit.submit();

    expect(cubit.state, isA<AddPaymentError>());
    final err = cubit.state as AddPaymentError;
    expect(err.failure.message, AppStrings.onlineRequired);
    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });
}
