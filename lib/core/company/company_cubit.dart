import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/constants/app_constants.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:makhzanflow/features/companies/data/models/company_member_model.dart';
import 'package:makhzanflow/features/companies/data/models/company_model.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_members_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_user_companies_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final GetUserCompaniesUseCase _getUserCompaniesUseCase;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences? _prefs;
  static const _lastCompanyKey = 'last_company_id';

  CompanyCubit({
    required GetUserCompaniesUseCase getUserCompaniesUseCase,
    FlutterSecureStorage? secureStorage,
    SharedPreferences? prefs,
  })  : _getUserCompaniesUseCase = getUserCompaniesUseCase,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _prefs = prefs,
        super(const CompanyInitial());

  Future<void> loadCompanies({String? selectCompanyId}) async {
    emit(const CompanyLoading());
    final result = await _getUserCompaniesUseCase();
    await result.fold((failure) async {
      // Offline launch with a previous selection: restore the snapshot so
      // the router can reach home. Re-validates on reconnect.
      if (shouldEnqueueFailure(failure)) {
        final restored = await _restoreSnapshot();
        if (kDebugMode) {
          debugPrint('[company] offline restore: hit=${restored != null}');
        }
        if (restored != null) {
          try {
            await sl<PermissionService>().loadPermissions(
              restored.company.id,
              restored.membership.id,
              Map<String, dynamic>.from(restored.membership.permissions),
              isOwner: restored.membership.isOwner,
            );
          } catch (_) {
            // Offline restore must never crash on permission hydration —
            // gates re-resolve from the snapshot map on next launch.
          }
          emit(CompanySelected(
            company: restored.company,
            membership: restored.membership,
            allCompanies: [restored.company],
          ));
          return;
        }
      }
      emit(CompanyError(failure.message));
    }, (companies) async {
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
    await _saveSnapshot(company, m);
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
    await _prefs?.remove(AppConstants.lastCompanyKey);
    emit(const CompanyInitial());
  }

  /// Persists the selected company + membership for offline restore.
  /// Membership may be null (owner fallback path) — then only the id is kept
  /// and restore is skipped.
  Future<void> _saveSnapshot(Company company, CompanyMember? membership) async {
    final prefs = _prefs;
    if (prefs == null || membership == null) return;
    try {
      await prefs.setString(
        AppConstants.lastCompanyKey,
        jsonEncode({
          'company': CompanyModel.fromEntity(company).toJson(),
          'membership': CompanyMemberModel.fromEntity(membership).toJson(),
        }),
      );
    } catch (_) {
      // Best-effort snapshot — online flow is unaffected by cache failure.
    }
  }

  Future<_CompanySnapshot?> _restoreSnapshot() async {
    try {
      final raw = _prefs?.getString(AppConstants.lastCompanyKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final companyJson = decoded['company'];
      final membershipJson = decoded['membership'];
      if (companyJson is! Map<String, dynamic> ||
          membershipJson is! Map<String, dynamic>) {
        return null;
      }
      final company = CompanyModel.fromJson(companyJson);
      final membership = CompanyMemberModel.fromJson(membershipJson);
      if (company.id.isEmpty) return null;
      return _CompanySnapshot(company: company, membership: membership);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() => super.close();
}

/// Last selected company + membership, restored offline at launch.
class _CompanySnapshot {
  final Company company;
  final CompanyMember membership;

  const _CompanySnapshot({required this.company, required this.membership});
}
