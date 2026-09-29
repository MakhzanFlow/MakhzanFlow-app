import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/products/domain/entities/product.dart';
import 'package:makhzanflow/features/products/domain/entities/product_input.dart';
import 'package:makhzanflow/features/products/domain/usecases/update_product_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/create_product_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/get_product_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/upload_product_image_usecase.dart';
import 'package:makhzanflow/features/products/presentation/cubit/add_edit_product/add_edit_product_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCreate extends Mock implements CreateProductUseCase {}

class _MockUpdate extends Mock implements UpdateProductUseCase {}

class _MockUpload extends Mock implements UploadProductImageUseCase {}

class _MockGet extends Mock implements GetProductUseCase {}

const _loaded = Product(
  id: 'p1',
  name: 'Rice',
  quantity: 10,
  price: 50,
  sku: 'R1',
  minStock: 2,
  createdBy: 'u1',
  version: 5,
);

Future<AddEditProductCubit> _editCubit(PendingOpsQueue queue) async {
  final get = _MockGet();
  when(() => get.call(any(), any()))
      .thenAnswer((_) async => const Right(_loaded));
  final update = _MockUpdate();
  when(
    () => update.call(any(), any(), any(), any(),
        version: any(named: 'version')),
  ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));
  final cubit = AddEditProductCubit(
    createProductUseCase: _MockCreate(),
    uploadImageUseCase: _MockUpload(),
    getProductUseCase: get,
    updateProductUseCase: update,
    pendingOpsQueue: queue,
  );
  await cubit.loadForEdit('p1', 'co-1');
  return cubit;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ProductInput(name: '', price: 0, quantity: 0, minStock: 0),
    );
  });

  test('connection loss on create enqueues productCreate op', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final create = _MockCreate();
    when(
      () => create.call(any(), any(), any()),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = AddEditProductCubit(
      createProductUseCase: create,
      uploadImageUseCase: _MockUpload(),
      getProductUseCase: _MockGet(),
      pendingOpsQueue: queue,
    );
    cubit.updateName('Rice');
    cubit.updatePrice('50');
    cubit.updateQuantity('10');
    cubit.updateMinStock('2');

    final saved = await cubit.save('user-1', 'co-1');

    expect(saved, isTrue);
    expect(cubit.state.successMessage, AppStrings.queuedWillSync);
    final pending = await queue.pending();
    expect(pending.single.opType, PendingOpType.productCreate);
    expect(pending.single.method, 'POST');
    expect(pending.single.body['name'], 'Rice');
    expect(pending.single.body.containsKey('version'), isFalse);
    expect(pending.single.imageLocalPath, isNull);
    await cubit.close();
  });

  test('offline create attaches the picked image path', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final create = _MockCreate();
    when(
      () => create.call(any(), any(), any()),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = AddEditProductCubit(
      createProductUseCase: create,
      uploadImageUseCase: _MockUpload(),
      getProductUseCase: _MockGet(),
      pendingOpsQueue: queue,
    );
    cubit.updateName('Rice');
    cubit.updatePrice('50');
    cubit.updateQuantity('10');
    cubit.updateMinStock('2');
    cubit.setImagePath('/tmp/picked.jpg');

    final saved = await cubit.save('user-1', 'co-1');

    expect(saved, isTrue);
    final pending = await queue.pending();
    expect(pending.single.imageLocalPath, '/tmp/picked.jpg');
    await cubit.close();
  });

  test('validation errors are not enqueued', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final cubit = AddEditProductCubit(
      createProductUseCase: _MockCreate(),
      uploadImageUseCase: _MockUpload(),
      getProductUseCase: _MockGet(),
      pendingOpsQueue: queue,
    );
    cubit.updatePrice('-5');

    await cubit.save('user-1', 'co-1');

    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });

  test('offline price change is refused (add-new-only), never queued',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final cubit = await _editCubit(queue);
    cubit.updatePrice('60');

    final saved = await cubit.save('user-1', 'co-1');

    expect(saved, isFalse);
    expect(cubit.state.errorMessage, AppStrings.offlineEditOnlyNew);
    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });

  test('offline metadata-only edit is refused too (add-new-only)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final cubit = await _editCubit(queue);
    cubit.updateName('Rice Premium');

    final saved = await cubit.save('user-1', 'co-1');

    expect(saved, isFalse);
    expect(cubit.state.errorMessage, AppStrings.offlineEditOnlyNew);
    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });
}
