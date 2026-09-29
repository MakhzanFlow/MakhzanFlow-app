import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer_filter_counts.dart';
import 'package:makhzanflow/features/customers/domain/usecases/get_customer_filter_counts_usecase.dart';
import 'package:makhzanflow/features/customers/domain/usecases/get_customers_usecase.dart';
import 'package:makhzanflow/features/customers/presentation/cubit/customers/customers_cubit.dart';
import 'package:makhzanflow/features/customers/presentation/cubit/customers/customers_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockGetCustomers extends Mock implements GetCustomersUseCase {}

class _MockCounts extends Mock implements GetCustomerFilterCountsUseCase {}

const _serverCustomer = Customer(id: 's1', name: 'Server Shop');

Future<PendingOpsQueue> _queueWithCreate() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final queue = PendingOpsQueue(prefs: prefs);
  await queue.enqueue(PendingOp.createNew(
    opType: PendingOpType.customerCreate,
    method: 'POST',
    path: '/customers/',
    body: const {'name': 'Queued Shop', 'phone': '010'},
    companyId: 'co-1',
  ));
  return queue;
}

CustomersCubit _cubit(PendingOpsQueue queue) => CustomersCubit(
      getCustomersUseCase: _MockGetCustomers(),
      getCustomerFilterCountsUseCase: _MockCounts(),
      pendingOpsQueue: queue,
    );

void main() {
  test('offline failure with queued create shows optimistic rows', () async {
    final queue = await _queueWithCreate();
    final get = _MockGetCustomers();
    when(
      () => get.call(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        companyId: any(named: 'companyId'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));
    final counts = _MockCounts();
    when(
      () => counts.call(query: any(named: 'query'), companyId: any(named: 'companyId')),
    ).thenAnswer(
      (_) async => const Right(CustomerFilterCounts.zero()),
    );

    final cubit = CustomersCubit(
      getCustomersUseCase: get,
      getCustomerFilterCountsUseCase: counts,
      pendingOpsQueue: queue,
    );
    await cubit.loadCustomers('co-1');

    expect(cubit.state.status, CustomersStatus.success);
    expect(cubit.state.customers.single.name, 'Queued Shop');
    expect(
      cubit.state.pendingIds.single,
      startsWith('pending_'),
    );
    await cubit.close();
  });

  test('online success prepends queued creates', () async {
    final queue = await _queueWithCreate();
    final get = _MockGetCustomers();
    when(
      () => get.call(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        companyId: any(named: 'companyId'),
      ),
    ).thenAnswer((_) async => const Right([_serverCustomer]));
    final counts = _MockCounts();
    when(
      () => counts.call(query: any(named: 'query'), companyId: any(named: 'companyId')),
    ).thenAnswer(
      (_) async => const Right(CustomerFilterCounts.zero()),
    );

    final cubit = CustomersCubit(
      getCustomersUseCase: get,
      getCustomerFilterCountsUseCase: counts,
      pendingOpsQueue: queue,
    );
    await cubit.loadCustomers('co-1');

    expect(
      cubit.state.customers.map((c) => c.name),
      ['Queued Shop', 'Server Shop'],
    );
    expect(cubit.state.pendingIds, hasLength(1));
    await cubit.close();
  });
}
