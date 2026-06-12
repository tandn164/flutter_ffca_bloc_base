// ignore_for_file: avoid_print
//
// Reads composable_config.json, validates, syncs pubspec path deps, generates code.
//
// Usage: dart run tool/composable_sync.dart

import 'dart:convert';
import 'dart:io';

import 'config_validator.dart';

const _configPath = 'composable_config.json';
const _pubspecPath = 'pubspec.yaml';
const _generatedDir = 'lib/generated/composable_core';
const _modulesFile = '$_generatedDir/modules.g.dart';
const _registrarsFile = '$_generatedDir/di_registrars.g.dart';

const _packagesStart = '# COMPOSABLE_PACKAGES_START';
const _packagesEnd = '# COMPOSABLE_PACKAGES_END';

const _optionalPackages = <String, _PackageRef>{
  'offline': _PackageRef(
    pub: 'composable_offline',
    path: 'packages/composable_offline',
  ),
  'cache': _PackageRef(
    pub: 'composable_cache',
    path: 'packages/composable_cache',
  ),
  'auth': _PackageRef(pub: 'composable_auth', path: 'packages/composable_auth'),
  'log': _PackageRef(pub: 'composable_log', path: 'packages/composable_log'),
  'overlay': _PackageRef(
    pub: 'composable_overlay',
    path: 'packages/composable_overlay',
  ),
  'shell': _PackageRef(pub: 'composable_shell', path: 'packages/composable_shell'),
  'router': _PackageRef(
    pub: 'composable_router',
    path: 'packages/composable_router',
  ),
  'validation': _PackageRef(
    pub: 'composable_validation',
    path: 'packages/composable_validation',
  ),
  'push': _PackageRef(pub: 'composable_push', path: 'packages/composable_push'),
};

const _corePackage = _PackageRef(
  pub: 'composable_core',
  path: 'packages/composable_core',
);

void main() {
  final root = Directory.current;
  final configFile = File('${root.path}/$_configPath');

  if (!configFile.existsSync()) {
    stderr.writeln('Error: $_configPath not found');
    exit(1);
  }

  late final Map<String, dynamic> config;
  try {
    config = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  } on FormatException catch (e) {
    stderr.writeln('Error: invalid JSON in $_configPath: $e');
    exit(1);
  }

  try {
    validateComposableConfig(config);
    print('composable_sync: config validation OK');
  } on ConfigValidationException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }

  final packages = config['packages'] as Map<String, dynamic>? ?? {};
  final flags = _extractFlags(packages);

  final outDir = Directory('${root.path}/$_generatedDir');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  File('${root.path}/$_modulesFile')
      .writeAsStringSync(_generateModulesDart(flags));
  File('${root.path}/$_registrarsFile')
      .writeAsStringSync(_generateRegistrarsDart(flags));

  _syncPubspecDependencies(root.path, packages);

  print('composable_sync: wrote $_modulesFile');
  print('composable_sync: wrote $_registrarsFile');
  print('composable_sync: ${flags.length} package flags loaded');

  for (final entry in flags.entries) {
    final status = entry.value ? 'ON ' : 'OFF';
    print('  [$status] ${entry.key}');
  }
}

void _syncPubspecDependencies(String rootPath, Map<String, dynamic> packages) {
  final pubspecFile = File('$rootPath/$_pubspecPath');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Warning: $_pubspecPath not found — skip pubspec sync');
    return;
  }

  final lines = pubspecFile.readAsLinesSync();
  final start = lines.indexWhere((line) => line.trim() == _packagesStart);
  final end = lines.indexWhere((line) => line.trim() == _packagesEnd);

  if (start == -1 || end == -1 || end <= start) {
    stderr.writeln(
      'Warning: pubspec missing $_packagesStart/$_packagesEnd markers',
    );
    return;
  }

  final deps = <_PackageRef>[_corePackage];

  for (final entry in _optionalPackages.entries) {
    final enabled = _isTopLevelEnabled(packages, entry.key);
    final dir = Directory('$rootPath/${entry.value.path}');
    if (enabled && dir.existsSync()) {
      deps.add(entry.value);
    } else if (enabled && !dir.existsSync()) {
      print(
        '  [skip] ${entry.value.pub} enabled but ${entry.value.path} not found yet',
      );
    }
  }

  final block = <String>[
    _packagesStart,
    ...deps.map(
      (p) => '  ${p.pub}:\n    path: ${p.path}',
    ),
    _packagesEnd,
  ];

  final updated = [
    ...lines.sublist(0, start),
    ...block,
    ...lines.sublist(end + 1),
  ];

  pubspecFile.writeAsStringSync('${updated.join('\n')}\n');
  print('composable_sync: pubspec path dependencies synced (${deps.length})');
}

bool _isTopLevelEnabled(Map<String, dynamic> packages, String key) {
  final node = packages[key];
  if (node is Map && node['enabled'] is bool) {
    return node['enabled'] as bool;
  }
  return false;
}

Map<String, bool> _extractFlags(Map<String, dynamic> packages) {
  final flags = <String, bool>{};

  void walk(String prefix, Map<String, dynamic> node) {
    if (node.containsKey('enabled') && node['enabled'] is bool) {
      flags[prefix] = node['enabled'] as bool;
    }
    for (final entry in node.entries) {
      if (entry.key == 'enabled') continue;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final childPrefix = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        walk(childPrefix, value);
      }
    }
  }

  for (final entry in packages.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      walk(entry.key, value);
    }
  }

  return flags;
}

String _generateModulesDart(Map<String, bool> flags) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Generated by: dart run tool/composable_sync.dart')
    ..writeln()
    ..writeln('/// Feature flags from composable_config.json')
    ..writeln('abstract final class ComposableCoreModules {');

  final sortedKeys = flags.keys.toList()..sort();
  for (final key in sortedKeys) {
    final dartName = _toDartIdentifier(key);
    buffer.writeln('  static const bool $dartName = ${flags[key]};');
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _generateRegistrarsDart(Map<String, bool> flags) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Generated by: dart run tool/composable_sync.dart')
    ..writeln()
    ..writeln("import 'package:get_it/get_it.dart';")
    ..writeln("import 'package:composable_core/composable_core.dart';")
    ..writeln()
    ..writeln("import 'modules.g.dart';")
    ..writeln()
    ..writeln('/// Registers optional ComposableCore packages when enabled.')
    ..writeln('abstract final class ComposableCoreModuleRegistrars {')
    ..writeln('  static List<ComposableCoreModuleDescriptor> get descriptors => [');

  final sortedKeys = flags.keys.toList()..sort();
  for (final key in sortedKeys) {
    final dartName = _toDartIdentifier(key);
    final registerFn = '_register${_toPascalCase(key)}';
    buffer
      ..writeln('    ComposableCoreModuleDescriptor(')
      ..writeln("      id: '$key',")
      ..writeln('      enabled: ComposableCoreModules.$dartName,')
      ..writeln('      register: $registerFn,')
      ..writeln('    ),');
  }

  buffer
    ..writeln('  ];')
    ..writeln()
    ..writeln('  static Future<void> registerEnabled(GetIt sl) async {')
    ..writeln('    for (final descriptor in descriptors) {')
    ..writeln('      await descriptor.apply(sl);')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln();

  for (final key in sortedKeys) {
    final registerFn = '_register${_toPascalCase(key)}';
    buffer
      ..writeln('  static Future<void> $registerFn(GetIt sl) async {')
      ..writeln('    // TODO: register $key when package is extracted')
      ..writeln('  }')
      ..writeln();
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _toDartIdentifier(String key) {
  final parts = key.split('.');
  if (parts.length == 1) return parts.first;
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _toPascalCase(String key) {
  return key.split('.').map((p) {
    if (p.isEmpty) return '';
    return p[0].toUpperCase() + p.substring(1);
  }).join();
}

class _PackageRef {
  const _PackageRef({required this.pub, required this.path});
  final String pub;
  final String path;
}
