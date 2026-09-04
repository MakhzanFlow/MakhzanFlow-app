import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/invoice/domain/constants/invoice_constants.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/create_invoice_usecase.dart';
import 'create_invoice_state.dart';

export 'create_invoice_state.dart';

class CreateInvoiceCubit extends Cubit<CreateInvoiceState> {
  final CreateInvoiceUseCase _createInvoiceUseCase;

  CreateInvoiceCubit({required CreateInvoiceUseCase createInvoiceUseCase})
    : _createInvoiceUseCase = createInvoiceUseCase,
      super(CreateInvoiceLoaded());

  void selectCustomer(Customer customer) {
    final current = state;
    if (current is CreateInvoiceLoaded) {
      emit(current.copyWith(selectedCustomer: customer));
    } else if (current is CreateInvoiceFormState) {
      emit(CreateInvoiceLoaded(
        selectedCustomer: customer,
        products: current.products,
        discountType: current.discountType,
        discountValue: current.discountValue,
        paymentMethod: current.paymentMethod,
        paidNow: current.paidNow,
      ));
    } else {
      emit(CreateInvoiceLoaded(selectedCustomer: customer));
    }
  }

  void addProduct(SelectedProduct product) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    final products = List<SelectedProduct>.from(current.products);
    final index = products.indexWhere((p) => p.productId == product.productId);
    if (index >= 0) {
      final existing = products[index];
      products[index] = existing.copyWith(
        quantity: existing.quantity + product.quantity,
      );
    } else {
      products.add(product);
    }
    emit(_loadedCopyWith(current, products: products));
  }

  void updateProductQuantity(String productId, int quantity) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    final products = List<SelectedProduct>.from(current.products);
    final index = products.indexWhere((p) => p.productId == productId);
    if (index < 0) return;
    if (quantity <= 0) {
      products.removeAt(index);
    } else {
      products[index] = products[index].copyWith(quantity: quantity);
    }
    emit(_loadedCopyWith(current, products: products));
  }

  void removeProduct(String productId) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    final products = List<SelectedProduct>.from(current.products);
    products.removeWhere((p) => p.productId == productId);
    emit(_loadedCopyWith(current, products: products));
  }

  void setDiscountType(String type) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    emit(_loadedCopyWith(current, discountType: type));
  }

  void setDiscountValue(double value) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    emit(_loadedCopyWith(current, discountValue: value));
  }

  void setPaymentMethod(String method) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    final paidNow = method == InvoiceConstants.paymentPartial ? 0.0 : current.paidNow;
    emit(_loadedCopyWith(current, paymentMethod: method, paidNow: paidNow));
  }

  void setPaidNow(double value) {
    final current = state;
    if (current is! CreateInvoiceFormState) return;
    emit(_loadedCopyWith(current, paidNow: value));
  }

  Future<void> submit() async {
    final current = state;
    if (current is! CreateInvoiceFormState) return;

    if (current.selectedCustomer == null) {
      emit(CreateInvoiceError(
        failure: ValidationFailure(ErrorMessages.selectCustomer),
        selectedCustomer: current.selectedCustomer,
        products: current.products,
        discountType: current.discountType,
        discountValue: current.discountValue,
        paymentMethod: current.paymentMethod,
        paidNow: current.paidNow,
      ));
      return;
    }
    if (current.products.isEmpty) {
      emit(CreateInvoiceError(
        failure: ValidationFailure(ErrorMessages.addAtLeastOneProduct),
        selectedCustomer: current.selectedCustomer,
        products: current.products,
        discountType: current.discountType,
        discountValue: current.discountValue,
        paymentMethod: current.paymentMethod,
        paidNow: current.paidNow,
      ));
      return;
    }

    emit(CreateInvoiceLoading(
      selectedCustomer: current.selectedCustomer,
      products: current.products,
      discountType: current.discountType,
      discountValue: current.discountValue,
      paymentMethod: current.paymentMethod,
      paidNow: current.paidNow,
    ));

    final items = current.products
        .map(
          (p) => {
            'product_id': p.productId,
            'product_name': p.productName,
            'quantity': p.quantity,
            'unit_price': p.unitPrice,
            'total_price': p.total,
          },
        )
        .toList();

    final effectivePaidNow = switch (current.paymentMethod) {
      InvoiceConstants.paymentFull => current.totalAfterDiscount,
      InvoiceConstants.paymentDeferred => 0.0,
      _ => current.paidNow,
    };
    final result = await _createInvoiceUseCase(
      customerId: current.selectedCustomer!.id,
      items: items,
      paidNow: effectivePaidNow,
      discountType: current.discountValue > 0 ? current.discountType : InvoiceConstants.discountFixed,
      discountValue: current.discountValue,
    );

    result.fold(
      (failure) => emit(CreateInvoiceError(
        failure: failure,
        selectedCustomer: current.selectedCustomer,
        products: current.products,
        discountType: current.discountType,
        discountValue: current.discountValue,
        paymentMethod: current.paymentMethod,
        paidNow: current.paidNow,
      )),
      (invoiceId) => emit(CreateInvoiceSuccess(invoiceId: invoiceId)),
    );
  }

  CreateInvoiceLoaded _loadedCopyWith(CreateInvoiceFormState current, {
    Customer? selectedCustomer,
    List<SelectedProduct>? products,
    String? discountType,
    double? discountValue,
    String? paymentMethod,
    double? paidNow,
    bool clearCustomer = false,
  }) {
    return CreateInvoiceLoaded(
      selectedCustomer: clearCustomer ? null : selectedCustomer ?? current.selectedCustomer,
      products: products ?? current.products,
      discountType: discountType ?? current.discountType,
      discountValue: discountValue ?? current.discountValue,
      paymentMethod: paymentMethod ?? current.paymentMethod,
      paidNow: paidNow ?? current.paidNow,
    );
  }

  void reset() {
    emit(CreateInvoiceLoaded());
  }
}
