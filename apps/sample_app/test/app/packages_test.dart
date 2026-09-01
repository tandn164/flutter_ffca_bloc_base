import 'package:app_logging/app_logging.dart';
import 'package:app_session/app_session.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:chopper/chopper.dart';
import 'package:feed_data/feed_data.dart';
import 'package:feed_domain/feed_domain.dart';
import 'package:sample_app/app/di.dart';
import 'package:app_push/app_push.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_data/profile_data.dart';
import 'package:profile_domain/profile_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=\n');
  });

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await sl.reset();
  });

  test(
      'register wires AuthSession as Session and BufferedLogService as LogSink',
      () async {
    await register();
    expect(sl<Session>(), isA<AuthSession>());
    expect(sl<LogSink>(), isA<BufferedLogService>());
    expect(sl<LogReader>(), same(sl<LogSink>()));
    expect(sl<PushService>(), isA<StubPushService>());
    expect(sl.isRegistered<ChopperClient>(), isTrue);
    expect(sl.isRegistered<AuthApi>(), isTrue);
    expect(sl.isRegistered<AuthRepository>(), isTrue);
    expect(sl.isRegistered<FeedApi>(), isTrue);
    expect(sl.isRegistered<FeedRepository>(), isTrue);
    expect(sl.isRegistered<ProfileApi>(), isTrue);
    expect(sl.isRegistered<ProfileRepository>(), isTrue);
    sl<LogSink>().add(
      const LogEvent(kind: 't', message: 'hi', fields: {'token': 'secret'}),
    );
    expect(sl<LogReader>().recent, isNotEmpty);
    expect(sl<LogReader>().recent.last.fields['token'], '***');
  });
}
