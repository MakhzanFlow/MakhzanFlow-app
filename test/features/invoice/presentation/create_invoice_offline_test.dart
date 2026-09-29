import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/create_invoice_usecase.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCreateInvoice extends Mock implements CreateInvoiceUseCase {}

void main() {
  test('offline invoice create is refused (online-only), never queued',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final create = _MockCreateInvoice();
    when(
      () => create.call(
        customerId: any(named: 'customerId'),
        items: any(named: 'items'),
        paidNow: any(named: 'paidNow'),
        discountType: any(named: 'discountType'),
        discountValue: any(named: 'discountValue'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = CreateInvoiceCubit(createInvoiceUseCase: create);
    cubit.emit(CreateInvoiceLoaded(
      selectedCustomer: const Customer(id: 'cust-1', name: 'Shop'),
      products: const [
        SelectedProduct(
          productId: 'p1',
          productName: 'Rice',
          unitPrice: 50,
          quantity: 2,
        ),
      ],
    ));

    await cubit.submit();

    expect(cubit.state, isA<CreateInvoiceError>());
    final err = cubit.state as CreateInvoiceError;
    expect(err.failure.message, AppStrings.onlineRequired);
    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });
}
