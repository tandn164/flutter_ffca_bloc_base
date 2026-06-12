// ignore_for_file: avoid_print

/// Validates composable_config.json structure (lightweight — no external schema lib).
library;

class ConfigValidationException implements Exception {
  ConfigValidationException(this.message);
  final String message;

  @override
  String toString() => 'ConfigValidationException: $message';
}

void validateComposableConfig(Map<String, dynamic> config) {
  if (!config.containsKey('app')) {
    throw ConfigValidationException('missing required key "app"');
  }
  if (!config.containsKey('packages')) {
    throw ConfigValidationException('missing required key "packages"');
  }

  final app = config['app'];
  if (app is! Map) {
    throw ConfigValidationException('"app" must be an object');
  }
  final name = app['name'];
  if (name is! String || name.isEmpty) {
    throw ConfigValidationException('"app.name" must be a non-empty string');
  }

  final flavor = app['flavor'];
  if (flavor != null &&
      flavor is String &&
      !{'development', 'staging', 'production'}.contains(flavor)) {
    throw ConfigValidationException(
      '"app.flavor" must be development | staging | production',
    );
  }

  final packages = config['packages'];
  if (packages is! Map) {
    throw ConfigValidationException('"packages" must be an object');
  }

  _validatePackageNodes(packages, 'packages');
}

void _validatePackageNodes(Map<dynamic, dynamic> nodes, String path) {
  for (final entry in nodes.entries) {
    final key = entry.key as String;
    final value = entry.value;

    if (key == 'enabled') {
      if (value is! bool) {
        throw ConfigValidationException('"$path.enabled" must be boolean');
      }
      continue;
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      if (map.containsKey('enabled') && map['enabled'] is! bool) {
        throw ConfigValidationException('"$path.$key.enabled" must be boolean');
      }
      _validatePackageNodes(map, '$path.$key');
      continue;
    }

    // Other primitives (defaultScope, domain, sheetId, …) are allowed.
  }
}
