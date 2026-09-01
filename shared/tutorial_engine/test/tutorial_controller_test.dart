import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_engine/tutorial_engine.dart';

void main() {
  test('completed tutorial is skipped unless force is true', () async {
    final controller = TutorialController();

    expect(controller.start('feed'), isTrue);
    await controller.complete();

    expect(controller.start('feed'), isFalse);
    expect(controller.start('feed', force: true), isTrue);
  });

  test('cancel does not persist completion', () {
    final controller = TutorialController();

    controller
      ..start('feed')
      ..cancel();

    expect(controller.start('feed'), isTrue);
  });
}
