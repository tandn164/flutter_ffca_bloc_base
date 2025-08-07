part of 'global_bloc.dart';

@immutable
class GlobalState extends Equatable {
  final AuthStatus authStatus;
  final int tabBarIndex;
  final bool isIos;
  final double iosVersion;
  final Locale? locale;

  const GlobalState._({
    this.authStatus = AuthStatus.initial,
    this.tabBarIndex = 0,
    this.isIos = true,
    this.iosVersion = 0.0,
    this.locale,
  });

  const GlobalState.initial() : this._();

  const GlobalState.update({
    required AuthStatus authStatus,
    required int tabBarIndex,
    required bool isIos,
    required double iosVersion,
    required Locale? locale,
  }) : this._(
          authStatus: authStatus,
          tabBarIndex: tabBarIndex,
          isIos: isIos,
          iosVersion: iosVersion,
          locale: locale,
        );

  GlobalState copyWith({
    AuthStatus? authStatus,
    int? tabBarIndex,
    bool? isIos,
    double? iosVersion,
    Locale? locale,
  }) {
    return GlobalState.update(
      authStatus: authStatus ?? this.authStatus,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
      isIos: isIos ?? this.isIos,
      iosVersion: iosVersion ?? this.iosVersion,
      locale: locale ?? this.locale,
    );
  }

  bool get isGuest => authStatus.isGuest;
  bool get isUser => authStatus.isUser;
  bool get appleSignInAvailable => isIos && iosVersion >= 13.0;

  @override
  List<Object?> get props =>
      [authStatus, tabBarIndex, isIos, iosVersion, locale];
}
