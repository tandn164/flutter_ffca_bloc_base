import 'package:flutter/services.dart';
import 'package:composable_core/composable_core.dart';

abstract final class ComposableCoreRuntimeConfig {
  static const assetPath = 'composable_config.json';

  static ComposableCoreConfig? _cached;

  static Future<ComposableCoreConfig> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString(assetPath);
    _cached = ComposableCoreConfig.parse(raw);
    return _cached!;
  }
}
