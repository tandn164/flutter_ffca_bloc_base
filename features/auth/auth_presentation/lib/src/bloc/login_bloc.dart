import 'package:auth_domain/auth_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_notice.dart';

export 'auth_notice.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class LoginState extends Equatable {
  const LoginState({this.busy = false, this.notice});

  final bool busy;
  final AuthNotice? notice;

  @override
  List<Object?> get props => [busy, notice];
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginUseCase login,
    required Future<void> Function(TokenPair tokens) onAuthenticated,
  })  : _login = login,
        _onAuthenticated = onAuthenticated,
        super(const LoginState()) {
    on<LoginSubmitted>(_onSubmit);
  }

  final LoginUseCase _login;
  final Future<void> Function(TokenPair tokens) _onAuthenticated;
  int _noticeId = 0;

  Future<void> _onSubmit(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState(busy: true));
    try {
      final result = await _login.execute(
        email: event.email,
        password: event.password,
      );
      await result.fold<Future<void>>(
        ok: (tokens) async {
          await _onAuthenticated(tokens);
          emit(LoginState(
            notice: AuthNotice(
              message: 'Signed in',
              kind: AuthNoticeKind.success,
              id: ++_noticeId,
            ),
          ));
        },
        err: (f) async {
          emit(LoginState(
            notice: AuthNotice(
              message: f.message,
              kind: AuthNoticeKind.error,
              id: ++_noticeId,
            ),
          ));
        },
      );
    } catch (e) {
      emit(LoginState(
        notice: AuthNotice(
          message: e.toString(),
          kind: AuthNoticeKind.error,
          id: ++_noticeId,
        ),
      ));
    }
  }
}
