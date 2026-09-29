import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_user_companies_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCompanies extends Mock implements GetUserCompaniesUseCase {}

const _snapshot =
    '{"company":{"id":"co-1","name":"Shop","created_at":"2026-01-01T00:00:00.000Z"},'
    '"membership":{"id":"m1","company_id":"co-1","user_id":"u1","is_owner":true,'
    '"permissions":{},"joined_at":"2026-01-01T00:00:00.000Z","status":"active"}}';

void main() {
  group('offline company restore', () {
    test('restores last company when list fails offline', () async {
      SharedPreferences.setMockInitialValues(
        {'mf_last_company_v1': _snapshot},
      );
      final prefs = await SharedPreferences.getInstance();
      final useCase = _MockCompanies();
      when(() => useCase()).thenAnswer(
        (_) async => const Left(ConnectionLostFailure('no net')),
      );

      final cubit = CompanyCubit(
        getUserCompaniesUseCase: useCase,
        prefs: prefs,
      );
      await cubit.loadCompanies();

      expect(cubit.state, isA<CompanySelected>());
      final selected = cubit.state as CompanySelected;
      expect(selected.company.id, 'co-1');
      expect(selected.company.name, 'Shop');
      await cubit.close();
    });

    test('errors when offline with no snapshot', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final useCase = _MockCompanies();
      when(() => useCase()).thenAnswer(
        (_) async => const Left(ConnectionLostFailure('no net')),
      );

      final cubit = CompanyCubit(
        getUserCompaniesUseCase: useCase,
        prefs: prefs,
      );
      await cubit.loadCompanies();

      expect(cubit.state, isA<CompanyError>());
      await cubit.close();
    });
  });
}
