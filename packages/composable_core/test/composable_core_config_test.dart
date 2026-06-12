import 'package:composable_core/composable_core.dart';
import 'package:test/test.dart';

void main() {
  group('ComposableCoreConfig', () {
    test('parses app and package flags', () {
      const raw = '''
{
  "app": { "name": "Test", "flavor": "development" },
  "packages": {
    "offline": { "enabled": true },
    "overlay": {
      "toast": { "enabled": false }
    }
  }
}
''';

      final config = ComposableCoreConfig.parse(raw);
      expect(config.appName, 'Test');
      expect(config.isPackageEnabled('offline'), isTrue);
      expect(config.isPackageEnabled('overlay.toast'), isFalse);
    });
  });
}
