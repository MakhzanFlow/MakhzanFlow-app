import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/shared/widgets/version_conflict_dialog.dart';

void main() {
  testWidgets('T033: merge dialog shows both values and returns choice',
      (tester) async {
    MergeChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                choice = await showVersionConflictDialog(
                  context,
                  rows: const [
                    ConflictFieldRow(
                      label: 'price',
                      mine: '55.0',
                      server: '60.0',
                    ),
                  ],
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('55.0'), findsWidgets);
    expect(find.textContaining('60.0'), findsWidgets);

    await tester.tap(find.text('الاحتفاظ بقيمتي'));
    await tester.pumpAndSettle();
    expect(choice, MergeChoice.mine);
  });
}
