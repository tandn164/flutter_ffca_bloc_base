import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  test('responsive values use breakpoints instead of global scaling', () {
    expect(layoutSizeFor(400), LayoutSize.compact);
    expect(layoutSizeFor(700), LayoutSize.medium);
    expect(layoutSizeFor(1000), LayoutSize.expanded);
    expect(
      clampScale(value: 16, scale: 0.5, min: 14, max: 20),
      14,
    );
  });

  test('typed validation is independent from localized messages', () {
    final error = validateRules('', const [RequiredRule(), EmailRule()]);
    expect(error?.code, ValidationErrorCode.required);

    final validator = localizedValidator(
      rules: const [EmailRule()],
      messageFor: (error) => 'translated:${error.code.name}',
    );
    expect(validator('bad'), 'translated:invalidEmail');
  });
}
