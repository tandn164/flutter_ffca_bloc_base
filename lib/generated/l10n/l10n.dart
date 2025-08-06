import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @message429.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again!'**
  String get message429;

  /// No description provided for @messageE1.
  ///
  /// In en, this message translates to:
  /// **'User name is required.'**
  String get messageE1;

  /// No description provided for @messageE2.
  ///
  /// In en, this message translates to:
  /// **'Email Address is required.'**
  String get messageE2;

  /// No description provided for @messageE3.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get messageE3;

  /// No description provided for @messageE4.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required.'**
  String get messageE4;

  /// No description provided for @messageE5.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get messageE5;

  /// No description provided for @messageE6.
  ///
  /// In en, this message translates to:
  /// **'Password must have 8-20 characters including at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character.'**
  String get messageE6;

  /// No description provided for @messageE7.
  ///
  /// In en, this message translates to:
  /// **'Email has not been registered'**
  String get messageE7;

  /// No description provided for @messageE8.
  ///
  /// In en, this message translates to:
  /// **'Code is wrong/invalid'**
  String get messageE8;

  /// No description provided for @messageE9.
  ///
  /// In en, this message translates to:
  /// **'Email Address has been registered.'**
  String get messageE9;

  /// No description provided for @messageServerError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get messageServerError;

  /// No description provided for @cacheFailure.
  ///
  /// In en, this message translates to:
  /// **'Cache failure'**
  String get cacheFailure;

  /// No description provided for @noConnectionFailure.
  ///
  /// In en, this message translates to:
  /// **'No connection failure'**
  String get noConnectionFailure;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ja':
      return SJa();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
