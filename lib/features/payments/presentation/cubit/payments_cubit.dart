import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import 'payments_state.dart';

export 'payments_state.dart';

/// Loads paginated payment history from `GET /api/payments` with
/// search / date-range / sort filters.
class PaymentsCubit extends Cubit<PaymentsState> {
  final GetPaymentsUseCase _getPaymentsUseCase;

  PaymentsCubit({required GetPaymentsUseCase getPaymentsUseCase})
      : _getPaymentsUseCase = getPaymentsUseCase,
        super(const PaymentsState());

  Future<void> load() async {
    emit(state.copyWith(status: PaymentsStatus.loading, clearFailure: true));
    final result = await _getPaymentsUseCase(
      search: state.search,
      startDate: state.startDate,
      endDate: state.endDate,
      sort: state.sort,
      order: state.order,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PaymentsStatus.error, failure: failure)),
      (payments) => emit(
        state.copyWith(
          status:
              payments.isEmpty ? PaymentsStatus.empty : PaymentsStatus.success,
          payments: payments,
        ),
      ),
    );
  }

  Future<void> setFilters({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? sort,
    String? order,
  }) async {
    emit(
      state.copyWith(
        search: search,
        startDate: startDate,
        endDate: endDate,
        sort: sort,
        order: order,
      ),
    );
    await load();
  }

  Future<void> clearFilters() async {
    emit(
      const PaymentsState(status: PaymentsStatus.loading),
    );
    await load();
  }

  Future<void> refresh() => load();
}
