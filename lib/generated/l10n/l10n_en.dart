// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get message429 => 'Too many requests. Please try again!';

  @override
  String get messageE1 => 'User name is required.';

  @override
  String get messageE2 => 'Email Address is required.';

  @override
  String get messageE3 => 'Password is required.';

  @override
  String get messageE4 => 'Verification code is required.';

  @override
  String get messageE5 => 'Phone number is required.';

  @override
  String get messageE6 =>
      'Password must have 8-20 characters including at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character.';

  @override
  String get messageE7 => 'Email has not been registered';

  @override
  String get messageE8 => 'Code is wrong/invalid';

  @override
  String get messageE9 => 'Email Address has been registered.';

  @override
  String get messageServerError => 'Server Error';

  @override
  String get cacheFailure => 'Cache failure';

  @override
  String get noConnectionFailure => 'No connection failure';

  @override
  String get unknownError => 'Unknown error';
}
