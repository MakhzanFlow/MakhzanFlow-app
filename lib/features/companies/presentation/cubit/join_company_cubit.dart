import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:makhzanflow/features/companies/domain/usecases/check_join_request_status_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/join_company_by_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/cancel_join_request_usecase.dart';

sealed class JoinCompanyState extends Equatable {
  const JoinCompanyState();

  @override
  List<Object?> get props => [];
}

final class JoinCompanyInitial extends JoinCompanyState {
  const JoinCompanyInitial();
}

final class JoinCompanyLoading extends JoinCompanyState {
  const JoinCompanyLoading();
}

sealed class JoinCompanyRequestData extends JoinCompanyState {
  final String requestId;
  final String companyId;
  final String companyName;
  final String? companyLogo;

  const JoinCompanyRequestData({
    required this.requestId,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
  });

  @override
  List<Object?> get props => [requestId, companyId, companyName, companyLogo];
}

final class JoinCompanyCodeSent extends JoinCompanyRequestData {
  const JoinCompanyCodeSent({
    required super.requestId,
    required super.companyId,
    required super.companyName,
    super.companyLogo,
  });
}

final class JoinCompanyPending extends JoinCompanyRequestData {
  const JoinCompanyPending({
    required super.requestId,
    required super.companyId,
    required super.companyName,
    super.companyLogo,
  });
}

final class JoinCompanyApproved extends JoinCompanyState {
  final String companyId;

  const JoinCompanyApproved({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

final class JoinCompanyRejected extends JoinCompanyState {
  final String companyId;

  const JoinCompanyRejected({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

final class JoinCompanyError extends JoinCompanyState {
  final String message;

  const JoinCompanyError(this.message);

  @override
  List<Object?> get props => [message];
}

class JoinCompanyCubit extends Cubit<JoinCompanyState> {
  final JoinCompanyByCodeUseCase _joinCompanyByCodeUseCase;
  final CheckJoinRequestStatusUseCase _checkJoinRequestStatusUseCase;
  final CancelJoinRequestUseCase _cancelJoinRequestUseCase;
  Timer? _pollTimer;
  int _consecutivePollFailures = 0;

  JoinCompanyCubit({
    required JoinCompanyByCodeUseCase joinCompanyByCodeUseCase,
    required CheckJoinRequestStatusUseCase checkJoinRequestStatusUseCase,
    required CancelJoinRequestUseCase cancelJoinRequestUseCase,
  }) : _joinCompanyByCodeUseCase = joinCompanyByCodeUseCase,
       _checkJoinRequestStatusUseCase = checkJoinRequestStatusUseCase,
       _cancelJoinRequestUseCase = cancelJoinRequestUseCase,
       super(const JoinCompanyInitial());

  Future<void> joinByCode(String inviteCode) async {
    emit(const JoinCompanyLoading());
    final result = await _joinCompanyByCodeUseCase.call(inviteCode);
    result.fold((failure) => emit(JoinCompanyError(failure.message)), (data) {
      final state = JoinCompanyCodeSent(
        requestId: data['request_id'] as String,
        companyId: data['company_id'] as String,
        companyName: data['company_name'] as String,
        companyLogo: data['company_logo'] as String?,
      );
      emit(state);
      _startPolling(state.requestId, state.companyId);
    });
  }

  void resumePolling({
    required String requestId,
    required String companyId,
    required String companyName,
    String? companyLogo,
  }) {
    emit(JoinCompanyPending(
      requestId: requestId,
      companyId: companyId,
      companyName: companyName,
      companyLogo: companyLogo,
    ));
    _startPolling(requestId, companyId);
  }

  void _startPolling(String requestId, String companyId) {
    _pollTimer?.cancel();
    _consecutivePollFailures = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final result = await _checkJoinRequestStatusUseCase.call(requestId);
      result.fold(
        (failure) {
          // Status checks are rate-limited server-side — back off instead of
          // spinning forever: after 5 consecutive failures (e.g. 429),
          // surface the server message and stop.
          _consecutivePollFailures++;
          if (_consecutivePollFailures >= 5) {
            _pollTimer?.cancel();
            emit(JoinCompanyError(failure.message));
          }
        },
        (data) {
          _consecutivePollFailures = 0;
        final status = data['status'] as String;
        if (status == 'approved') {
          _pollTimer?.cancel();
          emit(JoinCompanyApproved(companyId: companyId));
        } else if (status == 'rejected') {
          _pollTimer?.cancel();
          emit(JoinCompanyRejected(companyId: companyId));
        } else if (state is JoinCompanyRequestData) {
          final current = state as JoinCompanyRequestData;
          emit(
            JoinCompanyPending(
              requestId: requestId,
              companyId: companyId,
              companyName: current.companyName,
              companyLogo: current.companyLogo,
            ),
          );
        }
      });
    });
  }

  Future<void> cancelJoinRequest(String requestId) async {
    _pollTimer?.cancel();
    final result = await _cancelJoinRequestUseCase.call(requestId);
    result.fold(
      (failure) => emit(JoinCompanyError(failure.message)),
      (_) => emit(const JoinCompanyInitial()),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
