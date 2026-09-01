import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Compile-time + `.env` values. Not a GetIt object — factories read this.
class AppEnv {
  const AppEnv._();

  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const guestAllowed = false;

  /// Empty / placeholder URLs keep the in-process fake API so `flutter run` works.
  static String get apiBaseUrl {
    final url = (dotenv.maybeGet('API_BASE_URL') ?? '').trim();
    if (url.isEmpty) return '';
    if (url.contains('example.com') || url.contains('your-api')) return '';
    return url;
  }
}
