import 'dart:convert';

import 'package:meta/meta.dart';

/// Parsed `composable_config.json`.
@immutable
class ComposableCoreConfig {
  const ComposableCoreConfig({
    required this.app,
    required this.packages,
    this.devTools = const {},
    this.environment = const {},
  });

  factory ComposableCoreConfig.fromJson(Map<String, dynamic> json) {
    return ComposableCoreConfig(
      app: Map<String, dynamic>.from(json['app'] as Map? ?? {}),
      packages: Map<String, dynamic>.from(json['packages'] as Map? ?? {}),
      devTools: Map<String, dynamic>.from(json['devTools'] as Map? ?? {}),
      environment: Map<String, dynamic>.from(
        json['environment'] as Map? ?? {},
      ),
    );
  }

  factory ComposableCoreConfig.parse(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'composable_config.json root must be an object',
      );
    }
    return ComposableCoreConfig.fromJson(decoded);
  }

  final Map<String, dynamic> app;
  final Map<String, dynamic> packages;
  final Map<String, dynamic> devTools;
  final Map<String, dynamic> environment;

  String get appName => app['name'] as String? ?? 'ComposableCore App';
  String get flavor => app['flavor'] as String? ?? 'development';

  bool isPackageEnabled(String id) {
    final parts = id.split('.');
    dynamic node = packages;
    for (final part in parts) {
      if (node is! Map) return false;
      node = node[part];
      if (node == null) return false;
    }
    if (node is Map && node['enabled'] is bool) {
      return node['enabled'] as bool;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'app': app,
        'packages': packages,
        'devTools': devTools,
        'environment': environment,
      };
}
