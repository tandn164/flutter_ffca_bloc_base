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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Flutter BLoC Base'**
  String get appName;

  /// No description provided for @appError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get appError;

  /// No description provided for @appInitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize app'**
  String get appInitError;

  /// No description provided for @appRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'Please restart the application'**
  String get appRestartMessage;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get authRegisterSubtitle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @userProfileActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get userProfileActions;

  /// No description provided for @userEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get userEditProfile;

  /// No description provided for @userUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get userUploadPhoto;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userEmail;

  /// No description provided for @userPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get userPhone;

  /// No description provided for @userStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get userStatus;

  /// No description provided for @userVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get userVerified;

  /// No description provided for @userUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get userUnverified;

  /// No description provided for @userMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get userMemberSince;

  /// No description provided for @userProfileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get userProfileCompletion;

  /// No description provided for @userNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get userNewLabel;

  /// No description provided for @userToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get userToday;

  /// No description provided for @userProfileComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get userProfileComplete;

  /// No description provided for @userProfileAlmostComplete.
  ///
  /// In en, this message translates to:
  /// **'Almost Complete'**
  String get userProfileAlmostComplete;

  /// No description provided for @userProfileInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get userProfileInProgress;

  /// No description provided for @userProfileGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get userProfileGettingStarted;

  /// No description provided for @userStatsFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get userStatsFollowers;

  /// No description provided for @userStatsFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get userStatsFollowing;

  /// No description provided for @userStatsPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get userStatsPosts;

  /// No description provided for @userSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get userSettings;

  /// No description provided for @userLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get userLogout;

  /// No description provided for @userDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get userDeleteAccount;

  /// No description provided for @userCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get userCancel;

  /// No description provided for @userDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get userDelete;

  /// No description provided for @userRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get userRetry;

  /// No description provided for @userClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get userClose;

  /// No description provided for @userFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get userFirstName;

  /// No description provided for @userLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get userLastName;

  /// No description provided for @userPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get userPhoneNumber;

  /// No description provided for @userBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get userBio;

  /// No description provided for @userProfileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get userProfileUpdatedSuccess;

  /// No description provided for @userAvatarUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded successfully'**
  String get userAvatarUploadedSuccess;

  /// No description provided for @validationFirstNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'First name cannot be empty'**
  String get validationFirstNameEmpty;

  /// No description provided for @validationLastNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Last name cannot be empty'**
  String get validationLastNameEmpty;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get validationPhoneInvalid;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @userID.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get userID;

  /// No description provided for @userUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userUsername;

  /// No description provided for @userDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get userDisplayName;

  /// No description provided for @userCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get userCreatedAt;

  /// No description provided for @userAccountAge.
  ///
  /// In en, this message translates to:
  /// **'Account Age'**
  String get userAccountAge;

  /// No description provided for @userActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get userActive;

  /// No description provided for @userInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get userInactive;

  /// No description provided for @userNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get userNotVerified;

  /// No description provided for @userNewUser.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get userNewUser;

  /// No description provided for @userDaysOld.
  ///
  /// In en, this message translates to:
  /// **'days old'**
  String get userDaysOld;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @doNotHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Do not have account? '**
  String get doNotHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;
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
