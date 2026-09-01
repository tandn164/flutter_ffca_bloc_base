import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_presentation/onboarding_presentation.dart';

void main() {
  testWidgets('completes after the final step', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(
          steps: [
            OnboardingStep(
              title: 'Welcome',
              description: 'First step',
              illustration: (_) => const SizedBox(),
            ),
          ],
          onComplete: () async => completed = true,
        ),
      ),
    );

    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(completed, isTrue);
  });
}
