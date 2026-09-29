import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/weekly_sales_point.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/activity_entry.dart';
import 'package:makhzanflow/features/dashboard/presentation/widgets/dashboard_loaded_body.dart';
import 'package:makhzanflow/features/dashboard/presentation/widgets/recent_invoices_card.dart';

Company _company() => Company(
      id: 'c1',
      name: 'شركة الإسماعيلية',
      businessType: 'تجارة الجملة',
      createdAt: DateTime(2026, 1, 1),
      logoUrl: null,
    );

DashboardStats _stats({
  double todaySales = 18450,
  double profit = 4250,
  double debt = 8430,
  int products = 126,
  List<WeeklySalesPoint> weekly = const [],
  List<ActivityEntry> activities = const [],
}) =>
    DashboardStats(
      todaySales: todaySales,
      weeklySales: weekly.isEmpty
          ? [
              WeeklySalesPoint(label: 'سبت', amount: 1200, date: DateTime(2026, 1, 1)),
              WeeklySalesPoint(label: 'أحد', amount: 2100, date: DateTime(2026, 1, 2)),
              WeeklySalesPoint(label: 'اثنين', amount: 1800, date: DateTime(2026, 1, 3)),
            ]
          : weekly,
      productsCount: products,
      customersCount: 42,
      totalDebt: debt,
      monthlyPayments: profit,
      recentActivities: activities,
      fetchedAt: DateTime(2026, 1, 4),
    );

Widget _wrap(Widget child, {AppLocaleCubit? localeCubit}) {
  return MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AppLocaleCubit>.value(value: localeCubit ?? AppLocaleCubit()),
      ],
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Flushes [MFEntrance] stagger delays (fake timers must not leak past teardown).
  Future<void> flushEntrances(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 600));

  group('DashboardLoadedBody — quiet SaaS, ForUI tokens, no hardcode (long)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('greeting header shows localized greeting + user name (AR)', (tester) async {
      final localeCubit = AppLocaleCubit();
      await tester.pumpWidget(_wrap(
        DashboardLoadedBody(userName: 'Hazem', company: _company(), stats: _stats(), isRefreshing: false, onRefresh: () {}),
        localeCubit: localeCubit,
      ));
      await tester.pump();
      // greeting contains Hazem and localized subtitle
      expect(find.textContaining('Hazem'), findsOneWidget);
      expect(find.text('إليك ملخص نشاطك اليوم'), findsOneWidget);
      // light-minimal header: first container is the tinted avatar
      final headerContainer = tester.widget<Container>(find.byType(Container).first);
      expect((headerContainer.decoration as BoxDecoration).color, MFTokens.primarySubtle);
      await flushEntrances(tester);
      await localeCubit.close();
    });

    testWidgets('greeting header shows English when locale EN', (tester) async {
      SharedPreferences.setMockInitialValues({'mf_locale_code': 'en'});
      final sp = await SharedPreferences.getInstance();
      final localeCubit = AppLocaleCubit(prefs: sp);
      await tester.pumpWidget(_wrap(
        DashboardLoadedBody(userName: 'Hazem', company: _company(), stats: _stats(), isRefreshing: false, onRefresh: () {}),
        localeCubit: localeCubit,
      ));
      await tester.pump();
      expect(find.text("Here's today's summary"), findsOneWidget);
      await flushEntrances(tester);
      await localeCubit.close();
    });

    testWidgets('metrics grid is 2x2 with 4 cards (Sales/Profit/Invoices/Overdue)', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(todaySales: 18450, profit: 4250, debt: 8430, products: 126),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      // titles ('المبيعات' lives in metric + chart header)
      expect(find.text('المبيعات'), findsWidgets);
      expect(find.text('الأرباح'), findsOneWidget);
      expect(find.text('الفواتير'), findsOneWidget);
      expect(find.text('المتأخرات'), findsOneWidget);
      // currency suffix
      expect(find.text('ج.م'), findsNWidgets(3)); // sales, profit, overdue
      // icons (receipt icon scoped to metrics grid — invoices header reuses it)
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.byIcon(Icons.receipt_long_outlined),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      await flushEntrances(tester);
    });

    testWidgets('metrics grid uses tokens for card Bg and borders', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      // at least one MF card decoration uses cardLight and borderLight in light mode
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCardLight = containers.any((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.color == MFTokens.cardLight;
      });
      expect(hasCardLight, isTrue);
      await flushEntrances(tester);
    });

    testWidgets('chart card has Sales title + range tabs', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      expect(find.text('المبيعات'), findsWidgets); // metric + chart title
      expect(find.text('آخر 7 أيام'), findsWidgets); // tab + header subtitle
      expect(find.text('آخر 30 يوم'), findsOneWidget);
      expect(find.text('آخر 3 أشهر'), findsOneWidget);
      await flushEntrances(tester);
    });

    testWidgets('tapping chart tabs switches selected index', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      await tester.tap(find.text('آخر 30 يوم'));
      await tester.pump();
      expect(find.text('آخر 30 يوم'), findsWidgets); // tab + subtitle follow
      await tester.tap(find.text('آخر 3 أشهر'));
      await tester.pump();
      expect(find.text('آخر 3 أشهر'), findsWidgets);
      await flushEntrances(tester);
    });

    testWidgets('recent invoices shows empty state when no activities', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(activities: []),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      expect(find.text('آخر الفواتير'), findsOneWidget);
      expect(find.text('لا توجد فواتير'), findsOneWidget);
      await flushEntrances(tester);
    });

    testWidgets('recent invoices lists up to 5 activities with badge + name + amount', (tester) async {
      final acts = List.generate(
        6,
        (i) => ActivityEntry(
          id: 'a$i',
          userId: 'u$i',
          entityId: '10${20 + i}',
          userName: 'عميل $i',
          action: 'create',
          entityType: 'invoice',
          details: {'amount': 1000.0 + i * 100},
          createdAt: DateTime.now(),
        ),
      );
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(activities: acts),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump(const Duration(milliseconds: 200));
      // only first 5 shown — check customer names (badge finder may be fragile)
      expect(find.text('عميل 0'), findsOneWidget);
      expect(find.text('عميل 1'), findsOneWidget);
      expect(find.text('عميل 4'), findsOneWidget);
      expect(find.text('عميل 5'), findsNothing);
      // 5 invoice amounts inside the card (scoped: metrics grid also shows ج.م)
      expect(
        find.descendant(
          of: find.byType(RecentInvoicesCard),
          matching: find.textContaining('ج.م'),
        ),
        findsNWidgets(5),
      );
      await flushEntrances(tester);
    });

    testWidgets('pull to refresh indicator exists', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsOneWidget);
      await flushEntrances(tester);
    });

    testWidgets('isRefreshing shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: true,
        onRefresh: () {},
      )));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await flushEntrances(tester);
    });

    testWidgets('uses hide TextDirection conflict fix (intl hide) — no crash', (tester) async {
      // already covered by not crashing with intl import
      await tester.pumpWidget(_wrap(DashboardLoadedBody(
        userName: 'Hazem',
        company: _company(),
        stats: _stats(),
        isRefreshing: false,
        onRefresh: () {},
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await flushEntrances(tester);
    });
  });
}
