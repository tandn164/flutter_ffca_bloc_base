part of 'global_bloc.dart';

@immutable
class GlobalState extends Equatable {
  final AuthStatus authStatus;
  final int tabBarIndex;
  final bool isIos;
  final double iosVersion;
  final Locale? locale;
  final bool isMute;

  const GlobalState._({
    this.authStatus = AuthStatus.initial,
    this.tabBarIndex = 0,
    this.isIos = true,
    this.iosVersion = 0.0,
    this.locale,
    this.isMute = true,
  });

  const GlobalState.initial() : this._();

  const GlobalState.update({
    required AuthStatus authStatus,
    required int tabBarIndex,
    required bool isIos,
    required double iosVersion,
    required Locale? locale,
    required bool isMute,
  }) : this._(
          authStatus: authStatus,
          tabBarIndex: tabBarIndex,
          isIos: isIos,
          iosVersion: iosVersion,
          locale: locale,
          isMute: isMute,
        );

  GlobalState copyWith({
    AuthStatus? authStatus,
    int? tabBarIndex,
    bool? isIos,
    double? iosVersion,
    Locale? locale,
    bool? isMute,
  }) {
    return GlobalState.update(
      authStatus: authStatus ?? this.authStatus,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
      isIos: isIos ?? this.isIos,
      iosVersion: iosVersion ?? this.iosVersion,
      locale: locale ?? this.locale,
      isMute: isMute ?? this.isMute,
    );
  }

  bool get isGuest => authStatus.isGuest;
  bool get isUser => authStatus.isUser;
  bool get appleSignInAvailable => isIos && iosVersion >= 13.0;

  @override
  List<Object?> get props =>
      [authStatus, tabBarIndex, isIos, iosVersion, locale, isMute];
}
