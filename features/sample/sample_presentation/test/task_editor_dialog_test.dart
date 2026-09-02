import 'package:sample_presentation/sample_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'closing the task editor does not use a disposed TextEditingController',
      (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showTaskEditorDialog(context, isNew: true);
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, 'Buy milk');
    expect(tester.takeException(), isNull);
  });
}
