import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/features/settings/presentation/pages/settings_screen.dart';

// Minimal mocks / providers
import 'package:makhzanflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:mocktail/mocktail.dart';

class MockPermissionService extends Mock implements PermissionService {}

Widget _wrap(Widget child, {required AppLocaleCubit localeCubit, CompanyCubit? companyCubit}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AppLocaleCubit>.value(value: localeCubit),
        if (companyCubit != null) BlocProvider<CompanyCubit>.value(value: companyCubit),
      ],
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen — appearance (AR/EN) via tokens', () {
    late AppLocaleCubit localeCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      localeCubit = AppLocaleCubit();
      await Future.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      await localeCubit.close();
    });

    testWidgets('shows appearance section with language segment', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen(), localeCubit: localeCubit));
      await tester.pumpAndSettle();
      // language segment shows EN / ع
      expect(find.text('EN'), findsOneWidget);
    });
  });
}
