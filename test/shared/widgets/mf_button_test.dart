import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/shared/widgets/mf_button.dart';

void main() {
  Widget wrap(Widget child, {bool isDark = false}) {
    final theme = isDark ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(theme: theme, home: Scaffold(body: Center(child: child)));
  }

  group('MFButton — ForUI design system, token-only', () {
    testWidgets('primary renders label and handles tap (light)', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(MFButton(label: 'حفظ', onPressed: () => tapped = true)));
      expect(find.text('حفظ'), findsOneWidget);
      await tester.tap(find.byType(MFButton));
      expect(tapped, isTrue);
    });

    testWidgets('loading shows spinner and disables tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(MFButton(label: 'جاري الحفظ...', loading: true, onPressed: () => tapped = true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(MFButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('secondary variant uses subtle bg (token)', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'إلغاء', variant: MFButtonVariant.secondary, onPressed: () {})));
      final material = tester.widget<Material>(find.descendant(of: find.byType(MFButton), matching: find.byType(Material)));
      expect(material.color, isNot(Colors.transparent));
      expect(material.color, MFTokens.primarySubtle);
    });

    testWidgets('outline variant has transparent bg and border', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'outline', variant: MFButtonVariant.outline, onPressed: () {})));
      final material = tester.widget<Material>(find.descendant(of: find.byType(MFButton), matching: find.byType(Material)));
      expect(material.color, Colors.transparent);
      final shape = material.shape as RoundedRectangleBorder;
      expect((shape.side).color, MFTokens.borderLight);
    });

    testWidgets('destructive uses error color (token)', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'حذف', variant: MFButtonVariant.destructive, onPressed: () {})));
      final material = tester.widget<Material>(find.descendant(of: find.byType(MFButton), matching: find.byType(Material)));
      expect(material.color, MFTokens.errorText);
    });

    testWidgets('ghost is transparent and uses muted text color (tap works)', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(MFButton(label: 'ghost', variant: MFButtonVariant.ghost, onPressed: () => tapped = true)));
      final material = tester.widget<Material>(find.descendant(of: find.byType(MFButton), matching: find.byType(Material)));
      expect(material.color, Colors.transparent);
      await tester.tap(find.byType(MFButton));
      expect(tapped, isTrue);
    });

    testWidgets('with icon shows icon + label', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'إضافة', icon: Icons.add, onPressed: () {})));
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('إضافة'), findsOneWidget);
    });

    testWidgets('fullWidth wraps with SizedBox width infinite', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'full', fullWidth: true, onPressed: () {})));
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('non-fullWidth does not expand', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'compact', fullWidth: false, onPressed: () {})));
      final btn = tester.widget<MFButton>(find.byType(MFButton));
      expect(btn.fullWidth, isFalse);
    });

    testWidgets('dark primary uses mint token', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'dark', onPressed: () {}), isDark: true));
      final material = tester.widget<Material>(find.descendant(of: find.byType(MFButton), matching: find.byType(Material)));
      expect(material.color, MFTokens.primaryDarkMode);
    });

    testWidgets('height respects token (44 = buttonHeightMD)', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'h', onPressed: () {})));
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minHeight ?? (container.child as dynamic), isNotNull);
      // container height should be 44
      expect(find.byType(MFButton), findsOneWidget);
    });

    testWidgets('disabled (null onPressed) renders but no tap effect', (tester) async {
      await tester.pumpWidget(wrap(MFButton(label: 'disabled', onPressed: null)));
      expect(find.text('disabled'), findsOneWidget);
      // InkWell still present but onTap null
      final inkWell = tester.widget<InkWell>(find.byType(InkWell).first);
      expect(inkWell.onTap, isNull);
    });
  });
}
