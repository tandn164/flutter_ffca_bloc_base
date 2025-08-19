part of 'global_bloc.dart';

@immutable
class GlobalState extends Equatable {
  final int tabBarIndex;
  final bool isIos;
  final double iosVersion;
  final Locale? locale;
  final bool splashDisplayed;

  const GlobalState._({
    this.tabBarIndex = 0,
    this.isIos = true,
    this.iosVersion = 0.0,
    this.locale,
    this.splashDisplayed = false,
  });

  const GlobalState.initial() : this._();

  const GlobalState.update({
    required int tabBarIndex,
    required bool isIos,
    required double iosVersion,
    required Locale? locale,
    required bool splashDisplayed,
  }) : this._(
    tabBarIndex: tabBarIndex,
    isIos: isIos,
    iosVersion: iosVersion,
    locale: locale,
    splashDisplayed: splashDisplayed,
  );

  GlobalState copyWith({
    int? tabBarIndex,
    bool? isIos,
    double? iosVersion,
    Locale? locale,
    bool? splashDisplayed
  }) {
    return GlobalState.update(
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
      isIos: isIos ?? this.isIos,
      iosVersion: iosVersion ?? this.iosVersion,
      locale: locale ?? this.locale,
      splashDisplayed: splashDisplayed ?? this.splashDisplayed,
    );
  }

  bool get appleSignInAvailable => isIos && iosVersion >= 13.0;

  @override
  List<Object?> get props =>
      [tabBarIndex, isIos, iosVersion, locale, splashDisplayed];
}
