import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/products/domain/entities/product.dart';
import 'package:makhzanflow/features/products/domain/usecases/get_products_usecase.dart';
import 'package:makhzanflow/features/products/presentation/cubit/products/products_cubit.dart';
import 'package:makhzanflow/features/products/presentation/cubit/products/products_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockGetProducts extends Mock implements GetProductsUseCase {}

const _serverProduct = Product(
  id: 's1',
  name: 'Server Rice',
  quantity: 5,
  price: 40,
  sku: 'S1',
  minStock: 1,
  createdBy: 'u1',
);

Future<PendingOpsQueue> _queueWithCreate() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final queue = PendingOpsQueue(prefs: prefs);
  await queue.enqueue(PendingOp.createNew(
    opType: PendingOpType.productCreate,
    method: 'POST',
    path: '/products/',
    body: const {'name': 'Queued Rice', 'price': 55.0, 'stock': 7},
    companyId: 'co-1',
  ));
  return queue;
}

void main() {
  test('offline failure with queued create shows optimistic rows', () async {
    final queue = await _queueWithCreate();
    final get = _MockGetProducts();
    when(
      () => get.call(
        companyId: any(named: 'companyId'),
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        sortColumn: any(named: 'sortColumn'),
        ascending: any(named: 'ascending'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = ProductsCubit(
      getProductsUseCase: get,
      pendingOpsQueue: queue,
    );
    await cubit.loadProducts(companyId: 'co-1');

    expect(cubit.state.status, ProductsStatus.success);
    expect(cubit.state.products.single.name, 'Queued Rice');
    expect(
      cubit.state.pendingIds.single,
      startsWith('pending_'),
    );
    await cubit.close();
  });

  test('online success prepends queued creates', () async {
    final queue = await _queueWithCreate();
    final get = _MockGetProducts();
    when(
      () => get.call(
        companyId: any(named: 'companyId'),
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        sortColumn: any(named: 'sortColumn'),
        ascending: any(named: 'ascending'),
      ),
    ).thenAnswer((_) async => const Right([_serverProduct]));

    final cubit = ProductsCubit(
      getProductsUseCase: get,
      pendingOpsQueue: queue,
    );
    await cubit.loadProducts(companyId: 'co-1');

    expect(
      cubit.state.products.map((p) => p.name),
      ['Queued Rice', 'Server Rice'],
    );
    expect(cubit.state.pendingIds, hasLength(1));
    await cubit.close();
  });
}
