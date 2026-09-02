import 'package:app_connectivity/app_connectivity.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/app/di.dart';
import 'package:sample_data/sample_data.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async => sl.reset());

  test('register wires reusable capabilities and the local sample feature',
      () async {
    await register();

    expect(sl<ConnectivityHint>(), same(sl<MutableConnectivityHint>()));
    expect(sl<LogSink>(), isA<BufferedLogService>());
    expect(sl<LogReader>(), same(sl<LogSink>()));
    expect(sl<SampleRepository>(), isA<LocalSampleRepository>());

    sl<LogSink>().add(
      const LogEvent(kind: 'test', message: 'action', fields: {'token': 'x'}),
    );
    expect(sl<LogReader>().recent.single.fields['token'], '***');
  });
}
