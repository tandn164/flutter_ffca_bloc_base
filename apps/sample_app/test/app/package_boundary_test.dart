import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Walks up from the test CWD until `features/` + `shared/` are siblings.
Directory workspaceRoot() {
  var dir = Directory.current;
  while (true) {
    final features = Directory('${dir.path}/features');
    final shared = Directory('${dir.path}/shared');
    if (features.existsSync() && shared.existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
          'workspace root not found from ${Directory.current.path}');
    }
    dir = parent;
  }
}

String ws(String relative) => '${workspaceRoot().path}/$relative';

void _assertNoAppOrGetIt(String root) {
  const forbidden = [
    'package:sample_app/',
    'package:get_it/',
    'lib/app/',
  ];
  final files = Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final needle in forbidden) {
      expect(
        source.contains(needle),
        isFalse,
        reason: '${file.path} must not reference $needle',
      );
    }
  }
}

void _assertPureDomain(String feature) {
  final pubspec = File(ws('features/$feature/${feature}_domain/pubspec.yaml'))
      .readAsStringSync();
  expect(pubspec.contains('sdk: flutter'), isFalse);
  expect(pubspec.contains('api_client'), isFalse);

  final files = Directory(ws('features/$feature/${feature}_domain/lib'))
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final source = file.readAsStringSync();
    expect(source.contains('package:flutter/'), isFalse, reason: file.path);
    expect(source.contains('package:api_client/'), isFalse, reason: file.path);
  }
}

void _assertPresentationNotData(String feature) {
  final pubspec =
      File(ws('features/$feature/${feature}_presentation/pubspec.yaml'))
          .readAsStringSync();
  expect(
    RegExp('^\\s+${feature}_data:', multiLine: true).hasMatch(pubspec),
    isFalse,
  );

  final files = Directory(ws('features/$feature/${feature}_presentation'))
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    expect(
      file.readAsStringSync().contains('package:${feature}_data/'),
      isFalse,
      reason: '${file.path} must not import ${feature}_data',
    );
  }
}

void main() {
  test('no lib/features directory under sample_app', () {
    expect(Directory('lib/features').existsSync(), isFalse);
  });

  test('no legacy composable packages directory at workspace root', () {
    expect(Directory(ws('packages')).existsSync(), isFalse);
  });

  test('multi-app layout: apps/sample_app exists', () {
    expect(Directory(ws('apps/sample_app')).existsSync(), isTrue);
    expect(File(ws('apps/sample_app/pubspec.yaml')).existsSync(), isTrue);
  });

  for (final feature in ['sample', 'auth', 'profile', 'onboarding']) {
    test('$feature packages do not import the app or GetIt', () {
      _assertNoAppOrGetIt(ws('features/$feature/${feature}_domain/lib'));
      _assertNoAppOrGetIt(ws('features/$feature/${feature}_data/lib'));
      _assertNoAppOrGetIt(ws('features/$feature/${feature}_presentation/lib'));
    });

    test('${feature}_presentation does not depend on ${feature}_data', () {
      _assertPresentationNotData(feature);
    });

    test('${feature}_domain is pure Dart', () {
      _assertPureDomain(feature);
    });
  }

  test('no lib/core directory under sample_app', () {
    expect(Directory('lib/core').existsSync(), isFalse);
  });

  test('removed checkout is not promoted to a feature package', () {
    expect(Directory(ws('features/checkout')).existsSync(), isFalse);
  });

  test('feature packages remain unaware of app composition adapters', () {
    for (final feature in ['auth', 'sample', 'profile', 'onboarding']) {
      final root = ws('features/$feature');
      for (final file in Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        expect(source.contains('FeatureModule'), isFalse, reason: file.path);
        expect(source.contains('package:go_router/'), isFalse,
            reason: file.path);
      }
    }
  });

  test('shared/push does not import GoRouter or app routes', () {
    final dir = Directory(ws('shared/push/lib'));
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      expect(source.contains('go_router'), isFalse, reason: file.path);
      expect(source.contains('/checkout'), isFalse, reason: file.path);
    }
  });

  test('shared packages do not import the app or feature packages', () {
    const forbidden = [
      'package:sample_app/',
      'package:sample_domain/',
      'package:sample_data/',
      'package:sample_presentation/',
      'package:auth_',
      'package:profile_',
      'package:onboarding_',
      'package:get_it/',
    ];
    for (final shared in [
      'app_result',
      'connectivity',
      'api_client',
      'app_overlay',
      'local_storage/core',
      'local_storage/stores/shared_preferences',
      'offline_sync',
      'ui_kit',
      'session',
      'interceptor',
      'navigation',
      'logging',
      'push',
      'tutorial_engine',
    ]) {
      final dir = Directory(ws('shared/$shared/lib'));
      if (!dir.existsSync()) continue;
      for (final file in dir.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final source = file.readAsStringSync();
        for (final needle in forbidden) {
          expect(
            source.contains(needle),
            isFalse,
            reason: '${file.path} must not reference $needle',
          );
        }
      }
    }
  });

  test('every reusable workspace package has an English README', () {
    for (final group in ['features', 'shared']) {
      final packageSpecs = Directory(ws(group))
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('/pubspec.yaml'));
      for (final pubspec in packageSpecs) {
        final readme = File('${pubspec.parent.path}/README.md');
        expect(
          readme.existsSync(),
          isTrue,
          reason: '${pubspec.parent.path} must document its public usage',
        );
        expect(
          readme.readAsStringSync().trim().length,
          greaterThan(80),
          reason: '${readme.path} must contain useful usage documentation',
        );
      }
    }
  });
}
