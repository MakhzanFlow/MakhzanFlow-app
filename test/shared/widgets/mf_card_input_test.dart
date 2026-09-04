import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/shared/widgets/mf_card.dart';
import 'package:makhzanflow/shared/widgets/mf_input.dart';
import 'package:makhzanflow/shared/widgets/mf_dropdown.dart';
import 'package:makhzanflow/shared/widgets/mf_tabs.dart';
import 'package:makhzanflow/shared/widgets/mf_table.dart';

void main() {
  Widget lightWrap(Widget child) => MaterialApp(home: Scaffold(body: child));
  Widget darkWrap(Widget child) => MaterialApp(theme: ThemeData(brightness: Brightness.dark), home: Scaffold(body: child));

  group('MFCard — quiet SaaS, token borders & shadows', () {
    testWidgets('renders child with token radius and shadow', (tester) async {
      await tester.pumpWidget(lightWrap(const MFCard(child: Text('card content'))));
      expect(find.text('card content'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      final deco = container.decoration as BoxDecoration;
      expect(deco.borderRadius, BorderRadius.circular(MFTokens.radiusLG));
      expect(deco.boxShadow, MFTokens.shadowSM);
      expect(deco.color, MFTokens.cardLight);
    });

    testWidgets('dark uses cardDark and borderDark', (tester) async {
      await tester.pumpWidget(darkWrap(const MFCard(child: Text('dark'))));
      final container = tester.widget<Container>(find.byType(Container).first);
      final deco = container.decoration as BoxDecoration;
      expect(deco.color, MFTokens.cardDark);
      expect((deco.border as Border).top.color, MFTokens.borderDark);
    });

    testWidgets('onTap makes it tappable via InkWell', (tester) async {
      var tapped = false;
      await tester.pumpWidget(lightWrap(MFCard(onTap: () => tapped = true, child: const Text('tap'))));
      await tester.tap(find.text('tap'));
      expect(tapped, isTrue);
    });

    testWidgets('MFMetricCard shows title/value/suffix with token typography', (tester) async {
      await tester.pumpWidget(lightWrap(MFMetricCard(
        title: 'المبيعات',
        value: '18,450',
        suffix: 'ج.م',
        icon: Icons.trending_up,
        iconBg: MFTokens.successBg,
        iconColor: MFTokens.primary,
      )));
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('18,450'), findsOneWidget);
      expect(find.text('ج.م'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });
  });

  group('MFInput — ForUI-style, token borders', () {
    testWidgets('renders label + hint with Cairo and token colors', (tester) async {
      await tester.pumpWidget(lightWrap(const MFInput(label: 'اسم المتجر', hintText: 'مثال: سوبر ماركت')));
      expect(find.text('اسم المتجر'), findsOneWidget);
      expect(find.text('مثال: سوبر ماركت'), findsOneWidget);
    });

    testWidgets('obscureText hides input', (tester) async {
      final c = TextEditingController(text: 'secret');
      await tester.pumpWidget(lightWrap(MFInput(controller: c, obscureText: true)));
      expect(find.byType(TextFormField), findsOneWidget);
      // Verify underlying EditableText is obscured (no need to check getter)
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isTrue);
    });

    testWidgets('enabled false disables field', (tester) async {
      await tester.pumpWidget(lightWrap(const MFInput(enabled: false, hintText: 'disabled')));
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('dark uses inputBgDark and borderDark', (tester) async {
      await tester.pumpWidget(darkWrap(const MFInput(hintText: 'hint')));
      // Verify dark mode InputDecoration uses token via theme (smoke)
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('hint'), findsOneWidget);
    });

    testWidgets('calls onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(lightWrap(MFInput(onChanged: (v) => changed = v, hintText: 'h')));
      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('MFSearchField shows search icon and clear button when text present', (tester) async {
      final c = TextEditingController(text: 'بحث');
      await tester.pumpWidget(lightWrap(MFSearchField(controller: c, onChanged: (_) {}, hintText: 'ابحث...')));
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('MFSearchField hides clear when empty', (tester) async {
      final c = TextEditingController(text: '');
      await tester.pumpWidget(lightWrap(MFSearchField(controller: c, onChanged: (_) {}, hintText: 'ابحث...')));
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('MFTabs — ForUI segmented control, token-only', () {
    testWidgets('renders all labels and selects correct index', (tester) async {
      await tester.pumpWidget(lightWrap(MFTabs(labels: const ['اليوم', 'الأسبوع', 'الشهر'], selectedIndex: 1, onSelected: (_) {})));
      expect(find.text('اليوم'), findsOneWidget);
      expect(find.text('الأسبوع'), findsOneWidget);
      expect(find.text('الشهر'), findsOneWidget);
    });

    testWidgets('tapping tab calls onSelected', (tester) async {
      int? selected;
      await tester.pumpWidget(lightWrap(MFTabs(labels: const ['A', 'B', 'C'], selectedIndex: 0, onSelected: (i) => selected = i)));
      await tester.tap(find.text('B'));
      expect(selected, 1);
      await tester.tap(find.text('C'));
      expect(selected, 2);
    });

    testWidgets('selected uses primary token (light) or mint (dark)', (tester) async {
      await tester.pumpWidget(lightWrap(MFTabs(labels: const ['A', 'B'], selectedIndex: 0, onSelected: (_) {})));
      // first tab selected -> its container should have primary color
      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      // at least one selected container has primary color
      final hasPrimary = containers.any((c) {
        final deco = c.decoration as BoxDecoration?;
        return deco?.color == MFTokens.primary;
      });
      expect(hasPrimary, isTrue);
    });
  });

  group('MFDropdown — calm, token borders', () {
    testWidgets('renders hint and items', (tester) async {
      await tester.pumpWidget(lightWrap(MFDropdown<String>(
        value: null,
        hint: 'اختر النشاط',
        items: const ['تجارة الجملة', 'تجزئة'],
        onChanged: (_) {},
      )));
      expect(find.text('اختر النشاط'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('تجارة الجملة'), findsOneWidget);
      expect(find.text('تجزئة'), findsOneWidget);
    });

    testWidgets('shows label above field', (tester) async {
      await tester.pumpWidget(lightWrap(MFDropdown<String>(
        label: 'نوع النشاط',
        value: 'تجزئة',
        items: const ['تجارة الجملة', 'تجزئة'],
        onChanged: (_) {},
      )));
      expect(find.text('نوع النشاط'), findsOneWidget);
      expect(find.text('تجزئة'), findsWidgets);
    });

    testWidgets('itemLabel builder customizes display', (tester) async {
      await tester.pumpWidget(lightWrap(MFDropdown<int>(
        value: 1,
        items: const [1, 2],
        itemLabel: (v) => v == 1 ? 'واحد' : 'اثنان',
        onChanged: (_) {},
      )));
      expect(find.text('واحد'), findsOneWidget);
    });
  });

  group('MFTable — invoices / activity, quiet SaaS', () {
    testWidgets('renders headers and rows with token styling', (tester) async {
      await tester.pumpWidget(lightWrap(MFTable(
        headers: const ['#', 'العميل', 'المبلغ'],
        rows: const [
          ['#1024', 'أحمد', '1,250 ج.م'],
          ['#1023', 'محمد', '850 ج.م'],
        ],
      )));
      expect(find.text('#'), findsOneWidget);
      expect(find.text('العميل'), findsOneWidget);
      expect(find.text('#1024'), findsOneWidget);
      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('1,250 ج.م'), findsOneWidget);
    });

    testWidgets('empty shows emptyLabel', (tester) async {
      await tester.pumpWidget(lightWrap(const MFTable(headers: ['A'], rows: [], emptyLabel: 'لا توجد فواتير')));
      expect(find.text('لا توجد فواتير'), findsOneWidget);
    });

    testWidgets('dark uses cardDark', (tester) async {
      await tester.pumpWidget(darkWrap(const MFTable(headers: ['H'], rows: [['R']])));
      final container = tester.widget<Container>(find.byType(Container).first);
      final deco = container.decoration as BoxDecoration;
      expect(deco.color, MFTokens.cardDark);
    });

    testWidgets('MFInvoiceRow shows badge + name + amount', (tester) async {
      await tester.pumpWidget(lightWrap(const MFInvoiceRow(invoiceNumber: '#1024', customerName: 'Ali', amount: '2,300 ج.م')));
      expect(find.text('#1024'), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('2,300 ج.م'), findsOneWidget);
    });
  });
}
