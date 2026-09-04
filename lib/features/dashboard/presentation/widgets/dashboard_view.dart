import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:makhzanflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:makhzanflow/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'dashboard_error_widget.dart';
import 'dashboard_loading_shimmer.dart';
import 'dashboard_loaded_body.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with CompanyAwareState<DashboardView> {
  StreamSubscription? _authSubscription;
  String _userName = '';
  Company? _company;

  @override
  void initState() {
    super.initState();
    _syncState();
    _subscribeAuth();
    _triggerLoad();
  }

  @override
  void onCompanyChanged(String companyId) {
    setState(() {
      final companyState = context.read<CompanyCubit>().state;
      if (companyState is CompanySelected) {
        _company = companyState.company;
      }
    });
    _triggerLoad();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _syncState() {
    final authCubit = context.read<AuthCubit>();
    _userName = authCubit.state is Authenticated
        ? (authCubit.state as Authenticated).user.name
        : '';
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanySelected) {
      _company = companyState.company;
    }
  }

  void _subscribeAuth() {
    _authSubscription = context.read<AuthCubit>().stream.listen((state) {
      if (state is Authenticated && mounted) {
        setState(() => _userName = state.user.name);
      }
    });
  }

  void _triggerLoad() {
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanySelected) {
      context.read<DashboardCubit>().loadDashboard(companyState.company.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            AppSnackbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const DashboardLoadingShimmer(),
            DashboardLoading() => const DashboardLoadingShimmer(),
            DashboardError(:final message) => DashboardErrorWidget(
              message: message,
              onRetry: _triggerLoad,
            ),
            DashboardLoaded(:final stats, :final isRefreshing) =>
              DashboardLoadedBody(
                userName: _userName,
                company: _company,
                stats: stats,
                isRefreshing: isRefreshing,
                onRefresh: () => context.read<DashboardCubit>().refresh(),
              ),
          };
        },
      ),
    );
  }
}
