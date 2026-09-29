import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/get_customer_usecase.dart';
import 'customer_details_state.dart';

export 'customer_details_state.dart';

class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  final GetCustomerUseCase _getCustomerUseCase;

  CustomerDetailsCubit({
    required GetCustomerUseCase getCustomerUseCase,
  }) : _getCustomerUseCase = getCustomerUseCase,
       super(const CustomerDetailsState());

  Future<void> loadCustomer(
    String id,
    String companyId, {
    Customer? fallback,
  }) async {
    emit(state.copyWith(status: CustomerDetailsStatus.loading));

    final result = await _getCustomerUseCase(id, companyId);
    result.fold(
      (failure) {
        // Offline with list data: render the list snapshot as details.
        if (shouldEnqueueFailure(failure) && fallback != null) {
          emit(state.copyWith(
            status: CustomerDetailsStatus.success,
            customer: fallback,
          ));
          return;
        }
        emit(state.copyWith(
          status: CustomerDetailsStatus.error,
          failure: failure,
        ));
      },
      (customer) => emit(state.copyWith(
        status: CustomerDetailsStatus.success,
        customer: customer,
      )),
    );
  }
}
