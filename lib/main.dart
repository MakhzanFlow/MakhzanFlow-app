import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:makhzanflow/core/env.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/mf_design_system.dart';
import 'config/routes/router.dart';
import 'core/constants/app_strings.dart';
import 'core/company/company_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_locale_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await initServiceLocator();
  await loadOnboardingStatus();

  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn = MakhzanFlowEnv.sentryDsn;
      options.tracesSampleRate = 1.0;
      // ignore: experimental_member_use
      options.profilesSampleRate = 1.0;
    }, appRunner: () => runApp(const MyApp()));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<CompanyCubit>.value(value: sl<CompanyCubit>()),
        BlocProvider<AppLocaleCubit>.value(value: sl<AppLocaleCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final localeState = context.watch<AppLocaleCubit>().state;

          // Keep AppStrings in sync with the cubit so static lookups work.
          context.read<AppLocaleCubit>().stream
              .forEach((state) => AppStrings.setLocale(state.locale));

          return MaterialApp.router(
            title: 'MakhzanFlow',
            theme: MFForUITheme.materialLight(),
            routerConfig: appRouter,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'EG'),
              Locale('en', 'US'),
            ],
            locale: localeState.locale,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
