import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/customers/domain/usecases/get_customer_usecase.dart';
import 'package:makhzanflow/features/customers/presentation/cubit/customer_details/customer_details_cubit.dart';
import 'package:makhzanflow/features/customers/presentation/cubit/customer_details/customer_details_state.dart';

class _MockGet extends Mock implements GetCustomerUseCase {}

const _listCustomer = Customer(id: 'c1', name: 'Shop');

Future<CustomerDetailsCubit> _cubit() async {
  final get = _MockGet();
  when(() => get.call(any(), any())).thenAnswer(
    (_) async => const Left(ConnectionLostFailure('no net')),
  );
  return CustomerDetailsCubit(getCustomerUseCase: get);
}

void main() {
  test('offline load with list fallback renders details', () async {
    final cubit = await _cubit();
    await cubit.loadCustomer('c1', 'co-1', fallback: _listCustomer);

    expect(cubit.state.status, CustomerDetailsStatus.success);
    expect(cubit.state.customer?.name, 'Shop');
    await cubit.close();
  });

  test('offline load without fallback stays error', () async {
    final cubit = await _cubit();
    await cubit.loadCustomer('c1', 'co-1');

    expect(cubit.state.status, CustomerDetailsStatus.error);
    expect(cubit.state.customer, isNull);
    await cubit.close();
  });
}
