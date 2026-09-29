import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/products/domain/entities/product.dart';
import 'package:makhzanflow/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/get_product_usecase.dart';
import 'package:makhzanflow/features/products/domain/usecases/update_product_quantity_usecase.dart';
import 'package:makhzanflow/features/products/presentation/cubit/product_details/product_details_cubit.dart';
import 'package:makhzanflow/features/products/presentation/cubit/product_details/product_details_state.dart';

class _MockGet extends Mock implements GetProductUseCase {}

class _MockDelete extends Mock implements DeleteProductUseCase {}

class _MockQuantity extends Mock implements UpdateProductQuantityUseCase {}

class _MockMovements extends Mock implements GetInventoryMovementsUseCase {}

const _listProduct = Product(
  id: 'p1',
  name: 'Rice',
  quantity: 10,
  price: 50,
  sku: 'R1',
  minStock: 2,
  createdBy: 'u1',
);

Future<ProductDetailsCubit> _cubit() async {
  final get = _MockGet();
  when(() => get.call(any(), any())).thenAnswer(
    (_) async => const Left(ConnectionLostFailure('no net')),
  );
  return ProductDetailsCubit(
    getProductUseCase: get,
    deleteProductUseCase: _MockDelete(),
    updateQuantityUseCase: _MockQuantity(),
    getMovementsUseCase: _MockMovements(),
  );
}

void main() {
  test('offline load with list fallback renders details', () async {
    final cubit = await _cubit();
    await cubit.loadProduct('p1', 'co-1', fallback: _listProduct);

    expect(cubit.state.status, ProductDetailsStatus.success);
    expect(cubit.state.product?.name, 'Rice');
    await cubit.close();
  });

  test('offline load without fallback stays error', () async {
    final cubit = await _cubit();
    await cubit.loadProduct('p1', 'co-1');

    expect(cubit.state.status, ProductDetailsStatus.error);
    expect(cubit.state.product, isNull);
    await cubit.close();
  });
}
