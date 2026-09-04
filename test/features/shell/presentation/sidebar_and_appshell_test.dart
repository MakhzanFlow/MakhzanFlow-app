import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/shell/presentation/widgets/makhzanflow_sidebar.dart';
import 'package:makhzanflow/features/shell/presentation/widgets/makhzanflow_bottom_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MakhzanFlowSidebar — quiet SaaS, token-only', () {
    late AppLocaleCubit localeCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      localeCubit = AppLocaleCubit();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      await localeCubit.close();
    });

    testWidgets('sidebar destinations count is 5', (tester) async {
      expect(MakhzanFlowSidebar.destinations.length, 5);
    });

    testWidgets('bottom nav destinations count is 5', (tester) async {
      expect(MakhzanFlowBottomNav.destinations.length, 5);
    });
  });
}
