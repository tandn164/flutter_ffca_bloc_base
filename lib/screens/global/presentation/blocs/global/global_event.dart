part of 'global_bloc.dart';

@immutable
abstract class GlobalEvent extends Equatable {
  const GlobalEvent([List props = const <dynamic>[]]) : super();
}

class CheckAuthenticateEvent extends GlobalEvent {
  @override
  List<Object?> get props => [];
}

class LogoutEvent extends GlobalEvent {
  @override
  List<Object?> get props => [];
}

class ChangeTabEvent extends GlobalEvent {
  final int index;

  const ChangeTabEvent({required this.index});

  @override
  List<Object?> get props => [];
}

class GetDeviceInfoEvent extends GlobalEvent {
  @override
  List<Object?> get props => [];
}

class InitialLocaleEvent extends GlobalEvent {
  @override
  List<Object?> get props => [];
}

class ChangeLocaleEvent extends GlobalEvent {
  @override
  List<Object?> get props => [];
}

class UnMuteVideoEvent extends GlobalEvent {
  const UnMuteVideoEvent();

  @override
  List<Object?> get props => [];
}