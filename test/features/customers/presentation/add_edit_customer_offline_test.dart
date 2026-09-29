import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:makhzanflow/features/customers/domain/usecases/get_customer_usecase.dart';
import 'package:makhzanflow/features/customers/domain/usecases/update_customer_usecase.dart';
import 'package:makhzanflow/features/customers/domain/usecases/upload_customer_image_usecase.dart';
import 'package:makhzanflow/features/customers/presentation/cubit/add_edit_customer/add_edit_customer_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCreate extends Mock implements CreateCustomerUseCase {}

class _MockUpload extends Mock implements UploadCustomerImageUseCase {}

class _MockGet extends Mock implements GetCustomerUseCase {}

class _MockUpdate extends Mock implements UpdateCustomerUseCase {}

const _customer = Customer(id: 'c1', name: 'Shop');

void main() {
  test('offline customer edit is refused (add-new-only), never queued',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final get = _MockGet();
    when(() => get.call(any(), any()))
        .thenAnswer((_) async => const Right(_customer));
    final update = _MockUpdate();
    when(
      () => update.call(
        id: any(named: 'id'),
        name: any(named: 'name'),
        nameOfficial: any(named: 'nameOfficial'),
        phone: any(named: 'phone'),
        address: any(named: 'address'),
        imageUrl: any(named: 'imageUrl'),
        companyId: any(named: 'companyId'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = AddEditCustomerCubit(
      createCustomerUseCase: _MockCreate(),
      uploadImageUseCase: _MockUpload(),
      getCustomerUseCase: get,
      updateCustomerUseCase: update,
      pendingOpsQueue: queue,
    );
    await cubit.loadForEdit('c1', 'co-1');
    cubit.updateName('Shop New');

    final saved = await cubit.save('co-1');

    expect(saved, isFalse);
    expect(
      cubit.state.failure?.message,
      AppStrings.offlineEditOnlyNew,
    );
    expect(await queue.pending(), isEmpty);
    await cubit.close();
  });

  test('offline create pops success and attaches image path', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);
    final create = _MockCreate();
    when(
      () => create.call(
        name: any(named: 'name'),
        nameOfficial: any(named: 'nameOfficial'),
        phone: any(named: 'phone'),
        address: any(named: 'address'),
        totalDebt: any(named: 'totalDebt'),
        companyId: any(named: 'companyId'),
      ),
    ).thenAnswer((_) async => const Left(ConnectionLostFailure('no net')));

    final cubit = AddEditCustomerCubit(
      createCustomerUseCase: create,
      uploadImageUseCase: _MockUpload(),
      getCustomerUseCase: _MockGet(),
      pendingOpsQueue: queue,
    );
    cubit.updateName('Shop');
    cubit.updatePhone('010');
    cubit.setImagePath('/tmp/picked.jpg');

    final saved = await cubit.save('co-1');

    expect(saved, isTrue);
    expect(cubit.state.successMessage, AppStrings.queuedWillSync);
    final pending = await queue.pending();
    expect(pending.single.opType, PendingOpType.customerCreate);
    expect(pending.single.imageLocalPath, '/tmp/picked.jpg');
    await cubit.close();
  });
}
