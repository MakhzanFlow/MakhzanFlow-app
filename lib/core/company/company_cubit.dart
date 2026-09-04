import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_members_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_user_companies_usecase.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final GetUserCompaniesUseCase _getUserCompaniesUseCase;
  final FlutterSecureStorage _secureStorage;
  static const _lastCompanyKey = 'last_company_id';

  CompanyCubit({
    required GetUserCompaniesUseCase getUserCompaniesUseCase,
    FlutterSecureStorage? secureStorage,
  }) : _getUserCompaniesUseCase = getUserCompaniesUseCase,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       super(const CompanyInitial());

  Future<void> loadCompanies({String? selectCompanyId}) async {
    emit(const CompanyLoading());
    final result = await _getUserCompaniesUseCase();
    result.fold((failure) => emit(CompanyError(failure.message)), (companies) async {
      if (companies.isEmpty) {
        emit(CompaniesLoaded(companies: []));
        return;
      }

      final targetCompanyId = selectCompanyId ?? await _secureStorage.read(key: _lastCompanyKey);
      final company = targetCompanyId != null
          ? companies.where((c) => c.id == targetCompanyId).firstOrNull
          : null;

      if (company != null) {
        await switchCompany(company, allCompanies: companies);
      } else {
        emit(CompaniesLoaded(companies: companies));
      }
    });
  }

  Future<void> switchCompany(
    Company company, {
    CompanyMember? membership,
    List<Company>? allCompanies,
  }) async {
    await _secureStorage.write(key: _lastCompanyKey, value: company.id);
    sl<PermissionService>().clear();

    final m = membership ?? await _fetchMyMembership(company.id);
    if (m != null) {
      await sl<PermissionService>().loadPermissions(
        company.id,
        m.id,
        Map<String, dynamic>.from(m.permissions),
        isOwner: m.isOwner,
      );
    }

    final allCompaniesList = allCompanies ?? switch (state) {
      CompaniesLoaded(:final companies) => companies,
      CompanySelected(:final allCompanies) => allCompanies,
      _ => <Company>[company],
    };

    emit(
      CompanySelected(
        company: company,
        membership: m,
        allCompanies: allCompaniesList,
      ),
    );
  }

  Future<CompanyMember?> _fetchMyMembership(String companyId) async {
    try {
      final authState = sl<AuthCubit>().state;
      final userId = authState is Authenticated ? authState.user.id : null;
      if (userId == null) {
        return null;
      }
      final useCase = sl<GetCompanyMembersUseCase>();
      final result = await useCase(companyId);
      return result.fold((_) => null, (members) {
        try {
          return members.firstWhere((m) => m.userId == userId);
        } catch (_) {
          return null;
        }
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCompany() async {
    await _secureStorage.delete(key: _lastCompanyKey);
    emit(const CompanyInitial());
  }

  @override
  Future<void> close() => super.close();
}
