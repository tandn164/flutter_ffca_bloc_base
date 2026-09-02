import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory workspaceRoot() {
  var dir = Directory.current;
  while (true) {
    if (Directory('${dir.path}/features').existsSync() &&
        Directory('${dir.path}/shared').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
          'workspace root not found from ${Directory.current.path}');
    }
    dir = parent;
  }
}

String ws(String relative) => '${workspaceRoot().path}/$relative';

void main() {
  test('feature domain layers do not import Flutter, HTTP, or Overlay', () {
    final files = [
      ...Directory(ws('features/sample/sample_domain/lib'))
          .listSync(recursive: true),
      ...Directory(ws('features/auth/auth_domain/lib'))
          .listSync(recursive: true),
      ...Directory(ws('features/profile/profile_domain/lib'))
          .listSync(recursive: true),
      ...Directory(ws('features/onboarding/onboarding_domain/lib'))
          .listSync(recursive: true),
    ].whereType<File>().where((f) => f.path.endsWith('.dart'));

    const forbidden = [
      'package:flutter/',
      'package:chopper/',
      'package:dio/',
      'package:go_router/',
      'overlay_controller',
      'overlay_feedback',
      'package:get_it/',
      'composable_auth',
      'composable_log',
      'composable_push',
      'core_gateways',
    ];

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
  });

  test('sample_app must not host lib/features — features live under features/',
      () {
    expect(
      Directory('lib/features').existsSync(),
      isFalse,
      reason:
          'VGV FFCA: business features are packages under features/, not lib/features/',
    );
  });
}
